local util = require "treewalker.util"
local load_fixture = require "tests.load_fixture"
local stub = require 'luassert.stub'
local assert = require "luassert"
local tw = require 'treewalker'
local ops = require 'treewalker.ops'

-- Assert the cursor is in the expected position
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

describe("Movement in a regular lua file: ", function()
  load_fixture("/lua.lua")

  it("moves up and down at the same pace", function()
    vim.fn.cursor(1, 1) -- Reset cursor
    tw.move_down()
    assert_cursor_at(3, 1)
    tw.move_down()
    assert_cursor_at(5, 1)
    tw.move_down()
    assert_cursor_at(10, 1)
    tw.move_down()
    assert_cursor_at(21, 1)
    tw.move_up()
    assert_cursor_at(10, 1)
    tw.move_up()
    assert_cursor_at(5, 1)
    tw.move_up()
    assert_cursor_at(3, 1)
    tw.move_up()
    assert_cursor_at(1, 1)
  end)

  it("doesn't consider empty lines to be outer scopes", function()
    vim.fn.cursor(85, 1)
    tw.move_down()
    assert_cursor_at(88, 3, "local")
    vim.fn.cursor(85, 1)
    tw.move_up()
    assert_cursor_at(84, 3, "end")
  end)

  it("goes into functions eagerly", function()
    vim.fn.cursor(143, 1) -- In a bigger function
    tw.move_in()
    assert_cursor_at(144, 3)
    tw.move_in()
    assert_cursor_at(147, 5)
    tw.move_in()
    assert_cursor_at(149, 7)
  end)

  it("doesn't jump into a comment", function()
    vim.fn.cursor(177, 1)
    tw.move_in()
    assert_cursor_at(179, 3, "local")
  end)

  it("goes out of functions", function()
    vim.fn.cursor(149, 7)
    tw.move_out()
    assert_cursor_at(148, 5, "if")
    tw.move_out()
    assert_cursor_at(146, 3, "while")
    tw.move_out()
    assert_cursor_at(143, 1, "function")
  end)
end)

describe("Movement in a lua spec file: ", function()
  load_fixture("/lua-spec.lua")

  -- go to first describe
  local function go_to_describe()
    vim.fn.cursor(1, 1)
    for _ = 1, 6 do
      tw.move_down()
    end
    assert_cursor_at(17, 1, "describe")
  end

  -- go to first load_buf
  local function go_to_load_buf()
    go_to_describe()
    tw.move_in(); tw.move_in()
    assert_cursor_at(19, 5, "load_buf")
  end

  it("moves up and down at the same pace", function()
    go_to_load_buf()
    tw.move_down(); tw.move_down()
    assert_cursor_at(41, 5, "it")
    tw.move_up(); tw.move_up()
    assert_cursor_at(19, 5, "load_buf")
  end)

  it("down moves at least one line", function()
    go_to_load_buf()
    tw.move_down()
    assert_cursor_at(21, 5, "it")
  end)
end)
