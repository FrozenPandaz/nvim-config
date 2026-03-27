# nvim-config

My Neovim configuration — a single `init.lua` file managed with [lazy.nvim](https://github.com/folke/lazy.nvim).

## Plugins

| Plugin | Purpose |
|--------|---------|
| **neo-tree** | File tree sidebar |
| **telescope** | Fuzzy finder for files, grep, buffers |
| **treesitter** | Syntax highlighting and code folding |
| **nvim-lspconfig + mason** | LSP with auto-installed servers (TS, Lua, JSON, YAML) |
| **nvim-cmp** | Autocompletion (LSP, buffer, path, snippets) |
| **conform** | Auto-format on save (prettier, stylua) |
| **trouble** | Diagnostics panel |
| **gitsigns** | Git diff markers in the gutter |
| **lazygit** | Full git UI inside Neovim |
| **git-conflict** | Inline merge conflict resolver |
| **leap** | Jump anywhere with 2 keystrokes |
| **vim-visual-multi** | Multi-cursor editing (Ctrl-n) |
| **Comment.nvim** | Toggle comments (gcc / gc) |
| **nvim-autopairs** | Auto-close brackets and quotes |
| **indent-blankline** | Indent guide lines |
| **which-key** | Keybinding cheatsheet popup |
| **lualine** | Status bar |
| **tokyonight** | Color scheme |

## Key Bindings

Leader key: `Space`

| Key | Action |
|-----|--------|
| `<leader>e` | Toggle file tree |
| `<leader>ff` | Find files (git) |
| `<leader>fg` | Live grep |
| `<leader>fb` | Find buffers |
| `<leader>fr` | Recent files |
| `gd` | Go to definition |
| `gr` | Find references |
| `K` | Hover docs |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code actions |
| `<leader>gg` | Open LazyGit |
| `<leader>/` | Toggle comment |
| `s` / `S` | Leap forward / backward |
| `<CR>` | Start/expand selection |
| `<BS>` | Shrink selection (visual) |
| `Ctrl-s` | Save |
| `q` | Quit |

## Setup

### Prerequisites

1. **Neovim 0.11+** — [install instructions](https://github.com/neovim/neovim/blob/master/INSTALL.md)
2. **A Nerd Font** — needed for file icons (e.g. [JetBrains Mono Nerd Font](https://www.nerdfonts.com/font-downloads)). Set it as your terminal font after installing.
3. **ripgrep** — required by Telescope for live grep
   ```
   # Windows (scoop)
   scoop install ripgrep

   # macOS
   brew install ripgrep

   # Ubuntu/Debian
   sudo apt install ripgrep
   ```
4. **Node.js** — needed for the TypeScript/JSON/YAML language servers and prettier
5. **git** — for lazy.nvim to clone plugins

### Install

Back up any existing config, then clone:

```bash
# Windows (PowerShell)
mv ~/AppData/Local/nvim ~/AppData/Local/nvim.bak  # backup existing config
git clone git@github.com:FrozenPandaz/nvim-config.git ~/AppData/Local/nvim

# macOS / Linux
mv ~/.config/nvim ~/.config/nvim.bak  # backup existing config
git clone git@github.com:FrozenPandaz/nvim-config.git ~/.config/nvim
```

### First launch

1. Open Neovim (`nvim`) — lazy.nvim will bootstrap itself and install all plugins automatically
2. Wait for plugin installation to finish, then restart Neovim
3. Mason will auto-install LSP servers on first use. Run `:Mason` to check progress
4. Open a TypeScript/Lua file to verify LSP is working — you should see autocompletion and `gd` (go to definition) should work

### Optional tools

- **lazygit** — for the `<leader>gg` integration: [install instructions](https://github.com/jesseduffield/lazygit#installation)
- **prettier** — for auto-format on save: `npm install -g prettier`
- **stylua** — for Lua formatting: `cargo install stylua` or download from [releases](https://github.com/JohnnyMorganz/StyLua/releases)
