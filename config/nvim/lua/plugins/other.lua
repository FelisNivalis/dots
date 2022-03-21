local kopts = { noremap = true, silent = true }
local getkopts = function(opts)
	return vim.tbl_extend("force", kopts, opts)
end
local plugins = {}

table.insert(plugins, {
	'xiyaowong/nvim-cursorword',
	config = function(spec, opts)
		vim.cmd [[
			let g:cursorword_min_width = 1
			hi default CursorWord cterm=underline gui=underline
		]]
	end
}) -- highlight words on the cursor

table.insert(plugins, {
	'johnfrankmorgan/whitespace.nvim',
	opts = {
		highlight = 'DiffDelete',
		ignored_filetypes = {},
	}
}) -- trailing whitespaces
-- vim.api.nvim_set_keymap(
-- 	'n',
-- 	'<Leader>t',
-- 	[[<cmd>lua require('whitespace-nvim').trim()<CR>]]
-- 	{ noremap = true }
-- )
table.insert(plugins, {
	'norcalli/nvim-colorizer.lua',
	opts = {
		'*',
		css = { hsl_fn = true },
		lua = { hsl_fn = true },
		vim = { hsl_fn = true }
	}
})                              -- highlight colours
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
}) -- diff mode
vim.g.DiffCharDoMapping = 0

table.insert(plugins, { 'galicarnax/vim-regex-syntax' })


-- themes
table.insert(plugins, { 'Haron-Prime/evening_vim' })
table.insert(plugins, {
	'savq/melange',
	config = function()
		vim.cmd("colorscheme melange")
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
	}
}) -- indentation guide
-- vim.opt.listchars:append "space:⋅"
-- vim.opt.listchars:remove "trail"

table.insert(plugins, {
	'lukas-reineke/virt-column.nvim',
	priority = 1100,
}) -- vertical line at columns
-- table.insert(plugins, {
-- 	'declancm/cinnamon.nvim',
-- }) -- smooth scrolling
table.insert(plugins, {
	'winston0410/range-highlight.nvim',
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
	}
}) -- enhanced *
-- asterisk
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

table.insert(plugins, {
	'kevinhwang91/nvim-hlslens',
	opts = {},
}) -- enhanced *
vim.api.nvim_set_keymap('n', 'n',
	[[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
	kopts)
vim.api.nvim_set_keymap('n', 'N',
	[[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
	kopts)

table.insert(plugins, { 'stsewd/gx-extended.vim' })
vim.g.netrw_browsex_viewer = os.getenv('BROWSER')
vim.api.nvim_set_keymap("n", "gx", "<Plug>(gxext-normal)", kopts)
vim.api.nvim_set_keymap("v", "gx", "<Plug>(gxext-visual)", kopts)

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
	'anuvyklack/pretty-fold.nvim',
	opts = {
		keep_indentation = false,
		fill_char = '━',
		sections = {
			left = {
				'━ ', function() return string.rep('*', vim.v.foldlevel) end, ' ━┫', 'content', '┣'
			},
			right = {
				'┫ ', 'number_of_folded_lines', ': ', 'percentage', ' ┣━━',
			}
		}
	}
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
if vim.fn.has('nvim-0.10') > 0 then
	table.insert(plugins, {
		'lewis6991/satellite.nvim',
		config = true,
	})
end
table.insert(plugins, { 'rcarriga/nvim-notify' })

table.insert(plugins, { 'mbbill/undotree' })
vim.g.undotree_WindowLayout = 1
vim.g.undotree_ShortIndicators = 1
vim.g.undotree_SetFocusWhenToggle = 1
vim.api.nvim_set_keymap('n', '<leader>u', ':UndotreeToggle<CR>', kopts)

table.insert(plugins, {
	'rmagatti/auto-session',
	opts = {}
})
vim.api.nvim_set_keymap('n', '<leader>ss', "<cmd>SessionSave<CR>", getkopts({ desc = "Save or create a session" }))
vim.api.nvim_set_keymap('n', '<leader>sd', "<cmd>Autosession delete<CR>",
	getkopts({ desc = "Delete a session from a picker" }))
vim.api.nvim_set_keymap('n', '<leader>sr', "<cmd>Autosession search<CR>",
	getkopts({ desc = "Restore a session from a picker" }))

table.insert(plugins, { 'gennaro-tedesco/nvim-peekup' }) -- registers
vim.g.peekup_open = '<leader>"'


-- functionalities
table.insert(plugins, {
	'phaazon/hop.nvim',
	config = function()
		local hop = require('hop')
		local directions = require('hop.hint').HintDirection
		vim.keymap.set('', 'f', function()
			hop.hint_char1({ current_line_only = false })
		end, { remap = true })
		vim.keymap.set('', 'F', function()
			hop.hint_char1({ current_line_only = true })
		end, { remap = true })
		require('hop').setup()
		-- PATCH `hop.nvim` to sort the jump targets
		local hop_jump_target = require('hop.jump_target')
		hop_jump_target.manh_dist = function(a, b, x_bias)
			-- https://github.com/phaazon/hop.nvim/blob/03f0434869f1f38868618198b5f4f2ab6d39aef2/lua/hop/window.lua#L10
			return a[1] == b[1] + 1 and (b[2] - a[2]) / 1000 or
				b[1] + 1 - a[1] + b[2] / 1000 - (b[1] + 1 < a[1] and 1 or 0)
		end
		hop_jump_target.sort_indirect_jump_targets = function(indirect_jump_targets, opts)
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
table.insert(plugins, { 'junegunn/vim-easy-align' })
vim.api.nvim_set_keymap('x', 'aa', '<Plug>(EasyAlign)', kopts)

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
}) -- switch between windows
vim.api.nvim_set_keymap('n', '<C-W>a', [[<Cmd>lua require('nvim-window').pick()<CR>]], kopts)

table.insert(plugins, { 'famiu/bufdelete.nvim' }) -- keep window
table.insert(plugins, {
	'folke/which-key.nvim',
	config = function()
		require("which-key").add({
			{ "<leader>g", group = 'git' },
		})
	end
})
table.insert(plugins, {
	'anuvyklack/keymap-amend.nvim',
	config = function()
		require('keymap-amend')('n', '<Tab>', function(original)
			if not require('ufo').peekFoldedLinesUnderCursor() then
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
if vim.fn.has('nvim-0.10') > 0 then
	table.insert(plugins, {
		'Bekaboo/dropbar.nvim',
		-- optional, but required for fuzzy finder support
		dependencies = {
			'nvim-telescope/telescope-fzf-native.nvim',
		},
		config = function()
			require('dropbar').setup()
			vim.ui.select = require('dropbar.utils.menu').select
		end
	})
end

return plugins
