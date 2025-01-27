local operations = require "treewalker.operations"
local targets = require "treewalker.targets"
local nodes = require "treewalker.nodes"

local M = {}

---@return nil
function M.move_out()
  local node = nodes.get_current()
  local target, row = targets.out(node)

  if target and row then
    operations.jump(target, row)
    return
  end
end

---@return nil
function M.move_in()
  local node = nodes.get_current()
  local target, row = targets.inn(node)

  if target and row then
    operations.jump(target, row)
  end
end

---@return nil
function M.move_up()
  local node = nodes.get_current()
  local target, row = targets.up(node)

  if target and row  then
    operations.jump(target, row)
  end
end

---@return nil
function M.move_down()
  local node = nodes.get_current()
  local target, row = targets.down(node)

  if target and row then
    operations.jump(target, row)
  end
end

return M
