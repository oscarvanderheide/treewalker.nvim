-- This file soas to get access to whether in visual mode or not
--
-- via https://www.petergundel.de/neovim/lua/hack/2023/12/17/get-neovim-mode-when-executing-a-command.html

-- DESIGN:
-- * If there are no j's, back out (h) and try j again, until a j happens

local util = require('gptmodels.util')

local M = {}

---@alias InOut "in" | "out"
---@alias PrevNext "prev" | "next"

---set cursor without throwing error
---@param row integer
---@param col integer
local function safe_set_cursor(row, col)
  local ok, error = pcall(vim.api.nvim_win_set_cursor, 0, { row, col }) -- catch any errors in nvim_win_set_cursor
  if not ok then
    util.log("safe_set_cursor error:", error)
  end
end

---Flash a highlight over the given range
---@param range Range4
local function highlight(range)
  local start_row, start_col, end_row, end_col = range[1], range[2], range[3], range[4]
  local ns_id = vim.api.nvim_create_namespace("")
  local hl_group = "DiffText"
  for row = start_row, end_row do
    if row == start_row and row == end_row then
      -- Highlight within the same line
      vim.api.nvim_buf_add_highlight(0, ns_id, hl_group, start_row - 1, start_col, end_col)
    elseif row == start_row then
      -- Highlight from start_col to the end of the start_row
      vim.api.nvim_buf_add_highlight(0, ns_id, hl_group, start_row - 1, start_col, -1)
    elseif row == end_row then
      -- Highlight from the beginning of the end_row to end_col
      vim.api.nvim_buf_add_highlight(0, ns_id, hl_group, end_row - 1, 0, end_col)
    else
      -- Highlight the entire row for intermediate rows
      vim.api.nvim_buf_add_highlight(0, ns_id, hl_group, row - 1, 0, -1)
    end
  end

  vim.defer_fn(function()
    vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
  end, 250)
end

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

-----@return TSNode | nil
--local function get_farthest_parent_with_same_range()
--  local node = vim.treesitter.get_node()
--  if not node then return nil end

--  local node_col, node_row = vim.treesitter.get_node_range(node)
--  local parent = node:parent()

--  local farthest_parent = node

--  while parent do
--    local parent_col, parent_row = vim.treesitter.get_node_range(parent)
--    if parent_col ~= node_col or parent_row ~= node_row then
--      break
--    end
--    farthest_parent = parent
--    parent = parent:parent()
--  end

--  return farthest_parent
--end

local IRRELEVANT_NODE_TYPES = { "comment" }

---Special helper to get a desired child node, skipping undesired node types like comments
---@param node TSNode
---@return TSNode | nil
local function get_relevant_child_node(node)
  for child in node:iter_children() do
    if child:type() ~= "comment" then
      return child
    end
  end

  return nil
end

---@param node TSNode
---@return TSNode | nil
local function get_relevant_prev_sibling(node)
  local prev_sibling = node:prev_sibling()
  while prev_sibling do
    if prev_sibling:type() ~= "comment" then
      return prev_sibling
    end

    prev_sibling = prev_sibling:prev_sibling()
  end

  return nil
end

---@param node TSNode
---@return TSNode | nil
local function get_relevant_next_sibling(node)
  local iter_sibling = node:next_sibling()
  while iter_sibling do
    if iter_sibling:type() ~= "comment" then
      return iter_sibling
    end

    iter_sibling = iter_sibling:next_sibling()
  end

  return nil
end

---@param node TSNode
local function jump(node)
    local start_row, start_col, end_row, end_col = vim.treesitter.get_node_range(node)
    util.log(string.format("%s %d %d %d %d", tostring(node:type()), start_row, start_col, end_row, end_col))
    safe_set_cursor(start_row + 1, start_col)
    highlight({ start_row + 1, start_col, end_row + 1, end_col })
end

---@param node TSNode
---@param dir PrevNext
---@return TSNode | nil
local function get_sibling(node, dir)
  local sibling
  if dir == "prev" then
    sibling = get_relevant_prev_sibling(node)
  elseif dir == "next" then
    sibling = get_relevant_next_sibling(node)
  end

  return sibling
end

---Get current node under cursor
---@return TSNode
local function get_node()
  -- local node = get_farthest_parent_with_same_range()
  local node = vim.treesitter.get_node()
  assert(node)
  return node
end

---@param node TSNode
---@param dir InOut
---@return TSNode | nil
local function get_relative(node, dir)
  --- @type TSNode | nil
  local relative

  if dir == "in" then
    relative = get_relevant_child_node(node)
  elseif dir == "out" then
    relative = node:parent()
  end

  return relative
end

---up/down
---@param dir "prev" | "next"
---@return nil
local function move_lateral(dir)
  util.log('move lateral')
  local node = get_node()

  local sibling = get_sibling(node, dir)
  if sibling then
    jump(sibling)
  end
end

---left/right
---@param dir InOut
---@return nil
local function move_level(dir)
  util.log('move level')
  local node = get_node()
  local relative = get_relative(node, dir)

  if not relative then
    util.log("no relative")
    return
  end

  jump(relative)
end

function M.up() move_lateral("prev") end
function M.down() move_lateral("next") end
function M.left() move_level("out") end
function M.right() move_level("in") end
return M

-- -- you can define your setup function here. Usually configurations can be merged, accepting outside params and
-- -- you can also put some validation here for those.
-- local config = {}
-- M.config = config
-- M.setup = function(args)
--   M.config = vim.tbl_deep_extend("force", M.config, args or {})
-- end

