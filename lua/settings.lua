--[=[
	settings helper -- serializes/deserializes data into variables
	---------------------

	Usage:
	local settings = require "settings"

    function OnPluginInstall()
        my_setting = settings.load("my_setting", DEFAULT_VALUE)
    end

    function OnPluginSaveState()
        settings.save("my_setting", my_setting)
    end
]=]

local settings = {}

require "serialize"

---Load a setting saved in the mushclient variables
---@param name string # Name of the variable
---@param default any # Default value if we don't have a value saved already
---@return any # The stored value, if one exists, or the default otherwise
function settings.load(name, default)
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
function settings.save(name, value)
    SetVariable(name, serialize.save(name, value))
end

return settings