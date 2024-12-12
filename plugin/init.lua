local util = require('treewalker.util')

local subcommands = {
  Up = function()
    -- util.R('treewalker').move_up()
    require('treewalker').move_up()
  end,

  Down = function()
    -- util.R('treewalker').move_down()
    require('treewalker').move_down()
  end,

  Left = function()
    -- util.R('treewalker').move_out()
    require('treewalker').move_out()
  end,

  Right = function()
    -- util.R('treewalker').move_in()
    require('treewalker').move_in()
  end,
}

local command_opts = {
  nargs = 1,
  complete = function(ArgLead, CmdLine, CursorPos)
    return vim.tbl_filter(function(cmd)
      return cmd:match("^" .. ArgLead)
    end, vim.tbl_keys(subcommands))
  end
}

function Treewalker(opts)
  local subcommand = opts.fargs[1]
  if subcommands[subcommand] then
    subcommands[subcommand](vim.list_slice(opts.fargs, 2))
  else
    print("Unknown subcommand: " .. subcommand)
  end
end

vim.api.nvim_create_user_command("Treewalker", Treewalker, command_opts)
