local util = require "treewalker.util"

local NON_TARGET_NODE_MATCHERS = {
  -- "chunk", -- lua
  "^.*comment.*$",
}

local TARGET_DESCENDANT_TYPES = {
  "body_statement",  -- lua, rb
  "block",           -- lua
  "statement_block", -- lua

  -- "then", -- helps rb, hurts lua
  "do_block", -- rb
}

local M = {}

---@param node TSNode
---@return boolean
function M.is_jump_target(node)
  for _, matcher in ipairs(NON_TARGET_NODE_MATCHERS) do
    if node:type():match(matcher) then
      return false
    end
  end
  return true
end

function M.is_descendant_jump_target(node)
  return util.contains(TARGET_DESCENDANT_TYPES, node:type())
end

---Do the nodes have the same starting point
---@param node1 TSNode
---@param node2 TSNode
---@return boolean
function M.have_same_start(node1, node2)
  local srow1, scol1 = node1:range()
  local srow2, scol2 = node2:range()
  return
      srow1 == srow2 and
      scol1 == scol2
end

---Do the nodes have the same level of indentation
---@param node1 TSNode
---@param node2 TSNode
---@return boolean
function M.have_same_indent(node1, node2)
  local _, scol1 = node1:range()
  local _, scol2 = node2:range()
  return scol1 == scol2
end

---Do the nodes have the same starting line
---@param node1 TSNode
---@param node2 TSNode
---@return boolean
function M.on_same_line(node1, node2)
  local srow1 = node1:start()
  local srow2 = node2:start()
  return srow1 == srow2
end

---helper to get all the children from a node
---@param node TSNode
---@return TSNode[]
function M.get_children(node)
  local children = {}
  local iter = node:iter_children()
  local child = iter()
  while child do
    table.insert(children, child)
    child = iter()
  end
  return children
end

--- Get all descendants of a given TSNode
---@param node TSNode
---@return TSNode[]
function M.get_descendants(node)
    local descendants = {}

    -- Helper function to recursively collect descendants
    local function collect_descendants(current_node)
        local child_count = current_node:child_count()
        for i = 0, child_count - 1 do
            local child = current_node:child(i)
            table.insert(descendants, child)
            -- Recursively collect descendants of the child
            collect_descendants(child)
        end
    end

    -- Start the recursive collection with the given node
    collect_descendants(node)

    return descendants
end

--- Take a list of nodes and unique them based on line start
---@param nodes TSNode[]
---@return TSNode[]
function M.unique_per_line(nodes)
    local unique_nodes = {}
    local seen_lines = {}

    for _, node in ipairs(nodes) do
        local line = node:start()  -- Assuming node:start() returns the line number of the node
        if not seen_lines[line] then
            table.insert(unique_nodes, node)
            seen_lines[line] = true
        end
    end

    return unique_nodes
end

return M
