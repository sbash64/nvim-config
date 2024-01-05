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
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
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
    'simrat39/rust-tools.nvim',
    'jose-elias-alvarez/null-ls.nvim',
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
        source = "always",
        format = diagnostic_format,
    },
    float = {
        source = "always",
        format = diagnostic_format,
    },
})

require('lualine').setup {
    options = {
        --        icons_enabled = true,
        --        theme = 'auto',
        component_separators = '|',
        section_separators = '',
        --        disabled_filetypes = {
        --            statusline = {},
        --            winbar = {},
        --        },
        --        ignore_focus = {},
        --        always_divide_middle = true,
        --        globalstatus = false,
        --        refresh = {
        --            statusline = 1000,
        --            tabline = 1000,
        --            winbar = 1000,
        --        }
    },
    sections = {
        --        lualine_a = { 'mode' },
        --        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { 'buffers' },
        --        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        --        lualine_y = { 'progress' },
        --        lualine_z = { 'location' }
    },
    --    inactive_sections = {
    --        lualine_a = {},
    --        lualine_b = {},
    --        lualine_c = { 'filename' },
    --        lualine_x = { 'location' },
    --        lualine_y = {},
    --        lualine_z = {}
    --    },
    --    tabline = {},
    --    winbar = {},
    --    inactive_winbar = {},
    --    extensions = {}
}

vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })

-- Add additional capabilities supported by nvim-cmp
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- luasnip setup
local luasnip = require 'luasnip'

-- nvim-cmp setup
local cmp = require 'cmp'
cmp.setup {
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        },
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
    sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    },
}

local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '[e', function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end, opts)
vim.keymap.set('n', ']e', function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end, opts)
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
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
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

require 'rust-tools'.setup({
    server = {
        on_attach = enable_lsp_keymaps_and_formatting,
        capabilities = capabilities
    }
})

require 'lspconfig'.pyright.setup {
    on_attach = enable_lsp_keymaps,
    capabilities = capabilities,
    cmd = { "/home/seth/installed/npm-packages/bin/pyright-langserver", "--stdio" }
}

require 'lspconfig'.ruff_lsp.setup {
    on_attach = enable_formatting,
    capabilities = capabilities
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

require 'lspconfig'.tsserver.setup {
    on_attach = enable_lsp_keymaps,
    capabilities = capabilities,
    cmd = { "/home/seth/installed/npm-packages/bin/typescript-language-server", "--stdio" }
}

--require 'lspconfig'.eslint.setup {
--    capabilities = capabilities,
--    cmd = { "/home/seth/installed/npm-packages/bin/vscode-eslint-language-server", "--stdio" }
--}

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
    cmd = { "/home/seth/installed/lua-language-server-3.6.23/bin/lua-language-server" },
    on_init = function(client)
        local path = client.workspace_folders[1].name
        if not vim.loop.fs_stat(path .. '/.luarc.json') and not vim.loop.fs_stat(path .. '/.luarc.jsonc') then
            client.config.settings = vim.tbl_deep_extend('force', client.config.settings.Lua, {
                runtime = {
                    -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                    version = 'LuaJIT'
                },
                -- Make the server aware of Neovim runtime files
                workspace = {
                    library = { vim.env.VIMRUNTIME }
                    -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
                    -- library = vim.api.nvim_get_runtime_file("", true)
                }
            })

            client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
        end
        return true
    end,
    settings = {
        Lua = {
            workspace = {
                checkThirdParty = false,
            },
            telemetry = {
                enable = false
            }
        },
    },
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
