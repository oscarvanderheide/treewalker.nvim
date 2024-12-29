local movement = require('treewalker.movement')
local swap = require('treewalker.swap')

local Treewalker = {}

---@alias Opts { highlight: boolean, highlight_duration: integer, highlight_group: string }

-- Default setup() options
---@type Opts
Treewalker.opts = {
  highlight = true,
  highlight_duration = 250,
  highlight_group = "ColorColumn",
}

-- This does not need to be called for Treewalker to work. The defaults are preinitialized and aim to be sane.
---@param opts Opts | nil
function Treewalker.setup(opts)
  if opts then
    Treewalker.opts = vim.tbl_deep_extend('force', Treewalker.opts, opts)
  end
end

---@param fn function
local function ensuring_parser(fn)
  return function()
    local ft = vim.bo.ft
    if vim.treesitter.language.get_lang(ft) then
      fn()
    else
      vim.notify_once(
        string.format("Missing parser for %s files! Treewalker.nvim won't work until one is installed.", ft),
        vim.log.levels.ERROR
      )
    end
  end
end

Treewalker.move_up = ensuring_parser(movement.move_up)
Treewalker.move_out = ensuring_parser(movement.move_out)
Treewalker.move_down = ensuring_parser(movement.move_down)
Treewalker.move_in = ensuring_parser(movement.move_in)

Treewalker.swap_up = ensuring_parser(swap.swap_up)
Treewalker.swap_down = ensuring_parser(swap.swap_down)

return Treewalker
