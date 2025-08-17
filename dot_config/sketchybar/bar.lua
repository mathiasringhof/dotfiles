local colors = require("colors")

sbar.bar({
	height = 32,
	color = colors.transparent,
	position = "top",
	topmost = "off",
	sticky = "on",
	padding_left = 6,
	padding_right = 6,
	corner_radius = 0,
	blur_radius = 32,
	notch_width = 170,
})
