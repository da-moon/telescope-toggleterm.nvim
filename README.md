<h1 align="center">telescope-toggleterm</h1>
<div align="center"><p>
    <a href="https://github.com/da-moon/telescope-toggleterm.nvim/pulse">
      <img src="https://img.shields.io/github/last-commit/da-moon/telescope-toggleterm.nvim?color=%4dc71f&label=Last%20Commit&logo=github&style=flat-square"/>
    </a>
    <a href="https://github.com/da-moon/telescope-toggleterm.nvim/blob/main/LICENSE">
      <img src="https://img.shields.io/github/license/da-moon/telescope-toggleterm.nvim?label=License&logo=MIT&style=flat-square"/>
    </a>
    <a href="https://builds.sr.ht/~havi/telescope-toggleterm.nvim/commits/.build.yml?">
      <img src="https://builds.sr.ht/~havi/telescope-toggleterm.nvim/commits/.build.yml.svg"/>
    </a>
    <a href="https://neovim.io/">
      <img src="https://img.shields.io/badge/Neovim-0.6+-blueviolet.svg?style=flat-square&logo=Neovim&logoColor=white"/>
    </a>
</p>
</div>

<p align="center">
A simple Telescope extension to manage Terminal buffers
</p>

## ✨ Features

- List and switch between all terminal buffers opened with `toggleterm.nvim`.
- Kill terminal buffers easily with keybindings.
- Open buffer picker with `:Telescope toggleterm`
or `lua require('telescope-toggleterm').open()`

## ⚡ Requirements

- [`telescope`](https://github.com/nvim-telescope/telescope.nvim) plugin.
- [`nvim-toggleterm`](https://github.com/akinsho/nvim-toggleterm.lua) plugin.

## 🛠️ Installation

```lua
use {
  "https://git.sr.ht/~havi/telescope-toggleterm.nvim",
  event = "TermOpen",
  requires = {
     "akinsho/nvim-toggleterm.lua",
     "nvim-telescope/telescope.nvim",
     "nvim-lua/popup.nvim",
     "nvim-lua/plenary.nvim",
  },
  config = function()
     require("telescope").load_extension "toggleterm"
  end,
}
```

## ⚙️ Configuration

```lua
require("telescope-toggleterm").setup {
   telescope_mappings = {
      -- <ctrl-c> : kill the terminal buffer (default) .
      ["<C-c>"] = require("telescope-toggleterm").actions.exit_terminal,
   },
}
```

<div align="center" id="madewithlua">

[![Lua](https://img.shields.io/badge/Made%20with%20Lua-blue.svg?style=for-the-badge&logo=lua)](https://lua.org)

</div>
