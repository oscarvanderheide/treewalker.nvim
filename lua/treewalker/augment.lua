local nodes = require "treewalker.nodes"

local M = {}

-- Gets the "augment" nodes that exist above a given node
-- These are nodes that are, like, kind of attached to the provided node.
-- Think comments, decorators, annotations, etc. Stuff that wants to stay
-- with the given node. This was originally implemented to aid with swapping,
-- because if you swap a node that has a comment description, comment types,
-- annotations, etc, those should move along with the node.
---@param node TSNode
---@return TSNode[]
function M.get_node_augments(node)
  local augments = {}
  local row = nodes.range(node)[1] + 1
  while true do
    local candidate = nodes.get_from_neighboring_line(row, "up")
    if candidate and nodes.is_augment_target(candidate) then
      table.insert(augments, candidate)
      row = row - 1
    else
      break
    end
  end

  return augments
end

return M
