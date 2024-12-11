local nodes = require('treewalker.nodes')
local getters = require('treewalker.getters')
local util = require('treewalker.util')
local ops = require('treewalker.ops')
local lines = require('treewalker.lines')
local strategies = require('treewalker.strategies')

local M = {}

---@return nil
local function move_out()
  local node = getters.get_node()
  local target = getters.get_direct_ancestor(node)
  if not target then return end
  local lnum = target:range()
  ops.jump(lnum, target)
end

---@return nil
local function move_in()
  local node = getters.get_node()
  local target = getters.get_descendant(node)
  if not target then return end
  local lnum = target:range()
  ops.jump(lnum, target)
end

---@param lnum integer
---@param line string
---@param candidate TSNode
---@param prefix string
---@return nil
local function log(lnum, line, candidate, prefix)
  util.log(
    prefix .. ": [L " .. lnum .. "] |" .. line .. "| [" .. candidate:type() .. "]" .. vim.inspect(nodes.range(candidate))
  )
end

---@return nil
local function move_up()
  local current_lnum = vim.fn.line(".")
  local current_indent = lines.get_indent(lines.get_line(current_lnum))

  --- Get next target, if one is found
  local candidate_lnum, candidate_line, candidate =
      strategies.get_next_vertical_target_at_same_indent("up", current_lnum, current_indent)

  -- Ultimate failure
  if not candidate_lnum or not candidate_line or not candidate then
    return util.log("no next candidate")
  end

  log(candidate_lnum, candidate_line, candidate, "move_up dest")
  ops.jump(candidate_lnum + 1, candidate)
end

---@return nil
local function move_down()
  local current_lnum = vim.fn.line(".")
  local current_indent = lines.get_indent(lines.get_line(current_lnum))

  --- Get next target, if one is found
  local candidate_lnum, candidate_line, candidate =
      strategies.get_next_vertical_target_at_same_indent("down", current_lnum, current_indent)

  -- Ultimate failure
  if not candidate_lnum or not candidate_line or not candidate then
    return util.log("no next candidate")
  end

  log(candidate_lnum, candidate_line, candidate, "move_down dest")
  ops.jump(candidate_lnum - 1, candidate)
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
