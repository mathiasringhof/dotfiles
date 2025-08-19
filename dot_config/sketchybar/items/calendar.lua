local settings = require("settings")

return function()
	local cal = sbar.add("item", "calendar", {
		icon = {
			font = {
				size = settings.label_font_size,
			},
			padding_left = 16,
		},
		label = {
			align = "right",
			font = {
				size = settings.label_font_size,
			},
			padding_right = 18,
		},
		background = {
			drawing = false,
		},
		position = "right",
		update_freq = 15,
	})

	local function update()
		local date = os.date("%a. %d %b.")
		local time = os.date("%H:%M")
		cal:set({ icon = date, label = time })
	end

	cal:subscribe("routine", update)
	cal:subscribe("forced", update)

	return cal
end
