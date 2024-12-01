
---Get the indentation level of the node in the ast
---@param node TSNode
---@return integer
local function get_node_level(node)
  local count = 0

  local parent = node:parent()
  while parent do
    count = count + 1
    parent = parent:parent()
  end

  return count
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

---Ignores the node tree, traverses the node list linearly, getting the next node that starts on the same column, but a different row
---TODO Good idea but I can't get it working. Breaking from this to explore using ts.get_next_node directly.
---@param node TSNode
---@return TSNode | nil
local function get_next_sibling_by_start(node)
  local row, col = node:start()
  local iter = ts.get_next_node(node, true, true)

  while iter do
    local iter_row, iter_col = iter:start()
    local has_same_indent = iter_col == col and iter_row ~= row
    if has_same_indent and is_jump_target(iter) then
      return iter
    end
    iter = ts.get_next_node(iter)
  end
end

---Is the node the top module of the file, the root node
---@param node TSNode
---@return boolean
local function is_root(node)
  local srow, scol = node:range()
  return srow == 0 and scol == 0
end

