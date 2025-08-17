local colors = require("colors")
local settings = require("settings")
local battery = require("items.battery")
local volume = require("items.volume")

local item_names = { battery.name, volume.volume_slider.name, volume.volume_icon.name }

return sbar.add("bracket", item_names, {
	position = "right",
	blur_radius = 32,
	background = {
		drawing = "on",
		color = colors.bar_color,
		border_color = colors.bar_border_color,
		height = settings.bar_height - 6,
		corner_radius = settings.corner_radius,
	},
})
