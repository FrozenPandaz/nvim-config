-- Basic Settings
vim.opt.number = true           -- Show line numbers
vim.opt.relativenumber = true   -- Relative line numbers
vim.opt.mouse = 'a'             -- Enable mouse
vim.opt.ignorecase = true       -- Case insensitive search
vim.opt.smartcase = true        -- Unless uppercase is used
vim.opt.tabstop = 2             -- Tab width
vim.opt.shiftwidth = 2          -- Indent width
vim.opt.expandtab = true        -- Use spaces instead of tabs
vim.opt.termguicolors = true    -- Enable full color support
vim.opt.hlsearch = true          -- Highlight search matches
vim.opt.incsearch = true         -- Show matches while typing

-- Folding settings - use indent-based folding (simpler, always works)
vim.opt.foldmethod = 'indent'
vim.opt.foldenable = true       -- Enable folding
vim.opt.foldlevel = 99          -- Open all folds by default
vim.opt.foldlevelstart = 99     -- Start with all folds open

-- Switch to treesitter folding after it loads (if available)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript", "javascript", "lua", "rust", "python", "json" },
  callback = function()
    local has_ts, _ = pcall(vim.treesitter.get_parser)
    if has_ts then
      vim.opt_local.foldmethod = 'expr'
      vim.opt_local.foldexpr = 'nvim_treesitter#foldexpr()'
      print("Treesitter folding enabled for " .. vim.bo.filetype)
    else
      print("Using indent folding for " .. vim.bo.filetype)
    end
  end,
})

-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Setup plugins
require("lazy").setup({
  -- File tree (neo-tree - richer UI with git status, buffers view, etc.)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        filesystem = {
          follow_current_file = { enabled = true },
          filtered_items = {
            visible = true,
            hide_dotfiles = false,
          },
        },
        window = {
          width = 30,
        },
      })
    end,
  },

  -- Treesitter for better syntax and folding
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup()
      -- Auto-install parsers for these languages
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "lua", "typescript", "javascript", "json", "yaml", "markdown" },
        callback = function(ev)
          pcall(function() vim.treesitter.start(ev.buf) end)
        end,
      })
    end,
  },


  -- Telescope fuzzy finder
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-ui-select.nvim',
    },
    config = function()
      require('telescope').setup({
        defaults = {
          layout_config = {
            horizontal = {
              preview_width = 0.55,
            },
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      })
      require('telescope').load_extension('ui-select')
    end,
  },

  -- Leap - jump to any location with 2 keystrokes (like Ace Jump)
  {
    url = 'https://codeberg.org/andyg/leap.nvim',
    config = function()
      local leap = require('leap')
      -- Add mappings manually (add_default_mappings is deprecated)
      vim.keymap.set({'n', 'x', 'o'}, 's',  '<Plug>(leap-forward)')
      vim.keymap.set({'n', 'x', 'o'}, 'S',  '<Plug>(leap-backward)')
      vim.keymap.set({'n', 'x', 'o'}, 'gs', '<Plug>(leap-from-window)')
    end,
  },

  -- Mason - auto-installs LSP servers (like a package manager for language tools)
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "ts_ls", "lua_ls", "jsonls", "yamlls" },
      })
    end,
  },

  -- LSP configs from nvim-lspconfig (used as a config source, not the old setup() API)
  { "neovim/nvim-lspconfig", dependencies = { "williamboman/mason-lspconfig.nvim" } },

  -- Autocomplete
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",   -- LSP completions
      "hrsh7th/cmp-buffer",     -- Words from current buffer
      "hrsh7th/cmp-path",       -- File path completions
      "L3MON4D3/LuaSnip",       -- Snippet engine (required)
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
          { name = 'path' },
        }),
      })
    end,
  },

  -- Lualine - status bar showing git branch, file type, position, etc.
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "tokyonight",
          section_separators = { left = '', right = '' },
          component_separators = { left = '', right = '' },
        },
        sections = {
          lualine_a = { { 'filename', path = 1 } },
          lualine_b = { 'location' },
          lualine_c = { { 'diagnostics', color = { bg = 'NONE' } } },
          lualine_x = { { 'progress', color = { bg = 'NONE' } } },
          lualine_y = { 'branch' },
          lualine_z = { 'diff' },
        },
      })
    end,
  },

  -- Gitsigns - git diff markers in the gutter
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },

  -- Git conflict resolver - inline conflict picker (like VS Code)
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    config = function()
      require("git-conflict").setup()
    end,
  },

  -- Conform - auto-format on save (like prettier in VS Code)
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          javascript = { "prettier" },
          typescript = { "prettier" },
          json = { "prettier" },
          yaml = { "prettier" },
          html = { "prettier" },
          css = { "prettier" },
          lua = { "stylua" },
        },
        format_on_save = {
          timeout_ms = 2000,
          lsp_format = "fallback",
        },
      })
    end,
  },

  -- Trouble - pretty diagnostics panel (like VS Code's Problems tab)
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("trouble").setup()
    end,
  },

  -- Indent guides - vertical lines at each indent level
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup({
        indent = { char = "│" },
        scope = { enabled = true },
      })
    end,
  },

  -- Multi-cursor (Ctrl-n to select next occurrence, like Cmd+D in VS Code)
  { "mg979/vim-visual-multi", branch = "master" },

  -- Autopairs - auto-close brackets, quotes, etc.
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup()
    end,
  },

  -- Comment.nvim - toggle comments with gcc (line) or gc (selection)
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    config = function()
      require("Comment").setup()
    end,
  },

  -- Which-key - shows keybinding cheatsheet when you press leader
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup({
        delay = 300,  -- Show popup after 300ms
      })
      -- Label your keybinding groups so the popup is organized
      wk.add({
        { "<leader>f", group = "Find" },
        { "<leader>c", group = "Code" },
      })
    end,
  },

  -- Color scheme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",
      })
      vim.cmd([[colorscheme tokyonight-night]])
    end,
  },
}, {
  -- Automatically install missing plugins on startup
  install = {
    missing = true,
  },
})

-- LSP setup using native nvim 0.11 API (no more require('lspconfig').X.setup())
local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.lsp.config('ts_ls', { capabilities = capabilities })
vim.lsp.config('lua_ls', {
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
    },
  },
})
vim.lsp.config('jsonls', { capabilities = capabilities })
vim.lsp.config('yamlls', { capabilities = capabilities })

vim.lsp.enable({ 'ts_ls', 'lua_ls', 'jsonls', 'yamlls' })

-- Keybindings
vim.g.mapleader = " "  -- Set space as leader key

-- Toggle file tree with <leader>e
vim.keymap.set('n', '<leader>e', '<cmd>Neotree toggle<cr>', { desc = "Toggle file tree" })

-- Trouble keybindings
vim.keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', { desc = "All diagnostics" })
vim.keymap.set('n', '<leader>xd', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', { desc = "Buffer diagnostics" })
vim.keymap.set('n', '<leader>xq', '<cmd>Trouble quickfix toggle<cr>', { desc = "Quickfix list" })

-- Check treesitter status with <leader>ts
vim.keymap.set('n', '<leader>ts', ':TSInstallInfo<CR>', { silent = true })

-- Debug folding with <leader>fd
vim.keymap.set('n', '<leader>fd', function()
  print("foldmethod: " .. vim.opt.foldmethod:get())
  print("foldlevel: " .. vim.opt.foldlevel:get())
  print("foldenable: " .. tostring(vim.opt.foldenable:get()))
end, { desc = "Debug folding settings" })

-- Toggle folding on/off with <leader>fz
vim.keymap.set('n', '<leader>fz', function()
  vim.opt.foldenable = not vim.opt.foldenable:get()
  print("Folding: " .. (vim.opt.foldenable:get() and "enabled" or "disabled"))
end, { desc = "Toggle folding" })

-- Clear search highlighting
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = "Clear search highlight" })

-- Telescope keybindings
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope git_files<cr>', { desc = "Find files (git)" })
vim.keymap.set('n', '<leader>fa', '<cmd>Telescope find_files<cr>', { desc = "Find all files" })
vim.keymap.set('n', '<leader>fA', '<cmd>Telescope find_files find_command=rg,--files,--no-ignore,--hidden<cr>', { desc = "Find ALL files (incl node_modules)" })
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { desc = "Live grep" })
vim.keymap.set('n', '<leader>fw', '<cmd>Telescope grep_string<cr>', { desc = "Find word under cursor" })
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { desc = "Find buffers" })
vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { desc = "Help tags" })
vim.keymap.set('n', '<leader>fr', '<cmd>Telescope oldfiles<cr>', { desc = "Recent files" })

-- LSP keybindings (only active when an LSP server is attached)
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)           -- Go to definition
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)           -- Find references
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)                 -- Hover docs
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)       -- Rename symbol
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)  -- Code actions
    vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, opts) -- Show diagnostic
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)         -- Prev diagnostic
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)         -- Next diagnostic
  end,
})

-- Better window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')

-- Incremental selection (expand/shrink by syntax node)
local function get_node_range(node)
  local sr, sc, er, ec = node:range()
  return sr, sc, er, ec
end

vim.keymap.set('n', '<CR>', function()
  local node = vim.treesitter.get_node()
  if not node then return end
  local sr, sc, er, ec = get_node_range(node)
  vim.fn.setpos("'<", { 0, sr + 1, sc + 1, 0 })
  vim.fn.setpos("'>", { 0, er + 1, ec, 0 })
  vim.cmd('normal! gv')
end, { desc = "Start incremental selection" })

vim.keymap.set('v', '<CR>', function()
  local node = vim.treesitter.get_node()
  if not node then return end
  local parent = node:parent()
  if not parent then return end
  local sr, sc, er, ec = get_node_range(parent)
  vim.fn.setpos("'<", { 0, sr + 1, sc + 1, 0 })
  vim.fn.setpos("'>", { 0, er + 1, ec, 0 })
  vim.cmd('normal! gv')
end, { desc = "Expand selection" })

vim.keymap.set('v', '<BS>', function()
  local node = vim.treesitter.get_node()
  if not node then return end
  -- Find a smaller child node near the cursor
  local cursor = vim.api.nvim_win_get_cursor(0)
  local child = node:named_child(0)
  if not child then return end
  local sr, sc, er, ec = get_node_range(child)
  vim.fn.setpos("'<", { 0, sr + 1, sc + 1, 0 })
  vim.fn.setpos("'>", { 0, er + 1, ec, 0 })
  vim.cmd('normal! gv')
end, { desc = "Shrink selection" })

-- Toggle comment with <leader>/
vim.keymap.set('n', '<leader>/', function() require('Comment.api').toggle.linewise.current() end, { desc = "Toggle comment" })
vim.keymap.set('v', '<leader>/', '<ESC><cmd>lua require("Comment.api").toggle.linewise(vim.fn.visualmode())<CR>', { desc = "Toggle comment" })

-- Quick save/quit
vim.keymap.set('n', '<leader>w', '<cmd>w<CR>', { desc = "Save" })
vim.keymap.set('n', '<leader>q', '<cmd>q<CR>', { desc = "Quit" })
vim.keymap.set('n', '<leader>x', '<cmd>wq<CR>', { desc = "Save and quit" })
vim.keymap.set('n', '<leader>Q', '<cmd>q!<CR>', { desc = "Quit without saving" })

-- Save with Ctrl-s
vim.keymap.set('n', '<C-s>', ':w<CR>')
vim.keymap.set('i', '<C-s>', '<Esc>:w<CR>a')

-- Folding keybindings
vim.keymap.set('n', 'za', 'za')  -- Toggle fold
vim.keymap.set('n', 'zR', 'zR')  -- Open all folds
vim.keymap.set('n', 'zM', 'zM')  -- Close all folds
