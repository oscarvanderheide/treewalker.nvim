<a href="https://neovim.io/" style="vertical-align: middle;"><img src="https://img.shields.io/badge/NeoVim-%2357A143.svg?&amp;style=for-the-badge&amp;logo=neovim&amp;logoColor=white" alt="Neovim" style="height: 20px;"></a>
<span style="height: 20px;">
  <img alt="Static Badge" src="https://img.shields.io/badge/100%25_lua-purple" style="height: 20px;">
</span>
![build status](https://github.com/aaronik/treewalker.nvim/actions/workflows/test.yml/badge.svg)
![GitHub Issues or Pull Requests](https://img.shields.io/github/issues/aaronik/treewalker.nvim)
![GitHub Issues or Pull Requests](https://img.shields.io/github/issues-pr/aaronik/treewalker.nvim)

# Treewalker.nvim

![A fast paced demo of Treewalker.nvim](https://github.com/user-attachments/assets/4d23af49-bd94-412a-bc8c-d546df6775df)

Treewalker is a plugin that lets you **move around your code in a syntax tree aware manner**.
It uses neovim's native [Treesitter](https://github.com/tree-sitter/tree-sitter) under the hood for syntax tree awareness.
It has no dependencies, and is meant to "just work". It is "batteries included", with minimal configuration.

---

### Movement

The movement commands move you through the syntax tree in an intuitive way:

* **Up/Down** - Moves you up or down to the next neighbor node, skipping comments, annotations, and other unintuitive nodes
* **Right** - Moves to the next node that's indented further than the current node
* **Left** - Moves to the next ancestor node that's on a different line from the current node

---

### Swapping

The swap commands swap nodes, but up/down bring along any comments, annotations, or decorators associated with that node:

* **SwapUp/SwapDown** - Swaps nodes up or down in your document (so neighbor nodes), _bringing comments, annotations, and decorators._
                        These swaps will only bring stuff up and down relative to the document itself, so it'll only change nodes
                        _across different line numbers_. These are meant for swapping declarations and definitions.
* **SwapLeft/SwapRight** - These also swap neighbor nodes, but are literal about the definition of a node, whereas the up/down swaps
                           and movement take a lot of liberty to be "smart". Swap{Left/Right} are meant for swapping function arguments,
                           enum members, list elements, etc.

   _There are other plugins that do mostly this Left/Right swapping behavior:_

   [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects) - This can move around [a subset
   of nodes](https://github.com/nvim-treesitter/nvim-treesitter-textobjects?tab=readme-ov-file#built-in-textobjects), but misses some
   types (ex. rust enums). `Treewalker` is not aware of node type names, only the structure of the AST, so left/right swaps will work
   everywhere you want it to.

   [nvim-treesitter.ts_utils](https://github.com/nvim-treesitter/nvim-treesitter/blob/master/lua/nvim-treesitter/ts_utils.lua) - This doesn't
   suffer from node name awareness, and works mostly the same as `Treewalker`. Some of `Treewalker`'s left/right swapping code is even
   inspired by `ts_utils`. However `Treewalker` offers one fundamental difference - when it picks the "current node", the first of the two
   nodes to swap, it finds the _widest node with the same start point_. `ts_utils` finds the smallest node. This is a subtle difference,
   but ends up having a big effect on the intuitiveness of swapping.


---

### More Examples

<details>
<summary>Typing out the Move commands manually</summary>
<img src="static/slow_move_demo.gif" alt="A demo of moving around some code slowly typing out each Treewalker move command">
</details>

<details>
<summary>Typing out the SwapUp/SwapDown commands manually</summary>
<img src="static/slow_swap_demo.gif" alt="A demo of swapping code slowly using Treewalker swap commands">
</details>

---

### Installation

#### [Lazy](https://github.com/folke/lazy.nvim)
```lua
{
  'aaronik/treewalker.nvim',

  -- The following options are the defaults.
  -- Treewalker aims for sane defaults, so these are each individually optional,
  -- and setup() does not need to be called, so the whole opts block is optional as well.
  opts = {
    -- Whether to briefly highlight the node after jumping to it
    highlight = true,

    -- How long should above highlight last (in ms)
    highlight_duration = 250,

    -- The color of the above highlight. Must be a valid vim highlight group.
    -- (see :h highlight-group for options)
    highlight_group = 'CursorLine',
  }
}
```

#### [Packer](https://github.com/wbthomason/packer.nvim)
```lua
use {
  'aaronik/treewalker.nvim',

  -- The setup function is optional, defaults are meant to be sane
  -- and setup does not need to be called
  setup = function()
      require('treewalker').setup({
        -- Whether to briefly highlight the node after jumping to it
        highlight = true,

        -- How long should above highlight last (in ms)
        highlight_duration = 250,

        -- The color of the above highlight. Must be a valid vim highlight group.
        -- (see :h highlight-group for options)
        highlight_group = 'CursorLine',
      })
  end
}
```

#### [Vim-plug](https://github.com/junegunn/vim-plug)
```vimscript
Plug 'aaronik/treewalker.nvim'

" This line is optional
:lua require('treewalker').setup({ highlight = true, highlight_duration = 250, highlight_group = 'CursorLine' })
```

---

### Mapping

I've found Ctrl - h / j / k / l to be a really natural flow for this plugin, and adding
Shift to that for swapping just felt so clean. So here are the mappings I use:

In `init.lua`:

```lua
-- movement
vim.keymap.set({ 'n', 'v' }, '<C-k>', '<cmd>Treewalker Up<cr>', { silent = true })
vim.keymap.set({ 'n', 'v' }, '<C-j>', '<cmd>Treewalker Down<cr>', { silent = true })
vim.keymap.set({ 'n', 'v' }, '<C-l>', '<cmd>Treewalker Right<cr>', { silent = true })
vim.keymap.set({ 'n', 'v' }, '<C-h>', '<cmd>Treewalker Left<cr>', { silent = true })

-- swapping
vim.keymap.set('n', '<C-S-j>', '<cmd>Treewalker SwapDown<cr>', { silent = true })
vim.keymap.set('n', '<C-S-k>', '<cmd>Treewalker SwapUp<cr>', { silent = true })
vim.keymap.set('n', '<C-S-l>', '<cmd>Treewalker SwapRight<CR>', { silent = true })
vim.keymap.set('n', '<C-S-h>', '<cmd>Treewalker SwapLeft<CR>', { silent = true })
```

