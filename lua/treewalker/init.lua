local get = require('treewalker.getters')
local op = require('treewalker.ops')
require('treewalker.types')

local M = {}

---@param should_jump_to_next_sibling_after boolean
---@return nil
local function move_out(should_jump_to_next_sibling_after)
  local node = get.get_node()
  local target = get.get_ancestor(node)

  if target and should_jump_to_next_sibling_after then
    target = get.get_sibling(target, "next")
  end

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
  else
    move_out(false)
  end
end

---@return nil
local function move_down()
  local node = get.get_node()

  local target = get.get_next(node)
  if target then
    op.jump(target)
  else
    -- move_out(true)
    -- move out to the bottom until there's something to go down to
    -- get next down target
    -- get.get_out_and_down(node)
    -- get.get_deep_next(node)
  end
end

function M.up() move_up() end

function M.down() move_down() end

function M.left() move_out(false) end

function M.right() move_in() end

return M

-- -- you can define your setup function here. Usually configurations can be merged, accepting outside params and
-- -- you can also put some validation here for those.
-- local config = {}
-- M.config = config
-- M.setup = function(args)
--   M.config = vim.tbl_deep_extend("force", M.config, args or {})
-- end
