local Trigger = require "trigger"
local Alias = require "alias"

local kill = require "kill_lib"

local function print_kill(name, reason)
    ColourTell("white", "blue", "Killed:")
    ColourTell("yellow", "black", " " .. name)
    ColourNote("grey", "black", " (" .. reason .. ")")
end

--- Reload this plugin via an alias
local function reload(name, line, wildcards)
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
	end
end

function OnPluginInstall ()
    OnPluginEnable()
end

function OnPluginEnable()
    kill.init(print_kill, true)

    Alias("mobkillreload", Alias.NoGroup, [[^mobkill reload$]], { sequence = 1 }, reload)
end

function OnPluginDisable()
    Trigger.destroy_all()
    Alias.destroy_all()
end