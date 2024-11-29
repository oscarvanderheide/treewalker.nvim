local util = require('treewalker.util')

local M = {}

local IRRELEVANT_NODE_TYPES = { "comment" }

---Special helper to get a desired child node, skipping undesired node types like comments
---@param node TSNode
---@return TSNode | nil
function M.get_relevant_child_node(node)
  for child in node:iter_children() do
    if util.contains_string(IRRELEVANT_NODE_TYPES, child:type()) then
      return child
    end
  end

  return nil
end

---Special helper to get a desired sibling, skipping undesired node types like comments
---@param node TSNode
---@return TSNode | nil
function M.get_relevant_prev_sibling(node)
  local iter_sibling = node:prev_sibling()
  while iter_sibling do
    if util.contains_string(IRRELEVANT_NODE_TYPES, iter_sibling:type()) then
      return iter_sibling
    end

    iter_sibling = iter_sibling:prev_sibling()
  end

  return nil
end

---@param node TSNode
---@return TSNode | nil
function M.get_relevant_next_sibling(node)
  local iter_sibling = node:next_sibling()
  while iter_sibling do
    if iter_sibling:type() ~= "comment" then
      return iter_sibling
    end

    iter_sibling = iter_sibling:next_sibling()
  end

  return nil
end

---TODO Fold this into get_relevant_{prev, next}_sibling to avoid duplication there
---@param node TSNode
---@param dir PrevNext
---@return TSNode | nil
function M.get_sibling(node, dir)
  local sibling
  if dir == "prev" then
    sibling = M.get_relevant_prev_sibling(node)
  elseif dir == "next" then
    sibling = M.get_relevant_next_sibling(node)
  end

  return sibling
end

---Get current node under cursor
---@return TSNode
function M.get_node()
  -- local node = get_farthest_parent_with_same_range()
  local node = vim.treesitter.get_node()
  assert(node)
  return node
end

---@param node TSNode
---@param dir InOut
---@return TSNode | nil
function M.get_relative(node, dir)
  --- @type TSNode | nil
  local relative

  if dir == "in" then
    relative = M.get_relevant_child_node(node)
  elseif dir == "out" then
    relative = node:parent()
  end

  return relative
end

return M
