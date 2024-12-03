local getters = require('treewalker.getters')
local util = require('treewalker.util')
local ops = require('treewalker.ops')
local walker_tree = require('treewalker.walker_tree')

local M = {}

---@return nil
local function move_out()
  local node = getters.get_node()
  -- local target = getters.get_direct_ancestor(node)
  local target = node:parent()

  if target then
    ops.jump(target)
  end
end

---@return nil
local function move_in()
  local node = getters.get_node()
  -- local target = getters.get_descendant(node)
  local target = node.children[1]

  if target then
    ops.jump(target)
  end
end

---@return nil
local function move_up()
  local node = getters.get_node()
  -- local target = getters.get_prev(node)
  local target = node:prev_sibling()

  if target then
    ops.jump(target)
  end
end

---@return nil
local function move_down()
  local node = getters.get_node()
  util.log(string.format("current node: %s", node:print()))
  -- walker_tree.print_tree(node)
  -- local target = getters.get_next(node)
  local target = node:next_sibling()

  if target then
    ops.jump(target)
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
