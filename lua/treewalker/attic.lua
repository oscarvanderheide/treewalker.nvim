
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

---@return TSNode | nil
local function get_farthest_parent_with_same_range()
  local node = vim.treesitter.get_node()
  if not node then return nil end

  local node_col, node_row = vim.treesitter.get_node_range(node)
  local parent = node:parent()

  local farthest_parent = node

  while parent do
    local parent_col, parent_row = vim.treesitter.get_node_range(parent)
    if parent_col ~= node_col or parent_row ~= node_row then
      break
    end
    farthest_parent = parent
    parent = parent:parent()
  end

  return farthest_parent
end

