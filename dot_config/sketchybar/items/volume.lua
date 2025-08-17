local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local volume_slider = sbar.add("slider", "volume_slider", 100, {
	position = "right",
	updates = true,
	label = { drawing = false },
	icon = { drawing = false },
	slider = {
		highlight_color = colors.highlight,
		width = 0,
		background = {
			height = 6,
			corner_radius = settings.corner_radius,
			color = colors.highlight_25,
		},
		knob = {
			string = "􀀁",
			drawing = false,
		},
	},
	background = {
		drawing = false,
	},
})

local volume_icon = sbar.add("item", "volume_icon", {
	position = "right",
	icon = {
		string = icons.volume._100,
		width = 0,
		align = "left",
		color = colors.white,
		font = {
			style = "Regular",
			size = settings.icon_font_size,
		},
	},
	label = {
		width = 25,
		align = "left",
		font = {
			style = "Regular",
			size = settings.label_font_size,
		},
	},
	background = {
		drawing = false,
	},
})

volume_slider:subscribe("mouse.clicked", function(env)
	sbar.exec("osascript -e 'set volume output volume " .. env["PERCENTAGE"] .. "'")
end)

volume_slider:subscribe("volume_change", function(env)
	local volume = tonumber(env.INFO)
	local icon = icons.volume._0
	if volume > 66 then
		icon = icons.volume._100
	elseif volume > 33 then
		icon = icons.volume._66
	elseif volume > 0 then
		icon = icons.volume._33
	end

	volume_icon:set({ label = icon })
	volume_slider:set({ slider = { percentage = volume } })
end)

local function animate_slider_width(width)
	sbar.animate("tanh", 30.0, function()
		volume_slider:set({ slider = { width = width } })
	end)
end

volume_icon:subscribe("mouse.clicked", function()
	if tonumber(volume_slider:query().slider.width) > 0 then
		animate_slider_width(0)
	else
		animate_slider_width(100)
	end
end)

return {
	volume_slider = volume_slider,
	volume_icon = volume_icon,
}
