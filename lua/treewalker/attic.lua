
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

