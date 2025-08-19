-- Tokyo Night: https://github.com/tokyo-night/tokyo-night-vscode-theme
local TOKYO_NIGHT = {
	blue = "#7aa2f7",
	teal = "#1abc9c",
	cyan = "#7dcfff",
	grey = "#414868",
	green = "#9fe044",
	yellow = "#faba4a",
	orange = "#ff9e64",
	red = "#f7768e",
	purple = "#9d7cd8",
	maroon = "#914c54",
	black = "#24283b",
	trueblack = "#000000",
	white = "#c0caf5",
}

-- Dracula Refined https://github.com/mathcale/dracula-theme-refined
local DRACULA = {
	blue = "#6272A4",
	teal = "#69FF94",
	cyan = "#8BE9FD",
	grey = "#44475A",
	green = "#50FA7B",
	yellow = "#F1FA8C",
	orange = "#FFB86C",
	red = "#FF5555",
	purple = "#BD93F9",
	maroon = "#FF79C6",
	black = "#282A36",
	trueblack = "#1c1c1c",
	white = "#F8F8F2",
}

-- Rose Pine https://rosepinetheme.com/palette/ingredients/
local ROSE_PINE = {
	blue = "#7283CF",
	teal = "#419BBE",
	cyan = "#9ccfd8",
	grey = "#524f67",
	green = "#B4D99C",
	yellow = "#f6c177",
	orange = "#d7827e",
	red = "#eb6f92",
	purple = "#c4a7e7",
	maroon = "#b4637a",
	black = "#26233a",
	trueblack = "#000000",
	white = "#e0def4",
}

-- Catppuccin Mocha https://github.com/catppuccin/catppuccin#-palette
local CATPPUCCIN = {
	blue = "#89b4fa",
	teal = "#94e2d5",
	cyan = "#89dceb",
	grey = "#585b70",
	green = "#a6e3a1",
	yellow = "#f9e2af",
	orange = "#fab387",
	red = "#f38ba8",
	purple = "#cba6f7",
	maroon = "#eba0ac",
	black = "#1e1e2e",
	trueblack = "#000000",
	white = "#cdd6f4",
}

local CURRENT_THEME = DRACULA

local function percent_to_hex(percentage)
	local decimal = math.floor((percentage * 255) / 100)
	return string.format("%02X", decimal)
end

local function get_color(color_name, opacity)
	opacity = opacity or 100

	local color = CURRENT_THEME[color_name]
	if not color then
		error("Invalid color name: " .. color_name)
	end

	local hex_opacity = percent_to_hex(opacity)
	local color_hex = color:sub(2) -- Remove the # prefix

	return "0x" .. hex_opacity .. color_hex
end

return {
	get_color = get_color,

	bar_color = get_color("black", 50),
	bar_border_color = get_color("grey", 75),
	highlight = get_color("cyan"),
	highlight_75 = get_color("cyan", 75),
	highlight_50 = get_color("cyan", 50),
	highlight_25 = get_color("cyan", 25),
	highlight_10 = get_color("cyan", 10),
	icon_color = get_color("white"),
	icon_color_inactive = get_color("white", 25),
	label_color = get_color("white", 100),
	label_color_muted = get_color("white", 75),
	label_color_negative = get_color("black"),
	popup_background_color = get_color("black", 75),
	popup_border_color = get_color("black", 0),
	shadow_color = get_color("black"),
	transparent = get_color("black", 0),
}
