-- This file soas to get access to whether in visual mode or not
--
-- via https://www.petergundel.de/neovim/lua/hack/2023/12/17/get-neovim-mode-when-executing-a-command.html

-- DESIGN:
-- * If there are no j's, back out (h) and try j again, until a j happens

local util = require('treewalker.util')
local get = require('treewalker.get')
local op = require('treewalker.ops')
require('treewalker.types')

local M = {}

---up/down
---@param dir "prev" | "next"
---@return nil
local function move_lateral(dir)
  util.log('move lateral')
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
  util.log('move level')
  local node = get.get_node()
  local relative = get.get_relative(node, dir)

  if not relative then
    util.log("no relative")
    return
  end

  op.jump(relative)
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

