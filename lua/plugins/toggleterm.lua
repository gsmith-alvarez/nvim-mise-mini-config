--- [[ Toggleterm Terminal Manager ]]
--- Manages persistent, toggleable terminal windows for TUIs and shell commands.

--[[
EXECUTION STRATEGY: Deferred loading via keymap stubs.
- This entire module does nothing at startup except create keymaps.
- `toggleterm.nvim` is only downloaded and configured the *first* time
  one of its keymaps is pressed.
- This provides the ultimate on-demand loading, keeping startup completely
  unaffected by this plugin.
--]]

local utils = require('core.utils')

-- A flag to ensure we only run the setup once.
local loaded = false

-- The core loader function for toggleterm.nvim itself.
local function load_toggleterm()
  if loaded then return end

  -- ASYMMETRIC LEVERAGE: MiniDeps.add is idempotent; it won't re-download if the plugin exists.
  require('mini.deps').add('akinsho/toggleterm.nvim')
  -- Force load: Ensure toggleterm's modules are in Neovim's runtimepath immediately.
  vim.cmd('packadd toggleterm.nvim')

  require('toggleterm').setup({
    -- Configure toggleterm to use floating windows by default for all terminals.
    direction = 'float',
    float_opts = { border = 'curved' },
  })

  loaded = true
end

-- Helper to create keymap stubs that load the plugin on first use, then hotswap.
-- @param keys string|table Key or table of keys to map.
-- @param func function The function to execute after loading.
-- @param desc string The description for which-key.
local function create_stub(keys, func, desc)
  vim.keymap.set('n', keys, function()
    -- Load toggleterm.nvim on the very first execution of this keymap.
    load_toggleterm()
    -- Execute the actual function after the plugin is loaded.
    func()
    -- HOTSWAP: Overwrite the keymap to directly call the function for all future uses.
    vim.keymap.set('n', keys, func, { desc = desc })
  end, { desc = desc .. ' (loads on first use)' })
end

-- Stub for the main terminal toggle (<C-\>)
-- This one is handled slightly differently as it can be in normal or terminal mode.
vim.keymap.set({ 'n', 't' }, [[<C-\>]], function()
  load_toggleterm()
  -- After loading, the native ToggleTerm command should be available.
  vim.cmd('ToggleTerm')
  -- HOTSWAP: Redefine the keymap for direct execution.
  vim.keymap.set({ 'n', 't' }, [[<C-\>]], '<cmd>ToggleTerm<CR>', { desc = 'Toggle Terminal' })
end, { desc = 'Toggle Terminal (loads on first use)' })

-- [[ TUI Integrations: Lazygit, btm, Glow, Spotify, Aider, Podman ]]
-- Each of these is a `Terminal:new` instance managed by Toggleterm.

-- Stub for Lazygit (<leader>gg)
create_stub('<leader>gg', function()
  local lazygit_bin = utils.mise_shim('lazygit')
  if not lazygit_bin then
    utils.soft_notify('Lazygit missing. Run: mise install lazygit', vim.log.levels.WARN)
    return
  end
  local Terminal = require('toggleterm.terminal').Terminal
  local lazygit = Terminal:new({
    cmd = lazygit_bin,
    direction = 'float',
    hidden = true,
    float_opts = { border = 'curved' },
    on_open = function(term)
      vim.cmd('startinsert!')
      vim.api.nvim_buf_set_keymap(term.bufnr, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })
    end,
  })
  lazygit:toggle()
end, 'Toggle [G]it [G]ui (lazygit)')

-- Stub for Process Monitor (btm) (<leader>tp)
create_stub('<leader>tp', function()
  local btm_bin = utils.mise_shim('btm')
  if not btm_bin then
    utils.soft_notify('btm (bottom) missing. Run: mise install btm', vim.log.levels.WARN)
    return
  end
  local Terminal = require('toggleterm.terminal').Terminal
  local btm = Terminal:new({
    cmd = btm_bin,
    direction = 'float',
    hidden = true,
    float_opts = { border = 'curved', width = math.floor(vim.o.columns * 0.9), height = math.floor(vim.o.lines * 0.9) },
    on_open = function(term)
      vim.cmd('startinsert!')
      vim.api.nvim_buf_set_keymap(term.bufnr, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })
    end,
  })
  btm:toggle()
end, 'Toggle [P]rocess Monitor')

-- Stub for Glow Markdown Preview (<leader>tm)
create_stub('<leader>tm', function()
  local glow_bin = utils.mise_shim('glow')
  if not glow_bin then
    utils.soft_notify('Glow missing. Run: mise install glow', vim.log.levels.WARN)
    return
  end
  local Terminal = require('toggleterm.terminal').Terminal
  local glow = Terminal:new({
    -- ASYMMETRIC LEVERAGE: Pipe glow output through bat for persistent, highlighted view.
    cmd = function()
      local current_file = vim.fn.expand('%:p')
      local bat_bin = utils.mise_shim('bat')
      if not bat_bin then
        utils.soft_notify('Bat missing, defaulting to plain cat for markdown preview.', vim.log.levels.WARN)
        return glow_bin .. ' ' .. vim.fn.shellescape(current_file) .. ' | cat'
      end
      return glow_bin .. ' ' .. vim.fn.shellescape(current_file) .. ' | ' .. bat_bin .. ' --paging=always --theme=ansi --wrap=auto'
    end,
    direction = 'float',
    -- Keep the window open indefinitely until explicitly closed.
    close_on_exit = false,
    float_opts = { border = 'curved' },
  })
  -- ASYMMETRIC LEVERAGE: The `cmd` is a function, so it re-evaluates the current file dynamically.
  glow:toggle()
end, 'Toggle [M]arkdown Preview (glow)')

-- Stub for Spotify Player (<leader>ts)
create_stub('<leader>ts', function()
  local spotify_bin = utils.mise_shim('spotify_player')
  if not spotify_bin then
    utils.soft_notify('Spotify Player missing. Run: mise install spotify_player', vim.log.levels.WARN)
    return
  end
  local Terminal = require('toggleterm.terminal').Terminal
  local spotify = Terminal:new({
    cmd = spotify_bin,
    direction = 'float',
    hidden = true,
    on_open = function(term)
      vim.cmd('startinsert!')
      vim.api.nvim_buf_set_keymap(term.bufnr, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })
    end,
  })
  spotify:toggle()
end, 'Toggle [S]potify Player')

-- Stub for Aider AI Chat (<leader>ta)
create_stub('<leader>ta', function()
  local aider_bin = utils.mise_shim('aider')
  if not aider_bin then
    utils.soft_notify('Aider missing. Run: mise install aider', vim.log.levels.WARN)
    return
  end
  local Terminal = require('toggleterm.terminal').Terminal
  local aider = Terminal:new({
    cmd = function()
      local file = vim.fn.expand('%:p')
      -- ASYMMETRIC LEVERAGE: Automatically inject the current file into Aider's context.
      if file ~= '' and vim.fn.filereadable(file) == 1 then
        return aider_bin .. ' ' .. vim.fn.shellescape(file)
      end
      return aider_bin
    end,
    direction = 'float',
    hidden = true,
    float_opts = { border = 'curved' },
    on_open = function(term)
      vim.cmd('startinsert!')
      -- No 'q' mapping here because you might type 'q' in the chat!
    end,
  })
  aider:toggle()
end, 'Toggle [A]ider AI Chat')

-- Stub for Podman-TUI Infrastructure Control (<leader>ti)
create_stub('<leader>ti', function()
  local podman_tui_bin = utils.mise_shim('podman-tui')
  if not podman_tui_bin then
    utils.soft_notify('Podman-TUI missing. Run: mise install podman-tui', vim.log.levels.WARN)
    return
  end
  local Terminal = require('toggleterm.terminal').Terminal
  local podman = Terminal:new({
    cmd = podman_tui_bin,
    direction = 'float',
    hidden = true,
    on_open = function(term)
      vim.cmd('startinsert!')
      vim.api.nvim_buf_set_keymap(term.bufnr, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })
    end,
  })
  podman:toggle()
end, 'Toggle [I]nfrastructure (podman-tui)')

-- [[ PlatformIO Specific Tasks ]]
-- These are direct `vim.cmd` calls or Toggleterm instances for PlatformIO actions.

-- PIO Build Stub (<leader>pb)
create_stub('<leader>pb', function()
  local Terminal = require('toggleterm.terminal').Terminal
  local pio_build = Terminal:new({
    cmd = 'pio run',
    hidden = true,
    close_on_exit = false, -- Keep open to view build errors
  })
  pio_build:toggle()
end, 'PlatformIO: [B]uild Project')

-- PIO Upload Stub (<leader>pu)
create_stub('<leader>pu', function()
  local Terminal = require('toggleterm.terminal').Terminal
  local pio_upload = Terminal:new({
    cmd = 'pio run -t upload',
    hidden = true,
    close_on_exit = false, -- Keep open to diagnose upload failures
  })
  pio_upload:toggle()
end, 'PlatformIO: [U]pload Firmware')

-- PIO Monitor Stub (<leader>pm)
create_stub('<leader>pm', function()
  local Terminal = require('toggleterm.terminal').Terminal
  local pio_monitor = Terminal:new({
    cmd = 'pio device monitor',
    hidden = true,
  })
  pio_monitor:toggle()
end, 'PlatformIO: Device [M]onitor')

-- PIO Update Compile DB Stub (<leader>pc)
create_stub('<leader>pc', function()
  -- This command is direct, as it doesn't need a persistent terminal.
  vim.cmd('!pio run -t compiledb')
  vim.cmd('LspRestart') -- Restart LSP to pick up new compile_commands.json
end, 'PlatformIO: Update [C]ompilation Database')
