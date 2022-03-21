-- https://vim.fandom.com/wiki/Unused_keys

-- Tabs. May be overriten by autocmd rules
vim.opt.tabstop = 4
vim.opt.softtabstop = 0
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- For better completion
vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- Encoding
vim.opt.bomb = true
vim.opt.binary = true

vim.opt.fileformats = { "unix", "dos", "mac" }
vim.opt.showcmd = true
vim.opt.cursorline = true
-- swapfile & CursorHold
vim.opt.updatetime = 300

vim.opt.ruler = true
vim.opt.relativenumber = false
vim.opt.number = true

vim.opt.signcolumn = "auto:9"

vim.opt.termguicolors = true
-- Disable the blinking cursor.
vim.opt.guicursor = { "a:blinkon0" }
vim.opt.scrolloff = 3

-- spaces as filename
vim.opt.isfname:append('{,}')

-- undofile
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath('data') .. '/undo'
if not vim.fn.isdirectory(vim.fn.stdpath('data') .. '/undo') then
	vim.fn.mkdir(vim.fn.stdpath('data') .. '/undo', "p")
end

-- Status bar
vim.opt.laststatus = 2

-- Use modeline overrides
vim.opt.modeline = true
vim.opt.modelines = 10
vim.opt.wildmode = { "list:longest", "list:full" }
vim.opt.wildignore:append({ "*.o", "*.obj", ".git", "*.rbc", "*.pyc", "__pycache__" })

-- mouse
vim.opt.mouse = "nv"

-- local .nvimrc file
vim.opt.exrc = true
vim.opt.secure = true
-- see vim.secure.trust()

-- no folds closed when a buffer is opened
vim.opt.foldlevel = 99

-- session
vim.opt.sessionoptions = { 'buffers', 'curdir', 'help', 'tabpages', 'winsize', 'winpos', 'terminal' }
-- 'localoptions' (local options & keymaps) disabled cause don't want to keep my per buffer LSP keymaps

-- popup delay
vim.opt.timeoutlen = 300

-- host/provider
-- an opinionated setting, which only works when xxenv/mise exists.
if vim.env.LUAENV_ROOT ~= nil then
	vim.system({
		'find', vim.env.LUAENV_ROOT .. '/versions', '-maxdepth', '1', '-name', '5.1.*'
	}, {
		text = true
	}, function(obj)
		local latest_ver = nil
		for ver in string.gmatch(obj.stdout, '%d+\n') do
			if latest_ver == nil or tonumber(ver) > latest_ver then
				latest_ver = tonumber(ver)
			end
		end
		if latest_ver then
			vim.schedule(function() vim.env.LUAENV_VERSION = '5.1.' .. latest_ver end)
		end
	end)
end
if vim.env.PYENV_ROOT ~= nil then
	vim.env.PYENV_VERSION = 'neovim'
	vim.g.python3_host_prog = vim.env.PYENV_ROOT .. '/versions/neovim/bin/python'
end
if vim.env.RBENV_ROOT ~= nil then
	vim.system({
		'find', vim.env.RBENV_ROOT .. '/versions', '-maxdepth', '3', '-name', 'neovim'
	}, {
		text = true
	}, function(obj)
		local s, e = string.find(obj.stdout, '%d+%.%d+%.%d+')
		if s and e then
			vim.schedule(function() vim.env.RBENV_VERSION = string.sub(obj.stdout, s, e) end)
		end
	end)
	vim.env.RBENV_GEMSETS = 'neovim'
	vim.g.ruby_host_prog = vim.env.RBENV_ROOT .. '/shims/neovim-ruby-host'
end
if vim.env.PLENV_ROOT ~= nil then
	vim.env.PLENV_VERSION = 'neovim'
	vim.g.perl_host_prog = vim.env.PLENV_ROOT .. '/versions/neovim/bin/perl'
end
vim.system({ "mise", "bin-paths", "npm:neovim" }, { text = true },
	function(obj)
		if obj.code == 0 then
			vim.g.node_host_prog = string.match(obj.stdout, '[^%s]*\n') .. '/neovim-node-host'
		end
	end)

-- augroup
-- Remember cursor position
-- local au_curpos = vim.api.nvim_create_augroup("vimrc-remember-cursor-position", { clear = true })
-- vim.api.nvim_create_autocmd({ "BufReadPost" }, {
-- 	group = au_curpos,
-- 	pattern = "*",
-- 	callback = function(_)
-- 		if vim.fn.line("'\"") > 1 and vim.fn.line("'\"") <= vim.fn.line("$") then
-- 			vim.cmd.normal({ 'g`\"', bang = true })
-- 		end
-- 	end
-- })

-- Use relativenumber in Insert Mode
local au_rel = vim.api.nvim_create_augroup("relative-number-tab", { clear = true })
vim.api.nvim_create_autocmd({ "InsertEnter" }, {
	group = au_rel,
	pattern = "*",
	callback = function(_)
		vim.opt_local.relativenumber = true
	end
})
vim.api.nvim_create_autocmd({ "InsertLeave" }, {
	group = au_rel,
	pattern = "*",
	callback = function(_)
		vim.opt_local.relativenumber = false
	end
})

-- mappings
-- Map leader to ,
vim.g.mapleader = ','
-- \,;'

-- Delete buffer
vim.api.nvim_set_keymap("n", "<leader>c", ":bd<CR>", { silent = true, noremap = true, desc = "delete buffer" })
vim.api.nvim_set_keymap("n", "<leader>b", ":Bd<CR>", {
	silent = true,
	noremap = true,
	desc = "delete buffer but keep layouts"
}) -- bufdelete.nvim

-- Vmap for maintain Visual Mode after shifting > and <
vim.api.nvim_set_keymap("v", "<", "<gv", { noremap = true, desc = "lshift" })
vim.api.nvim_set_keymap("v", ">", ">gv", { noremap = true, desc = "rshift" })

if vim.fn.has("wsl") then
	vim.g.clipboard = {
		name = 'WslClipboard',
		copy = {
			['+'] = 'clip.exe',
			['*'] = 'clip.exe',
		},
		paste = {
			['+'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
			['*'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
		},
		cache_enabled = 0,
	}
end

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
-- get the first script of name "init.lua"
local config_path = vim.fn.fnamemodify(vim.fn.getscriptinfo({ name = "init.lua" })[1].name, ":p:h")
local default_config_path = vim.fn.stdpath('config')
-- replace `$XDG_CONFIG_HOME/nvim` with the path this file is in.
-- so that `require` can reach this file
if config_path ~= default_config_path then
	vim.opt.rtp:remove(default_config_path)
	vim.opt.rtp:prepend(config_path)
end
vim.opt.rtp:prepend(lazypath)

-- https://www.reddit.com/r/neovim/comments/zhweuc/whats_a_fast_way_to_load_the_output_of_a_command/
vim.api.nvim_create_user_command('Redir', function(ctx)
	local lines = vim.split(vim.api.nvim_exec2(ctx.args, { output = true }).output, '\n', { plain = true })
	vim.cmd('new')
	vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
	vim.opt_local.modified = false
end, { nargs = '+', complete = 'command' })

-- See :h grr
vim.keymap.del('n', 'grr')
vim.keymap.del('n', 'gra')
vim.keymap.del('n', 'grn')
vim.keymap.del('n', 'gri')
vim.keymap.del('n', 'gO')
vim.keymap.del('i', '<C-S>')

-- to enable a test env,
-- 1. `cp -L -r $XDG_CONFIG_HOME/nvim /tmp/nvim-config`
-- 2. `nvim -u /tmp/nvim-config/init.lua`
require("lazy").setup(
	{
		{
			dir = config_path,
			dev = true,
			import = vim.fn.fnamemodify(
				vim.split(
					vim.fn.glob(config_path .. "/lua/plugins*"),
					'\n', { trimempty = true }
				)[1],
				":t"
			), -- use a folder starting with "plugins"
			name = "all-plugins"
		},
	},
	{
		defaults = { version = false },
		checker = { enabled = true },
		-- hererocks?
	}
)
