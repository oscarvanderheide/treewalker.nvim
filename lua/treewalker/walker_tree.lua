local util = require "treewalker.util"
local node_util = require "treewalker.node_util"

---@class WalkerNode
---@field type string
---@field range [integer, integer, integer, integer, integer, integer]
---@field children  WalkerNode[]
---@field add_child fun(self: WalkerNode, child: WalkerNode)
---@field parent fun(self: WalkerNode): WalkerNode | nil
---@field next_sibling fun(self: WalkerNode): WalkerNode | nil
---@field prev_sibling fun(self: WalkerNode): WalkerNode | nil
---@field print fun(self: WalkerNode): string

---@param parent WalkerNode | nil
---@param current TSNode
---@return WalkerNode
local function construct_walker_node(parent, current)
  ---@type WalkerNode
  return {
    type = current:type(),
    range = { current:range() },
    children = {},

    add_child = function(self, child)
      table.insert(self.children, child)
    end,

    parent = function() return parent end,

    next_sibling = function(self)
      if self:parent() then
        for i, child in ipairs(self:parent().children) do
          if child == self then
            return self:parent().children[i + 1]
          end
        end
      end
    end,

    prev_sibling = function(self)
      if self:parent() then
        for i, child in ipairs(self:parent().children) do
          if child == self then
            return self:parent().children[i - 1]
          end
        end
      end
    end,

    print = function(self)
      return string.format("%s: %s [%d]", self.type, vim.inspect(self.range), #self.children)
    end,

  }
end

-- Helper function to perform depth-first search on TSNode
---@param current_ts_node TSNode
---@param parent_walker_node WalkerNode | nil
---@param seen_lines { [integer]: true }
local function build_walker_tree(current_ts_node, parent_walker_node, seen_lines)
  local current_walker_node = construct_walker_node(parent_walker_node, current_ts_node)

  local ts_children = node_util.get_children(current_ts_node)
  for _, child_ts_node in ipairs(ts_children) do
    local srow = child_ts_node:range()
    if not seen_lines[srow] and node_util.is_jump_target(child_ts_node) then
      seen_lines[srow] = true
      local child_walker_node = build_walker_tree(child_ts_node, current_walker_node, seen_lines)
      current_walker_node:add_child(child_walker_node)
    end
  end

  return current_walker_node
end

local M = {}

-- Create a parallel tree structure to the tree contained in in the passed in TSNode.
-- This parallel structure constists of nodes called WalkerNodes, which is a custom
-- tree implementation that has one key differentiator from TSTree - no two nodes
-- share the same start line.
---@param node TSNode
---@return WalkerNode
function M.from_root_node(node)
  return build_walker_tree(node, nil, { [0] = true })
end

---Get the indentation level of the node in the ast
---@param node WalkerNode
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

---util logs some version of the tree
---@param node WalkerNode
function M.print_tree(node)
  local str = ""
  for _ = 1, get_node_level(node) do
    str = str .. "  "
  end
  str = str .. node:print()
  util.log(str)

  for _, child in ipairs(node.children) do
    M.print_tree(child)
  end
end

---@param node WalkerNode
---@param lnum integer
---@return WalkerNode|nil
function M.get_for_line(node, lnum)
  local queue = util.merge_tables({ node }, node.children)

  while #queue > 0 do
    ---@type WalkerNode
    local current = table.remove(queue, 1)

    if current.range[1] == lnum then
      return current
    end

    queue = util.merge_tables(queue, current.children)
  end
end

return M
