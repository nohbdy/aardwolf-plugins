--[=[
Usage:
```
local Trigger = require "trigger"
local my_trg = Trigger.new("myTriggerName", "myTriggerGroup", [[^\{roomchars\}$]], { omit_from_output = true }, function (name, line, wildcards)
	-- Code goes here...
end)
```
]=]
local trigger = {}

---@alias trigger_callback fun(name:string, line:string, wildcards:table, styles:table)

---Class representation of a MushClient Trigger
---@class Trigger
---@field enable fun() # Enable the trigger
---@field disable fun() # Disable the trigger
---@field destroy fun() # Delete the trigger

---Value to use when the trigger shouldn't be assigned to any particular group
---@type string
trigger.NoGroup = ""

---@class TriggerSettings
---@field enabled boolean Should the Trigger be enabled by default
---@field omit_from_output boolean Should the trigger cause matched output to be omitted
---@field ignore_case boolean Should the regex matching ignore differences in case
---@field keep_evaluating boolean Should the client keep evaluating other triggers if this is a match
---@field one_shot boolean Should this trigger be deleted after matching once
---@field sequence integer The sequence order that this trigger should be evaluated (lowest comes first)

--- Default trigger settings
---@type TriggerSettings
trigger.Default = {}

--- Trigger options for triggers designed to parse MUD output that we've requested but not display it to the user
---@type TriggerSettings
trigger.ParseAndOmit = { enabled = false, omit_from_output = true }

function trigger.NullCallback() end

require "check"

---@type string
local _CALLBACK_FUNC = "nohh_generic_trigger_handler"

---@type table<string, Trigger>
local trigger_list = {}

---@type table<string, trigger_callback>
local trigger_callback_map = {}

_G[_CALLBACK_FUNC] = function(name, line, wildcards, styles)
	local callback = trigger_callback_map[name]
	assert(callback ~= nil, string.format("Callback not found for trigger '%s'",name))

	callback(name, line, wildcards, styles)
end

---Create a new Trigger
---@param name string
---@param group string|nil
---@param match_txt string
---@param settings TriggerSettings|nil
---@param callback trigger_callback|nil
---@return Trigger
trigger.new = function(name, group, match_txt, settings, callback)
	assert((type(callback) == "function") or (type(callback) == "nil"), "callback must be a function or nil")
	assert(type(name) == "string", "name must be a string")
	group = group or trigger.NoGroup
	assert(type(group) == "string", "group must be a string or nil")
	assert(type(match_txt) == "string", "match_txt must be a string")
	settings = settings or trigger.Default
	assert(type(settings) == "table", "settings must be a table or nil")

	local callbackfunc = _CALLBACK_FUNC
	if callback == nil then
		callbackfunc = ""
	end

	check(AddTrigger(name, match_txt, "", trigger_flag.Enabled + trigger_flag.RegularExpression + trigger_flag.KeepEvaluating, custom_colour.NoChange, 0, "", callbackfunc))
	check(SetTriggerOption(name, "group", group))

	---@type Trigger
	local self = {}

	---@return string name
	self.get_name = function() return name end

	---@return string group
	self.get_group = function() return group end

	---@return string match
	self.get_match = function() return match_txt end

	---@return trigger_callback|nil callback
	self.get_callback = function() return callback end

	---Enable the trigger
	self.enable = function() check(EnableTrigger(name, true)) end

	---Disable the trigger
	self.disable = function() check(EnableTrigger(name, false)) end

	---Destroy the trigger
	self.destroy = function()
		check(DeleteTrigger(name))
		trigger_list[name] = nil
		trigger_callback_map[name] = nil
	end

	---Set whether or not the trigger is enabled
	---@param enabled boolean
	self.set_enabled = function(enabled)
		if enabled then
			self.enable()
		else
			self.disable()
		end
	end

	---Set whether or not the trigger should be omit the matched text from output
	---@param omit boolean
	self.set_omit_from_output = function(omit)
		if omit then
			check(SetTriggerOption(name, "omit_from_output", "y"))
		else
			check(SetTriggerOption(name, "omit_from_output", "n"))
		end
	end

	---Whether or not the trigger should ignore case when matching
	---@param ignore_case boolean
	self.set_ignore_case = function(ignore_case)
		if ignore_case then
			check(SetTriggerOption(name, "ignore_case", "y"))
		else
			check(SetTriggerOption(name, "ignore_case", "n"))
		end
	end

	---Whether or not the client should continue attempting to match the line if this trigger is a match
	---@param keep_evaluating boolean
	self.set_keep_evaluating = function(keep_evaluating)
		if keep_evaluating then
			check(SetTriggerOption(name, "keep_evaluating", "y"))
		else
			check(SetTriggerOption(name, "keep_evaluating", "n"))
		end
	end

	---Whether or not this trigger should be destroyed after matching a line
	---@param one_shot boolean
	self.set_one_shot = function(one_shot)
		if one_shot then
			check(SetTriggerOption(name, "one_shot", "y"))
		else
			check(SetTriggerOption(name, "one_shot", "n"))
		end
	end

	---Set the sequence value for the trigger
	---@param seq integer
	self.set_sequence = function(seq)
		assert((seq >= 0) and (seq <= 10000), "sequence must be between 0 and 10,000")
		check(SetTriggerOption(name, "sequence", seq))
	end

	-- Track trigger internally
	trigger_list[name] = self
	trigger_callback_map[name] = callback

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

---Destroy all triggers
trigger.destroy_all = function()
	for k,v in pairs(trigger_list) do
		DeleteTrigger(k)
	end

	trigger_list = {}
	trigger_callback_map = {}
end

local mt = {}
mt.__call = function(self,...)
	return trigger.new(select(1,...),select(2,...),select(3,...),select(4,...),select(5,...))
end

setmetatable(trigger, mt)
return trigger