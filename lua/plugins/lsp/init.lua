-- [[ LSP DOMAIN ORCHESTRATOR ]]
-- Location: lua/plugins/lsp/init.lua
-- Domain: Intelligence & Completion

local M = {}
local utils = require('core.utils')

local modules = {
  'lsp.native-lsp',
  'lsp.blink',
}

for _, mod in ipairs(modules) do
  local module_path = 'plugins.' .. mod
  local ok, err = pcall(require, module_path)

  if not ok then
    utils.soft_notify(string.format("LSP DOMAIN FAILURE: [%s]\n%s", module_path, err), vim.log.levels.ERROR)
  end
end

return M
