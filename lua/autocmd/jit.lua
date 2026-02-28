-- [[ JIT NOTETAKING & SNIPPET ENGINE ]]
-- Domain: Deferred Plugin Initialization
--
-- PHILOSOPHY: Asymmetric Resource Allocation
-- Why load a 10,000-line Markdown plugin when editing a C++ file?
-- This module implements "Stubs" and "Proxy Autocmds" to defer loading
-- until the exact moment the functionality is required.

local M = {}

local utils = require('core.utils')
local jit_group = vim.api.nvim_create_augroup("JIT_Notetaking", { clear = true })

-- [[ INTERNAL STATE: Atomic Loading ]]
-- We use a local table instead of global vim.g variables for faster lookup
-- and to keep the global namespace clean.
local loaded = {
  obsidian = false,
  luasnip = false,
}

--- Atomic Loader for Obsidian.
--- Uses pcall to ensure a missing config file doesn't crash the editor.
local function load_obsidian()
  if loaded.obsidian then return true end

  local ok, plugin = pcall(require, "plugins.notetaking.obsidian")
  if ok and plugin.setup then
    -- ASYMMETRIC LEVERAGE: Only call setup once.
    pcall(plugin.setup)
    loaded.obsidian = true
    return true
  else
    utils.soft_notify("Failed to JIT load Obsidian: " .. (plugin or "Unknown Error"), vim.log.levels.ERROR)
    return false
  end
end

--- Atomic Loader for LuaSnip.
local function load_luasnip()
  if loaded.luasnip then return true end

  local ok, plugin = pcall(require, "plugins.notetaking.luasnips")
  if ok and plugin.setup then
    pcall(plugin.setup)
    loaded.luasnip = true
    return true
  else
    utils.soft_notify("Failed to JIT load LuaSnip: " .. (plugin or "Unknown Error"), vim.log.levels.ERROR)
    return false
  end
end

-- [[ 1. AUTO-TRIGGER: FileType Interceptors ]]
-- These autocmds detect when you enter a specific domain (Markdown/TeX)
-- and transparently initialize the required engines in the background.



vim.api.nvim_create_autocmd("FileType", {
  desc = "JIT Load Obsidian on Markdown entry",
  group = jit_group,
  pattern = "markdown",
  callback = load_obsidian,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "JIT Load Snippet Engine on Note/Doc entry",
  group = jit_group,
  pattern = { "markdown", "tex" },
  callback = load_luasnip,
})

-- [[ 2. PROXY COMMANDS: Global Stub Entry Points ]]
-- These keymaps act as "Proxies." When pressed, they first verify the plugin
-- is loaded, and then pass the intended command through to the newly
-- initialized plugin.

--- Higher-order function to create Obsidian command stubs.
--- @param cmd string The Obsidian command to run after loading.
local function obsidian_stub(cmd)
  return function()
    if load_obsidian() then
      vim.cmd(cmd)
    end
  end
end

local map = vim.keymap.set
map("n", "<leader>oq", obsidian_stub("ObsidianQuickSwitch"), { desc = "[O]bsidian [Q]uick Switch" })
map("n", "<leader>os", obsidian_stub("ObsidianSearch"), { desc = "[O]bsidian [S]earch (Ripgrep)" })
map("n", "<leader>on", obsidian_stub("ObsidianNew"), { desc = "[O]bsidian [N]ew Note" })

-- THE CONTRACT: Return the module to satisfy the Orchestrator's pcall.
return M
