--[[
AardPrint(str)  allows you to print strings using embedded aardwolf color codes
	@b - dark blue
	@B - bright blue
	@r - dark red
	@R - bright red
	@g - dark green
	@G - bright green
	@y - dark yellow
	@Y - bright yellow
	@c - dark cyan
	@C - bright cyan
	@m - dark magenta
	@M - bright magenta
	@w - white
	@W - bright white
	@D - grey
	@xN - xterm color N
]]

require "aardwolf_colors"

---allows you to print strings using embedded aardwolf color codes, adds a newline after the message
---@param fmt string
function AardPrint(fmt, ...)
	AnsiNote(ColoursToANSI(string.format(fmt, ...)))
end

---allows you to print strings using embedded aardwolf color codes without a newline
---@param fmt string
function AardTell(fmt, ...)
	local styles = ColoursToStyles(string.format(fmt, ...))
	for _, style in ipairs(styles) do
		-- Tell(string.format("('%s','%s','%s')", style.textcolour, style.backcolour, style.text))
		local textcolor = string.format("#%06x", style.textcolour)
		ColourTell(textcolor, "", style.text)
	end
end

local WARNING_FORECOLOR = "yellow"
local WARNING_BACKCOLOR = "blue"

function AardWarning(plugin, fmt, ...)
	ColourTell(WARNING_FORECOLOR, WARNING_BACKCOLOR, plugin)
	ColourTell(WARNING_FORECOLOR, WARNING_BACKCOLOR, " warning:")
	fmt = " @W"..fmt.."@w"
	AardPrint(fmt, ...)
end

local ERROR_FORECOLOR = "red"
local ERROR_BACKCOLOR = "blue"

function AardError(plugin, fmt, ...)
	ColourTell(ERROR_FORECOLOR, ERROR_BACKCOLOR, plugin)
	ColourTell(ERROR_FORECOLOR, ERROR_BACKCOLOR, " error:")
	fmt = " @W"..fmt.."@w"
	AardPrint(fmt, ...)
end

local INFO_FORECOLOR = "white"
local INFO_BACKCOLOR = ""

function AardInfo(plugin, fmt, ...)
	ColourTell(INFO_FORECOLOR, INFO_BACKCOLOR, plugin)
	ColourTell(INFO_FORECOLOR, INFO_BACKCOLOR, ":")
	fmt = " @w"..fmt.."@w"
	AardPrint(fmt, ...)
end

local DEBUG_FORECOLOR = "grey"
local DEBUG_BACKCOLOR = ""

function AardDebug(plugin, fmt, ...)
	ColourTell(DEBUG_FORECOLOR, DEBUG_BACKCOLOR, plugin)
	ColourTell(DEBUG_FORECOLOR, DEBUG_BACKCOLOR, ":")
	fmt = " @D"..fmt.."@w"
	AardPrint(fmt, ...)
end