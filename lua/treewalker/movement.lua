local operations = require("treewalker.operations")
local targets = require("treewalker.targets")
local nodes = require("treewalker.nodes")
local augment= require("treewalker.augment")
local M = {}

---@return nil
function M.move_out()
	local target, row, line = targets.out()
	if target and row and line then
		-- util.log("no out candidate")
		operations.jump(row, target)
		return
	end
end

---@return nil
function M.move_in()
	local target, row, line = targets.inn()

	if target and row and line then
		--util.log("no in candidate")
		operations.jump(row, target)
	end
end

---@return nil
function M.move_up()
	local target, row, line = targets.up()

	if target and row and line then
		--util.log("no up candidate")
		operations.jump(row, target)
	end
end

---@return nil
function M.move_down()
	-- Before, when there is no next sibling, the function did nothing
	-- I modified this s.t. it moves to the end of the node in that case
	-- because that feels more natural to me

	-- Extract current position to check whether 
	local cursor_pos_before = vim.api.nvim_win_get_cursor(0)
	vim.notify("Cursor position before: " .. vim.inspect(cursor_pos_before))
	local target, row, line = targets.down()

	if target and row and line then
		--util.log("no down candidate")
		operations.jump(row, target)
	end

	local cursor_pos_after = vim.api.nvim_win_get_cursor(0)
	vim.notify("Cursor position after: " .. vim.inspect(cursor_pos_after))

	-- If the cursor didn't move, we're at the last node in the file
	-- So we need to move the cursor to the end of the node
	if cursor_pos_before[1] == cursor_pos_after[1] then
		local current = nodes.get_row_current()
		local range = nodes.range(current)
		local end_row = range[3] + 1
		vim.api.nvim_win_set_cursor(0, { end_row, 0 })
		vim.cmd("normal! ^") -- Jump to start of line
	end
end

---@return nil
function M.select_node()
	local current = nodes.get_row_current()
	if current then
		operations.node_action("normal! v")
	end
end

---@return nil
function M.select_node_lines()
	local current = nodes.get_row_current()
	if current then
		operations.node_action("normal! V")
	end
end

---@return nil
function M.comment_node()
	local current = nodes.get_row_current()

  local current_augments = augment.get_node_augments(current)
	if current then
		operations.node_action("normal gc")
	end
end

---@return nil
function M.yank_node()
	local current = nodes.get_row_current()
	if current then
		operations.node_action("normal! y")
	end
end

---@return nil
function M.delete_node()
	local current = nodes.get_row_current()
	if current then
		operations.node_action("normal! d")
	end
end

return M
