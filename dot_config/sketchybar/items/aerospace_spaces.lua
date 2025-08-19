local colors = require("colors")
local settings = require("settings")
local icon_map = require("helpers.icon_map")
local blink_border = require("helpers.blink_border")

local COLOR_SPACE_LABEL = colors.label_color_muted
local COLOR_SPACE_ICON = colors.label_color
local COLOR_SPACE_FOCUSED = colors.highlight

local function parse_listworkspaces_output(output)
	local lines = output:gmatch("([^:\n]+):([^\n]+)")

	return function()
		local key, value = lines()
		if key then
			return key, (value == "true") -- Convert to boolean
		end
		return nil -- End iteration
	end
end

local function add_workspace_to_bar(workspace_id, is_focused)
	local label_color = is_focused and COLOR_SPACE_FOCUSED or COLOR_SPACE_LABEL
	local icon_color = is_focused and COLOR_SPACE_FOCUSED or COLOR_SPACE_ICON
	local space = sbar.add("item", "space." .. workspace_id, {
		position = "left",
		background = {
			drawing = "off",
		},
		icon = {
			padding_left = 4,
			padding_right = 0,
			color = icon_color,
			font = {
				size = settings.label_font_size,
				style = "bold",
			},
			string = workspace_id,
		},
		label = {
			padding_left = 8,
			padding_right = 4,
			color = label_color,
			font = {
				family = "sketchybar-app-font",
				style = "regular",
				size = settings.icon_font_size,
			},
		},
	})
	space.id = workspace_id
	return space
end

local function parse_iconlist_by_workspace(output)
	local workspace_apps = {}

	for app, workspace in output:gmatch("([^:\n]+):([^\n]+)") do
		workspace_apps[workspace] = workspace_apps[workspace] or {}

		-- Simple deduplication check
		local already_exists = false
		for _, existing_app in ipairs(workspace_apps[workspace]) do
			if existing_app == app then
				already_exists = true
				break
			end
		end

		if not already_exists then
			table.insert(workspace_apps[workspace], app)
		end
	end

	-- Convert to icon strings
	local result = {}
	for workspace, apps in pairs(workspace_apps) do
		local icons = {}
		for _, app in ipairs(apps) do
			table.insert(icons, icon_map[app] or ":default:")
		end
		result[workspace] = table.concat(icons, "")
	end

	return result
end

local function rebuild_icons(spaces)
	sbar.exec("aerospace list-windows --all --format %{app-name}:%{workspace}", function(window_list)
		local icon_lists = parse_iconlist_by_workspace(window_list)
		for workspace_id, workspace in pairs(spaces) do
			local icon_list = icon_lists[workspace_id] or "-"
			sbar.animate("tanh", 24.0, function()
				workspace:set({
					label = {
						string = icon_list,
					},
				})
			end)
		end
	end)
end

local function generate_workspace_change_function(workspace, is_focused)
	local prev_in_focus = is_focused
	return function(env)
		if env.FOCUSED_WORKSPACE == workspace.id then
			prev_in_focus = true
			workspace:set({
				icon = {
					color = COLOR_SPACE_FOCUSED,
				},
				label = {
					color = COLOR_SPACE_FOCUSED,
				},
			})
		elseif prev_in_focus then
			prev_in_focus = false
			workspace:set({
				icon = {
					color = COLOR_SPACE_ICON,
				},
				label = {
					color = COLOR_SPACE_LABEL,
				},
			})
		end
	end
end

local function generate_workspace_click_function(workspace)
	return function(_)
		sbar.exec("aerospace workspace " .. workspace.id)
	end
end

local function add_spaces_bracket(spaces)
	local space_names = {}
	for _, space in pairs(spaces) do
		table.insert(space_names, space.name)
	end
	return sbar.add("bracket", space_names, {
		position = "left",
		blur_radius = 32,
		background = {
			drawing = true,
			color = colors.bar_color,
			border_color = colors.bar_border_color,
			height = settings.bar_height - 6,
			corner_radius = settings.corner_radius,
			border_width = settings.bracket_border_width,
		},
	})
end

local function generate_modechange_function(bracket)
	local highlight_borderwidth = settings.bracket_border_width + 1
	return function(env)
		local is_highlight_border = env.MODE == "move"
		if is_highlight_border then
			blink_border(
				bracket,
				highlight_borderwidth,
				colors.get_color("orange", 100),
				settings.bracket_border_width,
				colors.bar_border_color
			)
		else
			sbar.animate("tanh", 12.0, function()
				bracket:set({
					background = {
						border_width = settings.bracket_border_width,
						border_color = colors.bar_border_color,
					},
				})
			end)
		end
	end
end

local function generate_focuschange_function(spaces)
	return function(_)
		rebuild_icons(spaces)
	end
end

return function(callback)
	sbar.exec(
		'aerospace list-workspaces --format "%{workspace}:%{workspace-is-focused}" --all',
		function(list_workspaces_output)
			local spaces = {}
			for workspace_id, is_focused in parse_listworkspaces_output(list_workspaces_output) do
				local space = add_workspace_to_bar(workspace_id, is_focused)
				spaces[workspace_id] = space
				space:subscribe("aerospace_workspace_change", generate_workspace_change_function(space, is_focused))
				space:subscribe("mouse.clicked", generate_workspace_click_function(space))
			end
			local spaces_bracket = add_spaces_bracket(spaces)
			spaces_bracket:subscribe("aerospace_mode_change", generate_modechange_function(spaces_bracket))
			spaces_bracket:subscribe("aerospace_focus_change", generate_focuschange_function(spaces))
			rebuild_icons(spaces)
			callback()
		end
	)
end
