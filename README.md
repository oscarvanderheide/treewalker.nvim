<span><img alt="Static Badge" src="https://img.shields.io/badge/100%25_lua-purple"></span>
<a href="https://neovim.io/"><img src="https://img.shields.io/badge/NeoVim-%2357A143.svg?&amp;style=for-the-badge&amp;logo=neovim&amp;logoColor=white" alt="Neovim"></a>

# treewalker.nvim

### A simple plugin that allows easy navigation around the abstract syntax tree

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

_(Contributions to this readme for how to do other package managers are welcome)_

#### Mapping - TODO

Here are some examples of how to map these -- this is what I use, `<leader>a` for the code window and `<leader>c` for the chat

in `init.lua`:
```lua
-- Both visual and normal mode for each, so you can open with a visual selection or without.
vim.api.nvim_set_keymap('v', '<leader>a', ':GPTModelsCode<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>a', ':GPTModelsCode<CR>', { noremap = true })

vim.api.nvim_set_keymap('v', '<leader>c', ':GPTModelsChat<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>c', ':GPTModelsChat<CR>', { noremap = true })
```

in `.vimrc`:
```vim
" Or if you prefer the traditional way
nnoremap <leader>a :GPTModelsCode<CR>
vnoremap <leader>a :GPTModelsCode<CR>

nnoremap <leader>c :GPTModelsChat<CR>
vnoremap <leader>c :GPTModelsChat<CR>
```
