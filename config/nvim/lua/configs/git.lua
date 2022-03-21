local plugins = require("plugins")

plugins.add({
	'ruifm/gitlinker.nvim',
	opts = {
		mappings = "<leader>gl"
	}
}) -- permalink
plugins.add({
	'lewis6991/gitsigns.nvim',
	opts = {
		on_attach = function(bufnr)
			local gs = package.loaded.gitsigns

			local function map(mode, l, r, opts)
				opts = opts or {}
				opts.buffer = bufnr
				vim.keymap.set(mode, l, r, opts)
			end

			-- Navigation
			map('n', '<leader>g]', function()
				if vim.wo.diff then return '<leader>g]' end
				vim.schedule(function() gs.next_hunk() end)
				return '<Ignore>'
			end, { expr = true, desc = "git next hunk" })

			map('n', '<leader>g[', function()
				if vim.wo.diff then return '<leader>g[' end
				vim.schedule(function() gs.prev_hunk() end)
				return '<Ignore>'
			end, { expr = true, desc = "git prev hunk" })

			-- Actions
			map({ 'n', 'v' }, '<leader>gs', ':Gitsigns stage_hunk<CR>', { desc = "git stage hunk" })
			map({ 'n', 'v' }, '<leader>gr', ':Gitsigns reset_hunk<CR>', { desc = "git reset hunk" })
			map('n', '<leader>gS', gs.stage_buffer, { desc = "git stage buffer" })
			map('n', '<leader>gu', gs.undo_stage_hunk, { desc = "git undo stage hunk" })
			map('n', '<leader>gR', gs.reset_buffer, { desc = "git reset buffer" })
			map('n', '<leader>gp', gs.preview_hunk, { desc = 'git preview hunk' })
			map('n', '<leader>gb', function() gs.blame_line { full = true } end, { desc = "git blame line" })
			-- map('n', '<leader>gd', gs.diffthis, { desc = "git diff this" })
			-- map('n', '<leader>gD', function() gs.diffthis('~') end, { desc = "git diff this ~" })

			-- map('n', '<leader>gB', function() vim.cmd("Git blame") end, { desc = "git blame (vim-fugitive)."})
			map('n', '<leader>gc', function() vim.cmd("Git commit") end, { desc = "git commit (vim-fugitive)." })
			map('n', '<leader>gd', function() vim.cmd("Gdiffsplit") end, { desc = "git diff split (vim-fugitive)." })
			-- Text object
			map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
		end,
		sign_priority = 0,
	}
})
plugins.add({ 'tpope/vim-fugitive' })
