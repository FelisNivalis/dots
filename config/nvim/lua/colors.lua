-- nvim-colorizer.lua
--- Determine whether to use black or white text
-- Ref: https://stackoverflow.com/a/1855903/837964
-- https://stackoverflow.com/questions/596216/formula-to-determine-brightness-of-rgb-color
local function color_is_bright(r, g, b)
	-- Counting the perceptive luminance - human eye favors green color
	local luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255
	if luminance > 0.5 then
		return true -- Bright colors, black font
	else
		return false -- Dark colors, white font
	end
end
-- https://gist.github.com/mjackson/5311256
local function hue_to_rgb(p, q, t)
	if t < 0 then t = t + 1 end
	if t > 1 then t = t - 1 end
	if t < 1 / 6 then return p + (q - p) * 6 * t end
	if t < 1 / 2 then return q end
	if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
	return p
end
local bit = require('bit')
local function hsl_to_rgb(str)
	local h, s, l, match_end = str:match("^hsl%(%s*(%d+)%s*,%s*(%d+)%%%s*,%s*(%d+)%%%s*%)()")
	h = h / 360
	s = s / 100
	l = l / 100
	if h > 1 or s > 1 or l > 1 then return end
	if s == 0 then
		local r = l * 255
		return r, r, r
	end
	local q
	if l < 0.5 then
		q = l * (1 + s)
	else
		q = l + s - l * s
	end
	local p = 2 * l - q
	return '#' ..
		bit.tohex(255 * hue_to_rgb(p, q, h + 1 / 3)):sub(7, 8) ..
		bit.tohex(255 * hue_to_rgb(p, q, h)):sub(7, 8) ..
		bit.tohex(255 * hue_to_rgb(p, q, h - 1 / 3)):sub(7, 8)
end
local grey = {
	white = hsl_to_rgb('hsl(  5, 2%,95%)'),
	grey1 = hsl_to_rgb('hsl(  5, 2%,80%)'),
	grey2 = hsl_to_rgb('hsl(  5, 2%,65%)'),
	grey3 = hsl_to_rgb('hsl(  5, 2%,50%)'),
	grey4 = hsl_to_rgb('hsl(  5, 2%,35%)'),
	grey5 = hsl_to_rgb('hsl(  5, 2%,20%)'),
	black = hsl_to_rgb('hsl(  5, 2%, 5%)'),
}

local scheme1 = {
	orange   = hsl_to_rgb('hsl( 23,45%,70%)'),
	yellow   = hsl_to_rgb('hsl( 52,45%,67%)'),
	straw    = hsl_to_rgb('hsl( 85,25%,66%)'),
	green    = hsl_to_rgb('hsl(135,32%,62%)'),
	cyan     = hsl_to_rgb('hsl(164,31%,62%)'),
	blue     = hsl_to_rgb('hsl(205,35%,75%)'),
	purple   = hsl_to_rgb('hsl(230,35%,70%)'),
	magenta  = hsl_to_rgb('hsl(268,32%,75%)'),
	lavender = hsl_to_rgb('hsl(285,25%,70%)'),
	pink     = hsl_to_rgb('hsl(315,25%,70%)'),
	salmon   = hsl_to_rgb('hsl(342,32%,78%)'),
	red      = hsl_to_rgb('hsl(  0,25%,60%)'),
}


local scheme2 = {
	orange   = hsl_to_rgb('hsl( 23,75%,60%)'),
	yellow   = hsl_to_rgb('hsl( 52,78%,62%)'),
	straw    = hsl_to_rgb('hsl( 85,55%,56%)'),
	green    = hsl_to_rgb('hsl(135,62%,52%)'),
	cyan     = hsl_to_rgb('hsl(164,71%,52%)'),
	blue     = hsl_to_rgb('hsl(205,75%,55%)'),
	purple   = hsl_to_rgb('hsl(230,75%,66%)'),
	magenta  = hsl_to_rgb('hsl(268,68%,75%)'),
	lavender = hsl_to_rgb('hsl(285,44%,63%)'),
	pink     = hsl_to_rgb('hsl(315,72%,76%)'),
	salmon   = hsl_to_rgb('hsl(342,68%,68%)'),
	red      = hsl_to_rgb('hsl(  0,53%,61%)'),
}


local scheme3 = {
	orange   = hsl_to_rgb('hsl( 23,66%,48%)'),
	yellow   = hsl_to_rgb('hsl( 52,99%,30%)'),
	straw    = hsl_to_rgb('hsl( 85,68%,34%)'),
	green    = hsl_to_rgb('hsl(135,72%,40%)'),
	cyan     = hsl_to_rgb('hsl(164,81%,37%)'),
	blue     = hsl_to_rgb('hsl(205,86%,44%)'),
	purple   = hsl_to_rgb('hsl(230,78%,57%)'),
	magenta  = hsl_to_rgb('hsl(268,85%,54%)'),
	lavender = hsl_to_rgb('hsl(285,69%,53%)'),
	pink     = hsl_to_rgb('hsl(315,68%,57%)'),
	salmon   = hsl_to_rgb('hsl(342,35%,54%)'),
	red      = hsl_to_rgb('hsl(  0,42%,50%)'),
}

local scheme = {}
for k, _ in pairs(scheme1) do
	scheme[k .. '1'] = scheme1[k]
	scheme[k] = scheme1[k]
	scheme[k .. '2'] = scheme2[k]
	scheme[k .. '3'] = scheme3[k]
end
for k, v in pairs(grey) do
	scheme[k] = v
end
scheme["background"] = scheme["black"]
scheme["foreground"] = scheme["salmon1"]
scheme["selectionBackground"] = scheme["white"]
scheme["cursorColor"] = scheme["white"]
local wt_scheme = {}
for _, name in ipairs({ "background", "foreground", "selectionBackground", "cursorColor", "black" }) do
	wt_scheme[name] = scheme[name]
end
for _, name in ipairs({ "blue", "cyan", "green", "purple", "yellow", "red" }) do
	wt_scheme[name] = scheme[name .. '1']
	wt_scheme['bright' .. name:sub(1, 1):upper() .. name:sub(2)] = scheme[name .. '2']
end
wt_scheme["white"] = scheme["grey1"]
wt_scheme["brightWhite"] = scheme["white"]
wt_scheme["brightBlack"] = scheme["grey4"]
wt_scheme["red"] = scheme["pink1"]
wt_scheme["brightRed"] = scheme["pink2"]
wt_scheme["brightPurple"] = scheme["magenta2"]
-- scheme = {
-- 	["background"] = "#0D0A0D",
-- 	["black"] = "#000000",
-- 	["blue"] = "#699BBF",
-- 	["brightBlack"] = "#666666",
-- 	["brightBlue"] = "#56B3F5",
-- 	["brightCyan"] = "#5BC7AA",
-- 	["brightGreen"] = "#1FC231",
-- 	["brightPurple"] = "#AD82E0",
-- 	["brightRed"] = "#FA84A8",
-- 	["brightWhite"] = "#FAFAFA",
-- 	["brightYellow"] = "#D6BA06",
-- 	["cursorColor"] = "#FFFFFF",
-- 	["cyan"] = "#5D9E8D",
-- 	["foreground"] = "#F2C2F2",
-- 	["green"] = "#429E59",
-- 	["name"] = "Spring Night",
-- 	["purple"] = "#9E82BF",
-- 	["red"] = "#C7738C",
-- 	["selectionBackground"] = "#FFFFFF",
-- 	["white"] = "#CCCCCC",
-- 	["yellow"] = "#AB9E4D",
-- 	["orange"] = "#E06D2B",
-- }
return {
	scheme = scheme,
	wt_scheme = wt_scheme,
	color_is_bright = color_is_bright,
}
