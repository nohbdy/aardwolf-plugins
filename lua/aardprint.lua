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
	$C - default
]]

require "aardwolf_colors"

---allows you to print strings using embedded aardwolf color codes
---@param fmt string
function AardPrint(fmt, ...)
	AnsiNote(ColoursToANSI(string.format(fmt, ...)))
end