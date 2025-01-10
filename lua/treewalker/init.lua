local movement = require("treewalker.movement")
local swap = require("treewalker.swap")
local options = require("treewalker.options")

local Treewalker = {}

-- Default setup() options
---@type Opts
Treewalker.opts = {
	highlight = true,
	highlight_duration = 250,
	highlight_group = "CursorLine",
}

-- This does not need to be called for Treewalker to work. The defaults are preinitialized and aim to be sane.
---@param opts Opts | nil
function Treewalker.setup(opts)
	if opts == nil then
		return
	end -- nil is valid, in which case we stick to the defaults

	local is_opts_valid, validation_errors = options.validate_opts(opts)
	if not is_opts_valid then
		return options.handle_opts_validation_errors(validation_errors)
	end

	Treewalker.opts = vim.tbl_deep_extend("force", Treewalker.opts, opts)
end

-- Makes sure the treesitter parser is available, otherwise makes a notification
---@param fn function
local function ensuring_parser(fn)
	return function()
		local ft = vim.bo.ft
		local ok = pcall(vim.treesitter.get_parser)
		if ok then
			fn()
		else
			vim.notify_once(
				string.format(
					"Treewalker.nvim: Missing parser for %s files! Treewalker won't work until one is installed.",
					ft
				),
				vim.log.levels.ERROR
			)
		end
	end
end

Treewalker.move_up = ensuring_parser(movement.move_up)
Treewalker.move_out = ensuring_parser(movement.move_out)
Treewalker.move_down = ensuring_parser(movement.move_down)
Treewalker.move_in = ensuring_parser(movement.move_in)
Treewalker.select_node = ensuring_parser(movement.select_node)
Treewalker.select_node_lines = ensuring_parser(movement.select_node_lines)
Treewalker.yank_node = ensuring_parser(movement.yank_node)
Treewalker.delete_node = ensuring_parser(movement.delete_node)
Treewalker.comment_node = ensuring_parser(movement.comment_node)

Treewalker.swap_up = ensuring_parser(swap.swap_up)
Treewalker.swap_down = ensuring_parser(swap.swap_down)
Treewalker.swap_right = ensuring_parser(swap.swap_right)
Treewalker.swap_left = ensuring_parser(swap.swap_left)

return Treewalker
