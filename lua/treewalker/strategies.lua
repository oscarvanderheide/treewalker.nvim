local lines = require('treewalker.lines')
local nodes = require('treewalker.nodes')
local util  = require('treewalker.util')

---@alias Dir "up" | "down"

-- Take row, give next row / node with same indentation
---@param current_row integer
---@param dir Dir
---@return TSNode | nil, integer | nil, string | nil
local function get_node_from_neighboring_line(current_row, dir)
  local candidate_row
  if dir == "up" then
    candidate_row = current_row - 1
  else
    candidate_row = current_row + 1
  end
  local max_row = vim.api.nvim_buf_line_count(0)
  if candidate_row > max_row or candidate_row <= 0 then return end
  local candidate_line = lines.get_line(candidate_row)
  local candidate_col = lines.get_start_col(candidate_line)
  local candidate = nodes.get_at_rowcol(candidate_row, candidate_col)
  return candidate, candidate_row, candidate_line
end

local M = {}

-- Gets the next target in the up/down directions
-- TODO this should not jump to other functions
---@param dir Dir
---@param starting_row integer
---@param starting_col integer
---@return TSNode | nil, integer | nil, string | nil
function M.get_next_vertical_target_at_same_col(dir, starting_row, starting_col)
  local candidate, candidate_row, candidate_line = get_node_from_neighboring_line(starting_row, dir)

  while candidate_row and candidate_line and candidate do
    local candidate_col = lines.get_start_col(candidate_line)
    local srow = candidate:range()
    if
        nodes.is_jump_target(candidate) -- only node types we consider jump targets
        and candidate_line ~= "" -- no empty lines
        and candidate_col == starting_col -- stay at current indent level
        and candidate_row == srow + 1 -- top of block; no end's or else's etc.
    then
      break -- use most recent assignment below
    else
      candidate, candidate_row, candidate_line = get_node_from_neighboring_line(candidate_row, dir)
    end
  end

  return candidate, candidate_row, candidate_line
end

-- Go down until there is a valid jump target to the right
---@param starting_row integer
---@param starting_col integer
---@return TSNode | nil, integer | nil, string | nil
function M.get_down_and_in(starting_row, starting_col)
  local last_row = vim.api.nvim_buf_line_count(0)

  if last_row == starting_row then return end

  for current_row = starting_row + 1, last_row, 1 do
    local current_line = lines.get_line(current_row)
    local current_col = lines.get_start_col(current_line)
    local is_empty = current_line == ""

    if current_col == starting_col then
      goto continue
    elseif current_col > starting_col then
      return nodes.get_at_row(current_row), current_row, current_line
    elseif current_col < starting_col and not is_empty then
      break
    end

    ::continue:: -- gross
  end
end

---Get the nearest ancestral node _which has different coordinates than the passed in node_
---@param node TSNode
---@return TSNode | nil
function M.get_first_ancestor_with_diff_scol(node)
  local iter_ancestor = node:parent()
  while iter_ancestor do
    -- Without have_same_range, this will get stuck, where it targets one node, but is then
    -- interpreted by get_node() as another.
    if nodes.is_jump_target(iter_ancestor) and not nodes.have_same_start(node, iter_ancestor) then
      return iter_ancestor
    end

    iter_ancestor = iter_ancestor:parent()
  end
end

return M
