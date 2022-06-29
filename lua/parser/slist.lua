--[=[
Aardwolf `slist` command parser

Usage:

    local slist_lib = require "parser/slist"

    function slist_callback(spells, recoveries)
        -- Do stuff with the data here
    end

    slist_lib.slist(slist_callback)             -- Command: slist
    slist_lib.slist_learned(slist_callback)     -- Command: slist learned
    slist_lib.slist_affected(slist_callback)    -- Command: slist affected
    slist_lib.slist_recoveries(slist_callback)  -- Command: slist recoveries
]=]
local library = {}

local Trigger = require "trigger"

local TRIGGER_GROUP = "parse_slist"
local TRIGGER_GROUP_SPELL = "parse_slist_spells"
local TRIGGER_GROUP_RECOVERY = "parse_slist_recoveries"

---@class SlistSpell
---@field id number # The spell number
---@field name string # The spell name
---@field target number # See 'help slist', 0 = special, 1 = attack, 2 = spellup, 3 = self only, 4 = object, 5 = other
---@field duration number # Remaining duration in seconds, or zero if you are not affected by this spell
---@field percentage number # The current learned percentage
---@field recovery? number # The id of the associated recovery, if any
---@field type number # 1 = spell, 2 = skill

---@class SlistRecovery
---@field id number # The recovery id
---@field name string # The recovery's name
---@field duration number # The time remaining, in seconds

---@alias slist_callback fun(spells:table<number,SlistSpell>, recoveries:table<number,SlistRecovery>)

---The trigger that matches {parse_slist_<id>}
---@type Trigger
local starttag = nil

---The list of SlistSpell data
---@type table<number,SlistSpell>
local current_spell_list = {}

---The list of SlistRecovery data
---@type table<number,SlistRecovery>
local current_recovery_list = {}

---The ID of the tag currently being processed
---@type number
local current_tag_id = 0

---Stores the callback function for an associated tag id
---@type table<number, slist_callback>
local callback_map = {}

---Keep track of how many `slist` requests we have out to the server
---@type number
local request_count = 0

--- Function that is called when we receive a {parse_slist_<id>} tag
local function on_starttag(name, line, wildcards)
    -- Enable data and end tag triggers
    EnableTriggerGroup(TRIGGER_GROUP, true)

    -- Decrement request_count and disable starttag if we have no more outstanding requests
    request_count = request_count - 1
    if (request_count == 0) then
        starttag.disable()
    end

    -- Parse out the id we're receiving and set data to default values
    current_tag_id = tonumber(wildcards.id)
    current_spell_list = {}
    current_recovery_list = {}
end

--- Function that is called when we receive a {/parse_slist} tag
local function on_endtag(name, line, wildcards)
    EnableTriggerGroup(TRIGGER_GROUP, false)

    -- Trigger associated callback
    local callback = callback_map[current_tag_id]
    if callback ~= nil then
        callback(current_spell_list, current_recovery_list)
    end

    -- Remove callback from cache
    callback_map[current_tag_id] = nil
end

--- Parse a spell
local function on_spell_line(name, line, wildcards)
    ---@type SlistSpell
    local spell = {}

    spell.id = tonumber(wildcards.sn)
    spell.name = wildcards.name
    spell.target = tonumber(wildcards.target)
    spell.duration = tonumber(wildcards.duration)
    spell.percentage = tonumber(wildcards.pct)
    spell.recovery = tonumber(wildcards.duration)
    if spell.recovery < 0 then spell.recovery = nil end
    spell.type = tonumber(wildcards.type)

    current_spell_list[spell.id] = spell
end

--- Parse a recovery
local function on_recovery_line(name, line, wildcards)
    ---@type SlistRecovery
    local recovery = {}

    recovery.id = tonumber(wildcards.id)
    recovery.name = wildcards.name
    recovery.duration = tonumber(wildcards.duration)

    current_recovery_list[recovery.id] = recovery
end

local function create_triggers()
    starttag = Trigger.new("parse_slist_starttag", Trigger.NoGroup, [[^\{parse_slist_(?<id>\d+)\}$]], Trigger.ParseAndOmit, on_starttag)
    Trigger.new("parse_slist_endtag", TRIGGER_GROUP, [[^\{/parse_slist\}$]], Trigger.ParseAndOmit, on_endtag)
    Trigger.new("parse_spellheaders_tag", TRIGGER_GROUP, [[^\{spellheaders\s*(?:(?:learned)|(?:affected))?\}$]], Trigger.ParseAndOmit, function() EnableTriggerGroup(TRIGGER_GROUP_SPELL, true) end)
    Trigger.new("parse_spellheaders_line", TRIGGER_GROUP_SPELL, [[^(?<sn>\d+),(?<name>[^,]+),(?<target>\d+),(?<duration>\d+),(?<pct>\d+),(?<recovery>-?\d+),(?<type>\d+)$]], Trigger.ParseAndOmit, on_spell_line)
    Trigger.new("parse_spellheaders_end_tag", TRIGGER_GROUP_SPELL, [[^\{/spellheaders\}$]], Trigger.ParseAndOmit, function() EnableTriggerGroup(TRIGGER_GROUP_SPELL, false) end)
    Trigger.new("parse_recoveries_tag", TRIGGER_GROUP, [[^\{recoveries\s*(?:(?:affected)|(?:recoveries))?\}$]], Trigger.ParseAndOmit, function() EnableTriggerGroup(TRIGGER_GROUP_RECOVERY, true) end)
    Trigger.new("parse_recoveries_line", TRIGGER_GROUP_RECOVERY, [[^(?<id>\d+),(?<name>[^,]+),(?<duration>\d+)$]], Trigger.ParseAndOmit, on_recovery_line)
    Trigger.new("parse_recoveries_end_tag", TRIGGER_GROUP_RECOVERY, [[^\{/recoveries\}$]], Trigger.ParseAndOmit, function() EnableTriggerGroup(TRIGGER_GROUP_RECOVERY, false) end)
end

create_triggers()

local function do_call(cmd, callback)
    assert((callback ~= nil) and type(callback) == "function", "Provided callback must be a lua function and cannot be nil")

    --- newly generated ID unique to this request
    local new_id = GetUniqueNumber()

    -- Store callback/search terms for later
    callback_map[new_id] = callback

    -- Send commands to server
    SendNoEcho(string.format("echo {parse_slist_%d}", new_id))
    SendNoEcho(cmd)
    SendNoEcho("echo {/parse_slist}")

    -- Increment our request count and enable the starttag trigger if necessary
    if (request_count == 0) then
        starttag.enable()
    end
    request_count = request_count + 1
end

---Perform an `slist`, parse the results, and return them to us via the provided callback function
---@param callback slist_callback # The callback to use
function library.slist(callback)
    do_call("slist", callback)
end

---Perform an `slist learned`, parse the results, and return them to us via the provided callback function
---@param callback slist_callback # The callback to use
function library.slist_learned(callback)
    do_call("slist learned", callback)
end

---Perform an `slist affected`, parse the results, and return them to us via the provided callback function
---@param callback slist_callback # The callback to use
function library.slist_affected(callback)
    do_call("slist affected", callback)
end

---Perform an `slist recoveries`, parse the results, and return them to us via the provided callback function
---@param callback slist_callback # The callback to use
function library.slist_recoveries(callback)
    do_call("slist recoveries", callback)
end

return library