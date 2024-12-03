local node_util = require "treewalker.nodes"
local util = require "treewalker.util"
local nodes = require "treewalker.nodes"

---A walker tree is a special kind of tree, based on a TSTree but without any duplicate nodes on the same line.
---@class WalkerTree
---@field private _llm_models { openai: string[], ollama: string[] }

---@class WalkerNode
---@field private child_index integer
---@field children  WalkerNode[]
---@field parent WalkerNode | nil
---@field next_sibling fun(self: WalkerNode): WalkerNode | nil
---@field prev_sibling fun(self: WalkerNode): WalkerNode | nil
---@field add_child fun(self: WalkerNode, child: WalkerNode)
---@field range [integer, integer, integer, integer, integer, integer]

---@param parent WalkerNode | nil
---@param current TSNode
---@return WalkerNode
local function construct_walker_node(parent, current)
  return {
    children = {},
    parent = parent,
    range = current:range(),
    next_sibling = function(self)
      if self.parent then
        for i, child in ipairs(self.parent.children) do
          if child == self then
            return self.parent.children[i + 1]
          end
        end
      end
    end,
    prev_sibling = function(self)
      if self.parent then
        for i, child in ipairs(self.parent.children) do
          if child == self then
            return self.parent.children[i - 1]
          end
        end
      end
    end,
    add_child = function(self, child)
      table.insert(self.children, child)
    end
  }
end

-- Helper function to perform depth-first search on TSNode
---@param current_ts_node TSNode
---@param parent_walker_node WalkerNode | nil
local function build_walker_tree(current_ts_node, parent_walker_node)
  local current_walker_node = construct_walker_node(parent_walker_node, current_ts_node)

  for _, child_ts_node in nodes.get_children(current_ts_node) do
    local child_walker_node = build_walker_tree(child_ts_node, current_walker_node)
    current_walker_node:add_child(child_walker_node)
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
  return build_walker_tree(node)
end

return M
