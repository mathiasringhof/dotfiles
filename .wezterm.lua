local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.font_size = 15
config.color_scheme = "Tokyo Night"
config.window_background_opacity = 0.95
config.tab_bar_at_bottom = false
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

config.keys = {
	-- we already have CMD--
	{
		key = "-",
		mods = "CTRL",
		action = wezterm.action.DisableDefaultAssignment,
	},
}

config.audible_bell = "Disabled"
config.visual_bell = {
	fade_in_duration_ms = 75,
	fade_out_duration_ms = 75,
	target = "CursorColor",
}

-- Finally, return the configuration to wezterm:
return config
