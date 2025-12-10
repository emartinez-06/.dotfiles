-- General settings
vim.g.lspconfig_deprecation_warnings = false
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.smartindent = true
vim.o.smarttab = true
vim.o.autoindent = true
vim.opt.tabstop = 4
vim.o.softtabstop = 4
vim.opt.shiftwidth = 4
-- Add current course snippets to runtime path
vim.opt.runtimepath:append(vim.fn.expand('~/current_course'))
vim.opt.expandtab = true
vim.opt.scrolloff = 999
vim.opt.guicursor = {
  "n-v-c:block",
  "i-ci-ve:ver25",
  "r-cr:hor20",
  "o:hor50",
  "a:blinkon0",
}

-- Spell check configuration
vim.opt.spell = true
vim.opt.spelllang = { 'en_us' }  -- Adjust languages as needed

-- Ctrl+L to fix previous spelling mistake
-- Jumps back to previous misspelled word, picks first suggestion, jumps back
vim.keymap.set('i', '<C-l>', '<c-g>u<Esc>[s1z=`]a<c-g>u', { 
  desc = 'Fix previous spelling mistake' 
})

vim.opt.clipboard = "unnamedplus"

vim.g.mapleader = " "
vim.g.tmux_navigator_no_wrap = 1

-- VimTeX + Skim settings
vim.g.vimtex_view_method = 'skim'
vim.g.vimtex_view_skim_sync = 1
vim.g.vimtex_view_skim_activate = 1

vim.g.vimtex_compiler_latexmk = {
  build_dir = 'build',
  options = {
    '-pdf',
    '-interaction=nonstopmode',
    '-synctex=1',
  },
}

vim.opt.wrap = true
-- vim.opt.clipboard = 'unnamedplus'
vim.opt.linebreak = true

-- Bootstrap lazy.nvim
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

-- Plugins
require("lazy").setup({
  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require'nvim-treesitter.configs'.setup {
        ensure_installed = { "cpp", "python", "javascript", "lua", "go", "rust", "bash", "html", "css" },
        highlight = {
          enable = true,
          disable = { "c", "rust" },
          additional_vim_regex_highlighting = false,
        },
        fold = {
          enable = true,
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
          },
        },
        autopairs = {
          enable = true,
        },
        rainbow = {
          enable = true,
          extended_mode = true,
          max_file_lines = nil,
        },
      }
    end,
  },
-- UltiSnips for LaTeX!
  {
  "sirver/ultisnips",
  lazy = false,
  init = function()
    vim.g.UltiSnipsExpandTrigger = "<tab>"
    vim.g.UltiSnipsJumpForwardTrigger = "<tab>"
    vim.g.UltiSnipsJumpBackwardTrigger = "<s-tab>"
  end
},

-- LSP Config
{
  'neovim/nvim-lspconfig',
  config = function()
    -- Modern way to setup LSP
    local lspconfig = require('lspconfig')
    vim.g.deprecate_lspconfig = false  -- Suppress the warning temporarily
    
    -- Setup clangd with default settings
    lspconfig.clangd.setup({
      on_attach = function(client, bufnr)
        -- LSP keybindings
        local opts = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
      end,
      capabilities = require('cmp_nvim_lsp').default_capabilities(),
    })
  end,
},
 
  -- Autocompletion (nvim-cmp is more modern than compe)
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),

        -- Normal Tab autocompletion for coding files
        ['<Tab>'] = cmp.mapping.select_next_item(),
        ['<S-Tab>'] = cmp.mapping.select_prev_item(),

        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
        }, {
          { name = 'buffer' },
          { name = 'path' },
        }),
      })

       -------------------------------------------------------------------------
    -- FILETYPE OVERRIDE: Disable CMP tab completion in LaTeX (.tex)
    -------------------------------------------------------------------------
 cmp.setup.filetype("tex", {
  mapping = {
    ["<Tab>"] = function(fallback)
      if vim.fn["UltiSnips#CanExpandSnippet"]() == 1 then
        vim.fn["UltiSnips#ExpandSnippet"]()
      elseif vim.fn["UltiSnips#CanJumpForwards"]() == 1 then
        vim.fn["UltiSnips#JumpForwards"]()
      else
        fallback()
      end
    end,

    ["<S-Tab>"] = function(fallback)
      if vim.fn["UltiSnips#CanJumpBackwards"]() == 1 then
        vim.fn["UltiSnips#JumpBackwards"]()
      else
        fallback()
      end
    end,
  },

  -- No LSP autocomplete for LaTeX unless you use texlab/ltex
  sources = {
  }
})
    end,
  },

  -- Formatting
  {
    'sbdchd/neoformat',
    config = function()
      vim.g.neoformat_enabled_cpp = {'clangformat'}
      vim.api.nvim_set_keymap('n', '<Leader>f', ':Neoformat<CR>', { noremap = true, silent = true })
      vim.cmd [[
        augroup auto_format
          autocmd!
          autocmd BufWritePre *.cpp,*.h Neoformat
        augroup END
      ]]
    end,
  },

  -- File Explorer 
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require("nvim-tree").setup()
      vim.api.nvim_set_keymap('n', '<Leader>n', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
    end,
  },

  -- Colorscheme
  {
    'wuelnerdotexe/vim-enfocado',
    lazy = false,
    priority = 1000,
    config = function()
      vim.o.termguicolors = true
      vim.o.background = 'dark'
      vim.g.enfocado_style = 'nature'
      vim.cmd('colorscheme enfocado')
    end,
  },

  -- Git integration
  { 'tpope/vim-fugitive' },

  -- VimTeX
  {
    'lervag/vimtex',
    ft = 'tex',
    config = function()
      vim.g.tex_flavor = 'latex'
      vim.g.vimtex_view_method = 'skim'
      vim.g.vimtex_view_skim_sync = 1
      vim.g.vimtex_view_skim_activate = 1
      vim.g.vimtex_quickfix_mode = 0

      vim.o.conceallevel = 1
      vim.g.tex_conceal = 'abdmg'
    end
  },

  -- Gitsigns
  {
    'lewis6991/gitsigns.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('gitsigns').setup {
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          vim.keymap.set('n', ']h', gs.next_hunk, { buffer = bufnr })
          vim.keymap.set('n', '[h', gs.prev_hunk, { buffer = bufnr })
          vim.keymap.set('n', '<leader>hs', gs.stage_hunk, { buffer = bufnr })
          vim.keymap.set('n', '<leader>hr', gs.reset_hunk, { buffer = bufnr })
          vim.keymap.set('n', '<leader>hS', gs.stage_buffer, { buffer = bufnr })
          vim.keymap.set('n', '<leader>hu', gs.undo_stage_hunk, { buffer = bufnr })
          vim.keymap.set('n', '<leader>hp', gs.preview_hunk, { buffer = bufnr })
        end,
      }
    end,
  },

  -- Neogit
  {
    'NeogitOrg/neogit',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'sindrets/diffview.nvim',
      'nvim-telescope/telescope.nvim',
    },
    config = function()
      require('neogit').setup {}
      vim.keymap.set('n', '<leader>g.', '<cmd>Neogit<CR>', { desc = "NeoGit" })
    end,
  },

  -- Tmux navigation
{ 'christoomey/vim-tmux-navigator' },

  -- Claude Code
  {
    'greggh/claude-code.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('claude-code').setup()
    end
  },
})


-- Write/Quit Keybinds
vim.api.nvim_set_keymap('n', '<Leader>s', ':w<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>q', ':q<CR>', { noremap = true, silent = true })
