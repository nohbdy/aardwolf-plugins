local Alias = require "alias"
local Trigger = require "trigger"
local settings = require "settings"

require "aardprint"

local KEYRING_DATA = "keyringdata"

--- Print help information
local function cmd_help(name, line, wildcards)
    AardPrint("@RTODO: Create Help Info!")
end

--- Reload the plugin
local function cmd_reload()
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

local deposit_container = ""

--- Deposit keys into a container
--- wildcards.container are keywords for the container in which the keys should be deposited
local function cmd_deposit(name, line, wildcards)
    local container = wildcards.container
    if (not container) then AardPrint("@RERROR: @WYou must specify a container in which to deposit the keys@w") return end

    deposit_container = container

    AardPrint("@WMoving keys from keyring to container")
    EnableTriggerGroup(KEYRING_DATA, true)
    SendNoEcho("keyring data")
end

local keyring_items = {}

--- Begin parsing keyring data
local function handle_keyring_data_start(name, line, wildcards)
    keyring_items = {}
end

--- Parse a line of keyring data
local function handle_keyring_data_line(name, line, wildcards)
    local keydata = {}
    keydata.id = tonumber(wildcards.id)
    keydata.flags = wildcards.flags
    keydata.name = wildcards.name
    keydata.level = tonumber(wildcards.level)
    keydata.type = tonumber(wildcards.type)
    keydata.unique = tonumber(wildcards.unique)
    keydata.wearloc = tonumber(wildcards.wearloc)
    keydata.timer = tonumber(wildcards.timer)

    keyring_items[keydata.id] = keydata
end

--- Finish parsing keyring data
local function handle_keyring_data_end(name, line, wildcards)
    EnableTriggerGroup(KEYRING_DATA, false) -- Disable our triggers for now

    local should_save = false

    for id, key in pairs(keyring_items) do
        if ((key.type == 13) and (key.timer == -1)) then
            -- Item is of type key and does not have a rot timer
            should_save = true
        elseif ((key.name == "Grax's Hope") or (key.name == "Grax's Trust")) then
            -- Grax's Hope and Grax's Trust are, for some reason, nosave treasures and not keys
            -- but we still want to save them...
            should_save = true
        else
            should_save = false
        end

        if should_save then
            AardPrint("@w\t>> %s @D[%d]", key.name, key.id)
            SendNoEcho("keyring get " .. id)
            SendNoEcho("put " .. id .. " " .. deposit_container)
        end
    end
end

local function create_aliases()
    Alias.new("keystore_deposit", Alias.NoGroup, [[^keystore deposit (?<container>.*)$]], Alias.Default, cmd_deposit)
    Alias.new("keystore_help", Alias.NoGroup, [[^keystore help$]], Alias.Default, cmd_help)
    Alias.new("keystore_reload", Alias.NoGroup, [[^keystore reload$]], Alias.Default, cmd_reload)
end

local function create_triggers()
    Trigger.new("trg_keyring_start", KEYRING_DATA, [[^{keyring}$]], Trigger.ParseAndOmit, handle_keyring_data_start)
    Trigger.new("trg_keyring_line", KEYRING_DATA, [[^(?<id>\d+),(?<flags>[KIMGHCETW]*),(?<name>[^,]*),(?<level>\d+),(?<type>\d+),(?<unique>\d+),(?<wearloc>-?\d+),(?<timer>-?\d+)$]], Trigger.ParseAndOmit, handle_keyring_data_line)
    Trigger.new("trg_keyring_end", KEYRING_DATA, [[^{/keyring}$]], Trigger.ParseAndOmit, handle_keyring_data_end)
end

function OnPluginInstall()
    AardPrint("@Ykeystore installed : see '@Ckeystore help@Y' for more details.")

    if GetVariable("enabled") == "false" then
        ColourNote("yellow", "", "Warning: Plugin " .. GetPluginName ().. " is currently disabled.")
        check (EnablePlugin(GetPluginID (), false))
        return
    end -- they didn't enable us last time

    -- Load saved settings


    OnPluginEnable()
end

function OnPluginSaveState ()
    SetVariable ("enabled", tostring (GetPluginInfo (GetPluginID (), 17)))

    -- Save Settings
end

function OnPluginEnable()
	create_aliases()
	create_triggers()
end

function OnPluginDisable()
	Alias.destroy_all()
	Trigger.destroy_all()
end