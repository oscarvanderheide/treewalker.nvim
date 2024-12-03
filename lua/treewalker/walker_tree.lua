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

-- Build a walker tree from a root TSNode
-- TODO this isn't getting all the nodes. If a child doesn't qualify, like it's on the same line, we never see any of its children. But we do need to.
---@param current_ts_node TSNode
---@param parent_walker_node WalkerNode | nil
---@param seen_lines { [integer]: true }
local function build_walker_tree(current_ts_node, parent_walker_node, seen_lines)
  local current_walker_node = nil

  local ts_children = node_util.get_children(current_ts_node)
  for _, ts_child in ipairs(ts_children) do
    local ts_child_lnum = ts_child:range()
    if not seen_lines[ts_child_lnum] and node_util.is_jump_target(ts_child) then
      -- If the node is a valid jump target and hasn't been seen, create a walker node
      current_walker_node = current_walker_node or construct_walker_node(parent_walker_node, current_ts_node)
      local child_walker_node = build_walker_tree(ts_child, current_walker_node, seen_lines)
      if child_walker_node then
        current_walker_node:add_child(child_walker_node)
      end
      seen_lines[ts_child_lnum] = true
    else
      -- Recursively process children of non-qualifying nodes
      build_walker_tree(ts_child, current_walker_node, seen_lines)
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

