local Alias = require "alias"
local Trigger = require "trigger"
local SpellData = require "spelldata"

require "aardprint"
require "serialize"

---Hold data about a given stat
---@class Stat
---@field min number # The minimum value desired for this stat
---@field max number # The maximum value desired for this stat
---@field buy number # How many of this stat we plan to buy
---@field costmod number # The combined racemod + tiermod + wishmod for this stat
---@field trained number # How much this stat has been trained already
---@field tiermod number # The tierstat modifier for this stat
---@field wishmod number # The wishstat modifier for this stat

---Holds data for a training profile
---@class Profile
---@field name string # Name of the profile
---@field convertall_enabled boolean # Whether or not to enabled autoconversion of practices
---@field stat_min table<string, number> # Minimum values a stat should be trained to, regardless of cost
---@field stat_max table<string, number> # Maximum values a stat should be trained to, regardless of cost
---@field stat_weight table<string, number> # Stat weights set by the user
---@field spells_to_practice table<number,string> # Spells we want to practice

---A collection of profiles stored for use
---@type table<string, Profile>
local profiles = {}

---The name of the profile we are currently using
---@type string
local current_profile = ""

---Should practices be converted before training
---@type boolean
local convertall_enabled = false

---Minimum values a stat should be trained to, regardless of cost
---@type table<string, number>
local stat_min = {}

---Maximum values a stat should be trained to, regardless of cost
---@type table<string, number>
local stat_max = {}

---Stat weights set by the user
---@type table<string, number>
local stat_weight = {}

---Stat names, sorted by weights in descending order
---@type string[]
local stat_sorted = {}

---Lookup table for training costs before cost reductions
---@type table<number,number>
local TRAINING_COSTS = {}

---Map stat long names to short names
---@type table<string,string>
local STAT_MAP = {}
STAT_MAP["Strength"] = "str"
STAT_MAP["Intelligence"] = "int"
STAT_MAP["Wisdom"] = "wis"
STAT_MAP["Dexterity"] = "dex"
STAT_MAP["Constitution"] = "con"
STAT_MAP["Luck"] = "luck"

---Spells we want to practice
---@type table<number,string>
local spells_to_practice = {}

---Calculate stat_sorted based on values in stat_weight
local function calculate_stat_sorted()
    -- Make a copy of our stat weights
    local weight_copy = {}
    for k,v in pairs(stat_weight) do weight_copy[k] = v end

    local result = {}
    local cnt = 0
    while cnt < 6 do
        local max_value = -9999.0
        local max_stat = ""

        for k,v in pairs(weight_copy) do
            if v > max_value then
                max_value = v
                max_stat = k
            end
        end

        weight_copy[max_stat] = nil
        table.insert(result, max_stat)
        cnt = cnt + 1
    end

    stat_sorted = result
end

--- Reload the plugin
local function do_reload()
	local scriptPrefix = GetAlphaOption("script_prefix")
	local retval

	-- If the user has not already specified the script prefix for this version of mush, pick a
	-- reasonable default value
	if (scriptPrefix == "") then
		scriptPrefix = "\\\\\\"
		SetAlphaOption("script_prefix", scriptPrefix)
	end

	-- Tell mush to reload the plugin in one second.  We can't do it directly here because a
	-- plugin can't unload itself.  Even if it could, how could it tell mush to load it again
	-- if it weren't installed?
	retval = Execute(scriptPrefix.."DoAfterSpecial(1, \"ReloadPlugin('"..GetPluginID().."')\", sendto.script)")

	if (retval ~= 0) then
		Note("Failed to reload the plugin: mush error " .. retval)
	end -- if
end

--- Print help info
local function do_help()
    AardPrint("@C--------------------------------------------------------------------------------")
    AardPrint("@Y                              Auto Trainer Help")
	AardPrint("@C--------------------------------------------------------------------------------")
    AardPrint("@Y   autotrain")
    AardPrint("@W       Spends your trains based on the settings you have chosen.")
    print()
    AardPrint("@Y   autotrain min <str> <int> <wis> <dex> <con> <luck>")
    AardPrint("@W       The minimum values a stat should be trained to, regardless of cost")
    print()
    AardPrint("@Y   autotrain max <str> <int> <wis> <dex> <con> <luck>")
    AardPrint("@W       The maximum values a stat should be trained to, regardless of cost")
    print()
    AardPrint("@Y   autotrain weight <str> <int> <wis> <dex> <con> <luck>")
    AardPrint("@W       How heavily to weight a stat's value (higher = more important)")
    AardPrint("@W       e.g. autotrain weight 4.0 1.0 2.0 5.0 2.0 3.0")
    print()
	AardPrint("@Y   autotrain show")
    AardPrint("@W       Shows the currently defined stat values.")
    AardPrint("@Y   autotrain convert on|off")
    AardPrint("@W       Enables automatic conversion of practices to trains.")
    AardPrint("@Y   autotrain reload")
    AardPrint("@W       Reloads the plugin.")
	AardPrint("@C--------------------------------------------------------------------------------")
end

--- Display the currently defined stat data
local function show_data()
    print("")
    AardPrint("@wYour current autotrain settings:")
    print("")
    AardPrint("@g               Min    Max    Weight")
    AardPrint("@c              ------ ------ -------")
    AardPrint("@w%12s :@W%6d %6d %7.2f", "Strength", stat_min.str, stat_max.str, stat_weight.str)
    AardPrint("@w%12s :@W%6d %6d %7.2f", "Intelligence", stat_min.int, stat_max.int, stat_weight.int)
    AardPrint("@w%12s :@W%6d %6d %7.2f", "Wisdom", stat_min.wis, stat_max.wis, stat_weight.wis)
    AardPrint("@w%12s :@W%6d %6d %7.2f", "Dexterity", stat_min.dex, stat_max.dex, stat_weight.dex)
    AardPrint("@w%12s :@W%6d %6d %7.2f", "Constitution", stat_min.con, stat_max.con, stat_weight.con)
    AardPrint("@w%12s :@W%6d %6d %7.2f", "Luck", stat_min.luck, stat_max.luck, stat_weight.luck)
    print("")
    if (convertall_enabled) then
        AardPrint("@wAuto convert practices: @WEnabled")
    else
        AardPrint("@wAuto convert practices: @WDisabled")
    end
    print("")

    -- print("Stat prio: " .. stat_sorted[1] .. ", " .. stat_sorted[2] .. ", " .. stat_sorted[3] .. ", " .. stat_sorted[4] .. ", " .. stat_sorted[5] .. ", " .. stat_sorted[6])
end

--- Set minimum stat values
local function set_minimums(name, line, wildcards)
    stat_min.str = tonumber(wildcards.str)
    stat_min.int = tonumber(wildcards.int)
    stat_min.wis = tonumber(wildcards.wis)
    stat_min.dex = tonumber(wildcards.dex)
    stat_min.con = tonumber(wildcards.con)
    stat_min.luck = tonumber(wildcards.luck)

    show_data()
    SaveState()
end

--- Set maximum stat values
local function set_maximums(name, line, wildcards)
    stat_max.str = tonumber(wildcards.str)
    stat_max.int = tonumber(wildcards.int)
    stat_max.wis = tonumber(wildcards.wis)
    stat_max.dex = tonumber(wildcards.dex)
    stat_max.con = tonumber(wildcards.con)
    stat_max.luck = tonumber(wildcards.luck)

    show_data()
    SaveState()
end

--- Set stat weights
local function set_weights(name, line, wildcards)
    stat_weight.str = tonumber(wildcards.str)
    stat_weight.int = tonumber(wildcards.int)
    stat_weight.wis = tonumber(wildcards.wis)
    stat_weight.dex = tonumber(wildcards.dex)
    stat_weight.con = tonumber(wildcards.con)
    stat_weight.luck = tonumber(wildcards.luck)

    calculate_stat_sorted()
    show_data()
    SaveState()
end

---Alias handler for 'autotrain convert on|off'
local function handle_convert(name, line, wildcards)
    if (wildcards.onoff == "on") then
        convertall_enabled = true
        AardPrint("@WAutomatic conversion of practices to trains @Yenabled@W.")
        SaveState()
        return
    end

    if (wildcards.onoff == "off") then
        convertall_enabled = false
        AardPrint("@WAutomatic conversion of practices to trains @Ydisabled@W.")
        SaveState()
        return
    end

    AardPrint("@RError: The only available options are '@Wautotrain convertall on@R' or '@Wautotrain convertall off@R' - You used '@Wautotrain convertall " .. wildcards.onoff .. "@R'")
end

---Alias handler for 'autotrain profile list'
local function handle_profile_list(aliasname, line, wildcards)
    AardPrint("Profile List Goes here")
end

---Alias handler for 'autotrain profile create name'
local function handle_profile_create(aliasname, line, wildcards)
    local name = wildcards.name
    AardPrint("Create New Profile: " .. name)
end

---Alias handler for 'autotrain profile delete name'
local function handle_profile_delete(aliasname, line, wildcards)
    local name = wildcards.name
    AardPrint("Delete Profile: " .. name)
end

---Alias handler for 'autotrain profile load name'
local function handle_profile_load(aliasname, line, wildcards)
    local name = wildcards.name
    AardPrint("Load Profile: " .. name)
end

---Alias handler for 'autotrain profile show name'
local function handle_profile_show(aliasname, line, wildcards)
    local name = wildcards.name
    AardPrint("Show Profile: " .. name)
end

---Parsed and calculated data about stats
---@type table<string,Stat>
local train_data = {}

--- How many trains are available server-side
---@type number
local available_trains = 0

--- How many practices are available server-side
---@type number
local available_practices = 0

--- Calculate how we should spend our currently available trains based on defined settings
local function do_train()
    EnableTriggerGroup("parse_train", true)
    SendNoEcho("train")
    train_data = {}
    available_trains = 0
    available_practices = 0
end

local function parse_available_practices(name, line, wildcards)
    available_practices = tonumber(wildcards.practices)
end

local function parse_available_trains(name, line, wildcards)
    available_trains = tonumber(wildcards.trains)
end

local function parse_train_data(name, line, wildcards)
    local stat = wildcards.stat

    -- Don't process Hp/Mana/Moves -- We're only going to train attributes...
    if ((stat == "Hp") or (stat == "Mana") or (stat == "Moves")) then
        return
    end

    local short_stat = STAT_MAP[wildcards.stat]

    ---@type Stat
    local stat_data = {}

    stat_data.trained = tonumber(wildcards.trained)
    stat_data.min = math.min(tonumber(wildcards.max), stat_min[short_stat])
    stat_data.max = math.min(tonumber(wildcards.max), stat_max[short_stat])
    stat_data.tiermod = tonumber(wildcards.tiermod or 0)
    stat_data.wishmod = tonumber(wildcards.wishmod)
    stat_data.costmod = tonumber(wildcards.racemod) + stat_data.wishmod + stat_data.tiermod
    stat_data.buy = 0

    -- AardPrint("@WParsed @C%s@W - trained = %d, min = %d, max = %d, costmod = %d", short_stat, stat_data.trained, stat_data.min, stat_data.max, stat_data.costmod)

    train_data[short_stat] = stat_data
end

---Calculate the cost to purchase a given stat, if it is trained to a certain amount
---@param stat Stat # Data about the stat to be purchased
---@param trained number # The level of the stat at which we want to determine the cost
---@return number # How many trains it will cost to train that stat
local function calculate_stat_cost(stat, trained)
    if trained <= 60 then
        -- Stats always cost 1 train through 60 regardless of modifiers
        return 1
    else
        -- Do the max of the value and 1, in case the costmod might reduce it below 1
        return math.max(TRAINING_COSTS[trained] + stat.costmod, 1)
    end
end

---Calculate the cost to buy a given amount of a given stat
---@param stat Stat
---@param amt number
---@return number # Total cost to train a given stat a given amount of times
local function calculate_total_cost(stat, amt)
    local target_val = stat.trained + amt
    local i = stat.trained
    local total = 0

    while i < target_val do
        total = total + calculate_stat_cost(stat, i)
        i = i + 1
    end

    return total
end

--- Buy one of the given stat, if possible
---@param trains number # How many trains we have
---@param stat Stat # Data about the stat to buy
---@return boolean # If the purchase was successful
---@return number # How many trains we have after buying
local function buy_one(trains, stat)
    local cost = calculate_stat_cost(stat, stat.trained + stat.buy)

    -- If we have enough trains to afford it, go ahead and buy it
    if (cost <= trains) then
        stat.buy = stat.buy + 1
        return true, (trains - cost)
    else
        return false, trains
    end
end

---Calculate the optimal stats to purchase given our available trains and stat priorities
local function calculate_purchase()
--[=[
    Stat purchase is calculated via the following method:

    First, loop through the stats order of highest to lowest priority
        If our current level of the stat is below the configured minimum and also the current allowed max
            Train the stat as much as possible, as long as we can afford it

    Next, loop through the stats in order of highest to lowest priority
        If the stat has been/will be trained to it's max, ignore the stat
        Calculate a 'marginal value' (MV) defined by the stat's priority divided by it's current cost
        Buy a single point of the stat with the highest MV
        Repeat loop, recalculating MVs with each stat purchase, until we can no longer afford any non-maxed stats
]=]

    local trains = available_trains
    local target_val = 0
    local loop_limit

    if ((available_practices > 10) and convertall_enabled) then
        SendNoEcho("train convertall")
        trains = trains + (available_practices / 10)
    end

    -- In sorted order, train stats until they reach the defined minimum value
    for _,stat in ipairs(stat_sorted) do
        target_val = train_data[stat].min
        if train_data[stat].trained < target_val then
            local cost = calculate_total_cost(train_data[stat], target_val - train_data[stat].trained)
            if cost < trains then
                train_data[stat].buy = target_val - train_data[stat].trained
                trains = trains - cost
            else
                -- We cannot afford to purchase up to the min for this stat, buy as many as we can...
                local success = true
                loop_limit = 60
                while success do
                    success, trains = buy_one(trains, train_data[stat])

                    loop_limit = loop_limit - 1
                    if loop_limit == 0 then
                        print("LOOP LIMIT REACHED -- MIN STAT BUY")
                        return
                    end
                end
            end
        end

        if trains <= 0 then return end
    end

    -- Calculate the marginal value of each potential stat purchase and purchase the stat with the highest marginal value
    -- Repeat until we're too low on trains to afford any stat that hasn't already been maxed

    ---The highest marginal value found
    local max_marginal = 0
    ---The stat with the highest marginal value thus far
    local max_marginal_stat = "str"
    ---Is set to true each iteration we find a stat we want to buy which can afford
    local has_match = false

    loop_limit = 300

    while true do
        max_marginal = 0
        has_match = false

        -- Calculate marginal values
        for _,stat in ipairs(stat_sorted) do
            -- Make sure we can afford to purchase this stat...
            local stat_data = train_data[stat]
            local next_stat = stat_data.trained + stat_data.buy
            local next_cost = calculate_stat_cost(stat_data, next_stat)
            local can_afford = (next_cost <= trains)
            -- AardPrint("@wMarginal Value of @C%s@w #%d - cost = %d, mv = %.2f", stat, next_stat, next_cost, stat_weight[stat] / next_cost)
            if (next_stat < stat_data.max) and can_afford then  -- Make sure we haven't exceeded our max and also that we have enough trains to buy one...
                local mv = stat_weight[stat] / next_cost
                if (mv > max_marginal) then
                    has_match = true
                    max_marginal = mv
                    max_marginal_stat = stat
                end
            end
        end

        if has_match then
            local buystat = train_data[max_marginal_stat]
            local buycost = calculate_stat_cost(buystat, buystat.trained + buystat.buy)
            -- AardPrint("@wBuying @C%s@w #%d - cost = %d, mv = %.2f", max_marginal_stat, buystat.trained + buystat.buy, buycost, max_marginal)
            trains = trains - buycost
            buystat.buy = buystat.buy + 1
        else
            break
        end

        loop_limit = loop_limit - 1
        if loop_limit == 0 then
            print("LOOP LIMIT REACHED -- MARGINAL VALUE BUY")
            return
        end
    end
end

--- We've completely parsed the train data and can now calculate how to spend our trains
local function train_data_complete(name, line, wildcards)
    EnableTriggerGroup("parse_train", false)

    calculate_purchase()

    for _,stat in ipairs(stat_sorted) do
        if train_data[stat].buy > 0 then
            Send("train " .. train_data[stat].buy .. " " .. stat)
        end
    end

    print("")
    AardPrint("@wTraining Results:")
    print("")
    AardPrint("@g               Min    Max    Weight  Was    Now")
    AardPrint("@c              ------ ------ ------- ------ ------")
    for _,long_stat_name in ipairs({ "Strength", "Intelligence", "Wisdom", "Dexterity", "Constitution", "Luck" }) do
        local stat = STAT_MAP[long_stat_name]
        local stat_data = train_data[stat]
        local now = stat_data.trained + stat_data.buy
        local bought_color = stat_data.buy == 0 and '' or '@C'
        local max_star = now >= stat_data.max and '*' or ''

        AardPrint("@w%-12s :@W%6d %6d %7.2f %6d %s%6d%s", long_stat_name, stat_min[stat], stat_max[stat], stat_weight[stat], stat_data.trained, bought_color, now, max_star)
    end
    -- AardPrint("@w%12s :@W%6d %6d %7.2f %6d %s%6d", "Strength", stat_min.str, stat_max.str, stat_weight.str, train_data.str.trained, (train_data.str.buy == 0 and '' or '@C'), train_data.str.trained + train_data.str.buy)
    -- AardPrint("@w%12s :@W%6d %6d %7.2f %6d %s%6d", "Intelligence", stat_min.int, stat_max.int, stat_weight.int, train_data.int.trained, (train_data.int.buy == 0 and '' or '@C'), train_data.int.trained + train_data.int.buy)
    -- AardPrint("@w%12s :@W%6d %6d %7.2f %6d %s%6d", "Wisdom", stat_min.wis, stat_max.wis, stat_weight.wis, train_data.wis.trained, (train_data.wis.buy == 0 and '' or '@C'), train_data.wis.trained + train_data.wis.buy)
    -- AardPrint("@w%12s :@W%6d %6d %7.2f %6d %s%6d", "Dexterity", stat_min.dex, stat_max.dex, stat_weight.dex, train_data.dex.trained, (train_data.dex.buy == 0 and '' or '@C'), train_data.dex.trained + train_data.dex.buy)
    -- AardPrint("@w%12s :@W%6d %6d %7.2f %6d %s%6d", "Constitution", stat_min.con, stat_max.con, stat_weight.con, train_data.con.trained, (train_data.con.buy == 0 and '' or '@C'), train_data.con.trained + train_data.con.buy)
    -- AardPrint("@w%12s :@W%6d %6d %7.2f %6d %s%6d", "Luck", stat_min.luck, stat_max.luck, stat_weight.luck, train_data.luck.trained, (train_data.luck.buy == 0 and '' or '@C'), train_data.luck.trained + train_data.luck.buy)
    print("")
end

--- Print a list of spells we want to practice
local function show_spells()
end

--- Attempt to find a spell given a partial spell name or spell number
---@param txt string # Either a partial spell name or a spell number (as a string)
---@return SpellData?
local function find_spell(txt)
    local sn = tonumber(txt)

    local spell = nil
    if sn ~= nil then
        spell = SpellData.GetSpellByNumber(sn)
    else
        spell = SpellData.MatchSpell(txt)
    end

    if spell == nil then
        AardPrint("@RERROR: @WCould not find a spell or skill matching '@Y%s@W'", txt)
        return
    end

    return spell
end

--- Add a spell to the list of spells we want to automatically practice
---@param name string
---@param line string
---@param wildcards any
local function add_spell(name, line, wildcards)
    local spell = find_spell(wildcards.spell)
    if (not spell) then
        AardPrint("@WUnknown spell: @Y%s@W", wildcards.spell)
        return
    end

    if spells_to_practice[spell.id] ~= nil then
        AardPrint("@WWe are already practicing '@Y%s@W'", spell.name)
    else
        spells_to_practice[spell.id] = spell.name
        AardPrint("@WWe will now practice: @Y%s@W", spell.name)
    end
end

--- Remove a spell from the list of spells we want to automatically practice
---@param name string
---@param line string
---@param wildcards any
local function remove_spell(name, line, wildcards)
    local spell = find_spell(wildcards.spell)
    if (not spell) then
        AardPrint("@WUnknown spell: @Y%s@W", wildcards.spell)
        return
    end

    if spells_to_practice[spell.id] == nil then
        AardPrint("@WWe are not practicing '@Y%s@W'", spell.name)
    else
        spells_to_practice[spell.id] = nil
        AardPrint("@WWe will no longer practice: @Y%s@W", spell.name)
    end
end

--- Define aliases
local function create_aliases()
    -- Base
    Alias.new("autotrain_help", Alias.NoGroup, [[^autotrain\s+help$]], Alias.Default, do_help)
    Alias.new("autotrain_reload", Alias.NoGroup, [[^autotrain\s+reload$]], Alias.Default, do_reload)
    Alias.new("autotrain_train", Alias.NoGroup, [[^autotrain\s*$]], Alias.Default, do_train)

    Alias.new("autotrain_convert", Alias.NoGroup, [[^autotrain\s+convert\s+(?<onoff>.*)$]], Alias.Default, handle_convert)

    -- Profiles
    Alias.new("autotrain_profile_list", Alias.NoGroup, [[^autotrain\s+profile\s+list\s*$]], Alias.Default, handle_profile_list)
    Alias.new("autotrain_profile_show", Alias.NoGroup, [[^autotrain\s+profile\s+show\s+(?<name>[^\s]+)$]], Alias.Default, handle_profile_show)
    Alias.new("autotrain_profile_create", Alias.NoGroup, [[^autotrain\s+profile\s+create\s+(?<name>[^\s]+)$]], Alias.Default, handle_profile_create)
    Alias.new("autotrain_profile_delete", Alias.NoGroup, [[^autotrain\s+profile\s+delete\s+(?<name>[^\s]+)$]], Alias.Default, handle_profile_delete)
    Alias.new("autotrain_profile_load", Alias.NoGroup, [[^autotrain\s+profile\s+load\s+(?<name>[^\s]+)$]], Alias.Default, handle_profile_load)

    -- Training
    Alias.new("autotrain_minimum_set", Alias.NoGroup, [[^autotrain min\s+(?<str>\d+)\s+(?<int>\d+)\s+(?<wis>\d+)\s+(?<dex>\d+)\s+(?<con>\d+)\s+(?<luck>\d+)\s*$]], Alias.Default, set_minimums)
    Alias.new("autotrain_maximum_set", Alias.NoGroup, [[^autotrain max\s+(?<str>\d+)\s+(?<int>\d+)\s+(?<wis>\d+)\s+(?<dex>\d+)\s+(?<con>\d+)\s+(?<luck>\d+)\s*$]], Alias.Default, set_maximums)
    Alias.new("autotrain_weights_set", Alias.NoGroup, [[^autotrain weight\s+(?<str>[\d\.]+)\s+(?<int>[\d\.]+)\s+(?<wis>[\d\.]+)\s+(?<dex>[\d\.]+)\s+(?<con>[\d\.]+)\s+(?<luck>[\d\.]+)\s*$]], Alias.Default, set_weights)
    Alias.new("autotrain_show", Alias.NoGroup, [[^autotrain\s+show$]], Alias.Default, show_data)

    -- Practices
    Alias.new("autotrain_spells", Alias.NoGroup, [[^autotrain\s+spells$]], Alias.Default, show_spells)
    Alias.new("autotrain_spells_add", Alias.NoGroup, [[^autotrain\s+add\s+(?<spell>.*)$]], Alias.Default, add_spell)
    Alias.new("autotrain_spells_remove", Alias.NoGroup, [[^autotrain\s+remove\s+(?<spell>.*)$]], Alias.Default, remove_spell)
end

--- Define triggers
local function create_triggers()
    Trigger.new("autotrain_trg_blank", "parse_train", [[^$]], Trigger.ParseAndOmit, function() end)
    Trigger.new("autotrain_trg_traintext", "parse_train", [[^Your stats and amount trained are\:$]], Trigger.ParseAndOmit, function() end)
    Trigger.new("autotrain_trg_header1", "parse_train", [[^              Base    Race   Tier   Wish   Your                    $]], Trigger.ParseAndOmit, function() end)
    Trigger.new("autotrain_trg_header3", "parse_train", [[^              Cost    Mod    Mod    Mod    Cost    Trained    Max  $]], Trigger.ParseAndOmit, function() end)
    Trigger.new("autotrain_trg_header5", "parse_train", [[^              \-\-\-\-\-\-\- \-\-\-\-\-\- \-\-\-\-\-\- \-\-\-\-\-\- \-\-\-\-\-\-  \-\-\-\-\-\-\-  \-\-\-\-\-\-\-$]], Trigger.ParseAndOmit, function() end)
    Trigger.new("autotrain_trg_traindata", "parse_train", [[^(?<stat>\w+)\s*\:\s*(?<base>\d+)\s*(?<racemod>[-]?\d+)\s*(?<tiermod>[-]?\d+)?\s*(?<wishmod>[-]?\d+)\s*(?<cost>\d+)\s*(?<trained>\d+)\s*(?<max>\d+)\*?$]], Trigger.ParseAndOmit, parse_train_data)
    Trigger.new("autotrain_trg_header2", "parse_train", [[^              Base    Race   Wish   Your                    $]], Trigger.ParseAndOmit, function() end)
    Trigger.new("autotrain_trg_header4", "parse_train", [[^              Cost    Mod    Mod    Cost    Trained    Max  $]], Trigger.ParseAndOmit, function() end)
    Trigger.new("autotrain_trg_header6", "parse_train", [[^              \-\-\-\-\-\-\- \-\-\-\-\-\- \-\-\-\-\-\- \-\-\-\-\-\-  \-\-\-\-\-\-\-  \-\-\-\-\-\-\-$]], Trigger.ParseAndOmit, function() end)
    Trigger.new("autotrain_trg_traindata2", "parse_train", [[^(?<stat>\w+)\s*\:\s*(?<base>\d+)\s*(?<racemod>[-]?\d+)\s*(?<wishmod>[-]?\d+)\s*(?<cost>\d+)\s*(?<trained>\d+)\s*(?<max>\d+?)\*?$]], Trigger.ParseAndOmit, parse_train_data)
    Trigger.new("autotrain_trg_practices", "parse_train", [[^You have (?<practices>\d+) practice sessions? available\.$]], Trigger.ParseAndOmit, parse_available_practices)
    Trigger.new("autotrain_trg_trains", "parse_train", [[^You have (?<trains>\d+) training sessions? available\.$]], Trigger.ParseAndOmit, parse_available_trains)
    Trigger.new("autotrain_trg_maxtrains", "parse_train", [[^You have (.*?) total stats out of (.*?) maximum\.$]], Trigger.ParseAndOmit, train_data_complete)
end

---Populate our training cost lookup table
local function init_training_costs()
    local i = 0

    while i <  71 do TRAINING_COSTS[i] =  1   i = i + 1    end
    while i <  91 do TRAINING_COSTS[i] =  2   i = i + 1    end
    while i < 131 do TRAINING_COSTS[i] =  3   i = i + 1    end
    while i < 171 do TRAINING_COSTS[i] =  4   i = i + 1    end
    while i < 201 do TRAINING_COSTS[i] =  6   i = i + 1    end
    while i < 225 do TRAINING_COSTS[i] =  9   i = i + 1    end
    while i < 251 do TRAINING_COSTS[i] = 11   i = i + 1    end
    while i < 276 do TRAINING_COSTS[i] = 15   i = i + 1    end
    while i < 291 do TRAINING_COSTS[i] = 17   i = i + 1    end
    while i < 301 do TRAINING_COSTS[i] = 20   i = i + 1    end
    while i < 326 do TRAINING_COSTS[i] = 25   i = i + 1    end
    while i < 351 do TRAINING_COSTS[i] = 35   i = i + 1    end
    while i < 376 do TRAINING_COSTS[i] = 50   i = i + 1    end
    while i < 400 do TRAINING_COSTS[i] = 60   i = i + 1    end
end
init_training_costs()

---Load a setting saved in the mushclient variables
---@param name string # Name of the variable
---@param default any # Default value if we don't have a value saved already
---@return any # The stored value, if one exists, or the default otherwise
local function load_setting(name, default)
    -- print("Loading Setting: " .. name)
    local env = {}
    local var = GetVariable(name)

    if var == nil or var == "" then
        return default
    end

    local f = assert(loadstring(GetVariable(name) or ""))
    setfenv(f, env) -- Set the environment when loading the setting to an empty table to avoid modifying the global namespace
    f()
    return env[name] -- Extract the variable from our sandbox environment
end

---Store a variable to be restored later
---@param name string # Name of the variable
---@param value any # Value of the variable
local function save_setting(name, value)
    SetVariable(name, serialize.save(name, value))
end

function OnPluginInstall()
    Note("autotrain installed : see 'autotrain help' for details")

    if GetVariable("enabled") == "false" then
        ColourNote("yellow", "", "Warning: Plugin " .. GetPluginName ().. " is currently disabled.")
        check (EnablePlugin(GetPluginID (), false))
        return
    end -- they didn't enable us last time

    -- Load saved settings
    stat_min = load_setting("stat_min", { str = 40, int = 40, wis = 40, dex = 40, con = 40, luck = 40 })
    stat_max = load_setting("stat_max", { str = 395, int = 71, wis = 131, dex = 395, con = 171, luck = 171 })
    stat_weight = load_setting("stat_weight", { str = 4.0, int = 1.0, wis = 2.0, dex = 5.0, con = 2.0, luck = 3.0 })
    spells_to_practice = load_setting("spells_to_practice", {})

    calculate_stat_sorted()

    convertall_enabled = (GetVariable("convertall_enabled") == "true")

    OnPluginEnable()
end

function OnPluginSaveState ()
    SetVariable ("enabled", tostring (GetPluginInfo (GetPluginID (), 17)))

    save_setting("stat_min", stat_min)
    save_setting("stat_max", stat_max)
    save_setting("stat_weight", stat_weight)
    save_setting("spells_to_practice", spells_to_practice)

    SetVariable("convertall_enabled", tostring(convertall_enabled))
end

function OnPluginEnable()
	create_aliases()
	create_triggers()
end

function OnPluginDisable()
	Alias.destroy_all()
	Trigger.destroy_all()
end