-- [[ MINI.STARTER: Workspace Dashboard ]]
-- Domain: UI & Entry Point
--
-- PHILOSOPHY: Zero-Friction Ignition

local M = {}
local utils = require('core.utils')
local quotes_engine = require('plugins.ui.quotes')

local ok, err = pcall(function()
  -- 1. Infrastructure
  require('mini.deps').add('echasnovski/mini.starter')
  local starter = require('mini.starter')

  -- 2. Workspace Validation
  local paths = {
    projects = vim.fn.expand("~/Documents/Projects"),
    obsidian = vim.fn.expand("~/Documents/Obsidian"),
    config   = vim.fn.expand("~/.config/nvim")
  }

  -- [[ THE JIT BRIDGE (WITH DIAGNOSTICS) ]]
  -- (ONLY ONE DEFINITION OF THIS FUNCTION)
  local function telescope_action(method, opts)
    return function()
      local ok_find, finding = pcall(require, 'plugins.finding.telescope')
      if not ok_find then
        utils.soft_notify("Bridge Error 1: Cannot find lua/plugins/finding/telescope.lua", vim.log.levels.ERROR)
        return
      end

      if type(finding.bootstrap) ~= "function" then
        utils.soft_notify("Bridge Error 2: 'M.bootstrap' is missing in telescope.lua!", vim.log.levels.ERROR)
        return
      end

      local boot_success = finding.bootstrap()
      if not boot_success then
         utils.soft_notify("Bridge Error 3: Telescope's internal bootstrap returned false.", vim.log.levels.ERROR)
         return
      end

      local ok_tel, builtin = pcall(require, 'telescope.builtin')
      if ok_tel then
        builtin[method](opts)
      else
        utils.soft_notify("Bridge Error 4: Plugin 'telescope.builtin' not found.", vim.log.levels.ERROR)
      end
    end
  end

  -- 4. Action Items
  local my_items = {
    -- Directories (Notice the new table syntax for opts: { cwd = ... })
    vim.fn.isdirectory(paths.projects) == 1 and
      { name = 'Projects', action = telescope_action('find_files', { cwd = paths.projects }), section = 'Directories' } or nil,
    vim.fn.isdirectory(paths.config) == 1 and
      { name = 'Config',   action = telescope_action('find_files', { cwd = paths.config }),   section = 'Directories' } or nil,
    vim.fn.isdirectory(paths.config) == 1 and
      { name = 'Obsidian',   action = telescope_action('find_files', { cwd = paths.obsidian }),   section = 'Directories' } or nil,
    -- Standard Actions
    { name = 'New file', action = 'ene | startinsert', section = 'Actions' },
    { name = 'Quit',     action = 'qall',             section = 'Actions' },

    -- Recent Files
    starter.sections.recent_files(5, false),
    starter.sections.recent_files(5, true),
  }

  -- 5. Initialization
  starter.setup({
    evaluate_single = true,
    items = vim.tbl_filter(function(x) return x ~= nil end, my_items),
    header = [[
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠤⠤⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⠰⡮⢳⡆⠀⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⠀⢀⡏⠀⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠢⡀⠘⠋⡀⠔⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣶⣾⣷⣶⣦⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢺⣿⣿⣿⣿⣿⣿⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣾⢿⣿⣿⣿⣿⣿⡟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⡞⢁⣿⣿⣿⣿⣿⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⢟⣥⣾⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣯⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⡿⣿⡿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
]] .. "\n" .. quotes_engine.get_cached_quote(),
    footer = "Type highlighted prefix to jump.",
    content_hooks = {
      starter.gen_hook.adding_bullet("󰍟 "),
      starter.gen_hook.aligning('center', 'center'),
      starter.gen_hook.padding(3, 2),
    },
  })

  -- 6. Highlighting (Native C-API)
  vim.api.nvim_set_hl(0, 'MiniStarterHeader',      { fg = '#89b4fa' })
  vim.api.nvim_set_hl(0, 'MiniStarterSection',     { fg = '#f5c2e7', bold = true })
  vim.api.nvim_set_hl(0, 'MiniStarterItem',        { fg = '#cdd6f4' })
  vim.api.nvim_set_hl(0, 'MiniStarterItemBullet',  { fg = '#94e2d5' })
  vim.api.nvim_set_hl(0, 'MiniStarterItemPrefix',  { fg = '#f38ba8' })
  vim.api.nvim_set_hl(0, 'MiniStarterFooter',      { fg = '#585b70' })

  -- 7. Buffer-Local Keymaps
  local group = vim.api.nvim_create_augroup('UI_Starter', { clear = true })
  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'MiniStarterOpened',
    callback = function()
      vim.keymap.set('n', 'q', '<cmd>quit<CR>', { buffer = true, silent = true })
      local nop = function() end
      vim.keymap.set('n', 'i', nop, { buffer = true, silent = true })
      vim.keymap.set('n', 'a', nop, { buffer = true, silent = true })
    end,
  })
end)

if not ok then
  utils.soft_notify('Mini.starter critical failure: ' .. err, vim.log.levels.ERROR)
end

return M
