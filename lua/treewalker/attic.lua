
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

