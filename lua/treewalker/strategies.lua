local lines = require('treewalker.lines')
local nodes = require('treewalker.nodes')

---@alias Dir "up" | "down"

-- Take lnum, give next lnum / node with same indentation
---@param current_lnum integer
---@param dir Dir
---@return integer | nil, TSNode | nil
local function get_next_jump_candidate(current_lnum, dir)
  local next_lnum
  if dir == "up" then
    next_lnum = current_lnum - 1
  else
    next_lnum = current_lnum + 1
  end
  local max_lnum = vim.api.nvim_buf_line_count(0)
  if next_lnum > max_lnum or next_lnum <= 0 then return end
  local current_line = lines.get_line(current_lnum)
  local current_indentation = lines.get_indent(current_line)
  local node_candidate = vim.treesitter.get_node({ pos = { next_lnum - 1, current_indentation } })
  return next_lnum, node_candidate
end

local M = {}

-- Skip unwanted nodes
-- TODO this should not jump to other functions
---@param dir Dir
---@param lnum integer
---@param indent integer
---@return integer | nil, string | nil, TSNode | nil
function M.get_next_vertical_target_at_same_indent(dir, lnum, indent)
  local candidate_lnum, candidate = get_next_jump_candidate(lnum, dir)
  local candidate_line = ""
  local candidate_indent = lines.get_indent(candidate_line)

  while candidate_lnum and candidate do
    if
        nodes.is_jump_target(candidate) -- only node types we consider jump targets
        and candidate_line ~= "" -- no empty lines
        and candidate_indent == indent -- stay at current indent level
    then
      break -- use most recent assignment below
    else
      candidate_line = lines.get_line(candidate_lnum)
      candidate_lnum, candidate = get_next_jump_candidate(candidate_lnum, dir)
      candidate_indent = lines.get_indent(candidate_line)
    end
  end

  return candidate_lnum, candidate_line, candidate
end

return M
