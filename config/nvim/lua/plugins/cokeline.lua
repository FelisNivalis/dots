-- cokeline
local function getopts()
  local map = vim.api.nvim_set_keymap

  map('n', '<Leader>z', '<Plug>(cokeline-focus-prev)', { silent = true })
  map('n', '<Leader>x', '<Plug>(cokeline-focus-next)', { silent = true })
  map('n', '<Leader><', '<Plug>(cokeline-switch-prev)', { silent = true })
  map('n', '<Leader>>', '<Plug>(cokeline-switch-next)', { silent = true })

  for i = 1, 9 do
    map('n', ('<Leader>%s'):format(i), ('<Plug>(cokeline-focus-%s)'):format(i), { silent = true })
    -- map('n', ('<Leader>%s'):format(i), ('<Plug>(cokeline-switch-%s)'):format(i), { silent = true })
  end

  -- local get_hex = require('cokeline/hlgroups').get_hl_attr -- needs a fix with `link=false`
  local get_hex = function(hlgroup_name, attr)
    local hlgroup_ID = vim.fn.synIDtrans(vim.fn.hlID(hlgroup_name))
    local hex = vim.fn.synIDattr(hlgroup_ID, attr)
    return hex ~= '' and hex or 'NONE'
  end
  local mappings = require('cokeline/mappings')

  local red = vim.g.terminal_color_1
  local green = vim.g.terminal_color_2
  local yellow = vim.g.terminal_color_3

  local get_fg = function(buffer, focus)
    return (buffer.is_focused and focus)
        and get_hex('Normal', 'fg')
        or get_hex('Comment', 'fg')
  end

  local bg_1 = '#666666' -- get_hex('DiffChange', 'bg')
  local bg_2 = get_hex('TabLine', 'bg')
  local get_bg_by_idx = function(index)
    return index % 2 ~= 1
        and bg_1
        or bg_2
  end
  local get_bg = function(buffer)
    return get_bg_by_idx(buffer.index)
  end
  local get_buf_git_status = function(buffer)
    local status, ret = pcall(function() return vim.api.nvim_buf_get_var(buffer.number, 'gitsigns_status_dict') end)
    return status and ret or {}
  end
  local signs = require("common.const").diagnostic_signs

  local components = {
    space = {
      text = ' ',
      truncation = { priority = 1 }
    },

    two_spaces = {
      text = '  ',
      truncation = { priority = 1 },
    },

    separator = {
      text = function(buffer)
        return ''
      end,
      fg = function(buffer)
        return get_bg(buffer)
      end,
      bg = function(buffer)
        return buffer.is_last
            and bg_2
            or get_bg_by_idx(buffer.index + 1)
      end,
      truncation = { priority = 1 }
    },

    devicon = {
      text = function(buffer)
        return (mappings.is_picking_focus() or mappings.is_picking_close())
            and buffer.pick_letter .. ' '
            or buffer.devicon.icon
      end,
      fg = function(buffer)
        return (mappings.is_picking_focus() and yellow)
            or (mappings.is_picking_close() and red)
            or buffer.devicon.color
      end,
      style = function(_)
        return (mappings.is_picking_focus() or mappings.is_picking_close())
            and 'italic,bold'
            or nil
      end,
      truncation = { priority = 1 }
    },

    index = {
      text = function(buffer)
        return buffer.index .. '  '
      end,
      truncation = { priority = 1 }
    },

    unique_prefix = {
      text = function(buffer)
        return buffer.unique_prefix
      end,
      fg = function(buffer)
        return get_fg(buffer, false)
      end,
      style = 'italic',
      truncation = {
        priority = 3,
        direction = 'left',
      },
    },

    filename = {
      text = function(buffer)
        return buffer.filename
      end,
      style = function(buffer)
        return ((buffer.is_focused and buffer.diagnostics.errors ~= 0)
              and 'bold,underline')
            or (buffer.is_focused and 'bold')
            or (buffer.diagnostics.errors ~= 0 and 'underline')
            or nil
      end,
      truncation = {
        priority = 2,
        direction = 'left',
      },
    },

    diagnostics = {
      text = function(buffer)
        return (buffer.diagnostics.errors ~= 0 and ' ' .. signs.error.text .. ' ' .. buffer.diagnostics.errors)
            or (buffer.diagnostics.warnings ~= 0 and ' ' .. signs.warn.text .. ' ' .. buffer.diagnostics.warnings)
            or (buffer.diagnostics.infos ~= 0 and ' ' .. signs.info.text .. ' ' .. buffer.diagnostics.infos)
            or (buffer.diagnostics.hints ~= 0 and ' ' .. signs.hint.text .. ' ' .. buffer.diagnostics.hints)
            or ''
      end,
      fg = function(buffer)
        return (buffer.diagnostics.errors ~= 0 and get_hex('DiagnosticError', 'fg'))
            or (buffer.diagnostics.warnings ~= 0 and get_hex('DiagnosticWarn', 'fg'))
            or (buffer.diagnostics.infos ~= 0 and get_hex('DiagnosticInfo', 'fg'))
            or (buffer.diagnostics.hints ~= 0 and get_hex('DiagnosticHint', 'fg'))
            or nil
      end,
      truncation = { priority = 1 },
    },

    close_or_unsaved = {
      text = function(buffer)
        return buffer.is_modified and '●' or '󰅖'
      end,
      fg = function(buffer)
        return buffer.is_modified and green or nil
      end,
      delete_buffer_on_left_click = true,
      truncation = { priority = 1 },
    },

    git_removed = {
      text = function(buffer)
        local num = get_buf_git_status(buffer).removed or 0
        return num == 0 and '' or (' -' .. num)
      end,
      fg = function(buffer)
        return get_hex('GitSignsDelete', 'fg')
      end,
      truncation = { priority = 0 },
    },
    git_changed = {
      text = function(buffer)
        local num = get_buf_git_status(buffer).changed or 0
        return num == 0 and '' or (' ~' .. num)
      end,
      fg = function(buffer)
        return get_hex('GitSignsChange', 'fg')
      end,
      truncation = { priority = 0 },
    },
    git_added = {
      text = function(buffer)
        local num = get_buf_git_status(buffer).added or 0
        return num == 0 and '' or (' +' .. num)
      end,
      fg = function(buffer)
        return get_hex('GitSignsAdd', 'fg')
      end,
      truncation = { priority = 0 },
    },
  }

  return {
    show_if_buffers_are_at_least = 1,

    buffers = {
      -- filter_valid = function(buffer) return buffer.type ~= 'terminal' end,
      -- filter_visible = function(buffer) return buffer.type ~= 'terminal' end,
      new_buffers_position = 'next',
    },

    rendering = {
      max_buffer_width = 50,
    },

    default_hl = {
      fg = function(buffer)
        return get_fg(buffer, true)
      end,
      bg = function(buffer)
        return get_bg(buffer)
      end
    },

    components = {
      components.space,
      components.devicon,
      components.index,
      components.unique_prefix,
      components.filename,
      components.diagnostics,
      components.git_added,
      components.git_changed,
      components.git_removed,
      components.two_spaces,
      components.close_or_unsaved,
      components.space,
      components.separator,
    },
  }
end

return {
  'noib3/nvim-cokeline',
  opts = getopts,
  dependencies = { 'nvim-lua/plenary.nvim' }
}
