-- [[ DIAGNOSTIC SUBSYSTEM ]]
-- Manages how Neovim communicates code intelligence errors to the user.

local M = {}

-- [[ Diagnostic Hover ]]
-- Triggers a floating window containing the full error message when the cursor idles.
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, { focusable = false, scope = "cursor" })
  end,
})

-- CRITICAL PERFORMANCE TUNING: `updatetime`
-- This controls the delay (in milliseconds) before the `CursorHold` event fires.
-- The Neovim default is an agonizing 4000ms. Lowering it to 500ms makes error
-- discovery feel instantaneous. (Note: This also controls how often Neovim
-- writes to the swap file, but 500ms is a highly stable modern standard).
vim.opt.updatetime = 500

-- [[ Diagnostic Discovery Toggles ]]
-- Diagnostics can create intense visual noise. These toggles allow you to
-- surgically mute the LSP when you are in the flow state, then turn it back
-- on for the error-correction phase.

vim.keymap.set('n', '<leader>dL', function()
  local current = vim.diagnostic.config().virtual_text
  vim.diagnostic.config({ virtual_text = not current })
  vim.notify("Virtual Text: " .. (not current and "ON" or "OFF"))
end, { desc = '[T]oggle [V]irtual Text' })

vim.keymap.set('n', '<leader>dU', function()
  local current = vim.diagnostic.config().underline
  vim.diagnostic.config({ underline = not current })
  vim.notify("Underlines: " .. (not current and "ON" or "OFF"))
end, { desc = '[T]oggle [U]nderlines' })

-- [[ Diagnostic Quickfix Routing ]]
vim.keymap.set('n', '<leader>q', function()
  -- If Trouble.nvim is loaded, delegate to its superior multi-file interface.
  -- Otherwise, fall back to dumping workspace diagnostics into the native quickfix list.
  local has_trouble, _ = pcall(require, 'trouble')
  if has_trouble then
    vim.cmd('Trouble diagnostics toggle')
  else
    vim.diagnostic.setqflist()
  end
end, { desc = '🗒️ Open diagnostic [Q]uickfix list' })

return M
