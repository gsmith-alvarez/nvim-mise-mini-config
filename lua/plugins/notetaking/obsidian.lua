-- ============================================================================
-- MODULE: Obsidian.nvim Integration
-- CONTEXT: JIT loaded. Only executes when called by an autocmd or global stub.
-- ============================================================================

local M = {}

function M.setup()
  -- 1. Anti-Fragility & Graceful Degradation Check
  -- Ensure the ripgrep binary (managed by mise) is available before loading.
  local has_rg = require('core.utils').mise_shim('rg')
  if not has_rg then
    vim.notify("Obsidian.nvim: 'rg' binary missing. Check mise configuration.", vim.log.levels.WARN)
    -- Fail gracefully by aborting the setup to prevent Lua errors.
    return
  end

  -- 2. Imperative Dependency Fetch via mini.deps
  require('mini.deps').add({
    source = 'epwalsh/obsidian.nvim',
    depends = { 'nvim-lua/plenary.nvim', 'echasnovski/mini.pick' } -- Added mini.pick dependency
  })

  -- 3. Execute the Setup Logic
  require("obsidian").setup({
    ui = { enable = false }, -- Disable Obsidian UI to prevent conflicts
    workspaces = {
      {
        name = "personal",
        path = "~/Documents/Obsidian", -- MANDATORY: Update to your actual vault path
      },
    },
    
    -- Force mini.pick integration to prevent telescope bloat
    picker = { name = "mini.pick" },

    -- Buffer-local keymaps (only active inside a note)
    mappings = {
      ["gf"] = {
        action = function() return require("obsidian").util.gf_passthrough() end,
        opts = { noremap = false, expr = true, buffer = true, desc = "Obsidian: Follow Link" },
      },
      ["<leader>of"] = {
        action = function() return require("obsidian").util.gf_passthrough() end,
        opts = { noremap = false, expr = true, buffer = true, desc = "Obsidian: [F]ollow Link" },
      },
      ["<leader>ov"] = {
        action = function() vim.cmd("ObsidianFollowLink vsplit") end,
        opts = { buffer = true, desc = "Obsidian: Follow Link (V-Split)" },
      },
      ["<leader>oh"] = {
        action = function() vim.cmd("ObsidianFollowLink hsplit") end,
        opts = { buffer = true, desc = "Obsidian: Follow Link (H-Split)" },
      },
    },
  })
end

return M
