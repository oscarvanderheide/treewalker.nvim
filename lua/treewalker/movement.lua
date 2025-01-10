local operations = require("treewalker.operations")
local targets = require("treewalker.targets")
local nodes = require("treewalker.nodes")
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
	local target, row, line = targets.down()

	if target and row and line then
		--util.log("no down candidate")
		operations.jump(row, target)
	end
end

---@return nil
function M.select_node()
	local current = nodes.get_row_current()
	if current then
		operations.select_node(current, "V")
	end
end

return M
