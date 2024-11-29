-- This file soas to get access to whether in visual mode or not
--
-- via https://www.petergundel.de/neovim/lua/hack/2023/12/17/get-neovim-mode-when-executing-a-command.html

local util = require('treewalker.util')

function Up()
  util.R('treewalker.main').up()
end

function Down()
  util.R('treewalker.main').down()
end

function Left()
  util.R('treewalker.main').left()
end

function Right()
  util.R('treewalker.main').right()
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

