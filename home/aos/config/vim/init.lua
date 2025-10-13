-- Load lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.runtimepath:prepend(lazypath)

vim.opt.number = true
vim.opt.wrap = true
vim.opt.showmode = true
vim.opt.title = true
vim.opt.hidden = true
vim.opt.autoread = true

vim.opt.cursorline = true
vim.opt.backspace = 'indent,eol,start'

vim.opt.sts = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.incsearch = true
vim.opt.smartcase = true
vim.opt.inccommand = 'nosplit'

vim.opt.path:append('**')

vim.opt.cp = false
vim.opt.completeopt = 'menuone,noinsert,noselect,preview'

vim.g.mapleader = ','

require("lazy").setup({
  pkg = {
    sources = {
      "lazy",
      "packspec",
    }
  },
  rocks = {
    enabled = false,
  },
  spec = {
    'neovim/nvim-lspconfig',
    'nvim-treesitter/nvim-treesitter',
    'nvim-treesitter/nvim-treesitter-textobjects',
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
    'zschreur/telescope-jj.nvim',
    'justinmk/vim-dirvish',
    'tpope/vim-fugitive',
    'tpope/vim-surround',
    'tpope/vim-unimpaired',
    '9seconds/repolink.nvim',

    'aos/vim-ascetic',
  },
})

vim.opt.background = 'dark'
vim.cmd.colorscheme('ascetic')

vim.keymap.set('i', 'jk', '<Esc>', { noremap = true })

vim.keymap.set('n', 'H', '^', { noremap = true })
vim.keymap.set('n', 'L', '$', { noremap = true })
vim.keymap.set('o', 'L', '$', { noremap = true })
vim.keymap.set('v', 'L', 'g_', { noremap = true })

vim.keymap.set(
  'n', 'k',
  function() return vim.v.count == 0 and 'gk' or 'k' end,
  { expr = true, silent = true }
)
vim.keymap.set(
  'n', 'j',
  function() return vim.v.count == 0 and 'gj' or 'j' end,
  { expr = true, silent = true }
)

vim.keymap.set('n', '<Esc>', ':noh<CR><Esc>', { silent = true })
vim.keymap.set('n', '<BS>', '<C-^>', { noremap = true })
vim.keymap.set('n', '<C-p>', '<Tab>', { noremap = true })

-- Copy/paste to/from system clipboard
vim.keymap.set('n', '<Leader>y', '"+y', { noremap = true })
vim.keymap.set('v', '<Leader>y', '"+y', { noremap = true })
vim.keymap.set('n', '<Leader>p', '"+p', { noremap = true })
vim.keymap.set('v', '<Leader>p', '"+p', { noremap = true })

-- Delete trailing whitespace
vim.keymap.set('n', '<Leader>wd', ':%s/\\s\\+$//e<CR>', { silent = true, noremap = true })

-- Use <Tab> and <S-Tab> to navigate through popup menu
vim.keymap.set('i', '<Tab>', function() return vim.fn.pumvisible() == 1 and '<C-n>' or '<Tab>' end, { expr = true })
vim.keymap.set('i', '<S-Tab>', function() return vim.fn.pumvisible() == 1 and '<C-p>' or '<S-Tab>' end, { expr = true })
-- Set preview window to bottom
vim.opt.splitbelow = true
-- Set preview window to right
vim.opt.splitright = true
-- Autoclose preview window when done selecting
vim.api.nvim_create_autocmd({ 'InsertLeave', 'CompleteDone' }, {
  pattern = '*',
  callback = function()
    if vim.fn.pumvisible() == 0 then
      vim.cmd('silent! pclose')
    end
  end
})

-- Tree-sitter based folding
vim.opt.foldenable = false -- start file unfolded
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.cmd('highlight! link Folded Special')

-- Fold mappings
vim.keymap.set('n', '<Space>', 'za', { noremap = true })
vim.keymap.set('n', '<Leader><Space>', function()
  return vim.opt.foldlevel:get() > 0 and 'zM' or 'zR'
end, { expr = true, noremap = true })

-- Disable Dirvish <C-p>
vim.api.nvim_create_augroup('dirvish_config', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'dirvish',
  group = 'dirvish_config',
  callback = function()
    pcall(vim.keymap.del, 'n', '<C-p>', { buffer = true })
  end
})

-- :RepoLink
require("repolink").setup{}

-- :Theme
vim.api.nvim_create_user_command(
  'Theme',
  function()
    if(vim.opt.background == 'dark')
    then
      vim.g.ascetic_transparent_bg = 0
      vim.opt.background = 'light'
    else
      vim.g.ascetic_transparent_bg = 1
      vim.opt.background = 'dark'
    end
  end,
  {bang = true, desc = 'Toggle dark/light theme'}
)

-- highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  pattern = '*',
  group = vim.api.nvim_create_augroup('YankHighlight', {clear = true}),
  callback = function()
    vim.highlight.on_yank()
  end
})

-- Telescope
local telescope = require('telescope')
local telescope_builtin = require('telescope.builtin')
local telescope_actions = require('telescope.actions')

telescope.setup({
  defaults = {
    layout_strategy = 'flex',
    layout_config = {
      flex = {
        flip_columns = 200,
      }
    },
    mappings = {
      i = {
        ['<C-o>'] = require('telescope.actions.layout').toggle_preview,
        ['<C-k>'] = telescope_actions.move_selection_previous,
        ['<C-j>'] = telescope_actions.move_selection_next,
        ['<C-x>'] = telescope_actions.delete_buffer,
      },
      n = {
        ['<C-o>'] = require('telescope.actions.layout').toggle_preview,
      }
    },
  },
  pickers = {
    find_files = {
      follow = true,
    }
  },
})
telescope.load_extension('jj')
local vcs_picker = function(opts)
  local jj_pick_status, jj_res = pcall(telescope.extensions.jj.files, opts)
  if jj_pick_status then
    return
  end

  local git_files_status, git_res = pcall(telescope_builtin.git_files, opts)
  if not git_files_status then
    local ff_pick_status, ff_res = pcall(telescope_builtin.find_files, opts)
  end
end

--Add telescope shortcuts
local tele_opts = { noremap = true, silent = true }
vim.keymap.set('n', '<Tab>', telescope_builtin.buffers, tele_opts)
vim.keymap.set('n', '<leader>ff', vcs_picker, tele_opts)
vim.keymap.set('n', '<leader>fg', telescope_builtin.live_grep, tele_opts)
vim.keymap.set('n', '<leader>fc', telescope_builtin.git_commits, tele_opts)
vim.keymap.set('n', '<leader>fb', telescope_builtin.git_bcommits, tele_opts)

-- Treesitter configs
require('nvim-treesitter.configs').setup({
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = 'gnn',
      node_incremental = 'grn',
      scope_incremental = 'grc',
      node_decremental = 'grm',
    },
  },
  indent = {
    enable = true,
    disable = { "yaml", "elixir" },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- auto jump forward to textobj
      keymaps = {
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true,
    },
  },
})

-- LSP global
-- Remove sign column for Lsp diagnostics and recolor the number instead
vim.o.signcolumn = "no"
vim.fn.sign_define("DiagnosticSignError",
  { text = "E", texthl = "DiagnosticSignError", numhl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn",
  { text = "W", texthl = "DiagnosticSignWarn", numhl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInfo",
  { text = "I", texthl = "DiagnosticSignInfo", numhl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint",
  { text = "H", texthl = "DiagnosticSignHint", numhl = "DiagnosticSignHint" })

local lsp_on_attach = function(client, bufnr)
  -- Mappings
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
  buf_set_option('formatexpr', 'v:lua.vim.lsp.formatexpr()')

  -- Mappings
  local opts = { noremap = true, silent = true }

  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'gr', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', 'gs', '<Cmd>lua vim.lsp.buf.signature_help()<CR>', opts)

  buf_set_keymap('n', 'gk', "<Cmd>lua vim.diagnostic.open_float(bufnr, {border='single',scope= 'line'})<CR>", opts)
  buf_set_keymap('n', '<C-k>', "<Cmd>lua vim.diagnostic.goto_prev({float = {border='single'}})<CR>", opts)
  buf_set_keymap('n', '<C-j>', "<Cmd>lua vim.diagnostic.goto_next({float = {border='single'}})<CR>", opts)

  vim.cmd [[ command! Fmt execute 'lua vim.lsp.buf.format()' ]]
end

local lsp_defaults = {
  on_attach = lsp_on_attach,
  flags = {
    debounce_text_changes = 200,
  },
  handlers = {
    ["textDocument/hover"] = vim.lsp.with(
      vim.lsp.handlers.hover, {
        border = "single"
      }
    ),
    ["textDocument/signatureHelp"] = vim.lsp.with(
      vim.lsp.handlers.signature_help, {
        border = "single"
      }
    ),
    ["textDocument/publishDiagnostics"] = vim.lsp.with(
      vim.lsp.diagnostic.on_publish_diagnostics, {
        -- enable signs
        signs = true,
        virtual_text = false,
        update_in_insert = false,
      }
    ),
  },
  silent = true,
}

local rust_analyzer_config = {
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,
      },
      procMacro = {
        enable = true,
      },
      rustfmt = {
        enableRangeFormatting = true,
      },
    }
  }
}

local lspconfig_util = require('lspconfig.util')

local pylsp_config = {
  root_dir = function(fname)
    local root_files = {
      'pyproject.toml',
      'setup.py',
      'setup.cfg',
      'requirements.txt',
      'Pipfile',
    }
    return lspconfig_util.root_pattern(unpack(root_files))(fname) or
           lspconfig_util.find_git_ancestor(fname)
  end,
  single_file_support = true,

  settings = {
    pylsp = {
      configurationSources = { "flake8" },
      plugins = {
        flake8 = { enabled = true },
        pycodestyle = { enabled = false },
        mccabe = { enabled = false },
        pyflakes = { enabled = false },
      }
    }
  }
}

local lsp_servers = {
  ['pylsp'] = pylsp_config,
  ['rust_analyzer'] = rust_analyzer_config,
  ['terraformls'] = {},
  ['gopls'] = {},
  ['elixirls'] = {
    cmd = { 'elixir-ls' }
  },
  ['zls'] = {},
}

for server, config in pairs(lsp_servers) do
  local full_config = vim.tbl_deep_extend("force", lsp_defaults, config)
  full_config.name = server
  vim.lsp.config(server, full_config)
end

vim.lsp.enable(vim.tbl_keys(lsp_servers))
