local util = require('treewalker.util')

local M = {}

local VALID_NODE_TYPES = {
  "variable_declaration",
  "function_declaration",
  "function_definition",
  "function_call",
  "return_statement",
  "assignment_statement",
  "while_statement",
  "if_statement",
  "for_statement",
  "statement_block",
  "expression_statement",
  "lexical_declaration",
}

local VALID_DESCENDANT_TYPES = {
  "block",
  "statement_block",
}

local function is_jump_target(node)
  return util.contains(VALID_NODE_TYPES, node:type())
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

---we only ever really need to go into the body of something
--- @param node TSNode
--- @return TSNode | nil
local function get_descendant(node)
    local queue = {node}

    while #queue > 0 do
        local current_node = table.remove(queue, 1)
        if util.contains(VALID_DESCENDANT_TYPES, current_node:type()) then
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

---Get the nearest ancestral node _which has different coordinates than the passed in node_
---@param node TSNode
---@return TSNode | nil
local function get_ancestor(node)
  local iter_ancestor = node:parent()
  while iter_ancestor do
    if have_same_range(node, iter_ancestor) or not is_jump_target(iter_ancestor) then
      iter_ancestor = iter_ancestor:parent()
    else
      return iter_ancestor
    end
  end
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
local function get_nearest_valid_ancestor(node)
  local iter_ancestor = node:parent()
  while iter_ancestor do
    if is_jump_target(iter_ancestor) then
      return iter_ancestor
    end

    iter_ancestor = iter_ancestor:parent()
  end
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

---Get either the child (in) or parent (out) of the given node
---@param node TSNode
---@param dir InOut
---@return TSNode | nil
function M.get_relative(node, dir)
  if dir == "in" then
    return get_descendant(node)
  elseif dir == "out" then
    return get_ancestor(node)
  end
end

---Get current node under cursor
---@return TSNode
function M.get_node()
  local node = vim.treesitter.get_node()
  assert(node)

  -- node = get_nearest_valid_ancestor(node)
  -- assert(node)

  -- special dispensation for identifier nodes, if we don't do this,
  -- identifiers in particular get stuck on themselves, ex lua's
  -- assert(node) above becomes a sink
  if node:type() == "identifier" then
    -- node = get_farthest_parent_with_same_range()
    local ancestor = get_nearest_valid_ancestor(node)
    if ancestor then
      node = ancestor
    end
  end

  return node
end

return M
