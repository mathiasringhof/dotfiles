local settings = require("settings")
local colors = require("colors")

sbar.default({
	updates = "when_shown",
	icon = {
		font = {
			family = settings.font,
			style = "Regular",
			size = settings.icon_font_size,
		},
		color = colors.white,
		padding_left = settings.paddings,
		padding_right = settings.paddings,
	},
	label = {
		font = {
			family = settings.font,
			style = "Bold",
			size = settings.label_font_size,
		},
		color = colors.white,
		padding_left = settings.paddings,
		padding_right = settings.paddings,
	},
	background = {
		height = settings.bar_height - 8,
		corner_radius = settings.corner_radius,
		border_width = 0,
		color = colors.bar_color,
		padding_left = settings.paddings,
		padding_right = settings.paddings,
	},
	popup = {
		background = {
			border_width = 2,
			corner_radius = 9,
			border_color = colors.popup_border_color,
			color = colors.popup_background_color,
			shadow = { drawing = true },
		},
		blur_radius = 20,
	},
	padding_left = settings.paddings,
	padding_right = settings.paddings,
})
