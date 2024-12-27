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

Treewalker.move_up = movement.move_up
Treewalker.move_out = movement.move_out
Treewalker.move_down = movement.move_down
Treewalker.move_in = movement.move_in

Treewalker.swap_up = swap.swap_up
Treewalker.swap_down = swap.swap_down

return Treewalker
