local util = require('treewalker.util')
local ts = require("nvim-treesitter.ts_utils")

local M = {}

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

---@param node TSNode
---@return boolean
local function is_jump_target(node)
  for _, matcher in ipairs(NON_TARGET_NODE_MATCHERS) do
    if node:type():match(matcher) then
      return false
    end
  end
  return true
end

local function is_descendant_jump_target(node)
  return util.contains(TARGET_DESCENDANT_TYPES, node:type())
end

---Do the nodes have the same starting point
---@param node1 TSNode
---@param node2 TSNode
---@return boolean
local function have_same_start(node1, node2)
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
local function have_same_indent(node1, node2)
  local _, scol1 = node1:range()
  local _, scol2 = node2:range()
  return scol1 == scol2
end

---Do the nodes have the same starting line
---@param node1 TSNode
---@param node2 TSNode
---@return boolean
local function on_same_line(node1, node2)
  local srow1 = node1:start()
  local srow2 = node2:start()
  return srow1 == srow2
end

---helper to get all the children from a node
---@param node TSNode
---@return TSNode[]
local function get_children(node)
  local children = {}
  local iter = node:iter_children()
  local child = iter()
  while child do
    table.insert(children, child)
    child = iter()
  end
  return children
end

---iterable for all nodes after the passed in node in the entire syntax tree
---for nod in forward_tree(node) do ... end
---Does not return passed in node
---@param node TSNode
---@param dir "before" | "after"
local function nodes_surrounding(node, dir)
  local tree = node:tree()
  local root = tree:root()
  local nodes = get_children(root)

  for i, nod in ipairs(nodes) do
    util.log(i, nod:type(), nod:range())
  end


  -- all the prior nodes, in order of closest first
  if dir == "before" then
    nodes = util.reverse(nodes)
  end

  return coroutine.wrap(function()
    local is_past_node = false
    for _, nod in ipairs(nodes) do
      if is_past_node then
        coroutine.yield(nod)
      end

      if nod:equal(node) then
        is_past_node = true
      end
    end
  end)
end

---Get _next_ or _out and next_
---TODO I think I might want this to operate by line numbers rather than
---by nodes in the tree. The tree, as I see in vim.treesitter.inspect_tree(),
---should be read linearly as a list as it appears vertically on my screen, ignoring
---the indentation. Only if there're no more matches there should it go out and next.
---@param node TSNode
---@return TSNode | nil
function M.get_next(node)
  --- Strategy: walking the tree intelligently

  ---@param n TSNode
  local function get_iter(n)
    return ts.get_next_node(n, true, true)
  end

  local iter = get_iter(node)
  while iter do
    if is_jump_target(iter) and not on_same_line(node, iter) then
      return iter
    end
    iter = get_iter(iter)
  end

  -- Strategy: walking the tree linearly
  for nod in nodes_surrounding(node, "after") do
    if is_jump_target(nod) and have_same_indent(nod, node) and not have_same_start(nod, node) then
      return nod
    end
  end

  -- No next sibling jump target is found
  -- Travel up the tree to find the next parent's sibling
  local ancestor = M.get_direct_ancestor(node)
  if ancestor then
    return M.get_next(ancestor)
  end

  return nil
end

---This one goes _prev_ or _out_
---@param node TSNode
---@return TSNode | nil
function M.get_prev(node)
  -- Strategy: walking the tree linearly
  for nod in nodes_surrounding(node, "before") do
    if is_jump_target(nod) and have_same_indent(nod, node) and not have_same_start(nod, node) then
      util.log("found from walking linearly:", nod:type())
      return nod
    end
  end

  --- Strategy: walking the tree intelligently
  ---@param n TSNode
  local function get_iter(n)
    return ts.get_previous_node(n, true, true)
  end

  local iter = get_iter(node)
  while iter do
    if is_jump_target(iter) then
      return iter
    end
    iter = get_iter(iter)
  end

  -- Strategy: If we reach a dead end, climb up a level
  return M.get_direct_ancestor(node)
end

---Get the nearest ancestral node _which has different coordinates than the passed in node_
---@param node TSNode
---@return TSNode | nil
function M.get_direct_ancestor(node)
  local iter_ancestor = node:parent()
  while iter_ancestor do
    -- Without have_same_range, this will get stuck, where it targets one node, but is then
    -- interpreted by get_node() as another.
    if is_jump_target(iter_ancestor) and not have_same_start(node, iter_ancestor) then
      return iter_ancestor
    end

    iter_ancestor = iter_ancestor:parent()
  end
end

---Get the next target descendent
---The idea here is it goes _in_ or _down and in_
---@param node TSNode
---@return TSNode | nil
function M.get_descendant(node)
  local queue = get_children(node)

  while #queue > 0 do
    local current_node = table.remove(queue, 1)
    if is_descendant_jump_target(current_node) then
      return current_node
    end

    local iter = current_node:iter_children()
    local child = iter()
    while child do
      table.insert(queue, child)
      child = iter()
    end
  end

  -- If there was nothing below us, try below a sibling
  local next_sibling = node:next_sibling()
  if next_sibling then
    return M.get_descendant(next_sibling)
  end

  -- If there were no nephews, try children of an uncle (final recursive step
  -- to get at the whole tree)
  local parent = node:parent()
  if not parent then return nil end
  local uncle = parent:next_sibling()
  if not uncle then return nil end

  return M.get_descendant(uncle)
end

---Get current node under cursor
---@return TSNode
function M.get_node()
  local node = vim.treesitter.get_node()
  assert(node)

  -- -- I think many of the issues with stuckage are solved by retrieving the
  -- -- original node as the node one level up
  -- local parent = node:parent()
  -- -- local parent = get_farthest_target_ancestor_with_same_range(node)
  -- if parent and not is_root(parent) then
  --   node = parent
  -- end

  -- Might help when starting from non target location?
  -- node = get_nearest_target_ancestor(node)
  -- assert(node)

  -- Meant to help with up and down navigation, giving the highest likelihood of having a relevant sibling
  -- Gives getting stuck at the top of the file
  -- node = get_farthest_target_ancestor_with_same_range(node)

  return node
end

return M
