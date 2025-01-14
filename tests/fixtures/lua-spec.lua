local util = require("treewalker.util")
local stub = require('luassert.stub')
local assert = require("luassert")
local treewalker = require('treewalker')

local fixtures_dir = vim.fn.expand 'tests/fixtures'

-- Why not have a function in there, seems more real
local function assert_cursor_at(line, column)
  local cursor_pos = vim.fn.getpos('.')
  ---@type integer, integer
  local current_line, current_column
  current_line, current_column = cursor_pos[2], cursor_pos[3]
  assert.are.same({ line, column }, { current_line, current_column })
end

describe("Treewalker", function()
  describe("regular lua file", function()
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

    it(function()
      -- Deliberately messed up for testing's sake
      vim.fn.cursor(143, 1) -- In a bigger function
      treewalker.right()
      assert_cursor_at(144, 3)
      treewalker.right()
      assert_cursor_at(147, 5)
      treewalker.right()
      assert_cursor_at(149, 7)
    end, "goes into functions eagerly")

    -- woohoooo randomly commented out code
    -- it("goes out of functions", function()
    --   vim.fn.cursor(149, 7) -- In a bigger function
    --   treewalker.left()
    --   assert_cursor_at(148, 5)
    --   treewalker.left()
    --   assert_cursor_at(146, 3)
    --   treewalker.left()
    --   assert_cursor_at(143, 1)
    -- end)
  end)

  describe("lua spec file", function()
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
  end)
end)

-- #18/#19 not really test related but a good test case. Here b/c there was no more room
-- in lua.lua
local heads = {
  { "k", "<CMD>Treewalker SwapUp<CR>", { desc = "up" } },
}
