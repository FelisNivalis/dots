local plugins = {}

-- nvim-cmp
table.insert(plugins, {
	'hrsh7th/nvim-cmp',
	config = function()
		local cmp = require('cmp')
		local cmp_types = require('cmp.types.cmp')
		local compare = require('cmp.config.compare')
		local lspkind = require('lspkind')
		cmp.setup({
			mapping = {
				['<C-u>'] = cmp.mapping(function(fallback)
					for i = 1, 4 do
						cmp.select_prev_item({ behavior = cmp_types.SelectBehavior.Select })
					end
					cmp.select_prev_item({ behavior = cmp_types.SelectBehavior.Insert })
				end),
				['<C-d>'] = cmp.mapping(function(fallback)
					for i = 1, 4 do
						cmp.select_next_item({ behavior = cmp_types.SelectBehavior.Select })
					end
					cmp.select_next_item({ behavior = cmp_types.SelectBehavior.Insert })
				end),
				['<Up>'] = cmp.mapping.select_prev_item({ behavior = cmp_types.SelectBehavior.Insert }),
				['<Down>'] = cmp.mapping.select_next_item({ behavior = cmp_types.SelectBehavior.Insert }),
				['<PageUp>'] = cmp.mapping.scroll_docs(-4),
				['<PageDown>'] = cmp.mapping.scroll_docs(4),
				['<Tab>'] = cmp.mapping(function(fallback)
					if cmp.visible() then
						if not cmp.complete_common_string() then
							cmp.select_next_item({ behavior = cmp_types.SelectBehavior.Select })
						end
					else
						local col = vim.fn.col('.') - 1
						if col == 0 or string.match(string.sub(vim.fn.getline('.'), col, col), '%s') ~= nil then
							fallback()
						else
							return cmp.complete()
						end
					end
				end, { 'i' }),
				['<S-Tab>'] = cmp.mapping.select_prev_item({ behavior = cmp_types.SelectBehavior.Select }),
				['<Esc>'] = cmp.mapping.abort(),
				['<CR>'] = cmp.mapping.confirm({ select = true }),
			},
			sorting = {
				comparators = {
					compare.offset,
					compare.exact,
					-- compare.scopes,
					compare.score,
					compare.recently_used,
					compare.locality,
					compare.kind,
					-- compare.sort_text,
					-- compare.length,
					compare.order,
				}
			},
			sources = cmp.config.sources({
				{ name = 'nvim_lsp' },
			}, {
				{ name = 'path' },
			}, {
				{ name = 'nerdfont' },
				{ name = 'emoji' },
				{ name = 'greek' },
			}),
			formatting = {
				format = function(entry, vim_item)
					if vim.tbl_contains({ 'path' }, entry.source.name) then
						local icon, hl_group = require('nvim-web-devicons').get_icon(entry:get_completion_item().label)
						if icon then
							local text = lspkind.cmp_format({ mode = 'text' })(entry, vim_item).kind
							vim_item.kind = icon .. " " .. text
							vim_item.kind_hl_group = hl_group
							return vim_item
						end
					end
					return lspkind.cmp_format({ mode = 'symbol_text' })(entry, vim_item)
				end
			},
			snippet = {
				expand = function(args)
					vim.fn["vsnip#anonymous"](args.body)
				end,
			},
		})
		local cmdline_mapping = {
			['<Tab>'] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_next_item({ behavior = cmp_types.SelectBehavior.Insert })
				else
					cmp.complete()
				end
			end, { 'c' }),
			['<S-Tab>'] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp_types.SelectBehavior.Insert }),
				{ 'c' }),
			['<PageUp>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'c' }),
			['<PageDown>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'c' }),
			-- ['<C-Q>'] = cmp.mapping(cmp.mapping.abort(), { 'c' }),
			['<Esc>'] = cmp.mapping(
			function(_) if not cmp.abort() then vim.api.nvim_feedkeys(
					vim.api.nvim_replace_termcodes('<Esc>', false, false, true), 'tn', false) end end, { 'c' }),
			['<CR>'] = cmp.mapping(cmp.mapping.confirm({ select = false }), { 'c' })
		}
		cmp.setup.cmdline({ '/', '?' }, {
			mapping = cmdline_mapping,
			sources = {
				{ name = 'buffer' }
			},
			completion = {
				autocomplete = false,
			}
		})
		cmp.setup.cmdline(':', {
			mapping = cmdline_mapping,
			sources = cmp.config.sources({
				{ name = 'path' }
			}, {
				{ name = 'cmdline' }
			}),
			completion = {
				autocomplete = false,
			}
		})
	end,
	dependencies = {
		'lspkind.nvim', 'nvim-web-devicons',
	},
})
table.insert(plugins, { 'onsails/lspkind.nvim' }) -- icons
-- cmp sources
table.insert(plugins, { 'hrsh7th/cmp-nvim-lsp' })
table.insert(plugins, { 'hrsh7th/cmp-vsnip' })
table.insert(plugins, { 'hrsh7th/vim-vsnip' })
table.insert(plugins, { 'hrsh7th/cmp-path' })
table.insert(plugins, { 'hrsh7th/cmp-emoji' })
table.insert(plugins, { 'hrsh7th/cmp-cmdline' })
table.insert(plugins, { 'hrsh7th/cmp-buffer' })
table.insert(plugins, { 'max397574/cmp-greek' })
table.insert(plugins, { 'chrisgrieser/cmp-nerdfont' })

return plugins
