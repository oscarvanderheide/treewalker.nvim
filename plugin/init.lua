-- This file soas to get access to whether in visual mode or not
--
-- via https://www.petergundel.de/neovim/lua/hack/2023/12/17/get-neovim-mode-when-executing-a-command.html

local util = require('treewalker.util')

function Up(opts, preview_ns, preview_buffer)
  util.R('treewalker.main').up()
end

function Down(opts, preview_ns, preview_buffer)
  util.R('treewalker.main').down()
end

function Left(opts, preview_ns, preview_buffer)
  util.R('treewalker.main').left()
end

function Right(opts, preview_ns, preview_buffer)
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

