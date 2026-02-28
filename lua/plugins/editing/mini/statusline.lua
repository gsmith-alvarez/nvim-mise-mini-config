--- [[ Mini.nvim: Statusline ]]
--- Configures the custom statusline.
local statusline = require('mini.statusline')
statusline.setup({
  content = {
    active = function()
      local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
      local git = statusline.section_git({ trunc_width = 75 })

      -- Directly query the Neovim Diagnostic Database
      local err_count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
      local warn_count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })

      local diagnostics = ""
      if err_count > 0 then diagnostics = diagnostics .. "󰅚 " .. err_count .. " " end
      if warn_count > 0 then diagnostics = diagnostics .. "󱈸 " .. warn_count end

      local filename = statusline.section_filename({ trunc_width = 140 })
      local fileinfo = statusline.section_fileinfo({ trunc_width = 120 })
      local location = statusline.section_location({ trunc_width = 75 })

      local mise_icon = '󱁛'
      local has_mise = vim.fn.filereadable('.mise.toml') == 1 or vim.fn.filereadable('mise.toml') == 1
      local mise_status = has_mise and (mise_icon .. ' local') or (mise_icon .. ' global')

      return statusline.combine_groups({
        { hl = mode_hl,                 strings = { mode } },
        { hl = 'MiniStatuslineDevinfo', strings = { git, diagnostics } },
        '%<',
        { hl = 'MiniStatuslineFilename', strings = { filename } },
        '%=',
        -- NATIVE C-CORE COMMAND TRACKING:
        -- '%S' is populated in real-time directly by Neovim
        { hl = 'WarningMsg',             strings = { '%S' } },
        { hl = 'MiniStatuslineFilename', strings = { mise_status } },
        { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
        { hl = mode_hl,                  strings = { location } },
      })
    end
  }
})
