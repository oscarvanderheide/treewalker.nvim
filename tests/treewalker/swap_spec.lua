local load_fixture = require "tests.load_fixture"
local assert = require "luassert"
local tw = require 'treewalker'
local lines = require 'treewalker.lines'
local helpers = require 'tests.treewalker.helpers'

describe("Swapping in a regular lua file:", function()
  before_each(function()
    load_fixture("/lua.lua")
  end)

  it("swap down bails early if user is on empty top level line", function()
    local lines_before = lines.get_lines(0, -1)
    vim.fn.cursor(2, 1) -- empty line
    tw.swap_down()
    local lines_after = lines.get_lines(0, -1)
    helpers.assert_cursor_at(2, 1) -- unchanged
    assert.same(lines_after, lines_before)
  end)

  it("swap up bails early if user is on empty top level line", function()
    local lines_before = lines.get_lines(0, -1)
    vim.fn.cursor(2, 1) -- empty line
    tw.swap_up()
    local lines_after = lines.get_lines(0, -1)
    helpers.assert_cursor_at(2, 1) -- unchanged
    assert.same(lines_after, lines_before)
  end)

  it("swap down bails early if user is on empty line in function", function()
    local lines_before = lines.get_lines(0, -1)
    vim.fn.cursor(51, 1)
    tw.swap_down()
    local lines_after = lines.get_lines(0, -1)
    helpers.assert_cursor_at(51, 1) -- unchanged
    assert.same(lines_after, lines_before)
  end)

  it("swap up bails early if user is on empty line in function", function()
    local lines_before = lines.get_lines(0, -1)
    vim.fn.cursor(51, 1) -- empty line
    tw.swap_up()
    local lines_after = lines.get_lines(0, -1)
    helpers.assert_cursor_at(51, 1) -- unchanged
    assert.same(lines_after, lines_before)
  end)

  it("swaps down one liners without comments", function()
    vim.fn.cursor(1, 1)
    tw.swap_down()
    assert.same({
      "local M = {}",
      "",
      "local util = require('treewalker.util')"
    }, lines.get_lines(1, 3))
    helpers.assert_cursor_at(3, 1)
  end)

  it("swaps up one liners without comments", function()
    vim.fn.cursor(3, 1)
    tw.swap_up()
    assert.same({
      "local M = {}",
      "",
      "local util = require('treewalker.util')",
    }, lines.get_lines(1, 3))
    helpers.assert_cursor_at(1, 1)
  end)

  it("swaps down when one has comments", function()
    vim.fn.cursor(21, 1)
    tw.swap_down()
    assert.same({ "local function is_descendant_jump_target(node)" }, lines.get_lines(19, 19))
    assert.same({ "---@param node TSNode" }, lines.get_lines(23, 23))
    helpers.assert_cursor_at(25, 1)
  end)

  it("swaps up when one has comments", function()
    vim.fn.cursor(21, 1)
    tw.swap_up()
    assert.same({
      "---@param node TSNode",
      "---@return boolean",
      "local function is_jump_target(node)",
    }, lines.get_lines(10, 12))
    helpers.assert_cursor_at(12, 1)
  end)

  it("swaps down when both have comments", function()
    vim.fn.cursor(38, 1)
    tw.swap_down()
    assert.same({
      "---Strictly sibling, no fancy business",
      "---@param node TSNode",
      "---@return TSNode | nil",
      "local function get_prev_sibling(node)"
    }, lines.get_lines(34, 37))
    assert.same({
      "---Do the nodes have the same starting point",
      "---@param node1 TSNode",
      "---@param node2 TSNode",
      "---@return boolean",
      "local function have_same_range(node1, node2)"
    }, lines.get_lines(49, 53))
    helpers.assert_cursor_at(53, 1)
  end)

  it("swaps up when both have comments", function()
    vim.fn.cursor(49, 1)
    tw.swap_up()
    assert.same({
      "---Strictly sibling, no fancy business",
      "---@param node TSNode",
      "---@return TSNode | nil",
      "local function get_prev_sibling(node)"
    }, lines.get_lines(34, 37))
    assert.same({
      "---Do the nodes have the same starting point",
      "---@param node1 TSNode",
      "---@param node2 TSNode",
      "---@return boolean",
      "local function have_same_range(node1, node2)"
    }, lines.get_lines(49, 53))
    helpers.assert_cursor_at(37, 1)
  end)
end)

describe("Swapping in a markdown file:", function()
  before_each(function()
    -- TODO This is a hack, really should be able to load a md file. Fix this.
    load_fixture("/lua.lua")
    vim.bo[0].filetype = "markdown"
  end)

  it("turns off in md files (doesn't work at all there, doesn't need to)", function()
    local lines_before = lines.get_lines(0, -1)
    tw.swap_up()
    tw.swap_down()
    local lines_after = lines.get_lines(0, -1)
    assert.same(lines_after, lines_before)
  end)
end)
