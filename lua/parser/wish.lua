--[=[
Aardwolf `wish list` command parser

Usage:

    local wish_lib = require "parser/wish"

    function wish_callback(wishes)
        -- Do stuff with the data here
        -- wishes is an array of Wish objects (see @class Wish)
    end

    wish_lib.wish(wish_callback)             -- Command: wish list
]=]
local library = {}

local Trigger = require "trigger"

local TRIGGER_GROUP = "parse_wish"
local TRIGGER_GROUP_WISHDATA = "parse_wish_data"

---@class Wish
---@field keyword string # The wish's keyword (e.g. scholar)
---@field description string # The textual description of the wish (e.g. Practice to 95% instead of 85%)
---@field has_wish boolean # True if the player has been granted that wish
---@field base_cost number # base cost of the wish
---@field adjustment number # adjustment cost of the wish
---@field cost number? # Cost for the player to buy the wish, or nil for wishes they already own

---@alias wish_callback fun(wishes:Wish[], adjustment:number, qp:number)

---The trigger that matches {parse_wish_<id>}
---@type Trigger
local starttag = nil

---The list of Wish data
---@type Wish[]
local current_wish_list = {}
local current_adjustment = 0
local current_qp = 0

---The ID of the tag currently being processed
---@type number
local current_tag_id = 0

---Stores the callback function for an associated tag id
---@type table<number, wish_callback>
local callback_map = {}

---Keep track of how many `wish` requests we have out to the server
---@type number
local request_count = 0

---Convert a value to a number and ensure it is not nil
---@param val any
---@return number
local function parsenumber(val)
    local ret = tonumber(val)
    assert(ret ~= nil, "Value is not a number")
    return ret
end

--- Function that is called when we receive a {parse_wish_<id>} tag
local function on_starttag(name, line, wildcards)
    -- Enable data and end tag triggers
    EnableTriggerGroup(TRIGGER_GROUP, true)

    -- Decrement request_count and disable starttag if we have no more outstanding requests
    request_count = request_count - 1
    if (request_count == 0) then
        starttag.disable()
    end

    -- Parse out the id we're receiving and set data to default values
    current_tag_id = parsenumber(wildcards.id)
    current_wish_list = {}
    current_adjustment = 0
    current_qp = 0
end

--- Function that is called when we receive a {/parse_wish} tag
local function on_endtag(name, line, wildcards)
    EnableTriggerGroup(TRIGGER_GROUP, false)

    -- Trigger associated callback
    local callback = callback_map[current_tag_id]
    if callback ~= nil then
        callback(current_wish_list, current_adjustment, current_qp)
    end

    -- Remove callback from cache
    callback_map[current_tag_id] = nil
end

--- Parse a wish
local function on_wish_line(name, line, wildcards)
    ---@type Wish
    local wish = {}

    wish.keyword = Trim(wildcards.keyword)
    wish.description = Trim(wildcards.desc)
    wish.adjustment = parsenumber(wildcards.adjustment)
    wish.base_cost = parsenumber(wildcards.basecost)
    wish.cost = tonumber(wildcards.cost)
    wish.has_wish = (wildcards.haswish == "*")

    table.insert(current_wish_list, wish)
end

local function on_wish_adjustment(name, line, wildcards)
    current_adjustment = parsenumber(wildcards.adjustment)
end

local function on_wish_qp(name, line, wildcards)
    current_qp = parsenumber(wildcards.qp)
end

local function create_triggers()
    starttag = Trigger.new("parse_wish_starttag", Trigger.NoGroup, [[^\{parse_wish_(?<id>\d+)\}$]], Trigger.ParseAndOmit, on_starttag)
    Trigger.new("parse_wish_endtag", TRIGGER_GROUP, [[^\{/parse_wish\}$]], Trigger.ParseAndOmit, on_endtag)
    Trigger.new("parse_wish_header1", TRIGGER_GROUP, [[^                                    Base Cost Adjustment Your Cost  Keyword$]], Trigger.ParseAndOmit, function() EnableTriggerGroup(TRIGGER_GROUP_WISHDATA, true) end)
    Trigger.new("parse_wish_header2", TRIGGER_GROUP_WISHDATA, [[^ ---------------------------------- --------- ---------- --------- -----------$]], Trigger.ParseAndOmit, Trigger.NullCallback)
    Trigger.new("parse_wish_line", TRIGGER_GROUP_WISHDATA, [[^(?<haswish>.)(?<desc>.{34})\s+(?<basecost>\d+)\s+(?<adjustment>\d+)\s+(?<cost>[\d-]+)\s+(?<keyword>.+)$]], Trigger.ParseAndOmit, on_wish_line)
    Trigger.new("parse_wish_footer1", TRIGGER_GROUP_WISHDATA, [[^Your total adjustment cost is: (?<adjustment>\d+)]], Trigger.ParseAndOmit, on_wish_adjustment)
    Trigger.new("parse_wish_footer2", TRIGGER_GROUP_WISHDATA, [[^Your quest points on hand are: (?<qp>\d+)]], Trigger.ParseAndOmit, on_wish_qp)
    Trigger.new("parse_wish_footer3", TRIGGER_GROUP_WISHDATA, [[^Refer to 'help wish' for a description of each wish\.$]], Trigger.ParseAndOmit, function() EnableTriggerGroup(TRIGGER_GROUP_WISHDATA, false) end)
end

create_triggers()

local function do_call(cmd, callback)
    assert((callback ~= nil) and type(callback) == "function", "Provided callback must be a lua function and cannot be nil")

    --- newly generated ID unique to this request
    local new_id = GetUniqueNumber()

    -- Store callback/search terms for later
    callback_map[new_id] = callback

    -- Send commands to server
    SendNoEcho(string.format("echo {parse_wish_%d}", new_id))
    SendNoEcho(cmd)
    SendNoEcho("echo {/parse_wish}")

    -- Increment our request count and enable the starttag trigger if necessary
    if (request_count == 0) then
        starttag.enable()
    end
    request_count = request_count + 1
end

---Perform a `wish list`, parse the results, and return them to us via the provided callback function
---@param callback wish_callback # The callback to use
function library.wish(callback)
    do_call("wish list", callback)
end

return library