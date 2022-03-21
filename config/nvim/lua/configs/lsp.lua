vim.diagnostic.config({
	virtual_text = {
		source = true,
	},
	signs = {
		priority = 5
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

local signs = require("common.const").diagnostic_signs
for _, sign in pairs(signs) do
	vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
end

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
		for _, d in pairs(diagnostics) do
			local m = max_severity_per_line[d.lnum]
			if not m or d.severity < m.severity then
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


local plugins = require('plugins')

plugins.add({
	'neovim/nvim-lspconfig',
	config = function()
		local on_attach = function(client, bufnr)
			local bufopts = { noremap = true, silent = true, buffer = bufnr }
			local getbufopts = function(opts)
				return vim.tbl_extend("force", bufopts, opts)
			end
			vim.keymap.set('n', 'gI', vim.lsp.buf.declaration, getbufopts({ desc = "lsp goto declaration" }))
			vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, getbufopts({ desc = "lsp goto implementation" }))
			vim.keymap.set('n', 'gd', vim.lsp.buf.definition, getbufopts({ desc = "lsp goto definition" }))
			vim.keymap.set("n", "gD", "<cmd>Lspsaga peek_definition<CR>", getbufopts({ desc = "lsp show difinition" }))
			vim.keymap.set("n", "gs", "<cmd>Lspsaga show_line_diagnostics<CR>",
				getbufopts({ desc = "lsp show line diagnostics" }))
			vim.keymap.set("n", "gS", "<cmd>Lspsaga show_cursor_diagnostics<CR>",
				getbufopts({ desc = "lsp show cursor diagnostics" }))
			vim.keymap.set('n', 'g[', "<cmd>Lspsaga diagnostic_jump_prev<CR>",
				getbufopts({ desc = "lsp goto prev diagnostics" }))
			vim.keymap.set('n', 'g]', "<cmd>Lspsaga diagnostic_jump_next<CR>",
				getbufopts({ desc = "lsp goto next diagnostics" }))
			vim.keymap.set("n", "g;", "<cmd>Lspsaga lsp_finder<CR>", getbufopts({ desc = "lsp show finder" }))
			vim.keymap.set("n", "ga", "<cmd>Lspsaga code_action<CR>", getbufopts({ desc = "lsp show code action" }))
			vim.keymap.set("n", "gk",
				function()
					vim.cmd("Lspsaga hover_doc"); require('lspsaga.definition'):focus_last_window()
				end,
				getbufopts({ desc = "lsp show doc" }))
			vim.keymap.set('n', 'gK', vim.lsp.buf.signature_help, getbufopts({ desc = "lsp show signature" }))
			-- vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, getbufopts({desc = "lsp add workspace folder"}))
			vim.keymap.set('n', 'gq', function() vim.lsp.buf.format({ async = true }) end,
				getbufopts({ desc = "lsp do format" }))
			vim.keymap.set("n", "gc", "<cmd>Lspsaga rename<CR>", getbufopts({ desc = "lsp do rename" }))
			vim.keymap.set('n', 'gX', "<CMD>TroubleToggle<CR>", getbufopts({ desc = "lsp show diagnostics" }))

			vim.api.nvim_create_autocmd({ 'CursorHold' }, {
				buffer = bufnr,
				callback = function()
					vim.diagnostic.config({ virtual_lines = { only_current_line = true } }) -- lsp_lines.nvim
					vim.api.nvim_create_autocmd({ 'CursorMoved', 'InsertEnter', 'BufHidden' }, {
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

		local lspconfig = require('lspconfig')
		lspconfig.vimls.setup({ on_attach = on_attach })
		lspconfig.hls.setup({ on_attach = on_attach })
		lspconfig.taplo.setup({ on_attach = on_attach }) -- TOML
		-- lspconfig.bashls.setup({ on_attach = on_attach })
		lspconfig.tsserver.setup({ on_attach = on_attach })
		lspconfig.yamlls.setup({ on_attach = on_attach })
		lspconfig.jsonls.setup({ on_attach = on_attach })
		lspconfig.marksman.setup({ on_attach = on_attach }) -- Markdown
		lspconfig.lemminx.setup({ on_attach = on_attach }) -- XML
		lspconfig.clangd.setup({ on_attach = on_attach })
		lspconfig.html.setup({ on_attach = on_attach })
		lspconfig.svelte.setup({ on_attach = on_attach })
		lspconfig.cssls.setup({ on_attach = on_attach })
		lspconfig.racket_langserver.setup({ on_attach = on_attach })
		lspconfig.rust_analyzer.setup({ on_attach = on_attach })
		lspconfig.lua_ls.setup({
			on_attach = on_attach,
			settings = {
				Lua = {
					runtime = {
						-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
						version = 'LuaJIT',
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
			},
		})
		lspconfig.pylsp.setup({
			on_attach = on_attach,
			settings = {
				pylsp = {
					plugins = {
						pylint = {
							enabled = true,
						},
						pylsp_path_patcher = {
							mypy_args = { '--explicit-package-bases' },
						},
					}
				}
			}
		})
	end
})
plugins.add({
	'williamboman/mason.nvim',
	opts = {
		registries = {
			"github:FelisNivalis/mason-registry",
			"github:mason-org/mason-registry",
		}
	},
}) -- lsp installer
plugins.add({
	'williamboman/mason-lspconfig.nvim',
	opts = {
		automatic_installation = true,
	},
	dependencies = { 'mason.nvim' }
})
plugins.add({
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
			if saga_hover.preview_bufnr and vim.api.nvim_buf_is_loaded(saga_hover.preview_bufnr) then
				vim.api.nvim_set_current_win(saga_hover.preview_winid)
			end
		end
	end
}) -- UI
plugins.add({
	'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
	config = true,
}) -- show diagnostics under the line
plugins.add({
	'j-hui/fidget.nvim',
	opts = {},
}) -- show progress
plugins.add({
	'folke/trouble.nvim',
	opts = {},
}) -- list diagnostics
plugins.add({
	'VidocqH/lsp-lens.nvim',
	opts = {
		enable = true,
		include_declaration = true, -- Reference include declaration
		sections = {          -- Enable / Disable specific request
			definition = true,
			references = true,
			implementation = true,
		},
		ignore_filetype = {
			"prisma",
		},
	}
}) -- displaying references and definition infos
