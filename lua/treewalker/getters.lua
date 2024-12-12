local util = require('treewalker.util')
local nodes = require('treewalker.nodes')
local ts = require("nvim-treesitter.ts_utils")

local M = {}

---iterable for all nodes after the passed in node in the entire syntax tree
---for nod in forward_tree(node) do ... end
---Does not return passed in node
---@param node TSNode
---@param dir "before" | "after"
local function nodes_surrounding(node, dir)
  local tree = node:tree()
  local root = tree:root()
  local nods = nodes.get_children(root)

  -- all the prior nodes, in order of closest first
  if dir == "before" then
    nods = util.reverse(nods)
  end

  return coroutine.wrap(function()
    local is_past_node = false
    for _, nod in ipairs(nods) do
      if is_past_node then
        coroutine.yield(nod)
      end

      if nod:equal(node) then
        is_past_node = true
      end
    end
  end)
end

---@param node TSNode
---@return TSNode | nil
function M.get_next(node)
  --- Strategy: walking the tree intelligently

  ---@param n TSNode
  local function get_iter(n)
    return ts.get_next_node(n, true, true)
  end

  local iter = get_iter(node)
  while iter do
    if nodes.is_jump_target(iter) and not nodes.on_same_line(node, iter) then
      return iter
    end
    iter = get_iter(iter)
  end

  -- Strategy: walking the tree linearly
  for nod in nodes_surrounding(node, "after") do
    if nodes.is_jump_target(nod) and nodes.have_same_indent(nod, node) and not nodes.have_same_start(nod, node) then
      return nod
    end
  end

  -- No next sibling jump target is found
  -- Travel up the tree to find the next parent's sibling
  local ancestor = M.get_direct_ancestor(node)
  if ancestor then
    return M.get_next(ancestor)
  end

  return nil
end

---This one goes _prev_ or _out_
---@param node TSNode
---@return TSNode | nil
function M.get_prev(node)
  -- Strategy: walking the tree linearly
  for nod in nodes_surrounding(node, "before") do
    if nodes.is_jump_target(nod) and nodes.have_same_indent(nod, node) and not nodes.have_same_start(nod, node) then
      util.log("found from walking linearly:", nod:type())
      return nod
    end
  end

  --- Strategy: walking the tree intelligently
  ---@param n TSNode
  local function get_iter(n)
    return ts.get_previous_node(n, true, true)
  end

  local iter = get_iter(node)
  while iter do
    if nodes.is_jump_target(iter) then
      return iter
    end
    iter = get_iter(iter)
  end

  -- Strategy: If we reach a dead end, climb up a level
  return M.get_direct_ancestor(node)
end

---Get the nearest ancestral node _which has different coordinates than the passed in node_
---@param node TSNode
---@return TSNode | nil
function M.get_direct_ancestor(node)
  local iter_ancestor = node:parent()
  while iter_ancestor do
    -- Without have_same_range, this will get stuck, where it targets one node, but is then
    -- interpreted by get_node() as another.
    if nodes.is_jump_target(iter_ancestor) and not nodes.have_same_start(node, iter_ancestor) then
      return iter_ancestor
    end

    iter_ancestor = iter_ancestor:parent()
  end
end

function M.get_root_node()
  local parser = vim.treesitter.get_parser()
  local tree = parser:trees()[1]
  return tree:root()
end

return M
