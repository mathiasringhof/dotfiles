local colors = require("colors")
local settings = require("settings")

return function(item_names)
	return sbar.add("bracket", item_names, {
		position = "right",
		blur_radius = 32,
		background = {
			drawing = true,
			color = colors.bar_color,
			border_color = colors.bar_border_color,
			border_width = settings.bracket_border_width,
			height = settings.bar_height - 6,
			corner_radius = settings.corner_radius,
		},
	})
end
