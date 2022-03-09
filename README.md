# Dim
**dim** is a lua plugin for neovim 0.7.0 dev to dim the unused variables and functions using lsp and treesitter.

<video src = "https://user-images.githubusercontent.com/79555780/157270883-da3120c8-b8b2-4036-8063-3b5ce10d4d88.mp4"></video>

## ✨ Features

- **dim** unused variables and functions using lsp and treesitter.

## ⚡️ Requirements

- Neovim >= 0.7.0 dev (should also work with 0.6 but haven't tested yet )

## 📦 Installation

Install the plugin with your preferred package manager:

### [packer](https://github.com/wbthomason/packer.nvim)

```lua
-- Lua
use {
  "narutoxy/dim.lua",
  requires = { "nvim-treesitter/nvim-treesitter", "neovim/nvim-lspconfig" },
  config = function()
    require('dim').setup({})
  end
}
```

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
" Vim Script
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'narutoxy/dim.lua'

lua require('dim').setup({})
```

## ⚙️ Configuratioon

Dim comes with the following defaults:

```lua
{
  disable_lsp_decorations = false -- disable virt text and underline by lsp on unused vars and functions
}
```

## Tested LSPs
| LSPs          | Status |
|---------------|--------|
| tsserver      | ✔️      | 
| sumneko_lua   | ✔️      | 
| rust_analyzer | ✔️      | 
