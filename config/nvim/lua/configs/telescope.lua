local kopts = { noremap = true, silent = true }
local getkopts = function(opts)
	return vim.tbl_extend("force", kopts, opts)
end

local plugins = require('plugins')

plugins.add({
	'nvim-telescope/telescope.nvim',
	dependencies = { 'nvim-lua/plenary.nvim' },
	config = function()
		local telescope = require('telescope')
		local actions = require("telescope.actions")
		local state = require("telescope.actions.state")
		local builtin = require('telescope.builtin')
		local ext = require('telescope').extensions
		local pickers = {
			find_files = function(opts)
				builtin.find_files(vim.tbl_extend(
					"force",
					{ hidden = true, find_command = { 'fd', '-t', 'f', '-t', 'd' } },
					opts or {}))
			end,
			file_browser = function(opts)
				ext.file_browser.file_browser(vim.tbl_extend("force", { hidden = true }, opts or {}))
			end,
		}
		local my_actions = require("telescope.actions.mt").transform_mod({
			find_files_cwd = function(_)
				print("find_files_cwd " .. state.get_selected_entry().cwd)
				pickers.find_files({ cwd = state.get_selected_entry().cwd })
			end,
			live_grep_cwd = function(_)
				builtin.live_grep({ cwd = state.get_selected_entry().cwd })
			end,
			find_files = function(_)
				local entry = state.get_selected_entry()
				local dir = vim.fs.normalize(entry.cwd .. "/" .. entry[1])
				pickers.find_files({ cwd = dir })
			end,
			file_browser = function(_)
				local entry = state.get_selected_entry()
				local dir = vim.fs.normalize(entry.cwd .. "/" .. entry[1])
				pickers.file_browser({ cwd = dir })
			end,
			live_grep = function(_)
				local entry = state.get_selected_entry()
				local dir = vim.fs.normalize(entry.cwd .. "/" .. entry[1])
				builtin.live_grep({ cwd = dir })
			end,
			yank = function(_)
				vim.fn.setreg([["]], state.get_selected_entry()[1], "l")
			end,
			goto_parent_dir = function(_)
				pickers.find_files({ cwd = vim.fn.fnamemodify(state.get_selected_entry().cwd, ':h') })
			end,
			goto_home_dir = function(_)
				pickers.find_files({ cwd = vim.fn.expand('$HOME') })
			end
		})

		telescope.setup({
			defaults = {
				scroll_strategy = "limit",
				cache_picker = {
					num_pickers = -1,
				},
				mappings = {
					n = {
						f = ext.hop.hop,
						y = my_actions.yank,
					},
				},
			},
			pickers = {
				find_files = {
					mappings = {
						n = {
							[";g"] = actions.close + my_actions.live_grep,
							[";e"] = actions.close + my_actions.file_browser,
							[";f"] = actions.close + my_actions.find_files,
							g = actions.close + my_actions.goto_parent_dir,
							e = actions.close + my_actions.goto_home_dir,
						}
					}
				},
			},
			extensions = {
				file_browser = {
					mappings = {
						n = {
							[";g"] = actions.close + my_actions.live_grep_cwd,
							[";f"] = actions.close + my_actions.find_files_cwd,
						}
					}
				},
			}
		})
		telescope.load_extension('hop')
		vim.keymap.set('n', ';ac', builtin.autocommands, getkopts({ desc = "autocommands" }))
		vim.keymap.set('n', ';b', builtin.buffers, getkopts({ desc = "buffers" }))
		vim.keymap.set('n', ';c', builtin.commands, getkopts({ desc = "commands" }))
		vim.keymap.set('n', ';d', builtin.diagnostics, getkopts({ desc = "diagnostics" }))
		-- telescope.load_extension("file_browser")
		vim.keymap.set('n', ';e',
			function() pickers.file_browser({ cwd = '%:h' }) end,
			getkopts({ desc = "file browser" }))
		vim.keymap.set('n', ';f', pickers.find_files, getkopts({ desc = "file finder" }))
		vim.keymap.set('n', ';g', builtin.live_grep, getkopts({ desc = "grep" }))
		vim.keymap.set('n', ';hc', builtin.command_history, getkopts({ desc = "history commands" }))
		vim.keymap.set('n', ';hi', builtin.highlights, getkopts({ desc = "highlights" }))
		vim.keymap.set('n', ';hq', builtin.quickfixhistory, getkopts({ desc = "history quickfix" }))
		vim.keymap.set('n', ';hs', builtin.search_history, getkopts({ desc = "history search" }))
		vim.keymap.set('n', ';ht', builtin.help_tags, getkopts({ desc = "help tags" }))
		telescope.load_extension('glyph')
		vim.keymap.set('n', ';i', function() ext.glyph.glyph({}) end, getkopts({ desc = "icons" }))
		vim.keymap.set('n', ';j', builtin.jumplist, getkopts({ desc = "jumplist" }))
		vim.keymap.set('n', ';km', builtin.keymaps, getkopts({ desc = "keymaps" }))
		vim.keymap.set('n', ';l', builtin.lsp_document_symbols, getkopts({ desc = "lsp_document_symbols" }))
		vim.keymap.set('n', ';m', builtin.marks, getkopts({ desc = "marks" }))
		vim.keymap.set('n', ';o', builtin.oldfiles, getkopts({ desc = "oldfiles" }))
		vim.keymap.set('n', ';p', builtin.pickers, getkopts({ desc = "pickers" }))
		vim.keymap.set('n', ';q', builtin.quickfix, getkopts({ desc = "quickfix" }))
		vim.keymap.set('n', ';r', builtin.registers, getkopts({ desc = "registers" }))
		vim.keymap.set('n', ';s', builtin.colorscheme, getkopts({ desc = "colorscheme" }))
		vim.keymap.set('n', ';t', builtin.filetypes, getkopts({ desc = "filetypes" }))
		vim.keymap.set('n', ';vo', builtin.vim_options, getkopts({ desc = "vim_options" }))
		telescope.load_extension("yank_history")
		vim.keymap.set('n', ';y', function() ext.yank_history.yank_history({}) end,
			getkopts({ desc = "yank_history" }))
		vim.keymap.set('n', ';z', builtin.current_buffer_fuzzy_find,
			getkopts({ desc = "current_buffer_fuzzy_find" }))
	end
})
plugins.add({
	'ziontee113/icon-picker.nvim',
	opts = { disable_legacy_commands = true },
	dependencies = { 'stevearc/dressing.nvim' }
}) -- input icons
plugins.add({
	'gbprod/yanky.nvim',
	config = function()
		local yanky_mapping = require("yanky.telescope.mapping")
		local yanky_utils = require("yanky.utils")
		require("yanky").setup({
			picker = {
				telescope = {
					mappings = {
						default = yanky_mapping.set_register(yanky_utils.get_default_register()),
						n = {
							p = { yanky_mapping.put("p"), "yank before" },
							P = { yanky_mapping.put("P"), "yank after" },
							d = { yanky_mapping.delete(), "delete" },
							y = { yanky_mapping.set_register([["]]), "set register \"" },
						},
					}
				}
			},
		})
	end,
	dependencies = { 'telescope.nvim' }
})
plugins.add({ 'nvim-telescope/telescope-hop.nvim' })
plugins.add({ 'ghassan0/telescope-glyph.nvim' })
plugins.add({ 'nvim-telescope/telescope-file-browser.nvim' })
