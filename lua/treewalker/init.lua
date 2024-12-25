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

-- TODO This is clever kinda, but it breaks autocomplete of `require('treewalker')`

-- Assign move_{in,out,up,down}
for fn_name, fn in pairs(movement) do
  Treewalker[fn_name] = fn
end

-- Assign swap_{up,down}
for fn_name, fn in pairs(swap) do
  Treewalker[fn_name] = fn
end

return Treewalker
