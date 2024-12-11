local fixtures_dir = vim.fn.expand 'tests/fixtures'

-- Creates a buffer, and loads the contents of a specified filename into it.
-- Sets it as the current buffer
---@param filename string
---@param lang string same as filename extension, laziness was here
---@return integer
local function load_fixture(filename, lang)
  local buf = vim.api.nvim_create_buf(false, true) -- Create a new buffer (listed) to enable interaction with it
  local lines = {}

  -- Read the file contents line by line and insert into the buffer
  for line in io.lines(fixtures_dir .. "/" .. filename) do
    table.insert(lines, line)
  end

  -- Set the lines into the created buffer
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Focus on the buffer
  vim.api.nvim_set_current_buf(buf)

  -- create and attach the Tree-sitter parser for the specified language
  vim.treesitter.get_parser(buf, lang)

  return buf
end

return load_fixture
