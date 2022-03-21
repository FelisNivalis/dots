local kopts = { noremap = true, silent = true }
return {
	{
		'nvim-treesitter/nvim-treesitter',
		branch = "master", -- master not compatible with main
		lazy = false,
		build = ':TSUpdate',
		opts = {
			ensure_installed = "all",
			ignore_install = { "d", "godot_resource", "gitignore", "swift", "teal", "devicetree", "ocamllex" },
			sync_install = false,
			auto_install = true,

			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
		},
		main = 'nvim-treesitter.configs',
		dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
	},
	{ 'nvim-treesitter/nvim-treesitter-context',                  dependencies = { 'nvim-treesitter' } },
	{ url = 'https://gitlab.com/HiPhish/rainbow-delimiters.nvim', dependencies = { 'nvim-treesitter' } },
	{ -- treesitter plugin, hl args
		'm-demare/hlargs.nvim',
		opts = { color = '#f9c7f9' },
		dependencies = { 'nvim-treesitter' }
	},
	{ 'JoosepAlviste/nvim-ts-context-commentstring', dependencies = { 'nvim-treesitter' } }, -- change `commentstring` automatically
	-- {
	-- 	'ziontee113/syntax-tree-surfer', -- repo archived
	-- 	config = true,
	-- 	dependencies = { 'nvim-treesitter' },
	-- 	init = function()
	-- 		-- Visual Selection from Normal Mode
	-- 		vim.keymap.set("n", "vx", '<cmd>STSSelectMasterNode<cr>', kopts)
	-- 		vim.keymap.set("n", "vn", '<cmd>STSSelectCurrentNode<cr>', kopts)
	--
	-- 		-- Select Nodes in Visual Mode
	-- 		vim.keymap.set("x", "K", '<cmd>STSSelectNextSiblingNode<cr>', kopts)
	-- 		vim.keymap.set("x", "J", '<cmd>STSSelectPrevSiblingNode<cr>', kopts)
	-- 		vim.keymap.set("x", "H", '<cmd>STSSelectParentNode<cr>', kopts)
	-- 		vim.keymap.set("x", "L", '<cmd>STSSelectChildNode<cr>', kopts)
	--
	-- 		-- Swapping Nodes in Visual Mode
	-- 		vim.keymap.set("x", "<C-k>", '<cmd>STSSwapNextVisual<cr>', kopts)
	-- 		vim.keymap.set("x", "<C-j>", '<cmd>STSSwapPrevVisual<cr>', kopts)
	-- 	end
	-- }
}
