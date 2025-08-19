return function(item, blink_width, blink_color, border_width, border_color)
	sbar.animate("linear", 6.0, function()
		item:set({
			background = {
				border_width = blink_width,
				border_color = blink_color,
			},
		})
		item:set({
			background = {
				border_width = border_width,
				border_color = border_color,
			},
		})
		item:set({
			background = {
				border_width = blink_width,
				border_color = blink_color,
			},
		})
		item:set({
			background = {
				border_width = border_width,
				border_color = border_color,
			},
		})
		item:set({
			background = {
				border_width = blink_width,
				border_color = blink_color,
			},
		})
	end)
end
