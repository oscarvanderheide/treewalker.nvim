local assert = require('luassert')

local M = {}

-- Assert the cursor is in the expected position
---@param row integer
---@param col integer
---@param line string?
function M.assert_cursor_at(row, col, line)
  local cursor_pos = vim.fn.getpos('.')
  ---@type integer, integer
  local current_line, current_column
  current_line, current_column = cursor_pos[2], cursor_pos[3]
  line = string.format("expected to be at [%s/%s](%s) but wasn't", row, col, line)
  assert.same({ row, col }, { current_line, current_column }, line)
end

-- Feed keys to neovim; keys are pressed no matter what vim mode or state
---@param keys string
---@return nil
M.feed_keys = function(keys)
  local termcodes = vim.api.nvim_replace_termcodes(keys, true, true, true)
  vim.api.nvim_feedkeys(termcodes, 'mtx', false)
end

return M
