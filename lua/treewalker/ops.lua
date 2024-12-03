local util = require('treewalker.util')

local M = {}

---set cursor without throwing error
---@param row integer
---@param col integer
function M.safe_set_cursor(row, col)
  pcall(vim.api.nvim_win_set_cursor, 0, { row, col }) -- catch any errors in nvim_win_set_cursor
end

---Flash a highlight over the given range
---@param range Range4
function M.highlight(range)
  local start_row, start_col, end_row, end_col = range[1], range[2], range[3], range[4]
  local ns_id = vim.api.nvim_create_namespace("")
  -- local hl_group = "DiffAdd"
  -- local hl_group = "MatchParen"
  -- local hl_group = "Search"
  local hl_group = "ColorColumn"


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

---@param node WalkerNode
function M.jump(node)
  local start_row, start_col, end_row, end_col = node.range[1], node.range[2], node.range[3], node.range[4]
  util.log(string.format("dest: %s", node:print()))
  M.safe_set_cursor(start_row + 1, start_col)
  M.highlight({ start_row + 1, start_col, end_row + 1, end_col })
end

return M
