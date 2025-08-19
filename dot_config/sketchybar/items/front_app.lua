local settings = require("settings")
local colors = require("colors")
local icon_map = require("helpers.icon_map")

return function()
	local front_app = sbar.add("item", "front_app", {
		position = "left",
		display = "active",
		icon = {
			font = {
				family = "sketchybar-app-font",
				size = settings.icon_font_size,
				style = "Regular",
			},
			padding_left = settings.paddings * 3,
		},
		label = {
			padding_right = settings.paddings * 5,
		},
		background = {
			drawing = true,
			border_width = settings.bracket_border_width,
			border_color = colors.bar_border_color,
			padding_left = 8,
		},
		blur_radius = 32,
	})

	front_app:subscribe("front_app_switched", function(env)
		local appname = env.INFO
		local icon = icon_map[appname] or ":default:"
		front_app:set({ icon = { string = icon }, label = { string = env.INFO } })
	end)
end
