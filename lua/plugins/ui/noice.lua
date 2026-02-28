-- [[ NOICE: Message & Command UI Replacement ]]
-- Domain: UI & Aesthetics
--
-- PHILOSOPHY: Immediate UI Interception
-- Replaces Neovim's default command line, message area, and popups with 
-- a modern, unobtrusive UI. Because this plugin intercepts core editor 
-- messaging, it must load synchronously during the UI boot phase to prevent 
-- native UI "flashing" or missed startup warnings.

local M = {}
local utils = require('core.utils')

local ok, err = pcall(function()
  -- 1. Safely resolve dependencies using the dependency graph
  MiniDeps.add({
    source = 'folke/noice.nvim',
    depends = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
    }
  })

  -- 2. Configure the Base Notification Engine
  -- Noice relies on nvim-notify for its floating message boxes. We set 
  -- sane defaults here to prevent CPU spikes from heavy animations.
  require('notify').setup({
    timeout = 3000,
    render = "compact",
    stages = "static", 
    top_down = false,
  })

  -- Immediately hijack the global notifier
  vim.notify = require('notify')

  -- 3. Configure the Core Noice Engine
  require('noice').setup({
    lsp = {
      override = {
        -- Override markdown rendering so that LSP hover and signature help 
        -- utilize the Noice formatting engine.
        ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
        ['vim.lsp.util.stylize_markdown'] = true,
      },
    },
    presets = {
      bottom_search = false,        -- Use a classic bottom cmdline for search
      command_palette = true,       -- Position the cmdline and popupmenu together
      long_message_to_split = true, -- Send long error traces to a split window
      inc_rename = true,            -- Seamless integration with our inc-rename.nvim proxy
      lsp_doc_border = false,       -- Clean borders for hover docs
    },
    routes = {
      {
        -- Suppress the 'showcmd' events (e.g., typing partial keystrokes) 
        -- to keep the command area perfectly clean.
        filter = { event = 'msg_showcmd' },
        opts = { skip = true },
      },
    },
  })
end)

if not ok then
  -- If Noice fails, Neovim naturally falls back to its native message UI.
  -- We log the failure securely without disrupting the editor session.
  utils.soft_notify('Noice UI failed to initialize: ' .. err, vim.log.levels.ERROR)
end

-- THE CONTRACT: Return the module to satisfy the UI Orchestrator
return M