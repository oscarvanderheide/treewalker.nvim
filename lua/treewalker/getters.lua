local util = require('treewalker.util')

local M = {}

local IRRELEVANT_NODE_TYPES = { "comment" }

local function is_relevant(node)
  return not util.contains_string(IRRELEVANT_NODE_TYPES, node:type())
end

---Special helper to get a desired child node, skipping undesired node types like comments
---@param node TSNode
---@return TSNode | nil
local function get_first_relevant_child_node(node)
  local iter = node:iter_children()
  local child = iter()
  while child do
    if is_relevant(child) then
      return child
    end

    child = iter()
  end
end

---@param node1 TSNode
---@param node2 TSNode
---@return boolean
local function have_same_range(node1, node2)
  local srow1, scol1 = node1:range()
  local srow2, scol2 = node2:range()
  return
    srow1 == srow2 and
    scol1 == scol2
end

---Get the nearest ancestral node _which has different coordinates than the passed in node_
---@param node TSNode
---@return TSNode | nil
local function get_nearest_ancestor(node)
  local iter_ancestor = node:parent()
  while iter_ancestor do
    if have_same_range(node, iter_ancestor) then
      iter_ancestor = iter_ancestor:parent()
    else
      return iter_ancestor
    end
  end
end

---@param node TSNode
---@param dir PrevNext
---@return TSNode | nil
local function get_sibling(node, dir)
  if dir == "prev" then
    return node:prev_sibling()
  else
    return node:next_sibling()
  end
end

---@param node TSNode
---@param dir PrevNext
---@return TSNode | nil
function M.get_relevant_sibling(node, dir)
  local iter_sibling = get_sibling(node, dir)

  while iter_sibling do
    if is_relevant(iter_sibling) then
      return iter_sibling
    end

    iter_sibling = get_sibling(iter_sibling, dir)
  end

  return nil
end

---Get either the child (in) or parent (out) of the given node
---@param node TSNode
---@param dir InOut
---@return TSNode | nil
function M.get_relative(node, dir)
  if dir == "in" then
    return get_first_relevant_child_node(node)
  else
    return get_nearest_ancestor(node)
  end
end

---Get current node under cursor
---@return TSNode
function M.get_node()
  -- local node = get_farthest_parent_with_same_range()
  local node = vim.treesitter.get_node()
  assert(node)
  return node
end

return M
