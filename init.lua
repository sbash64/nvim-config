vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.o.hlsearch = false
vim.wo.number = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.termguicolors = true
vim.o.clipboard = 'unnamedplus'

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.wrap = false
vim.opt.scrolloff = 5

vim.opt.smartindent = true
vim.opt.relativenumber = true

vim.keymap.set("n", "<leader>bd", "<cmd>bd<CR>")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    'neovim/nvim-lspconfig',
    'hrsh7th/nvim-cmp',
    'hrsh7th/cmp-nvim-lsp',
    'saadparwaiz1/cmp_luasnip',
    'L3MON4D3/LuaSnip',
    'lunarvim/darkplus.nvim',
    'ckipp01/stylua-nvim',
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate'
    },
    { 'nvim-telescope/telescope.nvim', branch = '0.1.x', dependencies = { 'nvim-lua/plenary.nvim' } },
    'nvim-lualine/lualine.nvim',
    'nvimtools/none-ls.nvim',
    'lewis6991/gitsigns.nvim',
    {
        'mrcjkb/rustaceanvim',
        version = '^5', -- Recommended
        lazy = false,   -- This plugin is already lazy
    }
}
)

local function diagnostic_format(diagnostic)
    if diagnostic.code then
        return ("[%s] %s"):format(diagnostic.code, diagnostic.message)
    end
    return diagnostic.message
end

vim.diagnostic.config({
    virtual_text = {
        source = true,
        format = diagnostic_format,
    },
    float = {
        source = true,
        format = diagnostic_format,
    },
})

require('lualine').setup {
    options = {
        component_separators = '|',
        section_separators = '',
    },
    sections = {
        lualine_c = { 'buffers' },
    },
}

require('gitsigns').setup {
    signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
    },
}

vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })

local luasnip = require 'luasnip'
luasnip.config.setup {}

local cmp = require 'cmp'
cmp.setup {
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert {
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-y>'] = cmp.mapping.confirm { select = true },
        ['<C-Space>'] = cmp.mapping.complete {},
        ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
                luasnip.expand_or_jump()
            end
        end, { 'i', 's' }),
        ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
            end
        end, { 'i', 's' }),
    },
    sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    },
}

local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1, float = true }) end, opts)
vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1, float = true }) end, opts)
vim.keymap.set('n', '[e',
    function() vim.diagnostic.jump({ count = -1, float = true, severity = vim.diagnostic.severity.ERROR }) end, opts)
vim.keymap.set('n', ']e',
    function() vim.diagnostic.jump({ count = 1, float = true, severity = vim.diagnostic.severity.ERROR }) end, opts)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)

local enable_lsp_keymaps = function(client, bufnr)
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gd', require('telescope.builtin').lsp_definitions, bufopts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
    vim.keymap.set('n', '<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts)
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
    vim.keymap.set({ 'v', 'n' }, '<leader>la', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, bufopts)
end

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local enable_formatting = function(client, bufnr)
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    if client.supports_method("textDocument/formatting") then
        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.format({
                    filter = function(candidate)
                        return client.name == candidate.name
                    end,
                    bufnr = bufnr
                })
            end,
        })
        vim.keymap.set('n', '<leader>f', function()
            vim.lsp.buf.format({
                filter = function(candidate)
                    return client.name == candidate.name
                end,
                bufnr = bufnr
            })
        end, bufopts)
    end
end

local enable_lsp_keymaps_and_formatting = function(client, bufnr)
    enable_lsp_keymaps(client, bufnr)
    enable_formatting(client, bufnr)
end

local null_ls = require("null-ls")

null_ls.setup({
    sources = {
        null_ls.builtins.formatting.prettier,
        null_ls.builtins.formatting["swift_format"].with({
            command = "/home/seth/installed/swift-format-508.0.0/swift-format"
        }),
    },
    on_attach = enable_formatting
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()

vim.g.rustaceanvim = {
    server = {
        on_attach = enable_lsp_keymaps_and_formatting,
        capabilities = capabilities
    }
}

require 'lspconfig'.pyright.setup {
    on_attach = enable_lsp_keymaps,
    capabilities = capabilities,
    cmd = { "/home/seth/installed/npm-packages/bin/pyright-langserver", "--stdio" }
}

require 'lspconfig'.ruff.setup {
    on_attach = enable_formatting,
    capabilities = capabilities
}

require 'lspconfig'.fish_lsp.setup {
    on_attach = enable_lsp_keymaps_and_formatting,
    capabilities = capabilities,
    cmd = { "/home/seth/installed/fish-lsp/bin/fish-lsp", "start" }
}

require 'lspconfig'.clangd.setup {
    on_attach = enable_lsp_keymaps_and_formatting,
    capabilities = capabilities,
}

require 'lspconfig'.cmake.setup {
    on_attach = enable_lsp_keymaps_and_formatting,
    capabilities = capabilities,
}

require 'lspconfig'.bashls.setup {
    on_attach = enable_lsp_keymaps_and_formatting,
    capabilities = capabilities,
    cmd = { "/home/seth/installed/npm-packages/bin/bash-language-server", "start" }
}

require 'lspconfig'.sourcekit.setup {
    on_attach = enable_lsp_keymaps,
    capabilities = capabilities,
    cmd = { "/home/seth/installed/swift-5.8-RELEASE-centos7/usr/bin/sourcekit-lsp" },
    cmd_env = { LD_LIBRARY_PATH = "/home/seth/installed/libtinfo-5", },
    filetypes = { "swift" }
}

require 'lspconfig'.ts_ls.setup {
    on_attach = enable_lsp_keymaps,
    capabilities = capabilities,
    cmd = { "/home/seth/installed/npm-packages/bin/typescript-language-server", "--stdio" }
}

require 'lspconfig'.eslint.setup {
    capabilities = capabilities,
    cmd = { "/home/seth/installed/npm-packages/bin/vscode-eslint-language-server", "--stdio" }
}

require 'lspconfig'.jsonls.setup {
    on_attach = enable_lsp_keymaps,
    capabilities = capabilities,
    cmd = { "/home/seth/installed/npm-packages/bin/vscode-json-language-server", "--stdio" }
}

require 'lspconfig'.html.setup {
    on_attach = enable_lsp_keymaps,
    capabilities = capabilities,
    cmd = { "/home/seth/installed/npm-packages/bin/vscode-html-language-server", "--stdio" }
}

require 'lspconfig'.cssls.setup {
    on_attach = enable_lsp_keymaps,
    capabilities = capabilities,
    cmd = { "/home/seth/installed/npm-packages/bin/vscode-css-language-server", "--stdio" }
}

require 'lspconfig'.lua_ls.setup {
    on_attach = enable_lsp_keymaps_and_formatting,
    capabilities = capabilities,
    cmd = { "/home/seth/installed/lua-language-server-3.10.5/bin/lua-language-server" },
    on_init = function(client)
        local path = client.workspace_folders[1].name
        if vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc') then
            return
        end

        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            runtime = {
                -- Tell the language server which version of Lua you're using
                -- (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT'
            },
            -- Make the server aware of Neovim runtime files
            workspace = {
                checkThirdParty = false,
                library = {
                    vim.env.VIMRUNTIME
                    -- Depending on the usage, you might want to add additional paths here.
                    -- "${3rd}/luv/library"
                    -- "${3rd}/busted/library",
                }
                -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
                -- library = vim.api.nvim_get_runtime_file("", true)
            }
        })
    end,
    settings = {
        Lua = {}
    }
}

require 'nvim-treesitter.configs'.setup {
    highlight = {
        enable = true,
    },
    incremental_selection = {
        enable = true,
    }
}

vim.cmd("colorscheme darkplus")
