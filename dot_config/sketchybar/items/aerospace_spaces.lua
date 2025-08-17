local colors = require("colors")
local settings = require("settings")

local COLOR_SPACE_LABEL = colors.label_color_muted
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
	local space = sbar.add("item", "space." .. workspace_id, {
		position = "left",
		background = {
			drawing = "off",
		},
		icon = {
			padding_left = 8,
			padding_right = 0,
		},
		label = {
			padding_left = 0,
			padding_right = 8,
			string = workspace_id,
			color = label_color,
		},
	})
	space.id = workspace_id
	return space
end

local function generate_workspacechange_function(workspace, is_focused)
	local prev_in_focus = is_focused
	return function(env)
		if env.FOCUSED_WORKSPACE == workspace.id then
			prev_in_focus = true
			workspace:set({
				label = {
					color = COLOR_SPACE_FOCUSED,
				},
			})
		elseif prev_in_focus then
			prev_in_focus = false
			workspace:set({
				label = {
					color = COLOR_SPACE_LABEL,
				},
			})
		end
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
		},
	})
end

local function generate_modechange_function(bracket)
	return function(env)
		local highlight_border = env.MODE == "move"
		if highlight_border then
			sbar.animate("linear", 8.0, function()
				bracket:set({ background = { border_width = 3, border_color = colors.get_color("orange", 100) } })
				bracket:set({ background = { border_width = 1, border_color = colors.get_color("black", 100) } })
				bracket:set({ background = { border_width = 3, border_color = colors.get_color("orange", 100) } })
				bracket:set({ background = { border_width = 1, border_color = colors.get_color("black", 100) } })
				bracket:set({ background = { border_width = 3, border_color = colors.get_color("orange", 100) } })
			end)
		else
			sbar.animate("tanh", 12.0, function()
				bracket:set({ background = { border_width = 1, border_color = colors.get_color("black", 100) } })
			end)
		end
	end
end

sbar.exec(
	'aerospace list-workspaces --format "%{workspace}:%{workspace-is-focused}" --all',
	function(list_workspaces_output)
		local spaces = {}
		for workspace_id, is_focused in parse_listworkspaces_output(list_workspaces_output) do
			local space = add_workspace_to_bar(workspace_id, is_focused)
			table.insert(spaces, space)
			space:subscribe("aerospace_workspace_change", generate_workspacechange_function(space, is_focused))
		end
		local spaces_bracket = add_spaces_bracket(spaces)
		spaces_bracket:subscribe("aerospace_mode_change", generate_modechange_function(spaces_bracket))
	end
)
