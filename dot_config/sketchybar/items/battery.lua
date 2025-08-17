local icons = require("icons")
local settings = require("settings")

local battery = sbar.add("item", "battery", {
	position = "right",
	icon = {
		drawing = false,
	},
	label = {
		drawing = true,
		align = "center",
		width = 40,
		font = {
			style = "Regular",
			size = settings.icon_font_size,
		},
	},
	update_freq = 120,
	background = {
		drawing = false,
		padding_left = 0,
		padding_right = 0,
	},
})

local function battery_update()
	sbar.exec("pmset -g batt", function(batt_info)
		local icon = "!"
		local is_charging = string.find(batt_info, "AC Power") ~= nil

		local found, _, charge = batt_info:find("(%d+)%%")
		if found then
			charge = tonumber(charge)
		end

		if found and charge > 90 then
			icon = is_charging and icons.battery_charging._100 or icons.battery._100
		elseif found and charge > 80 then
			icon = is_charging and icons.battery_charging._90 or icons.battery._90
		elseif found and charge > 70 then
			icon = is_charging and icons.battery_charging._80 or icons.battery._80
		elseif found and charge > 60 then
			icon = is_charging and icons.battery_charging._70 or icons.battery._70
		elseif found and charge > 50 then
			icon = is_charging and icons.battery_charging._60 or icons.battery._60
		elseif found and charge > 40 then
			icon = is_charging and icons.battery_charging._50 or icons.battery._50
		elseif found and charge > 30 then
			icon = is_charging and icons.battery_charging._40 or icons.battery._40
		elseif found and charge > 20 then
			icon = is_charging and icons.battery_charging._30 or icons.battery._30
		elseif found and charge > 10 then
			icon = is_charging and icons.battery_charging._20 or icons.battery._20
		elseif found and charge > 90 then
			icon = is_charging and icons.battery_charging._10 or icons.battery._10
		else
			icon = is_charging and icons.battery_charging._0 or icons.battery._0
		end

		battery:set({ label = icon })
	end)
end

battery:subscribe({ "routine", "power_source_change", "system_woke" }, battery_update)

return battery
