local function tw()
	-- local util = require "treewalker.util"
	-- return util.R('treewalker')
	return require("treewalker")
end

local subcommands = {
	Up = function()
		tw().move_up()
	end,

	Left = function()
		tw().move_out()
	end,

	Down = function()
		tw().move_down()
	end,

	Right = function()
		tw().move_in()
	end,

	Select = function()
		tw().select_node()
	end,

	SwapUp = function()
		tw().swap_up()
	end,

	SwapDown = function()
		tw().swap_down()
	end,

	SwapLeft = function()
		tw().swap_left()
	end,

	SwapRight = function()
		tw().swap_right()
	end,
}

local command_opts = {
	nargs = 1,
	complete = function(ArgLead)
		return vim.tbl_filter(function(cmd)
			return cmd:match("^" .. ArgLead)
		end, vim.tbl_keys(subcommands))
	end,
}

local function treewalker(opts)
	local subcommand = opts.fargs[1]
	if subcommands[subcommand] then
		subcommands[subcommand](vim.list_slice(opts.fargs, 2))
	else
		print("Unknown subcommand: " .. subcommand)
	end
end

vim.api.nvim_create_user_command("Treewalker", treewalker, command_opts)
