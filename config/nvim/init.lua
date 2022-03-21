vim.cmd [[
"" Tabs. May be overriten by autocmd rules
set tabstop=4
set softtabstop=0
set shiftwidth=4
set expandtab

"" For better completion
set completeopt=menu,menuone,noselect

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
set sessionoptions=buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions

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

-- Searching
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = "split"

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
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

require("lazy").setup(
	{
		import = "plugins"
	},
	{
		defaults = { version = false },
		checker = { enabled = true },
		-- hererocks?
	}
)
