-- https://github.com/rebelot/heirline.nvim/blob/master/cookbook.md
local function getopts()
    --█
    local conditions = require("heirline.conditions")
    local utils = require("heirline.utils")

    local function get_status_line_hl()
        return utils.get_highlight(conditions.is_active() and "StatusLine" or "StatusLineNC")
    end
    local colors = require("colors")
    local function b_or_w(color)
        if color:sub(1, 1) ~= '#' then
            color = colors.scheme[color]
        end
        color = color:gsub('#', '')
        local r = tonumber('0x' .. color:sub(1, 2))
        local g = tonumber('0x' .. color:sub(3, 4))
        local b = tonumber('0x' .. color:sub(5, 6))
        return colors.color_is_bright(r, g, b) and 'black' or 'white'
    end
    local Flexible = {
        FileFormat = 9,
        FileSize = 7,
        FileLastModified = 5,
        Cursor = 11,
        Version = 19,
    }

    -------------------------------------------------------------------------------
    ---------------------------------*** ViMode ***--------------------------------
    -------------------------------------------------------------------------------
    local Version = {
        flexible = Flexible.Version,
        {
            { provider = '', hl = { fg = 'cyan' } },
            {
                static = {
                    version = vim.fn.matchstr(vim.fn.execute('version'), 'NVIM v\\zs[^\\n]*')
                },
                provider = function(self)
                    return '   ' .. self.version .. ' '
                end,
                hl = { bg = 'cyan', bold = true, fg = 'white' }
            },
            { provider = '', hl = { fg = 'cyan' } },
        },
        {}
    }
    local ViMode = {
        -- get vim current mode, this information will be required by the provider
        -- and the highlight functions, so we compute it only once per component
        -- evaluation and store it as a component attribute
        init = function(self)
            self.mode = vim.fn.mode(1) -- :h mode()
        end,
        -- Now we define some dictionaries to map the output of mode() to the
        -- corresponding string and color. We can put these into `static` to compute
        -- them at initialisation time.
        static = {
            mode_names = { -- change the strings if you like it vvvvverbose!
                n = "N",
                no = "N?",
                nov = "N?",
                noV = "N?",
                ["no\22"] = "N?",
                niI = "Ni",
                niR = "Nr",
                niV = "Nv",
                nt = "Nt",
                v = "V",
                vs = "Vs",
                V = "V_",
                Vs = "Vs",
                ["\22"] = "^V",
                ["\22s"] = "^V",
                s = "S",
                S = "S_",
                ["\19"] = "^S",
                i = "I",
                ic = "Ic",
                ix = "Ix",
                R = "R",
                Rc = "Rc",
                Rx = "Rx",
                Rv = "Rv",
                Rvc = "Rv",
                Rvx = "Rv",
                c = "C",
                cv = "Ex",
                r = "...",
                rm = "M",
                ["r?"] = "?",
                ["!"] = "!",
                t = "T",
            },
            mode_colors = {
                n = "red",
                i = "green",
                v = "cyan",
                V = "cyan",
                ["\22"] = "cyan",
                c = "orange",
                s = "purple",
                S = "purple",
                ["\19"] = "purple",
                R = "orange",
                r = "orange",
                ["!"] = "red",
                t = "red",
            },
            get_mode_color = function(self)
                return self.mode_colors[self.mode:sub(1, 1)] -- get only the first mode character
            end
        },
        -- Re-evaluate the component only on ModeChanged event!
        -- Also allows the statusline to be re-evaluated when entering operator-pending mode
        update = {
            "ModeChanged",
            pattern = "*:*",
            callback = vim.schedule_wrap(function()
                vim.cmd.redrawstatus()
            end),
        },
        -- We can now access the value of mode() that, by now, would have been
        -- computed by `init()` and use it to index our strings dictionary.
        -- note how `static` fields become just regular attributes once the
        -- component is instantiated.
        -- To be extra meticulous, we can also add some vim statusline syntax to
        -- control the padding and make sure our string is always at least 2
        -- characters long. Plus a nice Icon.
        {
            provider = function(self)
                return " %-2(" .. self.mode_names[self.mode] .. "%) 󰰫 "
            end,
            -- Same goes for the highlight. Now the foreground will change according to the current mode.
            hl = function(self)
                return { bg = self.get_mode_color(self), fg = b_or_w(self.get_mode_color(self)), bold = true, }
            end,
        },
        {
            provider = '',
            hl = function(self)
                return { fg = self.get_mode_color(self) }
            end
        },
    }

    local MacroRec = {
        condition = function()
            return vim.fn.reg_recording() ~= ""
        end,
        { provider = '  ' },
        {
            -- provider = '',
            provider = '',
            hl = { bg = get_status_line_hl().bg, fg = 'orange' }
        },
        {
            provider = " Rec",
            hl = { bg = "orange", bold = true }
        },
        -- { provider = '',  hl = { bg = 'orange', fg = 'green' } },
        -- { provider = '  ', hl = { bg = 'orange', bold = true } },
        {
            provider = function()
                return ' ' .. vim.fn.reg_recording() .. ' '
            end,
            hl = { bg = "orange", bold = true },
        },
        {
            -- provider = '',
            provider = '',
            hl = { fg = 'orange' }
        },
        update = {
            "RecordingEnter",
            "RecordingLeave",
        }
    }

    local SearchCount = {
        condition = function()
            return vim.v.hlsearch ~= 0
        end,
        init = function(self)
            local ok, search = pcall(vim.fn.searchcount)
            if ok then
                self.search = search or {}
            else
                self.search = {}
            end
        end,
        static = {
            fg1 = 'black', --utils.get_highlight("Search").fg,
            bg1 = 'blue',  --utils.get_highlight("Search").bg,
            fg2 = 'black', --utils.get_highlight("Search").fg,
            bg2 = 'cyan',  --utils.get_highlight("Search").bg,
        },
        {
            provider = '  ',
        },
        {
            -- provider = '',
            provider = '',
            hl = function(self)
                return { bg = get_status_line_hl().bg, fg = self.bg1 }
            end
        },
        {
            provider = function(self)
                return ' ' .. string.format(" %d ", self.search.current)
            end,
            hl = function(self)
                return { fg = self.fg1, bg = self.bg1, bold = true }
            end,
        },
        {
            provider = '',
            hl = function(self)
                return { fg = self.bg2, bg = self.bg1 }
            end
        },
        {
            provider = function(self)
                return string.format(" %d ", math.min(self.search.total, self.search.maxcount))
            end,
            hl = function(self)
                return { fg = self.fg2, bg = self.bg2, bold = true }
            end,
        },
        {
            -- provider = '',
            provider = '',
            hl = function(self)
                return { bg = get_status_line_hl().bg, fg = self.bg2 }
            end
        },
    }

    local Git = {
        condition = conditions.is_git_repo,

        init = function(self)
            self.status_dict = vim.b.gitsigns_status_dict
            self.status_dict.added = self.status_dict.added or 0
            self.status_dict.removed = self.status_dict.removed or 0
            self.status_dict.changed = self.status_dict.changed or 0
            self.has_changes = (
                self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
            )
            if self.status_dict.added ~= 0 then
                self.left_sep_color = "GitSignsAdd"
            elseif self.status_dict.removed ~= 0 then
                self.left_sep_color = "GitSignsDelete"
            else
                self.left_sep_color = "GitSignsChange"
            end
            if self.status_dict.changed ~= 0 then
                self.right_sep_color = "GitSignsChange"
            elseif self.status_dict.removed ~= 0 then
                self.right_sep_color = "GitSignsDelete"
            else
                self.right_sep_color = "GitSignsAdd"
            end
            if self.status_dict.removed ~= 0 then
                self.sep1_color = "GitSignsDelete"
            elseif self.status_dict.changed ~= 0 then
                self.sep1_color = "GitSignsChange"
            else
                self.sep1_color = nil
            end
            if self.status_dict.changed ~= 0 then
                self.sep2_color = "GitSignsChange"
            else
                self.sep2_color = nil
            end
        end,

        { provider = ' ' },
        { -- git branch name
            provider = function(self)
                return " " .. self.status_dict.head
            end,
            hl = { bold = true, fg = "orange" }
        },
        {
            condition = function(self)
                return self.has_changes
            end,
            { provider = ' ' },
            {
                provider = "",
                hl = function(self)
                    return { fg = utils.get_highlight(self.left_sep_color).fg }
                end
            },
            {
                condition = function(self)
                    return (self.status_dict.added or 0) > 0
                end,
                {
                    provider = function(self)
                        local count = self.status_dict.added or 0
                        return count > 0 and ("+" .. count)
                    end,
                    hl = { bg = utils.get_highlight("GitSignsAdd").fg, fg = 'white' },
                },
                {
                    condition = function(self) return self.sep1_color end,
                    provider = '',
                    hl = function(self)
                        return {
                            fg = utils.get_highlight("GitSignsAdd").fg,
                            bg = utils.get_highlight(self.sep1_color).fg
                        }
                    end,
                },
            },
            {
                condition = function(self)
                    return (self.status_dict.removed or 0) > 0
                end,
                {
                    provider = function(self)
                        local count = self.status_dict.removed or 0
                        return count > 0 and ("-" .. count)
                    end,
                    hl = { bg = utils.get_highlight("GitSignsDelete").fg, fg = 'white' },
                },
                {
                    condition = function(self) return self.sep2_color end,
                    provider = '',
                    hl = function(self)
                        return {
                            fg = utils.get_highlight("GitSignsDelete").fg,
                            bg = utils.get_highlight(self.sep2_color).fg
                        }
                    end,
                },
            },
            {
                condition = function(self)
                    return (self.status_dict.changed or 0) > 0
                end,
                {
                    provider = function(self)
                        local count = self.status_dict.changed or 0
                        return count > 0 and ("~" .. count)
                    end,
                    hl = { bg = utils.get_highlight("GitSignsChange").fg, fg = 'white' },
                },
            },
            {
                provider = '',
                hl = function(self)
                    return { fg = utils.get_highlight(self.right_sep_color).fg }
                end
            },
        }
    }



    -------------------------------------------------------------------------------
    ---------------------------------*** File ***----------------------------------
    -------------------------------------------------------------------------------
    local FileIcon = {
        {
            provider = '',
            hl = function(self)
                return { fg = self.icon_color, bg = '' }
            end
        },
        {
            provider = function(self)
                return self.icon and (self.icon .. " ")
            end,
        }
    }

    local FileName = {
        {
            condition = function(self)
                local fn = vim.fn.fnamemodify(self.filename, ":p")
                return fn:sub(1, #self.cwd) == self.cwd
            end,
            provider = function(self)
                for _, func in ipairs({
                    function(self) return self.cwd end,
                    function(self) return vim.fn.pathshorten(self.cwd, 2) end,
                    function(self) return vim.fn.pathshorten(self.cwd, 1) end,
                }) do
                    local s = func(self)
                    if conditions.width_percent_below(#s, 0.15) and s ~= '' then
                        return s .. '  '
                    end
                end
                return ''
            end,
            hl = function(self)
                return b_or_w(self.icon_color) == 'black' and { fg = 'grey5' } or { fg = 'grey2' }
            end,
        },
        {
            provider = function(self)
                local s = ""
                for _, func in ipairs({
                    function(self) return vim.fn.fnamemodify(self.filename, ":.") end,
                    function(self)
                        return vim.fn.pathshorten(vim.fn.fnamemodify(self.filename, ":.:h"), 2) ..
                            '/' .. vim.fn.fnamemodify(self.filename, ":t")
                    end,
                    function(self)
                        return vim.fn.pathshorten(vim.fn.fnamemodify(self.filename, ":.:h"), 1) ..
                            '/' .. vim.fn.fnamemodify(self.filename, ":t")
                    end,
                    function(self) return vim.fn.pathshorten(vim.fn.fnamemodify(self.filename, ":."), 1) end,
                    function(self)
                        return (vim.fn.fnamemodify(self.filename, ":.") ~= "." and ".../" or "") ..
                            vim.fn.fnamemodify(self.filename, ":t")
                    end,
                }) do
                    s = func(self)
                    if conditions.width_percent_below(#s, 0.15) then
                        return s or "[No Name]"
                    end
                end
                -- heirline/conditions.lua
                local winwidth
                if vim.o.laststatus == 3 then
                    winwidth = vim.o.columns
                else
                    winwidth = vim.api.nvim_win_get_width(0)
                end
                local n = winwidth * 0.15 + (s:sub(1, 3) == "..." and 4 or 0)
                if #s <= n then
                    return s
                else
                    return s:sub(1, n) .. '...'
                end
            end,
            hl = function(self)
                return b_or_w(self.icon_color)
            end,
        },
    }

    local FileType = {
        condition = function()
            return vim.bo.filetype ~= ''
        end,
        {
            provider = function()
                return string.upper(vim.bo.filetype)
            end,
        },
        { provider = ' ' },
        hl = { fg = utils.get_highlight("Type").fg, bold = true },
    }

    local FileNameBlock = {
        init = function(self)
            self.filename = vim.api.nvim_buf_get_name(0):gsub("%%", "%%%1")
            self.cwd = vim.fn.getcwd(0):gsub("%%", "%%%1")
            self.extension = vim.fn.fnamemodify(self.filename, ":e")
            self.icon, self.icon_color = require("nvim-web-devicons").get_icon_color(self.filename, self.extension,
                { default = true })
        end,
        FileIcon,
        FileName,
        { provider = ' ' },
        { FileType,      hl = { force = true } },
        hl = function(self) return { bg = self.icon_color, fg = b_or_w(self.icon_color) } end,
    }

    local FileEncoding = {
        init = function(self)
            self.enc = (vim.bo.fenc ~= '' and vim.bo.fenc) or vim.o.enc -- :h 'enc'
        end,
        condition = function(self)
            return self.enc ~= 'utf-8'
        end,
        { provider = ' ' },
        {
            provider = function(self)
                return self.enc:upper()
            end,
        },
    }

    local FileFormat = {
        provider = function()
            local fmt = vim.bo.fileformat
            return fmt:upper()
        end,
        hl = { bold = true },
    }

    local FileSize = {
        provider = function()
            -- stackoverflow, compute human readable file size
            local suffix = { 'b', 'k', 'M', 'G', 'T', 'P', 'E' }
            local fsize = vim.fn.getfsize(vim.api.nvim_buf_get_name(0))
            fsize = (fsize < 0 and 0) or fsize
            if fsize < 1024 then
                return fsize .. suffix[1]
            end
            local i = math.floor((math.log(fsize) / math.log(1024)))
            return string.format("%.2g%s", fsize / math.pow(1024, i), suffix[i + 1])
        end
    }

    local FileLastModified = {
        -- did you know? Vim is full of functions!
        provider = function(self)
            local ftime = (self[1].ftime or {})[vim.api.nvim_buf_get_name(0)]
            if ftime == nil then
                return ''
            end
            if ftime > 0 then
                local difftime = os.difftime(os.time(), vim.fn.getftime(vim.api.nvim_buf_get_name(0)))
                local unit
                if difftime < 100 then
                    unit = 's'
                    return string.format("~%d%s ago", difftime, unit)
                else
                    difftime = difftime / 60
                    if difftime < 100 then
                        unit = 'min'
                    else
                        difftime = difftime / 60
                        if difftime <= 50 then
                            unit = 'h'
                        else
                            difftime = difftime / 24
                            if difftime < 100 then
                                unit = 'd'
                            else
                                local dt_table = os.date("*t", os.difftime(os.time(), ftime))
                                if dt_table.year > 1970 then
                                    unit = 'y'
                                    difftime = dt_table.year - 1970 + (dt_table.month or 0) / 12 +
                                        (dt_table.day or 0) / 365
                                elseif dt_table.month > 0 then
                                    unit = 'mo'
                                    difftime = dt_table.month + (dt_table.day or 0) / 31 + (dt_table.hour or 0) / 31 / 24
                                elseif dt_table.day > 0 then
                                    unit = 'd'
                                    difftime = dt_table.day + (dt_table.hour or 0) / 24 + (dt_table.min or 0) / 60 / 24
                                end
                            end
                        end
                    end
                end
                return string.format("~%.2f%s ago", difftime, unit)
            end
            return nil
        end,
        {
            init = function(self)
                if self.ftime == nil then
                    self.ftime = {}
                end
                local fname = vim.api.nvim_buf_get_name(0)
                self.ftime[fname] = vim.fn.getftime(fname)
            end,
            provider = function()
                return ''
            end,
            update = { 'BufEnter', 'BufWritePost' } -- BufAdd?
        }
    }

    local FileFlags = {
        fallthrough = false,
        {
            condition = function()
                return vim.bo.modified
            end,
            provider = " ",
        },
        {
            condition = function()
                return not vim.bo.modifiable or vim.bo.readonly
            end,
            provider = " ",
        },
        {
            provider = "󰼭 ",
        },
    }

    local FileInfoBlock = {
        init = function(self)
            if vim.bo.modified then
                self.color = 'yellow'
            elseif not vim.bo.modifiable or vim.bo.readonly then
                self.color = 'orange'
            else
                self.color = 'green'
            end
        end,
        {
            {
                flexible = 4,
                hl = function(self)
                    return { bg = self.color, fg = b_or_w(self.color) }
                end,
                {
                    {
                        flexible = Flexible.FileFormat,
                        {
                            FileEncoding,
                            { provider = ' ' },
                            FileFormat,
                        },
                        {}
                    },
                    {
                        flexible = Flexible.FileSize,
                        {
                            { provider = ' ' },
                            FileSize,
                        },
                        {}
                    },
                    {
                        flexible = Flexible.FileLastModified,
                        {
                            { provider = '  ' },
                            FileLastModified,
                            { provider = ' ' },
                        },
                        {}
                    },
                    FileFlags,
                },
            },
        },
        {
            provider = '',
            hl = function(self)
                return { fg = self.color }
            end
        },
    }

    local FileBlock = {
        FileNameBlock,
        { provider = '', hl = function(self) return { fg = self[1].icon_color, bg = self[3].color } end },
        FileInfoBlock
    }


    -------------------------------------------------------------------------------
    ----------------------------------*** LSP ***----------------------------------
    -------------------------------------------------------------------------------
    local LSPActive = {
        condition = conditions.lsp_attached,
        update    = { 'LspAttach', 'LspDetach', 'BufEnter' },

        -- You can keep it simple,
        -- provider = " [LSP]",

        -- Or complicate things a bit and get the servers names
        { provider = '', hl = { fg = "white" } },
        {
            provider = function()
                local names = {}
                for _, server in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
                    table.insert(names, server.name)
                end
                return "  " .. table.concat(names, "  ") .. " "
            end,
            hl       = { bg = "white", fg = "black", bold = false },
        },
        { provider = '', hl = { fg = "white" } },
    }

    -- See lsp-status/README.md for configuration options.
    -- Note: check "j-hui/fidget.nvim" for a nice statusline-free alternative.
    -- local LSPMessages = {
    --     provider = require("lsp-status").status,
    --     hl = { fg = "gray" },
    -- }

    -- works in multi window, but does not support flexible components (yet ...)
    local Navic = {
        condition = function() return require("nvim-navic").is_available() end,
        -- flexible = 4,
        static = {
            -- create a type highlight map
            type_hl = {
                File = "Directory",
                Module = "@include",
                Namespace = "@namespace",
                Package = "@include",
                Class = "@structure",
                Method = "@method",
                Property = "@property",
                Field = "@field",
                Constructor = "@constructor",
                Enum = "@field",
                Interface = "@type",
                Function = "@function",
                Variable = "@variable",
                Constant = "@constant",
                String = "@string",
                Number = "@number",
                Boolean = "@boolean",
                Array = "@field",
                Object = "@type",
                Key = "@keyword",
                Null = "@comment",
                EnumMember = "@field",
                Struct = "@structure",
                Event = "@keyword",
                Operator = "@operator",
                TypeParameter = "@type",
            },
            -- bit operation dark magic, see below...
            enc = function(line, col, winnr)
                return bit.bor(bit.lshift(line, 16), bit.lshift(col, 6), winnr)
            end,
            -- line: 16 bit (65535); col: 10 bit (1023); winnr: 6 bit (63)
            dec = function(c)
                local line = bit.rshift(c, 16)
                local col = bit.band(bit.rshift(c, 6), 1023)
                local winnr = bit.band(c, 63)
                return line, col, winnr
            end
        },
        init = function(self)
            local data = require("nvim-navic").get_data() or {}
            local children = {
                { provider = ' ' }
            }
            local contrasted = {
                { provider = ' ' }
            }
            -- create a child for each level
            for i, d in ipairs(data) do
                -- encode line and column numbers into a single integer
                local pos = self.enc(d.scope.start.line, d.scope.start.character, self.winnr)
                local child = {
                    {
                        provider = d.icon,
                        hl = self.type_hl[d.type],
                    },
                    {
                        -- escape `%`s (elixir) and buggy default separators
                        provider = d.name:gsub("%%", "%%%%"):gsub("%s*->%s*", ''),
                        -- highlight icon only or location name as well
                        hl = self.type_hl[d.type],

                        on_click = {
                            -- pass the encoded position through minwid
                            minwid = pos,
                            callback = function(_, minwid)
                                -- decode
                                local line, col, winnr = self.dec(minwid)
                                vim.api.nvim_win_set_cursor(vim.fn.win_getid(winnr), { line, col })
                            end,
                            name = "heirline_navic",
                        },
                    },
                }
                if i == 2 or i == #data then
                    table.insert(contrasted, child)
                end
                if #data >= 4 and i == 3 then
                    table.insert(contrasted, {
                        provider = " > ... > ",
                        hl = { fg = 'foreground' },
                    })
                end
                -- add a separator only if needed
                if #data > 1 and i < #data then
                    child = {
                        child[1], child[2],
                        {
                            provider = " > ",
                            hl = { fg = 'foreground' }
                        },
                    }
                end
                table.insert(children, child)
            end
            -- instantiate the new child, overwriting the previous one
            self.children = {
                self:new(children, 1),
                self:new(contrasted, 2)
            }
        end,
        -- evaluate the children containing navic components
        {
            provider = function(self)
                return self.children[1]:eval()
            end,
        },
        -- {
        --     provider = function(self)
        --         return self.children[2]:eval()
        --     end,
        -- },
        hl = { fg = "grey4" },
        update = 'CursorMoved'
    }

    local Diagnostics = {
        fallthrough = false,
        {
            condition = conditions.has_diagnostics,
            static = {
                error_icon = vim.diagnostic.config().signs.text[vim.diagnostic.severity.ERROR],
                warn_icon = vim.diagnostic.config().signs.text[vim.diagnostic.severity.WARN],
                info_icon = vim.diagnostic.config().signs.text[vim.diagnostic.severity.INFO],
                hint_icon = vim.diagnostic.config().signs.text[vim.diagnostic.severity.HINT],
            },
            init = function(self)
                self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
                self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
                self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
                self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
                self.actives = {}
                self.indices = {}
                self.colors = {
                    utils.get_highlight("DiagnosticError").fg,
                    utils.get_highlight("DiagnosticWarn").fg,
                    utils.get_highlight("DiagnosticInfo").fg,
                    utils.get_highlight("DiagnosticHint").fg,
                }
                for idx, num in ipairs({ self.errors, self.warnings, self.info, self.hints }) do
                    if num > 0 then
                        self.actives[#self.actives + 1] = idx
                        self.indices[idx] = #self.actives
                    end
                end
                local children = {
                    [2] = {
                        condition = function(self) return self.errors > 0 end,
                        provider = function(self)
                            return self.error_icon .. " " .. self.errors
                        end,
                        hl = { bg = utils.get_highlight("DiagnosticError").fg },
                    },
                    [4] = {
                        condition = function(self) return self.warnings > 0 end,
                        provider = function(self)
                            return self.warn_icon .. " " .. self.warnings
                        end,
                        hl = { bg = utils.get_highlight("DiagnosticWarn").fg },
                    },
                    [6] = {
                        condition = function(self) return self.info > 0 end,
                        provider = function(self)
                            return self.info_icon .. " " .. self.info
                        end,
                        hl = { bg = utils.get_highlight("DiagnosticInfo").fg },
                    },
                    [8] = {
                        condition = function(self) return self.hints > 0 end,
                        provider = function(self)
                            return self.hint_icon .. " " .. self.hints
                        end,
                        hl = { bg = utils.get_highlight("DiagnosticHint").fg },
                    },
                }
                local sep = function(idx)
                    return {
                        -- {
                        --     condition = function(self)
                        --         return self.indices[idx] and self.actives[self.indices[idx] + 1]
                        --     end,
                        --     provider = ' ',
                        --     hl = function(self)
                        --         return { bg = self.colors[idx] }
                        --     end
                        -- },
                        {
                            condition = function(self)
                                return self.indices[idx] and self.actives[self.indices[idx] + 1]
                            end,
                            provider = '',
                            hl = function(self)
                                return { fg = self.colors[idx], bg = self.colors[self.actives[self.indices[idx] + 1]] }
                            end
                        }
                    }
                end
                for idx = 1, 3, 1 do
                    children[idx * 2 + 1] = sep(idx)
                end
                children[1] = {
                    condition = function(self)
                        return #self.actives > 0
                    end,
                    provider = '',
                    hl = function(self)
                        return { fg = self.colors[self.actives[1]] }
                    end
                }
                children[9] = {
                    condition = function(self)
                        return #self.actives > 0
                    end,
                    provider = '',
                    hl = function(self)
                        return { fg = self.colors[self.actives[#self.actives]] }
                    end
                }
                self.children = self:new(children, 1)
            end,

            update = { "DiagnosticChanged", "BufEnter" },

            hl = { fg = "black", bold = true },
            {
                provider = function(self)
                    return self.children:eval()
                end
            }
        },
        {
            provider = '',
            hl = { fg = 'white' }
        },
    }

    -- local DAPMessages = {
    --     condition = function()
    --         local session = require("dap").session()
    --         return session ~= nil
    --     end,
    --     provider = function()
    --         return " " .. require("dap").status()
    --     end,
    --     hl = "Debug"
    --     -- see Click-it! section for clickable actions
    -- }



    -------------------------------------------------------------------------------
    --------------------------------*** Cursor ***---------------------------------
    -------------------------------------------------------------------------------

    local Lazy = {
        condition = require("lazy.status").has_updates,
        { provider = '', hl = { fg = 'red' } },
        {
            update = { "User", pattern = "LazyUpdate" },
            provider = function() return " 󰂖 " .. require("lazy.status").updates() .. " " end,
            on_click = {
                callback = function() require("lazy").update() end,
                name = "update_plugins",
            },
            hl = { fg = "grey5", bg = "red", bold = true },
        },
        { provider = '', hl = { fg = 'red' } },
        { provider = '  ' }
    }

    local Cursor = {
        {
            flexible = Flexible.Cursor,
            {
                {
                    { provider = '', hl = { fg = 'grey4' } },
                    {
                        { provider = '  ' },
                        {
                            provider = function()
                                return vim.api.nvim_get_current_win()
                            end
                        },
                        hl = { bg = 'grey4' },
                    },
                    hl = { fg = 'white' }
                },
                { provider = ' ', hl = { fg = 'blue', bg = 'grey4' } },
                {
                    { provider = ' 󰓩 ' },
                    {
                        provider = function()
                            return vim.api.nvim_get_current_tabpage()
                        end
                    },
                    hl = { bg = 'blue' }
                },
                { provider = ' ', hl = { bg = 'blue', fg = 'green' } },
                -- %n = Buffer number.
                {
                    { provider = ' 󰈔 ' },
                    { provider = '%n' },
                    hl = { bg = 'green' },
                },
                { provider = ' ', hl = { bg = 'green', fg = 'yellow' } },
                -- %B = Value of character under cursor in hexadecimal.
                {
                    { provider = ' 󰻐 %B' },
                    hl = { bg = 'yellow' },
                },
                { provider = ' ', hl = { bg = 'yellow', fg = 'purple' } },
                {
                    {
                        provider = function()
                            return '  %l,%c%L,' .. vim.fn.col('$') .. ' '
                        end
                    },
                    hl = { bg = 'purple' },
                },
                -- { provider = '',  hl = { fg = 'purple' } },
                { provider = '', hl = { fg = 'purple' } },
            },
            {
                { provider = '', hl = { fg = 'purple' } },
                {
                    {
                        provider = function()
                            return '  %l,%c%L,' .. vim.fn.col('$') .. ' '
                        end
                    },
                    hl = { bg = 'purple' },
                },
                { provider = '', hl = { fg = 'purple' } },
            },
            {
                { provider = '', hl = { fg = 'purple' } },
                { provider = '  %l,%c ', hl = { bg = 'purple' } },
                { provider = '', hl = { fg = 'purple' } },
            },
            {
                { provider = '', hl = { fg = 'purple' } },
                { provider = '  %c ', hl = { bg = 'purple' } },
                { provider = '', hl = { fg = 'purple' } },
            },
            {},
            hl = { bold = true }
        },
        -- %P = percentage through file of displayed window
        { provider = '  %P ', hl = { fg = 'blue2' } },
        {
            static = {
                sbar = { '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█' }
            },
            provider = function(self)
                local curr_line = vim.api.nvim_win_get_cursor(0)[1]
                local lines = vim.api.nvim_buf_line_count(0)
                local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
                return string.rep(self.sbar[i], 2)
            end,
            hl = { fg = "blue", bg = "background" },
        },
        hl = { fg = "grey5" },
    }

    local TerminalName = {
        -- we could add a condition to check that buftype == 'terminal'
        -- or we could do that later (see #conditional-statuslines below)
        provider = function()
            local tname, _ = vim.api.nvim_buf_get_name(0):gsub(".*:", "")
            return " " .. tname
        end,
        hl = { fg = "black", bold = true },
    }

    local HelpFileName = {
        condition = function()
            return vim.bo.filetype == "help"
        end,
        provider = function()
            local filename = vim.api.nvim_buf_get_name(0)
            return vim.fn.fnamemodify(filename, ":t")
        end,
        hl = { fg = "blue" },
    }

    local Align = { provider = '%=' }
    local Space = { provider = " " }
    local WinBar = {
        condition = function()
            return conditions.is_active() and conditions.buffer_matches({ buftype = { '' } })
        end,
        ViMode,
        SearchCount,
        MacroRec,
        ---
        { provider = '%<' },
        Align,
        Navic,
        Space,
        LSPActive,
        Diagnostics,
    }
    local DefaultStatusline = {
        Version, Git,
        ---
        Align, FileBlock,
        ---
        -- Align, LSPActive, Diagnostics,
        ---
        Align, Lazy, Cursor
    }
    local SpecialStatusline = {
        condition = function()
            return conditions.buffer_matches({
                buftype = { "nofile", "prompt", "help", "quickfix" },
                filetype = { "^git.*", "fugitive" },
            })
        end,
        FileType,
        Space,
        HelpFileName,
        Align,
        Cursor
    }
    local TerminalStatusline = {
        condition = function()
            return conditions.buffer_matches({ buftype = { "terminal" } })
        end,
        hl = { bg = "red" },
        ViMode,
        Space,
        FileType,
        Space,
        TerminalName,
        Align,
        Cursor
    }

    return {
        statusline = {
            hl = function()
                if conditions.is_active() then
                    return "StatusLine"
                else
                    return "StatusLineNC"
                end
            end,

            -- the first statusline with no condition, or which condition returns true is used.
            -- think of it as a switch case with breaks to stop fallthrough.
            fallthrough = false,
            SpecialStatusline,
            TerminalStatusline,
            DefaultStatusline
        },
        winbar = {
            WinBar,
        },
        opts = {
            colors = colors.scheme
        }
    }
end

return {
    'rebelot/heirline.nvim',
    opts = getopts,
    dependencies = {
        'lewis6991/gitsigns.nvim',
        'melkster/modicator.nvim',
    },
}
