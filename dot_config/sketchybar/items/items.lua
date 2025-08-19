local add_spaces = require("items.aerospace_spaces")
local add_front_app = require("items.front_app")

local add_calendar = require("items.calendar")
local add_battery = require("items.battery")
local add_volume = require("items.volume")
local add_right_bracket = require("items.right_bracket")

-- Left side, spaces are async
add_spaces(function()
	add_front_app()
end)

-- Right side
local calendar = add_calendar()
local battery = add_battery()
local volume = add_volume()
local item_names = { calendar.name, battery.name, volume.volume_slider.name, volume.volume_icon.name }
add_right_bracket(item_names)
