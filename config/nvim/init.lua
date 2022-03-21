vim.cmd [[
"" Tabs. May be overriten by autocmd rules
set tabstop=4
set softtabstop=0
set shiftwidth=4
set expandtab

"" For better completion
set completeopt=menu,menuone,noselect

"" Searching
set ignorecase
set smartcase

"" Encoding
set bomb
set binary

set fileformats=unix,dos,mac
set showcmd
set cursorline
" swapfile & CursorHold
set updatetime=300

set ruler
set norelativenumber number

set signcolumn=auto:9

set termguicolors
"" Disable the blinking cursor.
set guicursor=a:blinkon0
set scrolloff=3

" spaces as filename
" set isfname+=32

"" undofile
set undofile
exe 'set undodir=' . stdpath('data') . '/undo'
if ! isdirectory(stdpath('data') . '/undo')
	call mkdir(stdpath('data') . '/undo', "p")
endif

"" Status bar
set laststatus=2

"" Use modeline overrides
set modeline
set modelines=10
set wildmode=list:longest,list:full
set wildignore+=*.o,*.obj,.git,*.rbc,*.pyc,__pycache__

" mouse
set mouse=nv

" local .nvimrc file
set exrc
set secure

" no folds closed when a buffer is opened
set foldlevel=99

" session
set sessionoptions=buffers,curdir,folds,help,tabpages,winsize,winpos,terminal

" popup delay
set timeoutlen=300

" host/provider
let $VIRTUAL_ENV = $PYENV_ROOT . '/versions/neovim'
let g:python3_host_prog = $PYENV_ROOT . '/versions/neovim/bin/python'
let g:node_host_prog = $XDG_DATA_HOME . '/mise/installs/npm-neovim/latest/bin/neovim-node-host'
let $RBENV_GEMSETS = 'neovim'
let g:ruby_host_prog = $RBENV_ROOT . '/shims/neovim-ruby-host'
let g:perl_host_prog = $PLENV_ROOT . '/versions/neovim/bin/perl'

" augroup
"" Remember cursor position
augroup vimrc-remember-cursor-position
	autocmd!
	autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END

" Use relativenumber in Insert Mode
augroup relative-number-tab
	autocmd!
	autocmd InsertLeave * :set norelativenumber
	autocmd InsertEnter * :set relativenumber number
augroup END

" mappings
"" Map leader to ,
let mapleader=','
" \,;'

"" Close buffer
noremap <silent> <leader>c :bd<CR>
noremap <silent> <leader>b :Bd<CR>

"" Vmap for maintain Visual Mode after shifting > and <
vnoremap < <gv
vnoremap > >gv

if has("wsl")
    let g:clipboard = {
	\   'name': 'WslClipboard',
	\   'copy': {
	\      '+': 'clip.exe',
	\      '*': 'clip.exe',
	\    },
	\   'paste': {
	\      '+': 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
	\      '*': 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
	\   },
	\   'cache_enabled': 0,
	\ }
endif
]]

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

local kopts = { noremap = true, silent = true }
local getkopts = function(opts)
	return vim.tbl_extend("force", kopts, opts)
end

local plugins = require('plugins')

require('configs.treesitter')
require('configs.telescope')
require('configs.lsp')
require('configs.cmp')
require('configs.git')

plugins.add({
	'xiyaowong/nvim-cursorword',
	config = function(spec, opts)
		vim.cmd [[
			let g:cursorword_min_width = 1
			hi default CursorWord cterm=underline gui=underline
		]]
	end
}) -- highlight words on the cursor

plugins.add({
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
plugins.add({
	'norcalli/nvim-colorizer.lua',
	opts = {
		'*',
		css = { hsl_fn = true },
		lua = { hsl_fn = true },
		vim = { hsl_fn = true }
	}
})                              -- highlight colours
plugins.add({ 'TaDaa/vimade' }) -- dim inactive buffers
plugins.add({
	'melkster/modicator.nvim',
	dependencies = {
		'savq/melange',
	},
	config = true
}) -- change fg of `CursorLineNr` based on vim mode

plugins.add({
	'rickhowe/diffchar.vim',
}) -- diff mode
vim.g.DiffCharDoMapping = 0

plugins.add({ 'galicarnax/vim-regex-syntax' })


-- themes
plugins.add({ 'Haron-Prime/evening_vim' })
plugins.add({
	'savq/melange',
	config = function()
		vim.cmd("colorscheme melange")
	end,
	priority = 1000,
})
plugins.add({ 'katawful/kat.nvim' })
plugins.add({ 'sts10/vim-pink-moon' })
plugins.add({ 'rktjmp/lush.nvim' })


-- enhancements
plugins.add({ 'Vimjas/vim-python-pep8-indent' })
plugins.add({
	'nmac427/guess-indent.nvim',
	config = true,
})
plugins.add({
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true,
	opts = {
		check_ts = true,
	},
})

plugins.add({
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

plugins.add({
	'lukas-reineke/virt-column.nvim',
	priority = 1100,
}) -- vertical line at columns
plugins.add({
	'declancm/cinnamon.nvim',
	opts = {
		max_delta = {
			line = 500,
			column = 200,
		},
		delay = 2,
	},
}) -- smooth scrolling
plugins.add({
	'winston0410/range-highlight.nvim',
	opts = {},
	dependencies = { 'winston0410/cmd-parser.nvim' }
}) -- highlight when :[line1],[line2]
plugins.add({
	'nacro90/numb.nvim',
	config = true,
}) -- peeking when :[number]

plugins.add({
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

plugins.add({
	'kevinhwang91/nvim-hlslens',
	opts = {},
}) -- enhanced *
vim.api.nvim_set_keymap('n', 'n',
	[[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
	kopts)
vim.api.nvim_set_keymap('n', 'N',
	[[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
	kopts)

plugins.add({ 'stsewd/gx-extended.vim' })
vim.g.netrw_browsex_viewer = os.getenv('BROWSER')
vim.api.nvim_set_keymap("n", "gx", "<Plug>(gxext-normal)", kopts)
vim.api.nvim_set_keymap("v", "gx", "<Plug>(gxext-visual)", kopts)

plugins.add({
	'gbprod/cutlass.nvim',
	opts = { cut_key = 'r', exclude = { 'vx', 'sx', 'xx', 'vX', 'sX', 'xX' } },
}) -- delete without yank
plugins.add({
	'terrortylor/nvim-comment',
	config = true,
	main = 'nvim_comment'
}) -- gc

plugins.add({
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
plugins.add({
	'kevinhwang91/nvim-ufo',
	opts = {
		provider_selector = function(bufnr, filetype, buftype)
			return { 'treesitter', 'indent' }
		end
	},
	dependencies = { 'kevinhwang91/promise-async', 'nvim-treesitter' }
}) -- auto create folds

plugins.add({
	'noib3/nvim-cokeline',
	opts = require('configs.cokeline'),
	dependencies = { 'nvim-lua/plenary.nvim' }
})
plugins.add({
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
plugins.add({
	'rebelot/heirline.nvim',
	opts = require('configs.heirline'),
	dependencies = {
		'lewis6991/gitsigns.nvim',
		'melkster/modicator.nvim',
	},
})
plugins.add({ 'SmiteshP/nvim-navic' })      -- lsp status
if vim.fn.has('nvim-0.10') > 0 then
	plugins.add({
		'lewis6991/satellite.nvim',
		config = true,
	})
end
plugins.add({ 'rcarriga/nvim-notify' })

plugins.add({ 'mbbill/undotree' })
vim.g.undotree_WindowLayout = 1
vim.g.undotree_ShortIndicators = 1
vim.g.undotree_SetFocusWhenToggle = 1
vim.api.nvim_set_keymap('n', '<leader>u', ':UndotreeToggle<CR>', kopts)

plugins.add({
	'rmagatti/auto-session',
	opts = {}
})

plugins.add({ 'gennaro-tedesco/nvim-peekup' }) -- registers
vim.g.peekup_open = '<leader>"'


-- functionalities
plugins.add({
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
plugins.add({ 'junegunn/vim-easy-align' })
vim.api.nvim_set_keymap('x', 'aa', '<Plug>(EasyAlign)', kopts)

plugins.add({ 'chrisbra/NrrwRgn' }) -- narrowed region
plugins.add({
	'chentoast/marks.nvim',
	opts = {
		-- builtin_marks = { ".", "<", ">", "^", "[", "]" },
		sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
		-- force_write_shada = true,
	}
})
plugins.add({ 'tweekmonster/helpful.vim' }) -- version info
plugins.add({
	'kylechui/nvim-surround', -- culprit of deleting when inserting a pair?
	opts = {},
})

plugins.add({
	url = 'https://gitlab.com/yorickpeterse/nvim-window',
}) -- switch between windows
vim.api.nvim_set_keymap('n', '<C-W>a', [[<Cmd>lua require('nvim-window').pick()<CR>]], kopts)

plugins.add({ 'famiu/bufdelete.nvim' }) -- keep window
plugins.add({
	'folke/which-key.nvim',
	config = function()
		require("which-key").register({
			["<leader>g"] = {
				name = 'git',
			}
		})
	end
})
plugins.add({
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


plugins.add({
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

plugins.add({ 'metakirby5/codi.vim' }) -- interactive scratchpad
if vim.fn.has('nvim-0.10') > 0 then
	plugins.add({
		'Bekaboo/dropbar.nvim',
		-- optional, but required for fuzzy finder support
		dependencies = {
			'nvim-telescope/telescope-fzf-native.nvim',
		},
		config = function ()
			require('dropbar').setup()
			vim.ui.select = require('dropbar.utils.menu').select
		end
	})
end

require("lazy").setup(
	plugins,
	{
		defaults = { version = false },
		checker = { enabled = true },
	}
)
