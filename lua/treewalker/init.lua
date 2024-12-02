local get = require('treewalker.getters')
local op = require('treewalker.ops')

local M = {}

---@return nil
local function move_out()
  local node = get.get_node()
  local target = get.get_direct_ancestor(node)

  if target then
    op.jump(target)
  end
end

---@return nil
local function move_in()
  local node = get.get_node()
  local target = get.get_descendant(node)

  if target then
    op.jump(target)
  end
end

---@return nil
local function move_up()
  local node = get.get_node()

  local target = get.get_prev(node)
  if target then
    op.jump(target)
  end
end

---@return nil
local function move_down()
  local node = get.get_node()
  local target = get.get_next(node)

  if target then
    op.jump(target)
  end
end

function M.up() move_up() end

function M.down() move_down() end

function M.left() move_out() end

function M.right() move_in() end

return M

-- -- you can define your setup function here. Usually configurations can be merged, accepting outside params and
-- -- you can also put some validation here for those.
-- local config = {}
-- M.config = config
-- M.setup = function(args)
--   M.config = vim.tbl_deep_extend("force", M.config, args or {})
-- end
