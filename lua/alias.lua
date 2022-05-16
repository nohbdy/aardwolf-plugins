--[=[
	Alias class
	---------------------
	
	Usage:
	local Alias = require "alias"
	local my_alias = Alias("myAliasName", "myAliasGroup", [[^alias\s+help\s*$]], { ignore_case = true }, function (name, line, wildcards)
	end)
]=]

local alias = {}

---Constant used if we don't want to put the alias in any particular group
alias.NoGroup = ""

---Default Settings
alias.Default = {}

---@alias alias_callback_function fun(name: string, line: number, wildcards: table)

local _CALLBACK_FUNC = "nohh_generic_alias_handler"

require "check"

---@type table<string, Alias>
local alias_list = {}

---@type table<string, alias_callback_function>
local alias_callback_map = {}

_G[_CALLBACK_FUNC] = function(name, line, wildcards)
	local callback = alias_callback_map[name]
	assert(callback ~= nil, string.format("Callback not found for alias '%s'",name))

	callback(name, line, wildcards)
end

---@class Alias
---@field get_name fun():string # Get the Alias' name
---@field get_group fun():string # Get the Alias' group
---@field get_cmd fun():string # Get the Alias' regular expression/match
---@field enable fun() # Enable the alias
---@field disable fun() # Disable the alias
---@field destroy fun() # Destroy the alias
---@field set_enabled fun(enabled:boolean) # Set whether or not the alias should be enabled
---@field set_echo fun(echo:boolean) # Set whether or not the alias should be echoed when matched
---@field set_ignore_case fun(ignore_case:boolean) # Set whether or not the regex should ignore case
---@field set_keep_evaluating fun(keep_evaluating:boolean) # Set whether or not to keep evaluating after matching the alias
---@field set_sequence fun(sequence:number) # Set a sequence number for the alias

---Create a new Alias
---@param name string
---@param group string
---@param cmd string
---@param settings table
---@param callback alias_callback_function
---@return Alias
alias.new = function(name, group, cmd, settings, callback)
	assert(type(callback) == "function", "callback must be a function")
	assert(type(name) == "string", "name must be a string")
	local group = group or ""
	assert(type(group) == "string", "group must be a string or nil")
	assert(type(cmd) == "string", "command must be a string")
	local settings = settings or {}
	assert(type(settings) == "table", "settings must be a table or nil")
	
	check(AddAlias(name, cmd, "", alias_flag.Enabled + alias_flag.RegularExpression, _CALLBACK_FUNC))
	check(SetAliasOption(name, "group", group))

	---@type Alias
	local self = {}
	self.get_name = function() return name end
	self.get_group = function() return group end
	self.get_cmd = function() return cmd end
	self.get_callback = function() return callback end
	self.enable = function() check(EnableAlias(name, true)) end
	self.disable = function() check(EnableAlias(name, false)) end
	self.destroy = function()
		check(DeleteAlias(name))
		alias_list[name] = nil
		alias_callback_map[name] = nil
	end
	self.set_enabled = function(enabled)
		if enabled then
			self.enable()
		else
			self.disable()
		end
	end
	self.set_echo = function(echo)
		if echo then
			check(SetAliasOption(name, "echo_alias", "y"))
		else
			check(SetAliasOption(name, "echo_alias", "n"))
		end
	end
	self.set_ignore_case = function(ignore_case)
		if ignore_case then
			check(SetAliasOption(name, "ignore_case", "y"))
		else
			check(SetAliasOption(name, "ignore_case", "n"))
		end
	end
	self.set_keep_evaluating = function(keep_evaluating)
		if keep_evaluating then
			check(SetAliasOption(name, "keep_evaluating", "y"))
		else
			check(SetAliasOption(name, "keep_evaluating", "n"))
		end
	end
	self.set_sequence = function(seq)
		assert((seq >= 0) and (seq <= 10000), "sequence must be between 0 and 10,000")
		check(SetAliasOption(name, "sequence", seq))
	end

	-- Track alias internally
	alias_callback_map[name] = callback
	alias_list[name] = self
	
	-- Process settings
	for k,v in pairs(settings) do
		local fn = self["set_" .. k]
		if fn == nil then
			error("Unknown setting: " .. k, 2)
		else
			fn(v)
		end
	end

	return self
end

--- Delete all the aliases we've created
alias.destroy_all = function()
	for k,v in pairs(alias_list) do
		DeleteAlias(k)
	end
	
	alias_list = {}
	alias_callback_map = {}
end

local mt = {}
mt.__call = function(self,...)
	return alias.new(...)
end

setmetatable(alias, mt)
return alias