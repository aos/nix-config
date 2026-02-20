-- Load lazy.nvim
local lazypath = vim.fn.stdpath("data") .. '/lazy/lazy.nvim'
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

-- Set up undodir
vim.opt.swapfile = false
vim.opt.backup = false
local undodir = vim.fn.stdpath('data') .. '/undo'
vim.fn.mkdir(undodir, 'p')
vim.opt.undodir = undodir
vim.opt.undofile = true
vim.opt.undolevels = 10000

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
    'folke/snacks.nvim',
    'justinmk/vim-dirvish',
    'tpope/vim-fugitive',
    'tpope/vim-surround',
    'tpope/vim-unimpaired',
    { 'julienvincent/hunk.nvim', cmd = { 'DiffEditor' }, dependencies = { 'MunifTanjim/nui.nvim' }, opts = {} },
    {
      'obsidian-nvim/obsidian.nvim',
      ft = "markdown",
      dependencies = { 'saghen/blink.cmp' },
    },

    'aos/vim-ascetic',
  },
})

vim.opt.termguicolors = true
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
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldtext = 'v:lua.vim.treesitter.foldtext()'

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

-- :RepoLink — copy permalink to clipboard via snacks.gitbrowse
vim.api.nvim_create_user_command(
  'RepoLink',
  function()
    Snacks.gitbrowse.open({
      what = "permalink",
      open = function(url)
        vim.fn.setreg('+', url)
        vim.notify(url, vim.log.levels.INFO)
      end,
    })
  end,
  { range = true, desc = 'Copy permalink to clipboard' }
)

-- :Theme
vim.api.nvim_create_user_command(
  'Theme',
  function()
    if(vim.opt.background:get() == 'dark')
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

-- Snacks.picker
vim.api.nvim_set_hl(0, "SnacksPickerDir", { link = "Comment" })

require('snacks').setup({
  picker = {
    sources = {
      files = {
        follow = true,
        hidden = true,
      },
      grep = {
        follow = true,
        hidden = true,
      },
      explorer = { hidden = true },
    },
    win = {
      input = {
        keys = {
          ['<C-o>'] = { 'toggle_preview', mode = { 'i', 'n' } },
        },
      },
      list = {
        keys = {
          ['<C-o>'] = 'toggle_preview',
        },
      },
    },
  },
})

local function jj_files()
  Snacks.picker.pick({
    title = "Jujutsu Files",
    finder = function(opts, ctx)
      local cwd = vim.fs.normalize(opts.cwd or vim.fn.getcwd(0))
      return require("snacks.picker.source.proc").proc(
        ctx:opts({
          cmd = "jj",
          args = { "file", "list", "--no-pager" },
          transform = function(item)
            item.cwd = cwd
            item.file = item.text
          end,
        }),
        ctx
      )
    end,
    format = "file",
    show_empty = true,
  })
end

local function vcs_picker()
  local jj = vim.system({ "jj", "root" }, { text = true }):wait()
  if jj.code == 0 then
    return jj_files()
  end

  local git = vim.system({ "git", "rev-parse", "--git-dir" }, { text = true }):wait()
  if git.code == 0 then
    return Snacks.picker.git_files()
  end

  Snacks.picker.files()
end

-- Picker shortcuts
local pick_opts = { noremap = true, silent = true }
vim.keymap.set('n', '<Tab>', function() Snacks.picker.buffers() end, pick_opts)
vim.keymap.set('n', '<leader>ff', vcs_picker, pick_opts)
vim.keymap.set('n', '<leader>fg', function() Snacks.picker.grep() end, pick_opts)
vim.keymap.set('n', '<leader>fc', function() Snacks.picker.git_log() end, pick_opts)
vim.keymap.set('n', '<leader>fb', function() Snacks.picker.git_log_file() end, pick_opts)

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
vim.opt.signcolumn = "no"
vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = 'E',
      [vim.diagnostic.severity.WARN] = 'W',
      [vim.diagnostic.severity.INFO] = 'I',
      [vim.diagnostic.severity.HINT] = 'H',
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = 'DiagnosticSignError',
      [vim.diagnostic.severity.WARN] = 'DiagnosticSignWarn',
      [vim.diagnostic.severity.INFO] = 'DiagnosticSignInfo',
      [vim.diagnostic.severity.HINT] = 'DiagnosticSignHint',
    },
    linehl = {
      [vim.diagnostic.severity.ERROR] = 'DiagnosticSignError',
      [vim.diagnostic.severity.WARN] = 'DiagnosticSignWarn',
      [vim.diagnostic.severity.INFO] = 'DiagnosticSignInfo',
      [vim.diagnostic.severity.HINT] = 'DiagnosticSignHint',
    },
  }
})

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
  buf_set_keymap('n', 'gd', '<Cmd>lua Snacks.picker.lsp_definitions()<CR>', opts)
  buf_set_keymap('n', 'gr', '<Cmd>lua Snacks.picker.lsp_references()<CR>', opts)
  buf_set_keymap('n', 'gs', '<Cmd>lua vim.lsp.buf.signature_help()<CR>', opts)

  buf_set_keymap('n', 'gk', "<Cmd>lua vim.diagnostic.open_float(bufnr, {border='single',scope='line'})<CR>", opts)
  buf_set_keymap('n', '<C-k>', "<Cmd>lua vim.diagnostic.goto_prev({float = {border='single'}})<CR>", opts)
  buf_set_keymap('n', '<C-j>', "<Cmd>lua vim.diagnostic.goto_next({float = {border='single'}})<CR>", opts)

  vim.api.nvim_create_user_command('Fmt', function() vim.lsp.buf.format() end, {})

  -- LSP-based folding
  local win = vim.api.nvim_get_current_win()
  vim.wo[win][0].foldtext = 'v:lua.vim.lsp.foldtext()'
  if client:supports_method('textDocument/foldingRange') then
    vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
  end

  -- Only create Imports command if server supports it
  if client.config.imports_command then
    vim.api.nvim_create_user_command(
      'Imports',
      function()
        vim.lsp.buf.code_action({
          context = {only = {"source.organizeImports"}}, apply=true
        })
      end,
      {}
    )
  end
end

-- override LSP floating windows
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = 'rounded'
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

local lsp_defaults = {
  on_attach = lsp_on_attach,
  flags = {
    debounce_text_changes = 200,
  },
  handlers = {
    ['textDocument/publishDiagnostics'] = vim.lsp.with(
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

local lsp_servers = {
  ['pyright'] = {},
  ['rust_analyzer'] = rust_analyzer_config,
  ['terraformls'] = {},
  ['gopls'] = {
    imports_command = true,
  },
  ['elixirls'] = {
    cmd = { 'elixir-ls' },
  },
  ['zls'] = {},
  ['shopify'] = {
    cmd = { 'shopify', 'theme', 'language-server' },
    filetypes = { 'liquid' },
    root_markers = { '.shopify', '.git' },
    on_demand = true,
  }
}

for server, config in pairs(lsp_servers) do
  local full_config = vim.tbl_deep_extend("force", lsp_defaults, config)
  full_config.name = server
  vim.lsp.config(server, full_config)
end

local auto_enabled = {}
for server, config in pairs(lsp_servers) do
  if not config.on_demand then
    table.insert(auto_enabled, server)
  end
end

vim.lsp.enable(auto_enabled)

-- Enable obsidian
require("obsidian").setup({
  note_id_func = function(title)
    if title then
      return title
    end
    return require("obsidian.builtin").zettel_id()
  end,
  ui = {
    ignore_conceal_warn = true,
  },
  legacy_commands = false,
  workspaces = {
    {
      name = "personal",
      path = "~/vaults/personal",
    },
    {
      name = "work",
      path = "~/vaults/work",
    },
  },
})
