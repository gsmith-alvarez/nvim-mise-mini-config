-- ============================================================================
-- MODULE: LuaSnip JIT Setup
-- CONTEXT: Inert module. Only executes when called by the global JIT trigger.
-- ============================================================================

local M = {}

function M.setup()
  -- 1. Imperatively fetch the engine ONLY when needed
  require('mini.deps').add({ source = 'L3MON4D3/LuaSnip' })

  local ls = require("luasnip")

  -- 2. Configure the aggressive auto-expansion
  ls.config.set_config({
    history = true,
    updateevents = "TextChanged,TextChangedI",
    enable_autosnippets = true,
  })

  -- 3. Require the inert payload file and inject it into the target filetypes
  local latex_snippets = require("snippets.latex").retrieve()
  ls.add_snippets("markdown", latex_snippets)
  ls.add_snippets("tex", latex_snippets)

  -- 4. Map the traversal keys
  local opts = { buffer = true, silent = true }

  vim.keymap.set({ "i", "s" }, "<C-j>", function()
    if ls.expand_or_jumpable() then
      ls.expand_or_jump()
    else
      -- Fallback for bracket/parentheses exit if not a snippet
      -- This will require integration with a bracket-matching/autoclose plugin's jump function
      -- For now, we'll keep it simple and focus on snippets.
    end
  end, vim.tbl_extend("force", opts, { desc = "LuaSnip: Expand or Jump (Forward)" }))

  vim.keymap.set({ "i", "s" }, "<C-k>", function()
    if ls.jumpable(-1) then
      ls.jump(-1)
    end
  end, vim.tbl_extend("force", opts, { desc = "LuaSnip: Jump to previous node (Backward)" }))
end

return M
