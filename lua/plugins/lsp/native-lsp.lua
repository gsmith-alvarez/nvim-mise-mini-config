-- [[ LSP: The Code Intelligence Engine ]]
-- Domain: LSP & Intelligence
--
-- PHILOSOPHY: Native Capability Injection
-- We bypass the 'lspconfig' abstraction layer in favor of Neovim 0.10's 
-- native 'vim.lsp.config' registry. This ensures the lightest possible 
-- memory footprint and direct interaction with the C-core LSP client.

local M = {}
local utils = require('core.utils')

-- [[ THE BOOTSTRAPPER ]]
local ok, err = pcall(function()
  local MiniDeps = require('mini.deps')
  
  -- 1. Infrastructure Registration
  MiniDeps.add('neovim/nvim-lspconfig') -- Required for server-specific logic stubs
  MiniDeps.add('j-hui/fidget.nvim')    -- Visual LSP progress notifications

  require('fidget').setup({})

  -- 2. Capability Resolution
  -- We explicitly pull capabilities from our blink.cmp engine.
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local has_blink, blink = pcall(require, 'blink.cmp')
  if has_blink then
    capabilities = blink.get_lsp_capabilities(capabilities)
  end

  -- 3. The Server Registry
  -- Maps lspconfig names to mise binary shims.
  local servers = {
    clangd   = { bin = 'clangd', ft = { 'c', 'cpp' }, root = { 'compile_commands.json', '.git' } },
    gopls    = { bin = 'gopls', ft = { 'go' }, root = { 'go.work', 'go.mod', '.git' } },
    zls      = { bin = 'zls', ft = { 'zig' }, root = { 'zls.json', 'build.zig', '.git' } },
    pyright  = { bin = 'pyright-langserver', args = { '--stdio' }, ft = { 'python' }, root = { 'pyproject.toml', '.git' } },
    ruff     = { bin = 'ruff', args = { 'server' }, ft = { 'python' }, root = { 'pyproject.toml', '.git' } },
    ts_ls    = { bin = 'typescript-language-server', args = { '--stdio' }, ft = { 'typescript', 'javascript' }, root = { 'package.json', '.git' } },
    lua_ls   = { 
      bin = 'lua-language-server', 
      ft = { 'lua' }, 
      root = { '.luarc.json', '.git' },
      settings = { Lua = { diagnostics = { globals = { 'vim' } }, workspace = { checkThirdParty = false } } }
    },
    -- Formats/Config
    jsonls   = { bin = 'vscode-json-languageserver', args = { '--stdio' }, ft = { 'json' }, root = { '.git' } },
    yamlls   = { bin = 'yaml-language-server', args = { '--stdio' }, ft = { 'yaml' }, root = { '.git' } },
    taplo    = { bin = 'taplo', args = { 'lsp', 'stdio' }, ft = { 'toml' }, root = { '.git' } },
    bashls   = { bin = 'bash-language-server', args = { 'start' }, ft = { 'sh', 'bash' }, root = { '.git' } },
    marksman = { bin = 'marksman', args = { 'server' }, ft = { 'markdown' }, root = { '.git' } },
  }

  local configured_servers = {}

  for name, cfg in pairs(servers) do
    local bin_path = utils.mise_shim(cfg.bin)

    if bin_path then
      -- Construct native Neovim LSP configuration payload
      vim.lsp.config[name] = {
        cmd = { bin_path, unpack(cfg.args or {}) },
        capabilities = capabilities,
        filetypes = cfg.ft,
        root_markers = cfg.root,
        settings = cfg.settings,
      }
      table.insert(configured_servers, name)
    else
      utils.soft_notify('LSP server bin missing: ' .. cfg.bin, vim.log.levels.WARN)
    end
  end

  -- 4. Enable configured servers globally
  vim.lsp.enable(configured_servers)
end)

if not ok then
  utils.soft_notify('LSP Config engine failure: ' .. err, vim.log.levels.ERROR)
end

-- [[ GLOBAL ATTACH LOGIC ]]
-- This fires EVERY time a server attaches to a buffer.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('LSP_Attach_Common', { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    
    local map = function(keys, func, desc, mode)
      vim.keymap.set(mode or 'n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    -- Standard Mappings
    map('<leader>cn', vim.lsp.buf.rename, 'Re[n]ame')
    map('<leader>ca', vim.lsp.buf.code_action, 'Code [A]ctions', { 'n', 'x' })
    map('<leader>cc', vim.lsp.buf.declaration, 'Go to Declaration')

    -- Telescope-integrated Intelligence (Loaded JIT)
    map('<leader>cl', function() require('telescope.builtin').lsp_references() end, 'References')
    map('<leader>ci', function() require('telescope.builtin').lsp_implementations() end, 'Implementations')
    map('<leader>cf', function() require('telescope.builtin').lsp_definitions() end, 'Definitions')
    map('<leader>ct', function() require('telescope.builtin').lsp_type_definitions() end, 'Type Definitions')
    map('<leader>co', function() require('telescope.builtin').lsp_document_symbols() end, 'Document Symbols')

    -- Semantic Highlighting
    if client and client.server_capabilities.documentHighlightProvider then
      local highlight_group = vim.api.nvim_create_augroup('LSP_Highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf, group = highlight_group, callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf, group = highlight_group, callback = vim.lsp.buf.clear_references,
      })
    end

    -- Inlay Hints
    if client and client.server_capabilities.inlayHintProvider then
      map('<leader>ch', function() 
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })) 
      end, 'Toggle Inlay [H]ints')
    end
  end,
})

return M
