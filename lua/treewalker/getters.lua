
local util = require('treewalker.util')

local M = {}

local NON_TARGET_NODE_MATCHERS = {
  -- "chunk", -- lua
  "^.*comment.*$",
}

local TARGET_DESCENDANT_TYPES = {
  "body_statement",  -- lua
  "block",           -- lua
  "statement_block", -- lua

  -- "then", -- helps rb, hurts lua
  "do_block", -- rb
}

---@param node TSNode
---@return boolean
local function is_jump_target(node)
  -- return not util.contains(NON_TARGET_NODE_MATCHERS, node:type())
  for _, matcher in ipairs(NON_TARGET_NODE_MATCHERS) do
    if node:type():match(matcher) then
      return false
    end
  end
  return true
end

local function is_target_descendant(node)
  return util.contains(TARGET_DESCENDANT_TYPES, node:type())
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

---@param node TSNode
---@param dir PrevNext
---@return TSNode | nil
local function get_raw_sibling(node, dir)
  if dir == "prev" then
    return node:prev_sibling()
  elseif dir == "next" then
    return node:next_sibling()
  end
end

---@param node TSNode
---@return TSNode | nil
local function get_nearest_target_ancestor(node)
  local iter_ancestor = node:parent()
  while iter_ancestor do
    if is_jump_target(iter_ancestor) then
      return iter_ancestor
    end

    iter_ancestor = iter_ancestor:parent()
  end
end

---Otherwise returns the original node
---@param node TSNode
---@return TSNode
local function get_farthest_target_ancestor_with_same_range(node)
  local node_row, node_col = vim.treesitter.get_node_range(node)
  local parent = node:parent()

  local farthest_parent = node

  while parent do
    local parent_col, parent_row = vim.treesitter.get_node_range(parent)
    if parent_row ~= node_row or parent_col ~= node_col then
      break
    end
    farthest_parent = parent
    parent = parent:parent()
  end

  return farthest_parent
end

---@param node TSNode
---@param dir PrevNext
---@return TSNode | nil
function M.get_sibling(node, dir)
  local iter_sibling = get_raw_sibling(node, dir)

  while iter_sibling do
    if is_jump_target(iter_sibling) then
      return iter_sibling
    end

    iter_sibling = get_raw_sibling(iter_sibling, dir)
  end

  return nil
end

---Get the nearest ancestral node _which has different coordinates than the passed in node_
---@param node TSNode
---@return TSNode | nil
function M.get_ancestor(node)
  local iter_ancestor = node:parent()
  while iter_ancestor do
    if have_same_range(node, iter_ancestor) or not is_jump_target(iter_ancestor) then
      iter_ancestor = iter_ancestor:parent()
    else
      return iter_ancestor
    end
  end
end

---Get the next target descendent
---@param node TSNode
---@return TSNode | nil
function M.get_descendant(node)
  local queue = { node }

  while #queue > 0 do
    local current_node = table.remove(queue, 1)
    if is_target_descendant(current_node) then
      return current_node
    end

    local iter = current_node:iter_children()
    local child = iter()
    while child do
      table.insert(queue, child)
      child = iter()
    end
  end

  return nil
end

---Get current node under cursor
---@return TSNode
function M.get_node()
  local node = vim.treesitter.get_node()
  assert(node)

  -- node = get_nearest_target_ancestor(node)
  -- assert(node)

  node = get_farthest_target_ancestor_with_same_range(node)

  return node
end

return M
