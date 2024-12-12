local lines = require('treewalker.lines')
local nodes = require('treewalker.nodes')
local util  = require('treewalker.util')

---@alias Dir "up" | "down"

-- Take lnum, give next lnum / node with same indentation
---@param current_lnum integer
---@param dir Dir
---@return TSNode | nil, integer | nil, string | nil
local function get_node_from_neighboring_line(current_lnum, dir)
  local candidate_lnum
  if dir == "up" then
    candidate_lnum = current_lnum - 1
  else
    candidate_lnum = current_lnum + 1
  end
  local max_lnum = vim.api.nvim_buf_line_count(0)
  if candidate_lnum > max_lnum or candidate_lnum <= 0 then return end
  local candidate_line = lines.get_line(candidate_lnum)
  local candidate_col = lines.get_start_col(candidate_line)
  local candidate = vim.treesitter.get_node({ pos = { candidate_lnum - 1, candidate_col } })
  return candidate, candidate_lnum, candidate_line
end

local M = {}

-- Gets the next target in the up/down directions
-- TODO this should not jump to other functions
---@param dir Dir
---@param starting_row integer
---@param starting_col integer
---@return TSNode | nil, integer | nil, string | nil
function M.get_next_vertical_target_at_same_col(dir, starting_row, starting_col)
  local candidate, candidate_lnum, candidate_line = get_node_from_neighboring_line(starting_row, dir)

  while candidate_lnum and candidate_line and candidate do
    local candidate_col = lines.get_start_col(candidate_line)
    local srow = candidate:range()
    if
        nodes.is_jump_target(candidate) -- only node types we consider jump targets
        and candidate_line ~= "" -- no empty lines
        and candidate_col == starting_col -- stay at current indent level
        and candidate_lnum == srow + 1 -- top of block; no end's or else's etc.
    then
      break -- use most recent assignment below
    else
      candidate, candidate_lnum, candidate_line = get_node_from_neighboring_line(candidate_lnum, dir)
    end
  end

  return candidate, candidate_lnum, candidate_line
end

---@param starting_row integer
---@param starting_col integer
---@return TSNode | nil, integer | nil, string | nil
function M.get_down_and_in(starting_row, starting_col)
  local node = get_node_from_neighboring_line(starting_row, "down")
  assert(node)
  local queue = nodes.get_children(node)

  while #queue > 0 do
    local current_node = table.remove(queue, 1)
    local current_srow, current_scol = current_node:range()
    current_srow = current_srow + 1

    local is_on_same_line = current_srow == starting_row
    local is_above = current_srow < starting_row
    local has_same_col = current_scol == starting_col

    if
      true -- just so they can be individually commented out

      -- always changing a line number
      and not is_on_same_line

      -- no jumping to outer nodes. There may be a better way to do this.
      and not is_above

      -- only going in, not just down one
      and not has_same_col
    then
      return current_node, current_srow, lines.get_line(current_srow)
    end

    queue = util.merge_tables(queue, nodes.get_children(current_node))
  end
end

---Get the next target descendent
---The idea here is it goes _in_ or _down and in_
---@param node TSNode
---@return TSNode | nil
function M.get_descendant(node)
  local queue = nodes.get_children(node)

  while #queue > 0 do
    local current_node = table.remove(queue, 1)

    if nodes.is_descendant_jump_target(current_node) then
      return current_node
    end

    queue = util.merge_tables(queue, nodes.get_children(current_node))
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

return M
