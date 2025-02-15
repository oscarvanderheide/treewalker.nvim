local lines = require('treewalker.lines')
local nodes = require('treewalker.nodes')

local M = {}

-- Gets the next target in the up/down directions
---@param dir "up" | "down"
---@param starting_row integer
---@param starting_col integer
---@return TSNode | nil, integer | nil, string | nil
function M.get_neighbor_at_same_col(dir, starting_row, starting_col)
  local candidate, candidate_row, candidate_line = nodes.get_from_neighboring_line(starting_row, dir)

  while candidate and candidate_row and candidate_line do
    local candidate_col = lines.get_start_col(candidate_line)
    local srow = candidate:range()
    if
        nodes.is_jump_target(candidate)   -- only node types we consider jump targets
        and candidate_line ~= ""          -- no empty lines
        and candidate_col == starting_col -- stay at current indent level
        and candidate_row == srow + 1     -- top of block; no end's or else's etc.
    then
      break                               -- use most recent assignment below
    else
      candidate, candidate_row, candidate_line = nodes.get_from_neighboring_line(candidate_row, dir)
    end
  end

  return candidate, candidate_row
end

-- Go down until there is a valid jump target to the right
---@param starting_row integer
---@param starting_col integer
---@return TSNode | nil, integer | nil, string | nil
function M.get_down_and_in(starting_row, starting_col)
  local last_row = vim.api.nvim_buf_line_count(0)

  if last_row == starting_row then return end

  for candidate_row = starting_row + 1, last_row, 1 do
    local candidate_line = lines.get_line(candidate_row)
    if not candidate_line then goto continue end
    local candidate_col = lines.get_start_col(candidate_line)
    local candidate = nodes.get_at_row(candidate_row)
    local is_empty = candidate_line == ""

    if candidate_col == starting_col or not candidate then
      goto continue
    elseif candidate_col > starting_col and nodes.is_jump_target(candidate) then
      return candidate, candidate_row, candidate_line
    elseif candidate_col < starting_col and not is_empty then
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
    if
        true
        and nodes.is_jump_target(iter_ancestor)
        and not nodes.have_same_scol(node, iter_ancestor)
    then
      return iter_ancestor
    end

    iter_ancestor = iter_ancestor:parent()
  end
end

-- Special case for when starting on empty line. In that case, find the next
-- line with stuff on it, and go to that.
---@param start_row integer
---@return TSNode | nil, integer | nil, string | nil
function M.get_next_if_on_empty_line(start_row)
  local start_line = lines.get_line(start_row)
  if start_line ~= "" then return end

  ---@type string | nil
  local current_line = start_line
  local max_row = vim.api.nvim_buf_line_count(0)
  local current_row = start_row
  local current_node = nodes.get_at_row(current_row)

  while
    true
    and current_line == ""
    or current_node and not nodes.is_jump_target(current_node)
    and current_row <= max_row
  do
    current_row = current_row + 1
    current_line = lines.get_line(current_row)
    current_node = nodes.get_at_row(current_row)
  end

  if current_row > max_row then return end

  return current_node, current_row, current_line
end

-- Special case for when starting on empty line. In that case, find the prev
-- line with stuff on it, and go to that.
---@param start_row integer
---@return TSNode | nil, integer | nil, string | nil
function M.get_prev_if_on_empty_line(start_row)
  local start_line = lines.get_line(start_row)
  if start_line ~= "" then return end

  ---@type string | nil
  local current_line = start_line
  local current_row = start_row
  local current_node = nodes.get_at_row(current_row)

  while
    true
    and current_line == ""
    or current_node and not nodes.is_jump_target(current_node)
    and current_row >= 0
  do
    current_row = current_row - 1
    current_line = lines.get_line(current_row)
    current_node = nodes.get_at_row(current_row)
  end

  if current_row < 0 then return end

  return current_node, current_row, current_line
end

-- Find the lowest ancestor node with a next sibling
---@param node TSNode
---@return TSNode | nil, TSNode | nil
function M.get_first_ancestor_with_next_named_sibling(node)
  local current = node

  local next = current:next_named_sibling()
  while not next do
    local parent = current:parent()
    if not parent then return end
    current = parent
    next = current:next_named_sibling()
  end

  return current, next
end

-- Find the lowest ancestor node with a previous sibling
---@param node TSNode
---@return TSNode | nil, TSNode | nil
function M.get_first_ancestor_with_previous_named_sibling(node)
  local current = node

  local prev = current:prev_named_sibling()
  while not prev do
    local parent = current:parent()
    if not parent then return end
    current = parent
    prev = current:prev_named_sibling()
  end

  return current, prev
end

-- Use this to get the whole string from inside of a string
-- returns nils if the passed in node is not a string node
---@param node TSNode
---@return TSNode | nil
function M.get_highest_string_node(node)
  ---@type TSNode | nil
  local highest = nil
  ---@type TSNode | nil
  local iter = node

  while iter do
    if string.match(iter:type(), "string") then
      highest = iter
    end
    iter = iter:parent()
  end

  return highest
end

return M
