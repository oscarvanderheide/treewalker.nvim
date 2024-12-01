local util = require("treewalker.util")
local stub = require('luassert.stub')
local assert = require("luassert")
local treewalker = require('treewalker')

local fixtures_dir = vim.fn.expand 'tests/fixtures'

---@param filename string
---@param lang string
---@return nil
local function load_buf(filename, lang)
  local buf = vim.api.nvim_create_buf(false, true) -- Create a new buffer (listed) to enable interaction with it
  local lines = {}

  -- Read the file contents line by line and insert into the buffer
  for line in io.lines(filename) do
    table.insert(lines, line)
  end

  -- Set the lines into the created buffer
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Focus on the buffer
  vim.api.nvim_set_current_buf(buf)

  -- create and attach the Tree-sitter parser for the specified language
  vim.treesitter.get_parser(buf, lang)
end

-- Assert the cursor is in the expected position
---i
---@param line integer
---@param column integer
---@param msg string?
local function assert_cursor_at(line, column, msg)
  local cursor_pos = vim.fn.getpos('.')
  ---@type integer, integer
  local current_line, current_column
  current_line, current_column = cursor_pos[2], cursor_pos[3]
  msg = string.format("expected to be at [%s] but wasn't", msg)
  assert.are.same({ line, column }, { current_line, current_column }, msg)
end

describe("Treewalker", function()
  describe("regular lua file: ", function()
    load_buf(fixtures_dir .. "/lua.lua", "lua")

    it("moves up and down at the same pace", function()
      vim.fn.cursor(1, 1) -- Reset cursor
      treewalker.down()
      assert_cursor_at(3, 1)
      treewalker.down()
      assert_cursor_at(5, 1)
      treewalker.down()
      assert_cursor_at(10, 1)
      treewalker.down()
      assert_cursor_at(21, 1)
      treewalker.up()
      assert_cursor_at(10, 1)
      treewalker.up()
      assert_cursor_at(5, 1)
      treewalker.up()
      assert_cursor_at(3, 1)
      treewalker.up()
      assert_cursor_at(1, 1)
    end)

    it("goes into functions eagerly", function()
      vim.fn.cursor(143, 1) -- In a bigger function
      treewalker.right()
      assert_cursor_at(144, 3)
      treewalker.right()
      assert_cursor_at(147, 5)
      treewalker.right()
      assert_cursor_at(149, 7)
    end)

    it("goes out of functions", function()
      vim.fn.cursor(149, 7) -- In a bigger function
      treewalker.left()
      assert_cursor_at(148, 5)
      treewalker.left()
      assert_cursor_at(146, 3)
      treewalker.left()
      assert_cursor_at(143, 1)
    end)
  end)

  describe("lua spec file: ", function()
    load_buf(fixtures_dir .. "/lua-spec.lua", "lua")

    local function go_to_describe()
      vim.fn.cursor(1, 1)
      for _ = 1, 6 do
        treewalker.down()
      end
      assert_cursor_at(17, 1, "describe")
    end

    local function go_to_load_buf()
      go_to_describe()
      treewalker.right(); treewalker.right()
      assert_cursor_at(19, 5, "load_buf")
    end

    it("moves up and down at the same pace", function()
      go_to_load_buf()
      treewalker.down(); treewalker.down()
      assert_cursor_at(21, 5, "it")
      treewalker.up(); treewalker.up()
      assert_cursor_at(19, 5, "load_buf")
    end)

    it("down moves at least one line", function()
      go_to_load_buf()
      treewalker.down()
      assert_cursor_at(21, 5, "it")
    end)

  end)
end)

-- Try one of these test files
-- Try rs
-- Try rb class
-- Try rb config
-- Try rb jsx
