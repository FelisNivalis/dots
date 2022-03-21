local signs = require("common.const").diagnostic_signs
vim.diagnostic.config({
    virtual_text = {
        source = true,
    },
    signs = {
        priority = 5,
        text = {
            [vim.diagnostic.severity.ERROR] = signs.error.text,
            [vim.diagnostic.severity.WARN] = signs.warn.text,
            [vim.diagnostic.severity.INFO] = signs.info.text,
            [vim.diagnostic.severity.HINT] = signs.hint.text,
        },
    },
    virtual_lines = false,
    update_in_insert = true,
    severity_sort = true,
})
vim.cmd("hi DiagnosticUnderLineError cterm=undercurl gui=undercurl")
vim.cmd("hi DiagnosticUnderLineWarning cterm=undercurl gui=undercurl")

-- local float = {
--   focusable = true,
--   style = "minimal",
--   border = "rounded",
-- }
-- vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, float)
-- vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, float)

-- Create a custom namespace. This will aggregate signs from all other
-- namespaces and only show the one with the highest severity on a
-- given line
local ns = vim.api.nvim_create_namespace("my_namespace")

-- Get a reference to the original signs handler
local orig_signs_handler = vim.diagnostic.handlers.signs

-- Override the built-in signs handler
vim.diagnostic.handlers.signs = {
    show = function(_, bufnr, _, opts)
        -- Get all diagnostics from the whole buffer rather than just the
        -- diagnostics passed to the handler
        local diagnostics = vim.diagnostic.get(bufnr)

        -- Find the "worst" diagnostic per line
        local max_severity_per_line = {}
        local max_line = vim.fn.line('$')
        for _, d in pairs(diagnostics) do
            local m = max_severity_per_line[d.lnum]
            if (not m or d.severity < m.severity) and d.lnum <= max_line then
                max_severity_per_line[d.lnum] = d
            end
        end

        -- Pass the filtered diagnostics (with our custom namespace) to
        -- the original handler
        local filtered_diagnostics = vim.tbl_values(max_severity_per_line)
        orig_signs_handler.show(ns, bufnr, filtered_diagnostics, opts)
    end,
    hide = function(_, bufnr)
        orig_signs_handler.hide(ns, bufnr)
    end,
}


local plugins = {}

table.insert(plugins, {
    'neovim/nvim-lspconfig',
    config = function()
        local on_attach = function(client, bufnr)
            vim.lsp.log.info(("LSP[%s]"):format(client.name), ("buffer[%s]"):format(bufnr), "Running `on_attach`.")
            local warnings = {}
            local bufopts = { noremap = true, silent = true, buffer = bufnr }
            local getbufopts = function(opts)
                return vim.tbl_extend("force", bufopts, opts)
            end
            if client:supports_method('textDocument/declaration', bufnr) then
                vim.keymap.set('n', 'gI', vim.lsp.buf.declaration, getbufopts({ desc = "lsp goto declaration" }))
            else
                table.insert(warnings, "`textDocument/declaration`")
            end
            if client:supports_method('textDocument/implementation', bufnr) then
                vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, getbufopts({ desc = "lsp goto implementation" }))
            else
                table.insert(warnings, "`textDocument/implementation`")
            end
            if client:supports_method('textDocument/definition', bufnr) then
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, getbufopts({ desc = "lsp goto definition" }))
                vim.keymap.set("n", "gD", "<cmd>Lspsaga peek_definition<CR>",
                    getbufopts({ desc = "LSPSaga peek definition" }))
            else
                table.insert(warnings, "`textDocument/definition`")
            end
            if client:supports_method('textDocument/diagnostic', bufnr) or client:supports_method('textDocument/publishDiagnostics') then
                vim.keymap.set("n", "gs", "<cmd>Lspsaga show_line_diagnostics<CR>",
                    getbufopts({ desc = "LSPSaga show line diagnostics" }))
                vim.keymap.set("n", "gS", "<cmd>Lspsaga show_cursor_diagnostics<CR>",
                    getbufopts({ desc = "LSPSaga show cursor diagnostics" }))
                vim.keymap.set('n', 'g[', "<cmd>Lspsaga diagnostic_jump_prev<CR>",
                    getbufopts({ desc = "LSPSaga goto prev diagnostics" }))
                vim.keymap.set('n', 'g]', "<cmd>Lspsaga diagnostic_jump_next<CR>",
                    getbufopts({ desc = "LSPSaga goto next diagnostics" }))
                vim.keymap.set('n', 'gX', "<cmd>TroubleToggle<CR>", getbufopts({ desc = "Trouble show diagnostics" }))
            else
                table.insert(warnings, "`textDocument/diagnostic`")
                table.insert(warnings, "`textDocument/publishDiagnostics`")
            end
            if client:supports_method('textDocument/references', bufnr) then
                vim.keymap.set("n", "gr", "<cmd>Lspsaga finder<CR>", getbufopts({ desc = "LSPSaga show finder" }))
                vim.keymap.set("n", "gR", "<cmd>Lspsaga incoming_calls<CR>",
                    getbufopts({ desc = "LSPSaga incoming calls" }))
                vim.keymap.set("n", "go", "<cmd>Lspsaga outgoing_calls<CR>",
                    getbufopts({ desc = "LSPSaga outgoing calls" }))
            else
                table.insert(warnings, "`textDocument/references`")
            end
            if client:supports_method('textDocument/codeAction', bufnr) then
                vim.keymap.set("n", "ga", "<cmd>Lspsaga code_action<CR>",
                    getbufopts({ desc = "LSPSaga show code action" }))
            else
                table.insert(warnings, "`textDocument/codeAction`")
            end
            if client:supports_method('textDocument/hover', bufnr) then
                vim.keymap.set("n", "gk", "<cmd>Lspsaga hover_doc<CR>", getbufopts({ desc = "LSPSaga show doc" }))
            else
                table.insert(warnings, "`textDocument/hover`")
            end
            if client:supports_method('textDocument/signatureHelp', bufnr) then
                vim.keymap.set('n', 'gK', vim.lsp.buf.signature_help, getbufopts({ desc = "lsp show signature" }))
            else
                table.insert(warnings, "`textDocument/signatureHelp`")
            end
            -- vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, getbufopts({desc = "lsp add workspace folder"}))
            if client:supports_method('textDocument/formatting', bufnr) then
                vim.keymap.set('n', 'gq', function() vim.lsp.buf.format({ async = true }) end,
                    getbufopts({ desc = "lsp format" }))
            else
                table.insert(warnings, "`textDocument/formatting`")
            end
            if client:supports_method('textDocument/rename', bufnr) then
                vim.keymap.set("n", "gc", "<cmd>Lspsaga rename<CR>", getbufopts({ desc = "LSPSaga rename" }))
            else
                table.insert(warnings, "`textDocument/rename`")
            end

            vim.lsp.log.warn(("LSP[%s]"):format(client.name), ("buffer[%s]"):format(bufnr),
                ("The LSP does not support capability %s."):format(table.concat(warnings, ", ")))

            vim.api.nvim_create_autocmd({ 'CursorHold' }, {
                group = vim.api.nvim_create_augroup("toggle_lsp_lines_" .. bufnr, { clear = false }),
                buffer = bufnr,
                callback = function()
                    vim.diagnostic.config({ virtual_lines = { only_current_line = true } }) -- lsp_lines.nvim
                    vim.api.nvim_create_autocmd({ 'CursorMoved', 'InsertEnter', 'BufHidden' }, {
                        group = vim.api.nvim_create_augroup("close_lsp_lines" .. bufnr, { clear = false }),
                        buffer = bufnr,
                        once = true,
                        callback = function()
                            if (vim.diagnostic.config().virtual_lines ~= false) then
                                vim.diagnostic.config({ virtual_lines = false })
                            end
                        end,
                        desc = 'Close lsp_lines',
                    })
                end,
                desc = "Toggle lsp_lines"
            })

            require("nvim-navic").attach(client, bufnr)
        end

        local function add_ruby_deps_command(client, bufnr)
            -- https://web.archive.org/web/20241005131741/https://shopify.github.io/ruby-lsp/editors.html#additional-setup-optional
            vim.api.nvim_buf_create_user_command(
                bufnr, "ShowRubyDeps",
                function(opts)
                    local params = vim.lsp.util.make_text_document_params()
                    local showAll = opts.args == "all"

                    client:request("rubyLsp/workspace/dependencies", params, function(error, result)
                        if error then
                            print("Error showing deps: " .. error)
                            return
                        end

                        local qf_list = {}
                        for _, item in ipairs(result) do
                            if showAll or item.dependency then
                                table.insert(qf_list, {
                                    text = string.format("%s (%s) - %s", item.name, item.version, item
                                        .dependency),
                                    filename = item.path
                                })
                            end
                        end

                        vim.fn.setqflist(qf_list)
                        vim.cmd('copen')
                    end, bufnr)
                end,
                { nargs = "?", complete = function() return { "all" } end }
            )
        end

        -- `nvim-lspconfig` defines `on_attach` for many LSPs, `vim.lsp.config` will override.
        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('my.lsp.on_attach', {}),
            callback = function(args)
                local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
                on_attach(client, args.buf)
                if client.name == 'ruby_lsp' then
                    add_ruby_deps_command(client, args.buf)
                end
            end,
        })

        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities.textDocument.completion.completionItem.snippetSupport = true
        vim.lsp.config('cssls', { capabilities = capabilities })
        vim.lsp.config('nil_ls', {
            settings = {
                -- https://github.com/oxalica/nil/blob/577d160da311cc7f5042038456a0713e9863d09e/docs/configuration.md
                ["nil"] = {
                    nix = {
                        flake = {
                            autoArchive = true,
                        },
                    },
                    formatting = {
                        command = { "nixfmt" },
                    },
                },
            },
        }) -- Nix. Possible performance issue: https://github.com/oxalica/nil/issues/83
        vim.lsp.config('lua_ls', {
            settings = {
                -- settings for `lua_ls`
                Lua = {
                    runtime = {
                        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                        version = 'LuaJIT',
                        -- Tell the language server how to find Lua modules same way as Neovim
                        -- (see `:h lua-module-load`)
                        path = {
                            '?.lua',
                            '?/init.lua',
                            'lua/?.lua',
                            'lua/?/init.lua',
                        },
                    },
                    diagnostics = {
                        -- Get the language server to recognize the `vim` global
                        globals = { 'vim' },
                    },
                    workspace = {
                        -- Make the server aware of Neovim runtime files
                        library = vim.api.nvim_get_runtime_file("", true),
                        -- https://github.com/LuaLS/lua-language-server/issues/679
                        checkThirdParty = false,
                    },
                    -- Do not send telemetry data containing a randomized but unique identifier
                    telemetry = {
                        enable = false,
                    },
                },
                -- Lua = {
                --     runtime = {
                --         -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                --         version = 'LuaJIT',
                --         -- Tell the language server how to find Lua modules same way as Neovim
                --         -- (see `:h lua-module-load`)
                --         requirePattern = {
                --             '?.lua',
                --             '?/init.lua',
                --             'lua/?.lua',
                --             'lua/?/init.lua',
                --         },
                --     },
                --     workspace = {
                --         -- Make the server aware of Neovim runtime files
                --         library = vim.api.nvim_get_runtime_file("", true),
                --         -- https://github.com/LuaLS/lua-language-server/issues/679
                --         -- checkThirdParty = false,
                --     },
                --     -- Do not send telemetry data containing a randomized but unique identifier
                --     -- telemetry = {
                --     -- 	enable = false,
                --     -- },
                -- },
            },
        })
        vim.lsp.config('pylsp', {
            before_init = function(params, config)
                -- `nvim-lspconfig` currently does not define `before_init` for `pylsp`
                -- If it does, there is no clean ways to get the function...
                -- the below code was modified from /nvim/runtime/lua/vim/lsp.lua
                --
                -- an alternative would be to do this in `on_attach` and use the "change settings" api
                -- which has the benefits that the workspace thing can be configured on a per buffer basis
                for _, v in ipairs(vim.api.nvim_get_runtime_file('lsp/pylsp.lua', true)) do
                    local rtp_config = assert(loadfile(v))()
                    if type(rtp_config.before_init) == "function" then
                        vim.lsp.log.info("exec `before_init` from " .. v)
                        rtp_config.before_init(params, config)
                    end
                end
                -- local projectPath = vim.fs.root(params.rootPath, { ".flake8", "setup.cfg", "tox.ini", "pyproject.toml" })
                local packagePath = vim.fs.root(params.rootPath, { ".venv" })
                if not packagePath then
                    local ret = vim.system({ "bash", "-c", [=[
                        # code from my archived `pylsp-path-patcher`
                        VENV_PREFIX=$(
                            # well, I don't remember how poetry and pipenv works, but I'm not using them anyway.
                            # ([[ ${in_project} > 0 ]] && poetry env info --path 2>/dev/null) || \
                            # ([[ ${in_project} > 0 ]] && pipenv --venv 2>/dev/null) || \

                            # `PYENV_VERSION` was set to `neovim` in `init.lua`
                            command -v pyenv >/dev/null && PYENV_VERSION= pyenv prefix 2>/dev/null || \
                            echo "$VIRTUAL_ENV"
                        )
                        if [[ -n "$VENV_PREFIX" ]]; then
                            "$VENV_PREFIX"/bin/python -c "import site; print(site.getsitepackages()[0])"
                        fi
                    ]=] }):wait()
                    packagePath = vim.fn.trim(ret.stdout)
                end
                vim.lsp.log.info(("rootPath: %s; PackagePath: %s"):format(params.rootPath, packagePath))
                if vim.v.shell_error == 0 and packagePath ~= "" then
                    -- https://github.com/neovim/neovim/issues/27740; https://github.com/neovim/neovim/pull/27443
                    config.settings.pylsp = vim.tbl_deep_extend("force", config.settings.pylsp, {
                        plugins = {
                            pylint = {
                                args = {
                                    ("--init-hook \"import sys; sys.path += ['%s']\""):format(packagePath)
                                }
                            },
                            jedi = {
                                extra_paths = { packagePath }
                            },
                            -- pylsp_mypy = {
                            --     overrides = {
                            --         "--python-executable", vim.fn.resolve(packagePath .. "/../../../bin/python"), true
                            --     }
                            -- }
                        }
                    })
                end
            end,
            settings = {
                pylsp = {
                    plugins = {
                        pylint = {
                            enabled = true,
                        },
                    }
                }
            }
        })
        vim.lsp.config('rust_analyzer', {
            settings = {
                ['rust-analyzer'] = {
                    check = {
                        command = 'clippy' -- TODO
                    }
                }
            }
        })
        vim.lsp.enable({
            'vimls', 'ts_ls', 'lua_ls',
            'nil_ls',   -- can use `nixfmt` as formatter
            'bashls',   -- can integrate `shfmt`, `shellcheck`
            'taplo',    -- TOML
            'marksman', -- Markdown
            'lemminx',  -- XML
            'yamlls', 'jsonls', 'cssls',
            'clangd', 'html', 'svelte',
            'racket_langserver',
            'ruby_lsp',
            'jdtls', -- Java
        })

        -- Does it matter if the lsp is not installed?

        -- install pylsp manually, because cannot include extra dependencies using Mason
        -- enable only when pylsp is installed
        if (vim.system({ "bash", "-c", "command -v pylsp" }):wait()).code == 0 then
            -- synchronously
            vim.lsp.enable('pylsp')
        end
        -- every rust version has its own rust-analyzer, so don't use Mason to install it;
        -- instead however, should add the `rust-analyzer` component manually in rustup
        if (vim.system({ "bash", "-c", "command -v rust-analyzer" }):wait()).code == 0 then
            vim.lsp.enable('rust_analyzer')
        end
        if (vim.system({ "bash", "-c", "command -v hls" }):wait()).code == 0 then
            vim.lsp.enable('hls')
        end
    end,
})
table.insert(plugins, {
    'williamboman/mason.nvim',
    opts = {
        registries = {
            -- "github:FelisNivalis/mason-registry", -- customize pylsp
            "github:mason-org/mason-registry",
        },
        -- PATH = "append" -- try system tools first
    },
}) -- lsp installer
table.insert(plugins, {
    'nvimdev/lspsaga.nvim',
    branch = 'main',
    config = function()
        local saga = require('lspsaga')
        saga.setup({
            symbol_in_winbar = {
                enable = false,
            },
            lightbulb = {
                sign = false,
                -- sign_priority = 100
            }
        })

        -- PATCH: tb removed if the plugin added support
        local saga_hover = require('lspsaga.hover')
        local open_floating_preview_original = saga_hover.open_floating_preview
        saga_hover.open_floating_preview = function(contents, opts)
            open_floating_preview_original(contents, opts)
            if saga_hover.bufnr and vim.api.nvim_buf_is_loaded(saga_hover.bufnr) then
                vim.api.nvim_set_current_win(saga_hover.winid)
            end
        end
    end,
    dependencies = {
        'nvim-treesitter/nvim-treesitter', -- optional
        'nvim-tree/nvim-web-devicons',     -- optional
    }
})                                         -- UI
table.insert(plugins, {
    'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
    config = true,
}) -- show diagnostics under the line
table.insert(plugins, {
    'j-hui/fidget.nvim',
    opts = {},
}) -- show progress
table.insert(plugins, {
    'folke/trouble.nvim',
    opts = {},
}) -- list diagnostics
-- table.insert(plugins, {
-- 	'VidocqH/lsp-lens.nvim',
-- 	opts = {
-- 		enable = true,
-- 		include_declaration = true, -- Reference include declaration
-- 		sections = {          -- Enable / Disable specific request
-- 			definition = true,
-- 			references = true,
-- 			implementation = true,
-- 		},
-- 		ignore_filetype = {
-- 			"prisma",
-- 		},
-- 	}
-- }) -- displaying references and definition infos
table.insert(plugins, {
    'Wansmer/symbol-usage.nvim',
    enabled = vim.fn.has('nvim-0.9') > 0,
    event = vim.fn.has('nvim-0.10') and 'LspAttach' or 'BufReadPre',
    config = function()
        local function h(name) return vim.api.nvim_get_hl(0, { name = name }) end

        vim.api.nvim_set_hl(0, 'SymbolUsageRef', { bg = h('Type').fg, fg = h('Normal').bg, bold = true })
        vim.api.nvim_set_hl(0, 'SymbolUsageRefRound', { fg = h('Type').fg })

        vim.api.nvim_set_hl(0, 'SymbolUsageDef', { bg = h('Function').fg, fg = h('Normal').bg, bold = true })
        vim.api.nvim_set_hl(0, 'SymbolUsageDefRound', { fg = h('Function').fg })

        vim.api.nvim_set_hl(0, 'SymbolUsageImpl', { bg = h('@parameter').fg, fg = h('Normal').bg, bold = true })
        vim.api.nvim_set_hl(0, 'SymbolUsageImplRound', { fg = h('@parameter').fg })

        local function text_format(symbol)
            local res = {}

            -- Indicator that shows if there are any other symbols in the same line
            local stacked_functions_content = symbol.stacked_count > 0
                and ("+%s"):format(symbol.stacked_count)
                or ''

            if symbol.references then
                table.insert(res, { '', 'SymbolUsageRefRound' })
                table.insert(res, { '󰌹 Ref ' .. tostring(symbol.references), 'SymbolUsageRef' })
                table.insert(res, { '', 'SymbolUsageRefRound' })
            end

            if symbol.definition then
                if #res > 0 then
                    table.insert(res, { ' ', 'NonText' })
                end
                table.insert(res, { '', 'SymbolUsageDefRound' })
                table.insert(res, { '󰳽 Def ' .. tostring(symbol.definition), 'SymbolUsageDef' })
                table.insert(res, { '', 'SymbolUsageDefRound' })
            end

            if symbol.implementation then
                if #res > 0 then
                    table.insert(res, { ' ', 'NonText' })
                end
                table.insert(res, { '', 'SymbolUsageImplRound' })
                table.insert(res, { '󰡱 Imp ' .. tostring(symbol.implementation), 'SymbolUsageImpl' })
                table.insert(res, { '', 'SymbolUsageImplRound' })
            end

            if stacked_functions_content ~= '' then
                if #res > 0 then
                    table.insert(res, { ' ', 'NonText' })
                end
                table.insert(res, { '', 'SymbolUsageImplRound' })
                table.insert(res, { ' ' .. tostring(stacked_functions_content), 'SymbolUsageImpl' })
                table.insert(res, { '', 'SymbolUsageImplRound' })
            end

            return res
        end

        require('symbol-usage').setup({
            text_format = text_format,
        })
    end
})

return plugins
