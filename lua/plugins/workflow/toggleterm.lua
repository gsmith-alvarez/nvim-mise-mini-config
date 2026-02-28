-- [[ TOGGLETERM: The Terminal Command Center ]]
-- Domain: Workflow & External TUI Integration
--
-- PHILOSOPHY: Action-Driven JIT Infrastructure
-- We treat the terminal not as a background process, but as a modular tool.
-- Every external binary (Lazygit, Spotify, Aider) is lazy-loaded and
-- validated against mise shims before execution.

local M = {}
local utils = require('core.utils')

local loaded = false

-- [[ THE JIT ENGINE ]]
-- Bootstraps the plugin only when a terminal keybind is invoked.
local function bootstrap_toggleterm()
  if loaded then return true end

  local ok, err = pcall(function()
    require('mini.deps').add('akinsho/toggleterm.nvim')
    -- We do not use packadd here because MiniDeps.add handles rtp; 
    -- we call setup immediately to initialize the command set.
    require('toggleterm').setup({
      direction = 'float',
      float_opts = { 
        border = 'curved',
        winblend = 3, -- Slight transparency for context
      },
      -- Integrated terminal behavior enhancements
      open_mapping = [[<C-\>]], -- Globally register the native toggle
      insert_mappings = true,   -- Whether open mapping applies in insert mode
      terminal_mappings = true, -- Whether open mapping applies in terminal mode
    })
  end)

  if not ok then
    utils.soft_notify('Toggleterm failed to initialize: ' .. err, vim.log.levels.ERROR)
    return false
  end

  loaded = true
  return true
end

-- [[ THE PROXY DISPATCHER ]]
-- Instead of hotswapping (which is fragile), we use a persistent proxy.
-- The overhead of a boolean check is lower than the cost of redefining keymaps.
local function proxy_exec(func)
  if bootstrap_toggleterm() then
    func()
  end
end

-- [[ THE TERMINAL FACTORY ]]
-- Centralized logic for creating floating TUI instances.
local function create_tui(bin_name, desc, cmd_override)
  return function()
    local path = utils.mise_shim(bin_name)
    if not path then
      utils.soft_notify(desc .. ' missing. Install via: mise install ' .. bin_name, vim.log.levels.WARN)
      return
    end

    local Terminal = require('toggleterm.terminal').Terminal
    local tui = Terminal:new({
      cmd = cmd_override or path,
      hidden = true,
      on_open = function(term)
        vim.cmd("startinsert!")
        -- Standardize the 'q' quit key for all TUIs
        vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
      end,
    })
    tui:toggle()
  end
end

-- [[ KEYMAP DEFINITIONS ]]

-- 1. Standard Terminal Toggle
vim.keymap.set({ 'n', 't' }, [[<C-\>]], function()
  if bootstrap_toggleterm() then
    vim.cmd('ToggleTerm')
  end
end, { desc = 'Toggle Terminal (JIT)' })

-- 2. TUI Mappings (Workflow Hub)
local tui_maps = {
  { '<leader>gg', 'lazygit', 'Git Client' },
  { '<leader>vp', 'btm',     'Process Monitor' },
  { '<leader>vs', 'spotify_player', 'Spotify' },
  { '<leader>vi', 'podman-tui', 'Container Infrastructure' },
}

for _, map in ipairs(tui_maps) do
  vim.keymap.set('n', map[1], function()
    proxy_exec(create_tui(map[2], map[3]))
  end, { desc = 'TUI: ' .. map[3] })
end

-- 3. Dynamic Context Mappings (Aider & Glow)
vim.keymap.set('n', '<leader>va', function()
  proxy_exec(function()
    local file = vim.fn.expand('%:p')
    local cmd = 'aider ' .. (file ~= '' and vim.fn.shellescape(file) or '')
    create_tui('aider', 'Aider AI', cmd)()
  end)
end, { desc = 'TUI: Aider AI Chat' })

vim.keymap.set('n', '<leader>vg', function()
  proxy_exec(function()
    local file = vim.fn.expand('%:p')
    local bat = utils.mise_shim('bat')
    local cmd = 'glow ' .. vim.fn.shellescape(file) .. (bat and (' | ' .. bat .. ' --paging=always') or '')
    create_tui('glow', 'Glow Markdown', cmd)()
  end)
end, { desc = 'TUI: Markdown Preview' })

-- 4. Hardware/PlatformIO Domain
local pio_tasks = {
  { '<leader>pb', 'pio run',              'Build Project' },
  { '<leader>pu', 'pio run -t upload',    'Upload Firmware' },
  { '<leader>pm', 'pio device monitor',   'Serial Monitor' },
}

for _, task in ipairs(pio_tasks) do
  vim.keymap.set('n', task[1], function()
    proxy_exec(function()
      local Terminal = require('toggleterm.terminal').Terminal
      Terminal:new({ cmd = task[2], close_on_exit = false }):toggle()
    end)
  end, { desc = 'PIO: ' .. task[3] })
end

return M