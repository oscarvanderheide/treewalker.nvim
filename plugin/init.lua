local util = require('treewalker.util')

function Up()
  -- util.R('treewalker').move_up()
  require('treewalker').move_up()
end

function Down()
  -- util.R('treewalker').move_down()
  require('treewalker').move_down()
end

function Left()
  -- util.R('treewalker').move_out()
  require('treewalker').move_out()
end

function Right()
  -- util.R('treewalker').move_in()
  require('treewalker').move_in()
end

vim.api.nvim_create_user_command(
  "TreewalkerUp",
  Up,
  { nargs = "?", range = "%", addr = "lines" }
)

vim.api.nvim_create_user_command(
  "TreewalkerDown",
  Down,
  { nargs = "?", range = "%", addr = "lines" }
)

vim.api.nvim_create_user_command(
  "TreewalkerLeft",
  Left,
  { nargs = "?", range = "%", addr = "lines" }
)

vim.api.nvim_create_user_command(
  "TreewalkerRight",
  Right,
  { nargs = "?", range = "%", addr = "lines" }
)

