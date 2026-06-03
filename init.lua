-- Lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)

-- Leader must be set BEFORE lazy loads plugins
vim.g.mapleader      = " "
vim.g.maplocalleader = " "

-- Disable netrw early (required by nvim-tree)
vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1

-- Plugins
require("lazy").setup({

    -- LSP
    { "neovim/nvim-lspconfig" },

    -- Java LSP
    {
        "mfussenegger/nvim-jdtls",
        ft = { "java" },
    },

    -- Go LSP + tooling
    {
        "ray-x/go.nvim",
        dependencies = {
            "ray-x/guihua.lua",
            "neovim/nvim-lspconfig",
            "nvim-treesitter/nvim-treesitter",
        },
        ft    = { "go", "gomod", "gowork", "gotmpl" },
        build = ':lua require("go.install").update_all_sync()',
        config = function()
            require("go").setup({
                lsp_cfg      = true,
                lsp_gofumpt  = true,
                lsp_on_attach = function(client, bufnr)
                    local opts = { silent = true, buffer = bufnr }
                    vim.keymap.set("n", "<leader>gr", "<cmd>GoRun<CR>",        opts)
                    vim.keymap.set("n", "<leader>gt", "<cmd>GoTest<CR>",       opts)
                    vim.keymap.set("n", "<leader>gi", "<cmd>GoImports<CR>",    opts)
                    vim.keymap.set("n", "<leader>gf", "<cmd>GoFmt<CR>",        opts)
                    vim.keymap.set("n", "<leader>ga", "<cmd>GoAlt<CR>",        opts)
                    vim.keymap.set("n", "<leader>gc", "<cmd>GoCoverage<CR>",   opts)
                    vim.keymap.set("n", "<leader>ge", "<cmd>GoIfErr<CR>",      opts)
                    vim.keymap.set("n", "<leader>gS", "<cmd>GoFillStruct<CR>", opts)
                end,
                lsp_codelens          = true,
                lsp_document_formatting = true,
                lsp_inlay_hints       = { enable = false },
                diagnostic = {
                    hdlr           = true,
                    underline      = true,
                    virtual_text   = { space = 2 },
                    signs          = true,
                    update_in_insert = false,
                },
            })
        end,
    },

    -- Auto close brackets / braces / quotes
    {
        "windwp/nvim-autopairs",
        event        = "InsertEnter",
        dependencies = { "hrsh7th/nvim-cmp" },
        config = function()
            require("nvim-autopairs").setup({
                check_ts         = true,
                ts_config        = {
                    lua  = { "string" },
                    go   = { "string" },
                    java = { "string" },
                },
                disable_filetype = { "TelescopePrompt", "vim" },
                fast_wrap        = {
                    map            = "<M-e>",
                    chars          = { "{", "[", "(", '"', "'" },
                    pattern        = [=[[%'%"%>%]%)%}%,]]=],
                    end_key        = "$",
                    keys           = "qwertyuiopzxcvbnmasdfghjkl",
                    check_comma    = true,
                    highlight      = "Search",
                    highlight_grey = "Comment",
                },
            })

            local cmp_autopairs = require("nvim-autopairs.completion.cmp")
            local ok_cmp, cmp   = pcall(require, "cmp")
            if ok_cmp then
                cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
            end
        end,
    },

    -- Autocomplete
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            local cmp     = require("cmp")
            local luasnip = require("luasnip")

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"]     = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"]      = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "buffer" },
                    { name = "path" },
                }),
            })
        end,
    },

    -- File Explorer
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = "nvim-tree/nvim-web-devicons",
        config = function()
            require("nvim-tree").setup({
                hijack_cursor       = true,
                update_focused_file = { enable = true },
                view                = { width = 40, side = "left" },
                renderer = {
                    icons = {
                        show = {
                            file         = false,
                            folder       = true,
                            folder_arrow = true,
                            git          = false,
                        },
                    },
                },
            })
        end,
    },

    -- Telescope
    {
        "nvim-telescope/telescope.nvim",
        branch       = "0.1.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        },
        config = function()
            local telescope = require("telescope")
            local actions   = require("telescope.actions")

            telescope.setup({
                defaults = {
                    mappings = {
                        i = {
                            ["<C-k>"] = actions.move_selection_previous,
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                            ["<Esc>"] = actions.close,
                        },
                    },
                    file_ignore_patterns = { "node_modules", ".git/", "target/" },
                    path_display         = { "truncate" },
                },
            })

            pcall(telescope.load_extension, "fzf")
        end,
    },

    -- Smear Cursor
    {
        "sphamba/smear-cursor.nvim",
        opts = {
            smear_between_buffers          = true,
            smear_between_neighbor_lines   = true,
            smear_insert_mode              = true,
            scroll_buffer_space            = true,
            stiffness                      = 0.8,
            trailing_stiffness             = 0.6,
            stiffness_insert_mode          = 0.7,
            trailing_stiffness_insert_mode = 0.7,
            damping                        = 0.95,
            damping_insert_mode            = 0.95,
            distance_stop_animating        = 0.5,
            transparent_bg_fallback_color  = "#1e1e2e",
            legacy_computing_symbols_support = false,
        },
    },
})

-- ─────────────────────────────────────────────
-- General settings
-- ─────────────────────────────────────────────

vim.opt.nu             = true
vim.opt.relativenumber = true

vim.opt.tabstop     = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth  = 4
vim.opt.expandtab   = true

vim.opt.smartindent = true
vim.opt.wrap        = false

vim.opt.swapfile = false
vim.opt.backup   = false
vim.opt.undodir  = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch  = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff  = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.number = true
vim.opt.cursorline = true

vim.opt.ignorecase   = true
vim.opt.smartcase    = true
vim.opt.autowriteall = true

vim.opt.clipboard = "unnamedplus"

-- ─────────────────────────────────────────────
-- Transparent background
-- ─────────────────────────────────────────────

local transparent_groups = {
    "Normal", "NormalNC", "NormalFloat",
    "FloatBorder", "SignColumn", "EndOfBuffer",
}
for _, group in ipairs(transparent_groups) do
    vim.api.nvim_set_hl(0, group, { bg = "none" })
end
vim.api.nvim_set_hl(0, "NvimTreeNormal",   { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = "none" })

-- ─────────────────────────────────────────────
-- Keymaps
-- ─────────────────────────────────────────────

local keymap = vim.keymap

keymap.set("i", "jk",         "<Esc>")
keymap.set("n", "<leader>w",  ":w<CR>")
keymap.set("n", "<leader>q",  ":q<CR>")
keymap.set("n", "<leader>h",  ":nohlsearch<CR>")
keymap.set("n", "<leader>e",  ":NvimTreeToggle<CR>")

-- Telescope keymaps — wrapped in pcall so startup doesn't crash if telescope
-- hasn't been installed yet on the very first launch
local tel_ok, builtin = pcall(require, "telescope.builtin")
if tel_ok then
    keymap.set("n", "<leader>ff", builtin.find_files)
    keymap.set("n", "<leader>fg", builtin.live_grep)
    keymap.set("n", "<leader>fb", builtin.buffers)
    keymap.set("n", "<leader>fh", builtin.help_tags)
    keymap.set("n", "<leader>fr", builtin.oldfiles)
end

-- ─────────────────────────────────────────────
-- Autocommands
-- ─────────────────────────────────────────────

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function() vim.highlight.on_yank() end,
})

-- Go: real tabs (gofmt/gofumpt standard)
vim.api.nvim_create_autocmd("FileType", {
    pattern  = "go",
    callback = function()
        vim.opt_local.expandtab  = false
        vim.opt_local.tabstop    = 4
        vim.opt_local.shiftwidth = 4
    end,
})

-- ─────────────────────────────────────────────
-- Java (JDTLS) — safe-loaded with pcall
-- ─────────────────────────────────────────────

local jdtls_ok, jdtls = pcall(require, "jdtls")
if jdtls_ok then
    local home = os.getenv("HOME")

    local jdtls_path    = home .. "/.local/share/jdtls"
    local launcher      = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
    local workspace_dir = home .. "/.cache/jdtls/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")

    local lombok_matches = vim.fn.split(
        vim.fn.glob(home .. "/.m2/repository/org/projectlombok/lombok/*/lombok-*.jar"), "\n"
    )
    local lombok_path = lombok_matches[1] or ""
    local lombok_cmd  = (lombok_path ~= "") and ("-javaagent:" .. lombok_path) or nil

    local java_cmd = {
        "java",
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.level=ALL",
        "-Xms1g",
        "--add-modules=ALL-SYSTEM",
    }
    if lombok_cmd then table.insert(java_cmd, lombok_cmd) end
    vim.list_extend(java_cmd, {
        "-jar",           launcher,
        "-configuration", jdtls_path .. "/config_linux",
        "-data",          workspace_dir,
    })

    local jdtls_config = {
        cmd          = java_cmd,
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
        root_dir     = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml" }),
        on_attach    = function(client, bufnr)
            local opts = { silent = true, buffer = bufnr }
            vim.keymap.set("n", "<leader>oi", jdtls.organize_imports,    opts)
            vim.keymap.set("n", "<leader>ev", jdtls.extract_variable,    opts)
            vim.keymap.set("n", "<leader>ec", jdtls.extract_constant,    opts)
            vim.keymap.set("n", "<leader>tm", jdtls.test_nearest_method, opts)
        end,
    }

    vim.api.nvim_create_autocmd("FileType", {
        pattern  = "java",
        callback = function() jdtls.start_or_attach(jdtls_config) end,
    })

    vim.api.nvim_create_autocmd("BufWritePre", {
        pattern  = "*.java",
        callback = function()
            vim.lsp.buf.code_action({
                context = { only = { "source.organizeImports" } },
                apply   = true,
            })
        end,
    })
end
