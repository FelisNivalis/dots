local kopts = { noremap = true, silent = true }
local getkopts = function(opts)
	return vim.tbl_extend("force", kopts, opts)
end

return {
	{
		'nvim-telescope/telescope.nvim',
		dependencies = { 'nvim-lua/plenary.nvim' },
		config = function()
			local telescope = require('telescope')
			local actions = require("telescope.actions")
			local state = require("telescope.actions.state")
			local global_state = require("telescope.state")
			local builtin = require('telescope.builtin')
			local ext = require('telescope').extensions
			local pickers = {
				find_files = function(opts)
					opts = opts or {}
					if opts.hidden == nil then
						opts.hidden = true
					end
					global_state.set_global_key('find_files:opts', vim.deepcopy(opts))
					builtin.find_files(vim.tbl_extend(
						"force",
						{ find_command = { 'fd', '-t', 'f', '-t', 'd' } },
						opts))
				end,
				file_browser = function(opts)
					ext.file_browser.file_browser(vim.tbl_extend("force", { hidden = true }, opts or {}))
				end,
				live_grep = function(opts)
					opts = opts or {}
					if opts.hidden == nil then
						opts.hidden = true
					end
					global_state.set_global_key('live_grep:opts', vim.deepcopy(opts))
					if opts.hidden then
						opts.additional_args = vim.iter({ opts.additional_args or {}, { "--hidden" } }):flatten():totable()
					end
					opts.hidden = nil
					builtin.live_grep(vim.tbl_extend("force", {}, opts or {}))
				end,
			}
			local my_actions = require("telescope.actions.mt").transform_mod({
				find_files_toggle_hidden = function(prompt_bufnr)
					local opts = vim.deepcopy(global_state.get_global_key('find_files:opts') or {})
					opts.hidden = not opts.hidden or false
					pickers.find_files(opts)
				end,
				live_grep_toggle_hidden = function(prompt_bufnr)
					local opts = vim.deepcopy(global_state.get_global_key('live_grep:opts') or {})
					opts.hidden = not opts.hidden or false
					pickers.live_grep(opts)
				end,
				find_files_cwd = function(_)
					-- print("find_files_cwd " .. state.get_selected_entry().cwd)
					pickers.find_files({ cwd = state.get_selected_entry().cwd })
				end,
				live_grep_cwd = function(_)
					pickers.live_grep({ cwd = state.get_selected_entry().cwd })
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
					pickers.live_grep({ cwd = dir })
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
					temp__scrolling_limit = 100000,
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
								[";s"] = actions.close + my_actions.live_grep,
								[";e"] = actions.close + my_actions.file_browser,
								[";f"] = actions.close + my_actions.find_files,
								g = actions.close + my_actions.goto_parent_dir,
								e = actions.close + my_actions.goto_home_dir,
								h = actions.close + my_actions.find_files_toggle_hidden,
							}
						}
					},
					live_grep = {
						attach_mappings = function(_, map)
							map(
								"n", "h",
								actions.close + my_actions.live_grep_toggle_hidden,
								{ desc = "toggle hidden" }
							)
							return true
						end,
						temp__scrolling_limit = 1000,
					},
				},
				extensions = {
					file_browser = {
						mappings = {
							n = {
								[";s"] = actions.close + my_actions.live_grep_cwd,
								[";f"] = actions.close + my_actions.find_files_cwd,
							}
						}
					},
				}
			})
			telescope.load_extension('hop')
			vim.keymap.set('n', ';b', builtin.buffers, getkopts({ desc = "buffers" }))
			vim.keymap.set('n', ';ca', builtin.autocommands, getkopts({ desc = "autocommands" }))
			vim.keymap.set('n', ';cc', builtin.commands, getkopts({ desc = "commands" }))
			-- telescope.load_extension("file_browser")
			vim.keymap.set('n', ';e',
				function() pickers.file_browser({ cwd = '%:h' }) end,
				getkopts({ desc = "file browser" }))
			vim.keymap.set('n', ';f', pickers.find_files, getkopts({ desc = "file finder" }))
			vim.keymap.set('n', ';s', pickers.live_grep, getkopts({ desc = "grep" }))
			vim.keymap.set('n', ';gd', builtin.lsp_definitions, getkopts({ desc = "lsp definitions" }))
			vim.keymap.set('n', ';gl', builtin.lsp_document_symbols, getkopts({ desc = "lsp_document_symbols" }))
			vim.keymap.set('n', ';gr', builtin.lsp_references, getkopts({ desc = "lsp references" }))
			vim.keymap.set('n', ';gR', builtin.lsp_incoming_calls, getkopts({ desc = "lsp incoming calls" }))
			vim.keymap.set('n', ';go', builtin.lsp_outgoing_calls, getkopts({ desc = "lsp outgoing calls" }))
			vim.keymap.set('n', ';gs', builtin.diagnostics, getkopts({ desc = "lsp diagnostics" }))
			vim.keymap.set('n', ';hc', builtin.command_history, getkopts({ desc = "history commands" }))
			vim.keymap.set('n', ';hi', builtin.highlights, getkopts({ desc = "highlights" }))
			vim.keymap.set('n', ';hq', builtin.quickfixhistory, getkopts({ desc = "history quickfix" }))
			vim.keymap.set('n', ';hs', builtin.search_history, getkopts({ desc = "history search" }))
			vim.keymap.set('n', ';ht', builtin.help_tags, getkopts({ desc = "help tags" }))
			telescope.load_extension('glyph')
			vim.keymap.set('n', ';i', function() ext.glyph.glyph({}) end, getkopts({ desc = "icons" }))
			vim.keymap.set('n', ';j', builtin.jumplist, getkopts({ desc = "jumplist" }))
			vim.keymap.set('n', ';k', builtin.keymaps, getkopts({ desc = "keymaps" }))
			vim.keymap.set('n', ';m', builtin.marks, getkopts({ desc = "marks" }))
			vim.keymap.set('n', ';n', ext.notify.notify, getkopts({ desc = "notify.nvim" }))
			vim.keymap.set('n', ';o', builtin.oldfiles, getkopts({ desc = "oldfiles" }))
			vim.keymap.set('n', ';p', builtin.pickers, getkopts({ desc = "pickers" }))
			vim.keymap.set('n', ';q', builtin.quickfix, getkopts({ desc = "quickfix" }))
			vim.keymap.set('n', ';r', builtin.registers, getkopts({ desc = "registers" }))
			vim.keymap.set('n', ';C', builtin.colorscheme, getkopts({ desc = "colorscheme" }))
			vim.keymap.set('n', ';t', builtin.filetypes, getkopts({ desc = "filetypes" }))
			vim.keymap.set('n', ';v', builtin.vim_options, getkopts({ desc = "vim_options" }))
			telescope.load_extension("yank_history")
			vim.keymap.set('n', ';y', function() ext.yank_history.yank_history({}) end,
				getkopts({ desc = "yank_history" }))
			vim.keymap.set('n', ';z', builtin.current_buffer_fuzzy_find,
				getkopts({ desc = "current_buffer_fuzzy_find" }))
		end
	},
	{
		'ziontee113/icon-picker.nvim',
		opts = { disable_legacy_commands = true },
		dependencies = { 'stevearc/dressing.nvim' }
	}, -- input icons
	{
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
	},
	{ 'nvim-telescope/telescope-hop.nvim' },
	{ 'ghassan0/telescope-glyph.nvim' },
	{ 'nvim-telescope/telescope-file-browser.nvim' },
}
