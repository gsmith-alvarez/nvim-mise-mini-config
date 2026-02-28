-- ============================================================================
-- MODULE: LuaSnip JIT Setup
-- CONTEXT: Inert module. Only executes when called by the global JIT trigger.
-- ============================================================================

local M = {}

function M.setup()
  -- 1. Infrastructure Registration
  require('mini.deps').add({ source = 'L3MON4D3/LuaSnip' })
  local ls = require("luasnip")

  -- 2. Performance & Region Tracking
  ls.config.set_config({
    history = true,
    updateevents = "TextChanged,TextChangedI",
    enable_autosnippets = true,
    region_check_events = "InsertEnter,CursorMoved,CursorMovedI",
    delete_check_events = "TextChanged,InsertLeave",
  })

  -- 3. THE ATOMIC HANDSHAKE:
  -- Load snippets from the lua/snippets directory using the native loader.
  require("luasnip.loaders.from_lua").lazy_load({ paths = { vim.fn.stdpath("config") .. "/lua/snippets" } })

  -- 4. Unified Traversal (Logic unchanged, remains robust)
  local opts = { silent = true }

  vim.keymap.set({ "i", "s" }, "<C-j>", function()
    if ls.expand_or_jumpable() then
      ls.expand_or_jump()
    end
  end, { desc = "Snippet: Expand/Jump Forward" })

  vim.keymap.set({ "i", "s" }, "<C-k>", function()
    if ls.jumpable(-1) then
      ls.jump(-1)
    end
  end, { desc = "Snippet: Jump Backward" })
end

return M
