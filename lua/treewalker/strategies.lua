local lines = require('treewalker.lines')
local nodes = require('treewalker.nodes')

---@alias Dir "up" | "down"

-- Take lnum, give next lnum / node with same indentation
---@param current_lnum integer
---@param dir Dir
---@return integer | nil, string | nil, TSNode | nil
local function get_next_jump_candidate(current_lnum, dir)
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
  return candidate_lnum, candidate_line, candidate
end

local M = {}

-- Skip unwanted nodes
-- TODO this should not jump to other functions
---@param dir Dir
---@param row integer
---@param col integer
---@return integer | nil, string | nil, TSNode | nil
function M.get_next_vertical_target_at_same_col(dir, row, col)
  local candidate_lnum, candidate_line, candidate = get_next_jump_candidate(row, dir)

  while candidate_lnum and candidate_line and candidate do
    local candidate_col = lines.get_start_col(candidate_line)
    local srow, scol, erow, ecol = candidate:range()
    if
        nodes.is_jump_target(candidate) -- only node types we consider jump targets
        and candidate_line ~= "" -- no empty lines
        and candidate_col == col -- stay at current indent level
        and candidate_lnum == srow + 1 -- top of block; no end's or else's etc.
    then
      break -- use most recent assignment below
    else
      candidate_lnum, candidate_line, candidate = get_next_jump_candidate(candidate_lnum, dir)
    end
  end

  return candidate_lnum, candidate_line, candidate
end

return M
