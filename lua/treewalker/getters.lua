local util = require('treewalker.util')
local node_util = require('treewalker.node_util')
local ts = require("nvim-treesitter.ts_utils")
local walker_tree = require("treewalker.walker_tree")

local M = {}

---iterable for all nodes after the passed in node in the entire syntax tree
---for nod in forward_tree(node) do ... end
---Does not return passed in node
---@param node TSNode
---@param dir "before" | "after"
local function nodes_surrounding(node, dir)
  local tree = node:tree()
  local root = tree:root()
  local nodes = node_util.get_children(root)

  -- all the prior nodes, in order of closest first
  if dir == "before" then
    nodes = util.reverse(nodes)
  end

  return coroutine.wrap(function()
    local is_past_node = false
    for _, nod in ipairs(nodes) do
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
    if M.is_jump_target(iter) and not node_util.on_same_line(node, iter) then
      return iter
    end
    iter = get_iter(iter)
  end

  -- Strategy: walking the tree linearly
  for nod in nodes_surrounding(node, "after") do
    if M.is_jump_target(nod) and node_util.have_same_indent(nod, node) and not node_util.have_same_start(nod, node) then
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
    if M.is_jump_target(nod) and node_util.have_same_indent(nod, node) and not node_util.have_same_start(nod, node) then
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
    if M.is_jump_target(iter) then
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
    if M.is_jump_target(iter_ancestor) and not node_util.have_same_start(node, iter_ancestor) then
      return iter_ancestor
    end

    iter_ancestor = iter_ancestor:parent()
  end
end

---Get the next target descendent
---The idea here is it goes _in_ or _down and in_
---@param node TSNode
---@return TSNode | nil
function M.get_descendant(node)
  local queue = node_util.get_children(node)

  while #queue > 0 do
    local current_node = table.remove(queue, 1)
    if M.is_descendant_jump_target(current_node) then
      return current_node
    end

    local iter = current_node:iter_children()
    local child = iter()
    while child do
      table.insert(queue, child)
      child = iter()
    end
  end

  -- If there was nothing below us, try below a sibling
  local next_sibling = node:next_sibling()
  if next_sibling then
    return M.get_descendant(next_sibling)
  end

  -- If there were no nephews, try children of an uncle (final recursive step
  -- to get at the whole tree)
  local parent = node:parent()
  if not parent then return nil end
  local uncle = parent:next_sibling()
  if not uncle then return nil end

  return M.get_descendant(uncle)
end

---Get current node under cursor
---@return TSNode
function M.get_node()
  local node = vim.treesitter.get_node()
  assert(node)

  return node
end

function M.get_root_node()
  local parser = vim.treesitter.get_parser()
  local tree = parser:trees()[1]
  return tree:root()
end

return M
