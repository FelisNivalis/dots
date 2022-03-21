local kopts = { noremap = true, silent = true }
local getkopts = function(opts)
	return vim.tbl_extend("force", kopts, opts)
end
local plugins = {}

table.insert(plugins, {
	'stevearc/qf_helper.nvim',
	config = true,
})

table.insert(plugins, {
	'xiyaowong/nvim-cursorword',
	config = function(spec, opts)
		vim.g.cursorword_min_width = 1
		vim.cmd "hi default CursorWord cterm=underline gui=underline"
	end
}) -- highlight words on the cursor

table.insert(plugins, {
	'johnfrankmorgan/whitespace.nvim',
	opts = {
		highlight = 'DiffDelete',
		ignored_filetypes = {},
	},
	init = function()
		-- vim.api.nvim_set_keymap(
		-- 	'n',
		-- 	'<Leader>t',
		-- 	[[<cmd>lua require('whitespace-nvim').trim()<CR>]]
		-- 	{ noremap = true }
		-- )
	end
}) -- trailing whitespaces
table.insert(plugins, {
	'norcalli/nvim-colorizer.lua',
	opts = {
		'*',
		css = { hsl_fn = true },
		lua = { hsl_fn = true },
		vim = { hsl_fn = true }
	}
}) -- highlight colours
table.insert(plugins, {
	'levouh/tint.nvim',
	config = true,
	priority = 0 -- load the last
})
table.insert(plugins, {
	'melkster/modicator.nvim',
	dependencies = {
		'savq/melange',
	},
	config = true
}) -- change fg of `CursorLineNr` based on vim mode

table.insert(plugins, {
	'rickhowe/diffchar.vim',
	init = function()
		vim.g.DiffCharDoMapping = 0
	end,
}) -- diff mode

table.insert(plugins, { 'galicarnax/vim-regex-syntax' })


-- themes
table.insert(plugins, { 'Haron-Prime/evening_vim' })
table.insert(plugins, {
	'savq/melange',
	config = function()
		vim.cmd.colorscheme("melange")
	end,
	priority = 1000,
})
table.insert(plugins, { 'katawful/kat.nvim' })
table.insert(plugins, { 'sts10/vim-pink-moon' })
table.insert(plugins, { 'rktjmp/lush.nvim' })


-- enhancements
table.insert(plugins, { 'Vimjas/vim-python-pep8-indent' })
table.insert(plugins, {
	'nmac427/guess-indent.nvim',
	config = true,
})
table.insert(plugins, {
	'windwp/nvim-autopairs',
	event = "InsertEnter",
	config = true,
	opts = {
		check_ts = true,
	},
})

table.insert(plugins, {
	'lukas-reineke/indent-blankline.nvim',
	main = "ibl",
	opts = {
		indent = {
			char = "▎",
		},
		scope = {
			enabled = false,
		},
		whitespace = {
			remove_blankline_trail = false,
		},
	},
	init = function()
		-- vim.opt.listchars:append "space:⋅"
		-- vim.opt.listchars:remove "trail"
	end
}) -- indentation guide

table.insert(plugins, {
	'lukas-reineke/virt-column.nvim',
	priority = 1100,
}) -- vertical line at columns
-- table.insert(plugins, {
-- 	'declancm/cinnamon.nvim',
-- }) -- smooth scrolling
table.insert(plugins, {
	'FelisNivalis/range-highlight.nvim',
	opts = {},
	dependencies = { 'winston0410/cmd-parser.nvim' }
}) -- highlight when :[line1],[line2]
table.insert(plugins, {
	'nacro90/numb.nvim',
	config = true,
}) -- peeking when :[number]

table.insert(plugins, {
	'haya14busa/vim-asterisk',
	dependencies = {
		'kevinhwang91/nvim-hlslens',
	},
	init = function()
		vim.api.nvim_set_keymap('n', 'z*', [[<Plug>(asterisk-*)<Cmd>]], kopts)
		vim.api.nvim_set_keymap('n', 'z#', [[<Plug>(asterisk-#)<Cmd>]], kopts)
		vim.api.nvim_set_keymap('n', 'gz*', [[<Plug>(asterisk-g*)<Cmd>]], kopts)
		vim.api.nvim_set_keymap('n', 'gz#', [[<Plug>(asterisk-g#)<Cmd>]], kopts)

		vim.api.nvim_set_keymap('n', '<C-h>', ':noh<CR>', kopts)
		vim.api.nvim_set_keymap('n', '*', [[<Plug>(asterisk-*)<Cmd>lua require('hlslens').start()<CR>]], kopts)
		vim.api.nvim_set_keymap('n', '#', [[<Plug>(asterisk-#)<Cmd>lua require('hlslens').start()<CR>]], kopts)
		vim.api.nvim_set_keymap('n', 'g*', [[<Plug>(asterisk-g*)<Cmd>lua require('hlslens').start()<CR>]], kopts)
		vim.api.nvim_set_keymap('n', 'g#', [[<Plug>(asterisk-g#)<Cmd>lua require('hlslens').start()<CR>]], kopts)

		vim.api.nvim_set_keymap('x', '*', [[<Plug>(asterisk-*)<Cmd>lua require('hlslens').start()<CR>]], kopts)
		vim.api.nvim_set_keymap('x', '#', [[<Plug>(asterisk-#)<Cmd>lua require('hlslens').start()<CR>]], kopts)
		vim.api.nvim_set_keymap('x', 'g*', [[<Plug>(asterisk-g*)<Cmd>lua require('hlslens').start()<CR>]], kopts)
		vim.api.nvim_set_keymap('x', 'g#', [[<Plug>(asterisk-g#)<Cmd>lua require('hlslens').start()<CR>]], kopts)
	end
}) -- enhanced *

table.insert(plugins, {
	'kevinhwang91/nvim-hlslens',
	opts = {},
	init = function()
		vim.api.nvim_set_keymap('n', 'n',
			[[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
			kopts)
		vim.api.nvim_set_keymap('n', 'N',
			[[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
			kopts)
	end
}) -- enhanced *

table.insert(plugins, {
	'stsewd/gx-extended.vim',
	init = function()
		vim.g.netrw_browsex_viewer = os.getenv('BROWSER')
		vim.api.nvim_set_keymap("n", "gx", "<Plug>(gxext-normal)", kopts)
		vim.api.nvim_set_keymap("v", "gx", "<Plug>(gxext-visual)", kopts)
	end
})

table.insert(plugins, {
	'gbprod/cutlass.nvim',
	opts = { cut_key = 'r', exclude = { 'vx', 'sx', 'xx', 'vX', 'sX', 'xX' } },
}) -- delete without yank
table.insert(plugins, {
	'terrortylor/nvim-comment',
	config = true,
	main = 'nvim_comment'
}) -- gc

table.insert(plugins, {
	"OXY2DEV/foldtext.nvim",
	lazy = false
})
table.insert(plugins, {
	'kevinhwang91/nvim-ufo',
	opts = {
		provider_selector = function(bufnr, filetype, buftype)
			return { 'treesitter', 'indent' }
		end
	},
	dependencies = { 'kevinhwang91/promise-async', 'nvim-treesitter' }
}) -- auto create folds

table.insert(plugins, {
	'nvim-tree/nvim-web-devicons',
	opts = {
		override = {
			zsh = {
				icon = "",
				color = "#428850",
				cterm_color = "65",
				name = "Zsh"
			}
		},
		-- globally enable different highlight colors per icon (default to true)
		-- if set to false all icons will have the default icon's color
		color_icons = true,
		-- globally enable default icons (default to false)
		-- will get overriden by `get_icons` option
		default = true,
	}
}) -- required by cokeline
table.insert(plugins, { 'echasnovski/mini.icons', version = false })
table.insert(plugins, { 'prichrd/netrw.nvim', opts = {}, dependencies = { 'echasnovski/mini.icons' } })

table.insert(plugins, { 'SmiteshP/nvim-navic' }) -- lsp status
table.insert(plugins, {
	'lewis6991/satellite.nvim',
	enabled = vim.fn.has('nvim-0.10') > 0,
	config = true,
})
table.insert(plugins, {
	'rcarriga/nvim-notify',
	init = function()
		vim.notify = require("notify")
	end
})

table.insert(plugins, {
	'mbbill/undotree',
	init = function()
		vim.g.undotree_WindowLayout = 1
		vim.g.undotree_ShortIndicators = 1
		vim.g.undotree_SetFocusWhenToggle = 1
		vim.api.nvim_set_keymap('n', '<leader>u', ':UndotreeToggle<CR>', kopts)
	end
})

table.insert(plugins, {
	'rmagatti/auto-session',
	opts = {},
	init = function()
		vim.api.nvim_set_keymap('n', '<leader>ss', "<cmd>AutoSession save<CR>",
			getkopts({ desc = "Save or create a session" }))
		vim.api.nvim_set_keymap('n', '<leader>sd', "<cmd>Autosession delete<CR>",
			getkopts({ desc = "Delete a session from a picker" }))
		vim.api.nvim_set_keymap('n', '<leader>sr', "<cmd>Autosession search<CR>",
			getkopts({ desc = "Restore a session from a picker" }))
	end
})

table.insert(plugins, {
	'gennaro-tedesco/nvim-peekup',
	init = function()
		vim.g.peekup_open = '<leader>"'
	end
}) -- registers


-- functionalities
table.insert(plugins, {
	'smoka7/hop.nvim',
	config = function()
		local hop = require('hop')
		vim.keymap.set('', 'f', function()
			hop.hint_char1({ current_line_only = false })
		end, { remap = true })
		vim.keymap.set('', 'F', function()
			hop.hint_char1({ current_line_only = true })
		end, { remap = true })
		-- PATCH `hop.nvim` to sort the jump targets
		require('hop').setup({
			distance_method = function(a, b, x_bias)
				return a.row == b.row and (b.col - a.col) / 1000 or
					b.row - a.row + b.col / 1000 - (b.row < a.row and 1 or 0)
			end
		})
		require('hop.jump_target').sort_indirect_jump_targets = function(indirect_jump_targets, opts)
			local score_comparison = function(a, b)
				return math.abs(a.score) < math.abs(b.score)
			end
			table.sort(indirect_jump_targets, score_comparison)
			local indices = { [true] = 1, [false] = 2 }
			for _, target in ipairs(indirect_jump_targets) do
				local i = target.score > 0
				target.score = indices[i]
				indices[i] = indices[i] + 2
			end
			table.sort(indirect_jump_targets, function(a, b)
				return a.score < b.score
			end)
		end
	end
}) -- easymotion
table.insert(plugins, {
	'junegunn/vim-easy-align',
	init = function()
		vim.api.nvim_set_keymap('x', 'aa', '<Plug>(EasyAlign)', kopts)
	end
})

table.insert(plugins, { 'chrisbra/NrrwRgn' }) -- narrowed region
table.insert(plugins, {
	'chentoast/marks.nvim',
	opts = {
		-- builtin_marks = { ".", "<", ">", "^", "[", "]" },
		sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
		-- force_write_shada = true,
	}
})
table.insert(plugins, { 'tweekmonster/helpful.vim' }) -- version info
table.insert(plugins, {
	'kylechui/nvim-surround',
	opts = {},
})

table.insert(plugins, {
	url = 'https://gitlab.com/yorickpeterse/nvim-window',
	init = function()
		vim.api.nvim_set_keymap('n', '<C-W>a', [[<Cmd>lua require('nvim-window').pick()<CR>]], kopts)
	end
})                                                -- switch between windows

table.insert(plugins, { 'famiu/bufdelete.nvim' }) -- keep window
table.insert(plugins, {
	'folke/which-key.nvim',
	event = "VeryLazy",
	config = function()
		require("which-key").add({
			{ "<leader>g", group = 'git' },
			{ ";g",        group = "telescope git" },
			{ ";h",        group = "telescope history" },
			{ ";c",        group = "telescope commands" },
		})
	end
})
table.insert(plugins, {
	'anuvyklack/keymap-amend.nvim',
	config = function()
		require('keymap-amend')('n', '<Tab>', function(original)
			if not require('ufo.preview'):peekFoldedLinesUnderCursor() then
				original()
			end
		end
		)
	end,
	dependencies = {
		'kevinhwang91/nvim-ufo',
	}
})


table.insert(plugins, {
	'numToStr/FTerm.nvim',
	config = function()
		-- tnoremap <Esc><Esc> <C-\><C-n>
		vim.keymap.set('t', '<Esc><Esc>', function()
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-\\><C-n>', true, false, true), 'm', true)
		end, getkopts({ desc = "Normal mode" }))
		vim.keymap.set('n', '<leader>tt', function()
			require('FTerm'):toggle()
		end, { desc = "term shell" })
		vim.keymap.set('n', '<leader>tg', function()
			local function find_git_dir(path)
				while true do
					if vim.fn.isdirectory(path .. '/.git') > 0 then
						return path
					end
					path = vim.fn.fnamemodify(path, ":h")
				end
			end
			local term = require('FTerm'):new({ cmd = { 'lazygit', '-p', find_git_dir(vim.fn.expand("%:p:h")) } })
			term:open()
		end, { desc = "term lazygit" })
	end
})

table.insert(plugins, { 'metakirby5/codi.vim' }) -- interactive scratchpad
table.insert(plugins, {
	'Bekaboo/dropbar.nvim',
	enabled = vim.fn.has('nvim-0.11') > 0,
	-- optional, but required for fuzzy finder support
	dependencies = {
		'nvim-telescope/telescope-fzf-native.nvim',
		build = 'make',
	},
	config = function()
		require('dropbar').setup()
		vim.ui.select = require('dropbar.utils.menu').select
	end
})

table.insert(plugins, {
	'MeanderingProgrammer/render-markdown.nvim',
	opts = {
		file_types = { "markdown", "Avante" },
	},
	ft = { "markdown", "Avante" },

	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons"
	}
})

table.insert(plugins, {
	"m4xshen/hardtime.nvim",
	dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
	opts = {
		enabled = false,
	}
})

table.insert(plugins, {
	-- support for image pasting
	"HakonHarnes/img-clip.nvim",
	event = "VeryLazy",
	opts = {
		-- recommended settings
		default = {
			embed_image_as_base64 = false,
			prompt_for_file_name = false,
			drag_and_drop = {
				insert_mode = true,
			},
			-- required for Windows users
			use_absolute_path = true,
		},
	},
})

table.insert(plugins, {
	"blacklight/nvim-http",
	build = ":UpdateRemotePlugins",
})

table.insert(plugins, {
	"mizlan/iswap.nvim",
	event = "VeryLazy",
	init = function()
		vim.keymap.set('n', '<leader>ww', '<cmd>ISwap<cr>', getkopts({ desc = 'Swap.' }))
		vim.keymap.set('n', '<leader>wn', '<cmd>ISwapNode<cr>', getkopts({ desc = 'Swap nodes.' }))
		-- vim.keymap.set('n', '<leader>w<left>', '<cmd>ISwapWithLeft<cr>', getkopts({ desc = 'Swap with left sibling.' }))
		-- vim.keymap.set('n', '<leader>w<right>', '<cmd>ISwapWithRight<cr>', getkopts({ desc = 'Swap with right sibling.' }))
	end
})

table.insert(plugins, {
	"folke/todo-comments.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
})

-- table.insert(plugins, {
-- 	'jedrzejboczar/exrc.nvim',
-- 	dependencies = { 'neovim/nvim-lspconfig' },
-- 	config = true,
-- 	lazy = false,
-- 	opts = {
-- 		exrc_name = '.nvim.exrc.lua',
-- 		min_log_level = vim.log.levels.TRACE,
-- 		lsp = {
-- 			auto_setup = true, -- TODO: figure out how `on_new_config` works, cannot make it work
-- 		},
-- 	},
-- })

-- table.insert(plugins, {
-- 	-- TODO: fix: https://github.com/3rd/image.nvim/issues/264
-- 	"3rd/image.nvim",
-- 	opts = {
-- 		backend = "ueberzug",
-- 		processor = "magick_cli",
-- 		hijack_file_patterns = {
-- 			"*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif",
-- 			"*.PNG", "*.JPG", "*.JPEG", "*.GIF", "*.WEBP", "*.AVIF",
-- 		},
-- 		integrations = {
-- 			markdown = {
-- 				clear_in_insert_mode = true,
-- 				only_render_image_at_cursor = true,
-- 				only_render_image_at_cursor_mode = "popup", -- "popup" or "inline", defaults to "popup"
-- 				floating_windows = true,    -- if true, images will be rendered in floating markdown windows
-- 			},
-- 		}
-- 	}
-- })

return plugins
