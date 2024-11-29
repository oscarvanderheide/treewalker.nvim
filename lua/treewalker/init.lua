local get = require('treewalker.getters')
local op = require('treewalker.ops')
require('treewalker.types')

local M = {}

---left/right
---@param dir InOut
---@param should_jump_to_next_sibling_after boolean?
---@return nil
local function move_level(dir, should_jump_to_next_sibling_after)
  local node = get.get_node()
  local target = get.get_relative(node, dir)

  if target and should_jump_to_next_sibling_after then
    target = get.get_sibling(target, "next")
  end

  if target then
    op.jump(target)
  end
end

---up/down
---@param dir PrevNext
---@return nil
local function move_lateral(dir)
  local node = get.get_node()

  local target = get.get_sibling(node, dir)
  if target then
    op.jump(target)
  elseif dir == "next" then
    move_level("out", true)
  elseif dir == "prev" then
    move_level("out", false)
  end
end

function M.up() move_lateral("prev") end
function M.down() move_lateral("next") end
function M.left() move_level("out") end
function M.right() move_level("in") end
return M

-- -- you can define your setup function here. Usually configurations can be merged, accepting outside params and
-- -- you can also put some validation here for those.
-- local config = {}
-- M.config = config
-- M.setup = function(args)
--   M.config = vim.tbl_deep_extend("force", M.config, args or {})
-- end

