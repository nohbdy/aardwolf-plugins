local Alias = require "alias"
local Trigger = require "trigger"
local SpellData = require "spelldata"
local settings = require "settings"
local struct = require "struct"
local base64 = require "base64"

local wish_lib = require "parser/wish"
local slist_lib = require "parser/slist"

require "aardprint"
require "gmcphelper"

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
local current_profile_name = ""

---The profile we are currently using
---@type Profile
local current_profile = nil

---Should practices be converted before training
---@type boolean
--local convertall_enabled = false

---Minimum values a stat should be trained to, regardless of cost
---@type table<string, number>
--local stat_min = {}

---Maximum values a stat should be trained to, regardless of cost
---@type table<string, number>
--local stat_max = {}

---Stat weights set by the user
---@type table<string, number>
--local stat_weight = {}

---Stat names, sorted by weights in descending order
---@type string[]
local stat_sorted = {}

---Lookup table for training costs before cost reductions
---@type table<number,number>
local TRAINING_COSTS = {}

local trg_practice = nil --- `{start_practice}` trigger
local trg_end_practices = nil --- `{end_all_practices}` trigger

---Trigger Group for Practice triggers
local TRG_PRACTICE = "tgp_at_prac"

--- Array of spell numbers for our default skills/spells to practice
---@type number[]
local DEFAULT_SPELLS = { 330, 10, 103, 158, 23, 25, 27, 467, 238, 195, 70, 340, 322, 24, 26, 28, 54, 124, 445, 446, 132, 503, 504, 106, 214, 260, 459, 516, 261, 515, 219, 198, 257, 224, 215, 304, 275, 305, 217, 308, 309, 277, 222, 223, 410, 244, 327, 245, 316, 133, 324, 241 }

--- Create a new table mapping spell numbers to spell names, using DEFAULT_SPELLS for the spell numbers
---@return table<number, string>
local function DefaultSpellsToPractice()
    local result = {}
    for i, sn in ipairs(DEFAULT_SPELLS) do
        local spell = SpellData.GetSpellByNumber(sn)
        result[sn] = spell.name
    end

    return result
end

---Map stat long names to short names
---@type table<string,string>
local STAT_MAP = {}
STAT_MAP["Strength"] = "str"
STAT_MAP["Intelligence"] = "int"
STAT_MAP["Wisdom"] = "wis"
STAT_MAP["Dexterity"] = "dex"
STAT_MAP["Constitution"] = "con"
STAT_MAP["Luck"] = "luck"

---Convert a value to a number and ensure it is not nil
---@param val any
---@return number
local function parsenumber(val)
    local ret = tonumber(val)
    assert(ret ~= nil, "Value is not a number")
    return ret
end

---Whether or not we've checked the player's wish info for the scholar wish
---@type boolean
local has_checked_wishes = false

---Whether or not the player has the scholar wish
---@type boolean?
local has_scholar_wish = nil

local wish_doafter = nil

---Callback function called when we've gotten wish list data from server
---@param wishes Wish[] # Array of wish data
local function wish_callback(wishes)
    has_checked_wishes = true
    for _,wish in ipairs(wishes) do
        if (wish.keyword == "Scholar") then
            has_scholar_wish = wish.has_wish
            break
        end
    end

    if (has_scholar_wish == nil) then
        -- This should never happen but.. who knows!
        AardError("autotrain", "wish data didn't contain information about the Scholar wish???")
        has_scholar_wish = false
    end

    AardDebug("autotrain", "scholar wish = %s", has_scholar_wish and "true" or "false")

    -- If we have a callback assigned, call it
    if (wish_doafter ~= nil) then
        wish_doafter()
        wish_doafter = nil
    end
end

---Begin request for wish data from server
---@param doafter fun()? # A function to call after we've received our wish data or nil
local function get_wish_data(doafter)
    wish_doafter = doafter
    wish_lib.wish(wish_callback)
end

---Calculate stat_sorted based on values in stat_weight
local function calculate_stat_sorted()
    -- Make a copy of our stat weights
    local weight_copy = {}
    for k,v in pairs(current_profile.stat_weight) do weight_copy[k] = v end

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
    AardPrint("@Y   autotrain spells")
    AardPrint("@W       View a list of spells to be practiced")
    print()
    AardPrint("@Y   autotrain add <spell number>|<spell name>")
    AardPrint("@W       Add a spell to be practiced")
    AardPrint("@W       e.g. \"autotrain add 54\" or \"autotrain add heal\"")
    print()
    AardPrint("@Y   autotrain remove <spell number>|<spell name>")
    AardPrint("@W       Remove a spell from the list of spells to be practiced")
    AardPrint("@W       e.g. \"autotrain remove 54\" or \"autotrain remove heal\"")
    print("")
    AardPrint("@Y   autotrain profile list")
    AardPrint("@Y   autotrain profile show name")
    AardPrint("@Y   autotrain profile create name")
    AardPrint("@Y   autotrain profile delete name")
    AardPrint("@Y   autotrain profile load name")
    AardPrint("@Y   autotrain profile import name import_string")
    AardPrint("@Y   autotrain profile export name")
    print("")
    AardPrint("@Y   autotrain show")
    AardPrint("@W       Shows the currently defined stat values.")
    AardPrint("@Y   autotrain convert on|off")
    AardPrint("@W       Enables automatic conversion of practices to trains.")
    AardPrint("@Y   autotrain reload")
    AardPrint("@W       Reloads the plugin.")
    AardPrint("@C--------------------------------------------------------------------------------")
end

--- Display the stat data for the given profile
---@param profile Profile
local function show_profile(profile)
    print("")
    AardPrint("@g               Min    Max    Weight")
    AardPrint("@c              ------ ------ -------")
    AardPrint("@w%12s :@W%6d %6d %7.2f", "Strength", profile.stat_min.str, profile.stat_max.str, profile.stat_weight.str)
    AardPrint("@w%12s :@W%6d %6d %7.2f", "Intelligence", profile.stat_min.int, profile.stat_max.int, profile.stat_weight.int)
    AardPrint("@w%12s :@W%6d %6d %7.2f", "Wisdom", profile.stat_min.wis, profile.stat_max.wis, profile.stat_weight.wis)
    AardPrint("@w%12s :@W%6d %6d %7.2f", "Dexterity", profile.stat_min.dex, profile.stat_max.dex, profile.stat_weight.dex)
    AardPrint("@w%12s :@W%6d %6d %7.2f", "Constitution", profile.stat_min.con, profile.stat_max.con, profile.stat_weight.con)
    AardPrint("@w%12s :@W%6d %6d %7.2f", "Luck", profile.stat_min.luck, profile.stat_max.luck, profile.stat_weight.luck)
    print("")
    if (profile.convertall_enabled) then
        AardPrint("@wAuto convert practices: @WEnabled")
    else
        AardPrint("@wAuto convert practices: @WDisabled")
    end
    print("")
end

--- Display the currently defined stat data
local function show_data()
    show_profile(current_profile)
end

--- Set minimum stat values
local function set_minimums(name, line, wildcards)
    current_profile.stat_min.str = tonumber(wildcards.str) or 0
    current_profile.stat_min.int = tonumber(wildcards.int) or 0
    current_profile.stat_min.wis = tonumber(wildcards.wis) or 0
    current_profile.stat_min.dex = tonumber(wildcards.dex) or 0
    current_profile.stat_min.con = tonumber(wildcards.con) or 0
    current_profile.stat_min.luck = tonumber(wildcards.luck) or 0

    show_data()
    SaveState()
end

--- Set maximum stat values
local function set_maximums(name, line, wildcards)
    current_profile.stat_max.str = tonumber(wildcards.str) or 400
    current_profile.stat_max.int = tonumber(wildcards.int) or 400
    current_profile.stat_max.wis = tonumber(wildcards.wis) or 400
    current_profile.stat_max.dex = tonumber(wildcards.dex) or 400
    current_profile.stat_max.con = tonumber(wildcards.con) or 400
    current_profile.stat_max.luck = tonumber(wildcards.luck) or 400

    show_data()
    SaveState()
end

--- Set stat weights
local function set_weights(name, line, wildcards)
    current_profile.stat_weight.str = tonumber(wildcards.str) or 1
    current_profile.stat_weight.int = tonumber(wildcards.int) or 1
    current_profile.stat_weight.wis = tonumber(wildcards.wis) or 1
    current_profile.stat_weight.dex = tonumber(wildcards.dex) or 1
    current_profile.stat_weight.con = tonumber(wildcards.con) or 1
    current_profile.stat_weight.luck = tonumber(wildcards.luck) or 1

    calculate_stat_sorted()
    show_data()
    SaveState()
end

---Alias handler for 'autotrain convert on|off'
local function handle_convert(name, line, wildcards)
    if (wildcards.onoff == "on") then
        current_profile.convertall_enabled = true
        AardPrint("@WAutomatic conversion of practices to trains @Yenabled@W.")
        SaveState()
        return
    end

    if (wildcards.onoff == "off") then
        current_profile.convertall_enabled = false
        AardPrint("@WAutomatic conversion of practices to trains @Ydisabled@W.")
        SaveState()
        return
    end

    AardPrint("@RError: The only available options are '@Wautotrain convertall on@R' or '@Wautotrain convertall off@R' - You used '@Wautotrain convertall " .. wildcards.onoff .. "@R'")
end

---Alias handler for 'autotrain profile list'
local function handle_profile_list(aliasname, line, wildcards)
    AardPrint("@YListing all autotrain profiles:")
    local sorted = {}
    for i,k in pairs(profiles) do
        table.insert(sorted, i)
    end
    table.sort(sorted)
    for i,k in ipairs(sorted) do
        local isCurrent = "  "
        if (k == current_profile_name) then isCurrent = ">>" end
        AardPrint("@C%2s %s", isCurrent, k)
    end
    print("")
end

---Alias handler for 'autotrain profile create name'
local function handle_profile_create(aliasname, line, wildcards)
    local name = wildcards.name

    -- Check if the name is already used
    ---@type Profile
    local profile = nil
    profile = profiles[name]
    if (profile ~= nil) then
        AardPrint("@RERROR: @WUnable to create profile, there is already a profile named '%s'", name)
        return
    end

    -- Create a new profile with default settings
    profile = {}
    profile.name = name
    profile.stat_min = { str = 40, int = 40, wis = 40, dex = 40, con = 40, luck = 40 }
    profile.stat_max = { str = 395, int = 395, wis = 395, dex = 395, con = 395, luck = 395 }
    profile.stat_weight = { str = 1.0, int = 1.0, wis = 1.0, dex = 1.0, con = 1.0, luck = 1.0 }
    profile.convertall_enabled = false
    profile.spells_to_practice = DefaultSpellsToPractice()

    profiles[name] = profile

    AardPrint("@YCreated new autotrain profile: @W%s", name)
    SaveState()
end

--- Load a profile by name
---@param name string # Name of the profile to be loaded
local function load_profile(name)
    local loadme = profiles[name]

    if (not loadme) then
        AardPrint("@RERROR: @WAttempted to load non-existant profile %s???", name)
    end

    current_profile_name = name
    current_profile = loadme

    calculate_stat_sorted()

    AardPrint("@YLoaded autotrain profile: @W%s", name)
    SaveState()
end

---Alias handler for 'autotrain profile delete name'
local function handle_profile_delete(aliasname, line, wildcards)
    local name = wildcards.name

    if (not profiles[name]) then
        AardPrint("@RERROR: @WUnable to delete profile, there is no profile named '%s'", name)
        return
    end

    local numProfiles = 0
    for _ in pairs(profiles) do numProfiles = numProfiles + 1 end

    if (numProfiles < 2) then
        AardPrint("@RERROR: @WUnable to delete a profile when there would be none left afterwards.  Create another profile first.")
        return
    end

    local confirmed = (wildcards.confirm == "confirm")
    if (not confirmed) then
        AardPrint("@YTo delete the profile '%s', please enter '@Wautotrain profile delete %s confirm@Y'", name, name)
        return
    end

    -- Bye bye profile!
    AardPrint("@Rautotrain profile '%s' has been deleted.", name)
    profiles[name] = nil

    -- If we deleted the currently used profile, swap to a new one
    if (current_profile_name == name) then
        for k,_ in pairs(profiles) do
            if (k ~= name) then
                -- We don't really care which one we swap to, as long as it's not the one we're deleting
                load_profile(k)
                break
            end
        end
    else
        -- save the state after deletion, load_profile will save the state after loading so we'll always be saving
        SaveState()
    end
end

---Alias handler for 'autotrain profile load name'
local function handle_profile_load(aliasname, line, wildcards)
    local name = wildcards.name

    local new_profile = profiles[name]
    if (not new_profile) then
        AardPrint("@RERROR: @WUnable to load profile, there is no profile named '%s'", name)
        return
    end

    load_profile(name)
end

---Alias handler for 'autotrain profile show name'
local function handle_profile_show(aliasname, line, wildcards)
    local name = wildcards.name

    local profile = profiles[name]
    if (not profile) then
        AardPrint("@RERROR: @WUnable to show profile, there is no profile named '%s'", name)
        return
    end

    print("")
    AardPrint("@wProfile '%s' settings:", name)
    show_profile(profile)
end

---Alias handler for 'autotrain profile show name'
local function handle_profile_import(aliasname, line, wildcards)
    local name = wildcards.name

    -- Check if the profile name is already used
    ---@type Profile
    local profile = nil
    profile = profiles[name]
    if (profile ~= nil) then
        AardPrint("@RERROR: @WUnable to import profile, there is already a profile named '%s'", name)
        return
    end

    -- Decode the profile data
    local encoded_data = wildcards.profile

    local decoded = base64.decode(encoded_data)
    local spell_len = struct.unpack('H', decoded)
    local fmt = "HHHHHHHHHHHHHffffffb" .. string.rep("H", spell_len)
    local data = { struct.unpack(fmt, decoded) }
    local spell_len2,minstr,minint,minwis,mindex,mincon,minluk,maxstr,maxint,maxwis,maxdex,maxcon,maxluk,weightstr,weightint,weightwis,weightdex,weightcon,weightluk,convert = struct.unpack(fmt, decoded)

    profile = {}
    profile.name = name
    profile.stat_min = { str = data[2], int = data[3], wis = data[4], dex = data[5], con = data[6], luck = data[7] }
    profile.stat_max = { str = data[8], int = data[9], wis = data[10], dex = data[11], con = data[12], luck = data[13] }
    profile.stat_weight = { str = data[14], int = data[15], wis = data[16], dex = data[17], con = data[18], luck = data[19] }
    profile.convertall_enabled = (data[20] == 1)
    profile.spells_to_practice = {}
    local idx = 21
    while (idx < #data) do
        profile.spells_to_practice[data[idx]] = SpellData.GetSpellByNumber(data[idx]).name
        idx = idx + 1
    end

    -- Save the new profile data
    profiles[name] = profile

    -- Display the imported data to the user
    print("")
    AardPrint("@wImported new profile '%s':", name)
    show_profile(profile)

    SaveState()
end

---Alias handler for 'autotrain profile show name'
local function handle_profile_export(aliasname, line, wildcards)
    local name = wildcards.name

    ---@type Profile
    local profile = profiles[name]
    if (not profile) then
        AardPrint("@RERROR: @WUnable to export profile, there is no profile named '%s'", name)
        return
    end

    local convert = 0
    if (profile.convertall_enabled) then convert = 1 end

    local spells_array = {}
    local spell_len = 0
    for sn,_ in pairs(profile.spells_to_practice) do
        table.insert(spells_array, sn)
        spell_len = spell_len + 1
    end

    local fmt = "HHHHHHHHHHHHHffffffb" .. string.rep("H", spell_len)

    local data = struct.pack(fmt, spell_len, profile.stat_min.str, profile.stat_min.int, profile.stat_min.wis, profile.stat_min.dex, profile.stat_min.con, profile.stat_min.luck,
                                                    profile.stat_max.str, profile.stat_max.int, profile.stat_max.wis, profile.stat_max.dex, profile.stat_max.con, profile.stat_max.luck,
                                                    profile.stat_weight.str, profile.stat_weight.int, profile.stat_weight.wis, profile.stat_weight.dex, profile.stat_weight.con, profile.stat_weight.luck,
                                                    convert, unpack(spells_array))
    local encoded = base64.encode(data)

    AardPrint("@Cautotrain profile import %s %s", name, encoded)
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

local has_max_stats = false

--- How many practices were spent practicing skills/spells
---@type number
local practices_spent = 0

---How many skills we practiced this run...
---@type number
local practices_spells_learned = 0

--- How many practices we require to finish practicing all our skills/spells
---@type number
local practices_needed = 0

---How many skills we failed to practice this run...
---@type number
local practices_spells_not_learned = 0

local practices_nothere = false -- Set to true if we've hit a not_here before, so we don't spam messages

local function spend_trains()
    EnableTriggerGroup("parse_train", true)
    SendNoEcho("train")
    train_data = {}
    has_max_stats = false
    available_trains = 0
    available_practices = 0
end

---Process results of `slist learned` to find any spells we want to practice
---@param spells table<number, SlistSpell>
local function process_spell_list(spells)
    local practice_pct = 85
    if (has_scholar_wish) then practice_pct = 95 end

    local spells_to_practice = current_profile.spells_to_practice
    ---@type SlistSpell[]
    local practice_queue = {}

    for id,spell in pairs(spells) do
        -- If the spell hasn't been practiced to max and it's in our list of spells, then queue it up
        if ((spell.percentage < practice_pct) and (spells_to_practice[id] ~= nil)) then
            table.insert(practice_queue, spell)
        end
    end

    -- No skills/spells to practice, so skip straight to trains
    if (#practice_queue == 0) then
        spend_trains()
        return
    end

    -- Practice skills/spells...
    local queue_len = #practice_queue
    AardPrint("@WPracticing %d %s", queue_len, (queue_len == 1) and "skill/spell" or "skills/spells")

    trg_practice.enable()
    trg_end_practices.enable()

    practices_spent = 0
    practices_spells_learned = 0
    practices_needed = 0
    practices_spells_not_learned = 0
    practices_nothere = false

    if (current_profile.convertall_enabled) then
        SendNoEcho("train reconvertall")
    end

    for _,spell in ipairs(practice_queue) do
        SendNoEcho("echo {start_practice}")
        SendNoEcho(string.format("practice \"%s\" full", spell.name))
        SendNoEcho("echo {end_practice}")
    end
    SendNoEcho("echo {end_all_practices}")
end

---Request `slist learned` data from the server
local function practice_spells()
    slist_lib.slist_learned(process_spell_list)
end

--- When we've successfully practices a skill/spell
local function parse_practice_success(name, line, wildcards)
    --You spend (?<spent>\d+) practices? to increase (?<name>[\w\s]+) to (?<pct>\d+%)\.
    local spent = parsenumber(wildcards.spent)
    AardPrint("@WSpent @C%d@W %s to learn @C%s@w", spent, (spent == 1) and "practice" or "practices", wildcards.name or "")
    practices_spent = practices_spent + spent
    practices_spells_learned = practices_spells_learned + 1
end

--- When we've run out of practices
local function parse_practice_fail(name, line, wildcards)
    local cost = parsenumber(wildcards.cost)
    practices_needed = practices_needed + cost
    practices_spells_not_learned = practices_spells_not_learned + 1
end

--- When we try to practice in a room without a trainer, this shouldn't happen though
local function parse_practice_not_here(name, line, wildcards)
    if (not practices_nothere) then
        AardError("autotrain", "Somehow we can't practice in this room? Did you change rooms?")
        practices_nothere = true
    end
end

local function end_practices()
    trg_practice.disable()
    trg_end_practices.disable()

    if (practices_spells_learned > 0) then
        AardPrint("@WSpent @C%d@W %s on learning @C%d@W %s", practices_spent, (practices_spent == 1) and "practice" or "practices", practices_spells_learned, (practices_spells_learned == 1) and "skill/spell" or "skills/spells")
    end

    if (practices_spells_not_learned > 0) then
        AardPrint("@WWe need @C%d@W %s to learn @C%d@W %s", practices_needed, (practices_needed == 1) and "practice" or "practices", practices_spells_not_learned, (practices_spells_not_learned == 1) and "skill/spell" or "skills/spells")
    end

    if (current_profile.convertall_enabled) then
        SendNoEcho("train convertall")
    end

    spend_trains()
end

--- Calculate how we should spend our currently available trains based on defined settings
local function do_train()
    -- Ensure we're in a room with the 'trainer' flag
    local room_details = gmcp("room.info.details")

    if (string.find(room_details,"trainer") == nil) then
        AardWarning("autotrain", "Must be in a room with a trainer.")
        return
    end

    -- Make sure we've loaded wish data before we try to train
    if (not has_checked_wishes) then
        AardDebug("autotrain", "Pulling wish data from server...")
        get_wish_data(practice_spells) -- this will call do_train again after the wish data is loaded
        return
    end

    -- If we've already checked our wish data, go to practicing spells
    practice_spells()
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

    local trained = tonumber(wildcards.trained)
    assert(trained ~= nil, "trained is not a number??")
    stat_data.trained = trained
    stat_data.min = math.min(tonumber(wildcards.max) or 400, current_profile.stat_min[short_stat])
    stat_data.max = math.min(tonumber(wildcards.max) or 400, current_profile.stat_max[short_stat])
    stat_data.tiermod = tonumber(wildcards.tiermod) or 0
    stat_data.wishmod = tonumber(wildcards.wishmod) or 0
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

    if ((available_practices >= 10) and current_profile.convertall_enabled) then
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
                local mv = current_profile.stat_weight[stat] / next_cost
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

    if (not has_max_stats) then
        calculate_purchase()

        for _,stat in ipairs(stat_sorted) do
            if train_data[stat].buy > 0 then
                Send("train " .. train_data[stat].buy .. " " .. stat)
            end
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

        AardPrint("@w%-12s :@W%6d %6d %7.2f %6d %s%6d%s", long_stat_name, current_profile.stat_min[stat], current_profile.stat_max[stat], current_profile.stat_weight[stat], stat_data.trained, bought_color, now, max_star)
    end
    -- AardPrint("@w%12s :@W%6d %6d %7.2f %6d %s%6d", "Strength", stat_min.str, stat_max.str, stat_weight.str, train_data.str.trained, (train_data.str.buy == 0 and '' or '@C'), train_data.str.trained + train_data.str.buy)
    -- AardPrint("@w%12s :@W%6d %6d %7.2f %6d %s%6d", "Intelligence", stat_min.int, stat_max.int, stat_weight.int, train_data.int.trained, (train_data.int.buy == 0 and '' or '@C'), train_data.int.trained + train_data.int.buy)
    -- AardPrint("@w%12s :@W%6d %6d %7.2f %6d %s%6d", "Wisdom", stat_min.wis, stat_max.wis, stat_weight.wis, train_data.wis.trained, (train_data.wis.buy == 0 and '' or '@C'), train_data.wis.trained + train_data.wis.buy)
    -- AardPrint("@w%12s :@W%6d %6d %7.2f %6d %s%6d", "Dexterity", stat_min.dex, stat_max.dex, stat_weight.dex, train_data.dex.trained, (train_data.dex.buy == 0 and '' or '@C'), train_data.dex.trained + train_data.dex.buy)
    -- AardPrint("@w%12s :@W%6d %6d %7.2f %6d %s%6d", "Constitution", stat_min.con, stat_max.con, stat_weight.con, train_data.con.trained, (train_data.con.buy == 0 and '' or '@C'), train_data.con.trained + train_data.con.buy)
    -- AardPrint("@w%12s :@W%6d %6d %7.2f %6d %s%6d", "Luck", stat_min.luck, stat_max.luck, stat_weight.luck, train_data.luck.trained, (train_data.luck.buy == 0 and '' or '@C'), train_data.luck.trained + train_data.luck.buy)
    print("")
end

local function parse_available_practices(name, line, wildcards)
    local practices = tonumber(wildcards.practices)
    assert(practices ~= nil, "practices isn't a number? This should never happen")
    available_practices = practices

    if (has_max_stats) then
        -- For some reason, with max stats, the line we normally trigger parsing completion from doesn't come
        train_data_complete()
    end
end

local function parse_available_trains(name, line, wildcards)
    local trains = tonumber(wildcards.trains)
    assert(trains ~= nil, "trains isn't a number? This should never happen")
    available_trains = trains
end

local function sort_spells(a, b)
    return a.name < b.name
end

--- Print a list of spells we want to practice
local function show_spells()
    local spells = current_profile.spells_to_practice
    local count = 0

    local display_data = {}

    for sn,name in pairs(spells) do
        local spell = SpellData.GetSpellByNumber(sn)
        local data = {}
        data.name = spell.name
        data.sn = spell.id

        table.insert(display_data, data)
        count = count + 1
    end

    table.sort(display_data, sort_spells)

    for _,data in ipairs(display_data) do
        AardPrint("@W%s", data.name)
    end

    if (count == 0) then
        AardPrint("@WYou don't have any skills or spells set to be practiced!")
        return
    end
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

    if current_profile.spells_to_practice[spell.id] ~= nil then
        AardPrint("@WWe are already practicing '@Y%s@W'", spell.name)
    else
        current_profile.spells_to_practice[spell.id] = spell.name
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

    if current_profile.spells_to_practice[spell.id] == nil then
        AardPrint("@WWe are not practicing '@Y%s@W'", spell.name)
    else
        current_profile.spells_to_practice[spell.id] = nil
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
    Alias.new("autotrain_profile_list", Alias.NoGroup, [[^autotrain\s+profiles?\s+list\s*$]], Alias.Default, handle_profile_list)
    Alias.new("autotrain_profile_show", Alias.NoGroup, [[^autotrain\s+profiles?\s+show\s+(?<name>[^\s]+)$]], Alias.Default, handle_profile_show)
    Alias.new("autotrain_profile_create", Alias.NoGroup, [[^autotrain\s+profiles?\s+create\s+(?<name>[^\s]+)$]], Alias.Default, handle_profile_create)
    Alias.new("autotrain_profile_delete", Alias.NoGroup, [[^autotrain\s+profiles?\s+delete\s+(?<name>[^\s]+)(?:\s+(?<confirm>confirm))?$]], Alias.Default, handle_profile_delete)
    Alias.new("autotrain_profile_load", Alias.NoGroup, [[^autotrain\s+profiles?\s+load\s+(?<name>[^\s]+)$]], Alias.Default, handle_profile_load)
    Alias.new("autotrain_profile_import", Alias.NoGroup, [[^autotrain\s+profiles?\s+import\s+(?<name>[^\s]+)\s+(?<profile>[^\s]+)$]], Alias.Default, handle_profile_import)
    Alias.new("autotrain_profile_export", Alias.NoGroup, [[^autotrain\s+profiles?\s+export\s+(?<name>[^\s]+)$]], Alias.Default, handle_profile_export)

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
    -- Practice parsing
    trg_practice = Trigger.new("trg_autotrain_practice_start", Trigger.NoGroup, [[^\{start_practice\}$]], Trigger.ParseAndOmit, function() EnableTriggerGroup(TRG_PRACTICE, true) end)
    Trigger.new("trg_autotrain_practice_end", TRG_PRACTICE, [[^\{end_practice\}$]], Trigger.ParseAndOmit, function() EnableTriggerGroup(TRG_PRACTICE, false) end)
    trg_end_practices = Trigger.new("trg_autotrain_endallpractices", Trigger.NoGroup, [[^\{end_all_practices\}$]], Trigger.ParseAndOmit, end_practices)
    Trigger.new("trg_autotrain_practice_success", TRG_PRACTICE, [[^You spend (?<spent>\d+) practices? to increase (?<name>[\w\s]+) to (?<pct>\d+%)\.$]], Trigger.ParseAndOmit, parse_practice_success)
    Trigger.new("trg_autotrain_practice_fail", TRG_PRACTICE, [[^It will cost you (?<cost>\d+) practices? to increase [\w\s]+ to \d+%\.$]], Trigger.ParseAndOmit, parse_practice_fail)
    Trigger.new("trg_autotrain_practice_nothere", TRG_PRACTICE, [[^There is nobody here to help you practice\.$]], Trigger.ParseAndOmit, parse_practice_not_here)
    Trigger.new("trg_autotrain_prac_nopracs", TRG_PRACTICE, [[^You have no practice sessions available\.$]], Trigger.ParseAndOmit, Trigger.NullCallback)
    Trigger.new("trg_autotrain_prac_expert", TRG_PRACTICE, [[^You are now an expert in .+\.$]], Trigger.ParseAndOmit, Trigger.NullCallback)
    Trigger.new("trg_autotrain_prac_remaining", TRG_PRACTICE, [[^You have \d+ practice sessions remaining\.$]], Trigger.ParseAndOmit, Trigger.NullCallback)

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
    Trigger.new("autotrain_trg_maxstats1", "parse_train", [[^Note: You cannot train any more stats\.$]], Trigger.ParseAndOmit, Trigger.NullCallback)
    Trigger.new("autotrain_trg_maxstats2", "parse_train", [[^\s*You have already hit your maximum of \d+\.$]], Trigger.ParseAndOmit, function() has_max_stats = true end)
    -- Tierstats come after total stats, but isn't always there - so we need to trigger off some echo'ed thing to mark the end of the data instead
    -- Trigger.new("autotrain_trg_tierstat", "parse_train", [[^Note: You have unallocated tier or wish stats\.$]], Trigger.ParseAndOmit, function() end)

    --[=[  Catch and Omit these, maybe?
You convert 10 practices into 1 training session.
You now have 6 trains and 7 practices.
You spend 2 training sessions increasing your wisdom 2 times!
You now have 167 wisdom and 4 trains remaining.
You have now reached your max wisdom of 167.
You spend 2 training sessions increasing your luck 2 times!
You now have 167 luck and 2 trains remaining.
You have now reached your max luck of 167.
You spend 2 training sessions increasing your constitution!
You now have 149 constitution and 0 trains remaining.
Your next training session in constitution will cost 2 trains.
    ]=]
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

function OnPluginInstall()
    Note("autotrain installed : see 'autotrain help' for details")

    if GetVariable("enabled") == "false" then
        ColourNote("yellow", "", "Warning: Plugin " .. GetPluginName ().. " is currently disabled.")
        check (EnablePlugin(GetPluginID (), false))
        return
    end -- they didn't enable us last time

    -- Load saved settings
    profiles = settings.load("profiles", {
        default = {
            name = "default",
            stat_min = { str = 40, int = 40, wis = 40, dex = 40, con = 40, luck = 40 },
            stat_max = { str = 395, int = 395, wis = 395, dex = 395, con = 395, luck = 395 },
            stat_weight = { str = 1.0, int = 1.0, wis = 1.0, dex = 1.0, con = 1.0, luck = 1.0 },
            convertall_enabled = false,
            spells_to_practice = DefaultSpellsToPractice()
        }
    })
    current_profile_name = settings.load("current_profile_name", "default")
    current_profile = profiles[current_profile_name]

    calculate_stat_sorted()

    OnPluginEnable()
end

function OnPluginSaveState ()
    SetVariable ("enabled", tostring (GetPluginInfo (GetPluginID (), 17)))

    settings.save("profiles", profiles)
    settings.save("current_profile_name", current_profile_name)
end

function OnPluginEnable()
	create_aliases()
	create_triggers()
end

function OnPluginDisable()
	Alias.destroy_all()
	Trigger.destroy_all()
end