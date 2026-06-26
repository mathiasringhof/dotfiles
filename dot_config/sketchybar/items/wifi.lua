local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

return function()
	local wifi = sbar.add("item", "wifi", {
		position = "right",
		icon = {
			drawing = false,
		},
		label = {
			drawing = true,
			align = "center",
			width = 34,
			font = {
				style = "Regular",
				size = settings.icon_font_size,
			},
		},
		update_freq = 30,
		background = {
			drawing = false,
			padding_left = 0,
			padding_right = 0,
		},
	})

	-- macOS 14.4+ removed the `airport` binary and `networksetup -getairportnetwork`
	-- no longer reports the SSID. We read association + SSID from `ipconfig getsummary`
	-- and signal strength (RSSI) from `wdutil info`, which needs a passwordless
	-- sudoers rule (see /etc/sudoers.d/sketchybar-wdutil).
	local wifi_script = [=[
WIFI_DEVICE="$(route -n get default 2>/dev/null | awk '/interface:/{print $2; exit}')"
if [ -z "$WIFI_DEVICE" ]; then
	WIFI_DEVICE="$(networksetup -listallhardwareports 2>/dev/null | awk '/Hardware Port: Wi-Fi|Hardware Port: AirPort/{getline; print $2; exit}')"
fi
if [ -z "$WIFI_DEVICE" ]; then
	WIFI_DEVICE="en0"
fi

POWER="$(networksetup -getairportpower "$WIFI_DEVICE" 2>/dev/null | awk '{print $NF}')"
if [ "$POWER" = "Off" ]; then
	printf 'status=off\nssid=\nrssi=0\nhotspot=0\ndevice=%s\n' "$WIFI_DEVICE"
	exit 0
fi

SUMMARY="$(ipconfig getsummary "$WIFI_DEVICE" 2>/dev/null)"
LINK="$(printf '%s\n' "$SUMMARY" | awk -F ' : ' '/ LinkStatusActive / {print $2; exit}')"
SSID="$(printf '%s\n' "$SUMMARY" | awk -F ' SSID : ' '/ SSID : / {print $2; exit}')"

# RSSI requires root on modern macOS; sudoers rule makes this passwordless.
RSSI="$(sudo -n /usr/bin/wdutil info 2>/dev/null | awk -F ': ' '/ RSSI /{gsub(/[^-0-9]/,"",$2); print $2; exit}')"

GATEWAY="$(route -n get default 2>/dev/null | awk '/gateway:/{print $2; exit}')"
CONSTRAINED=0
if ifconfig "$WIFI_DEVICE" 2>/dev/null | grep -q ' constrained'; then
	CONSTRAINED=1
fi

HOTSPOT=0
if [ "$CONSTRAINED" = "1" ] || printf '%s' "$GATEWAY" | grep -Eq '^(172\.20\.10\.1|192\.0\.0\.1)$'; then
	HOTSPOT=1
fi
# Fallback for phones that do not expose a constrained/hotspot flag.
if [ "$HOTSPOT" = "0" ] && printf '%s' "$SSID" | grep -Eiq '(iphone|ipad|android|pixel|galaxy|samsung|phone|hotspot)'; then
	HOTSPOT=1
fi

if [ "$LINK" = "TRUE" ]; then
	printf 'status=connected\nssid=%s\nrssi=%s\nhotspot=%s\ndevice=%s\ngateway=%s\nconstrained=%s\n' "$SSID" "${RSSI:-0}" "$HOTSPOT" "$WIFI_DEVICE" "$GATEWAY" "$CONSTRAINED"
else
	printf 'status=disconnected\nssid=\nrssi=0\nhotspot=0\ndevice=%s\ngateway=%s\nconstrained=%s\n' "$WIFI_DEVICE" "$GATEWAY" "$CONSTRAINED"
fi
]=]

	local function parse_wifi_info(output)
		local info = {}
		for line in output:gmatch("[^\r\n]+") do
			local key, value = line:match("^([^=]+)=(.*)$")
			if key then
				info[key] = value
			end
		end
		return info
	end

	local function strength_icon(rssi)
		if rssi >= -55 then
			return icons.wifi._4, colors.icon_color
		elseif rssi >= -67 then
			return icons.wifi._3, colors.icon_color
		elseif rssi >= -75 then
			return icons.wifi._2, colors.icon_color
		else
			return icons.wifi._1, colors.icon_color
		end
	end

	local function wifi_update()
		sbar.exec(wifi_script, function(output)
			local info = parse_wifi_info(output or "")
			local status = info.status or "missing"
			local label = icons.wifi.off
			local color = colors.icon_color_inactive
			local width = 30

			if status == "connected" then
				local rssi = tonumber(info.rssi)
				-- RSSI of 0 means wdutil could not read it (sudoers not set up):
				-- treat as connected-but-unknown and show full strength.
				if not rssi or rssi == 0 then
					label, color = icons.wifi._4, colors.icon_color
				else
					label, color = strength_icon(rssi)
				end

				if info.hotspot == "1" then
					label = icons.phone
					width = 30
				end
			elseif status == "disconnected" then
				label = icons.wifi._0
			else
				label = icons.wifi.off
			end

			wifi:set({
				label = {
					string = label,
					color = color,
					width = width,
				},
			})
		end)
	end

	wifi_update()
	wifi:subscribe({ "routine", "wifi_change", "system_woke" }, wifi_update)
	wifi:subscribe("mouse.clicked", function()
		sbar.exec("open 'x-apple.systempreferences:com.apple.wifi-settings-extension'")
	end)

	return wifi
end
