<span><img alt="Static Badge" src="https://img.shields.io/badge/100%25_lua-purple"></span>
<a href="https://neovim.io/"><img src="https://img.shields.io/badge/NeoVim-%2357A143.svg?&amp;style=for-the-badge&amp;logo=neovim&amp;logoColor=white" alt="Neovim"></a>

# treewalker.nvim

Treewalker is a plugin that gives you the ability to move around your code in a syntax tree aware manner.
It uses [Treesitter](https://github.com/tree-sitter/tree-sitter) under the hood for syntax tree awareness.
It offers four subcommands: Up, Down, Right, and Left. Each command moves through the syntax tree
in an intuitive way.

**Up/Down** - Moves up or down to the next neighbor node
**Right** - Finds the next good child node
**Left** - Finds the next good parent node

It sounds easy, but complications arise walking the syntax trees, such as overlap, node name inconsistencies, and significant shape differences.
This plugin stumbled twice before working smoothly in a variety of languages. At first I tried to rely solely on

---

### Installation

##### Lazy:
```lua
{
  "aaronik/treewalker.nvim"
}
```

##### Plug:
```vim
Plug "aaronik/treewalker.nvim"
```

#### Mapping

Here are some examples of how to map these -- these are what I use

in `init.lua`:
```lua
vim.api.nvim_set_keymap('n', '<C-j>', ':Treewalker Down<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-k>', ':Treewalker Up<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-h>', ':Treewalker Left<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-l>', ':Treewalker Right<CR>', { noremap = true })
```
