local get = require('treewalker.getters')
local op = require('treewalker.ops')
require('treewalker.types')

local M = {}

---up/down
---@param dir "prev" | "next"
---@return nil
local function move_lateral(dir)
  local node = get.get_node()

  local sibling = get.get_sibling(node, dir)
  if sibling then
    op.jump(sibling)
  end
end

---left/right
---@param dir InOut
---@return nil
local function move_level(dir)
  local node = get.get_node()
  local relative = get.get_relative(node, dir)

  if relative then
    op.jump(relative)
    return
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

