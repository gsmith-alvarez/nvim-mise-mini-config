--- [[ Language Server Protocol (LSP) Engine ]]
--- The core of code intelligence: diagnostics, go-to-definition, etc.

--[[
EXECUTION STRATEGY: Deferred loading via `VimEnter` autocmd.
- The LSP engine is complex and one of the heaviest parts of the configuration.
- We defer its entire initialization until Neovim is fully loaded and idle.
- This ensures the fastest possible "time to interactive" for the editor UI.
--]]

local group = vim.api.nvim_create_augroup('MiniDeps_LSP', { clear = true })

vim.api.nvim_create_autocmd('VimEnter', {
  group = group,
  once = true, -- Only run this autocmd once per Neovim session
  callback = function()
    local MiniDeps = require('mini.deps')
    MiniDeps.add('neovim/nvim-lspconfig')
    MiniDeps.add('j-hui/fidget.nvim')
    -- blink.cmp is a dependency of completion.lua, ensure it is added here
    MiniDeps.add('saghen/blink.cmp')
    
    local utils = require('core.utils')
    require('fidget').setup({})

    -- Capability Resolution with Safety Check
    -- ASYMMETRIC LEVERAGE: We defensively check if blink.cmp is loaded.
    -- If not, we still provide basic capabilities, preventing a crash.
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local has_blink, blink = pcall(require, 'blink.cmp')
    if has_blink then
      capabilities = blink.get_lsp_capabilities(capabilities) -- Extend capabilities with blink.cmp
    end

    -- Define your LSP servers here. Map lspconfig server name to mise binary name.
    local servers = {
      clangd = { bin_name = 'clangd' },
      pyright = { bin_name = 'pyright-langserver', cmd_args = { '--stdio' } },
      ruff = { bin_name = 'ruff', cmd_args = { 'server' } },
      rust_analyzer = { bin_name = 'rust-analyzer' },
      bashls = { bin_name = 'bash-language-server', cmd_args = { 'start' } },
      jsonls = { bin_name = 'vscode-json-languageserver', cmd_args = { '--stdio' } },
      lua_ls = { bin_name = 'lua-language-server', settings = { Lua = { completion = { callSnippet = 'Replace' } } } },
      marksman = { bin_name = 'marksman', cmd_args = { 'server' } },
      gopls = { bin_name = 'gopls' },
      ts_ls = { bin_name = 'typescript-language-server', cmd_args = { '--stdio' } },
    }

    -- No longer using `require('lspconfig')` directly for `setup`.
    -- We configure `vim.lsp.config` directly and then enable servers.
    local configured_servers = {}
    for server_name, config_opts in pairs(servers) do
      local bin_path = utils.mise_shim(config_opts.bin_name)
      if bin_path then
        local server_config = {
          cmd = { bin_path },
          capabilities = capabilities,
          settings = config_opts.settings, -- Inherit settings if defined
        }
        if config_opts.cmd_args then
          vim.list_extend(server_config.cmd, config_opts.cmd_args)
        end
        vim.lsp.config[server_name] = server_config
        table.insert(configured_servers, server_name)
      else
        utils.soft_notify('LSP missing (graceful degradation): ' .. config_opts.bin_name, vim.log.levels.WARN)
      end
    end
    
    vim.lsp.enable(configured_servers)

    -- Autocommand for LSP features (keymaps, highlights) when an LSP attaches.
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach-post-deps', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc, mode)
          vim.keymap.set(mode or 'n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end
        map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
        
        -- Telescope-dependent mappings require Telescope to be loaded.
        map('grr', function() require('telescope.builtin').lsp_references() end, '[G]oto [R]eferences')
        map('gri', function() require('telescope.builtin').lsp_implementations() end, '[G]oto [I]mplementation')
        map('grd', function() require('telescope.builtin').lsp_definitions() end, '[G]oto [D]efinition')
        map('grt', function() require('telescope.builtin').lsp_type_definitions() end, '[G]oto [T]ype Definition')
        map('gO', function() require('telescope.builtin').lsp_document_symbols() end, 'Open Document Symbols')
        map('gW', function() require('telescope.builtin').lsp_dynamic_workspace_symbols() end, 'Open Workspace Symbols')
        
        map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
        
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.server_capabilities.documentHighlightProvider then
          local augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight-defer', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, { buffer = event.buf, group = augroup, callback = vim.lsp.buf.document_highlight })
          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, { buffer = event.buf, group = augroup, callback = vim.lsp.buf.clear_references })
        end
        if client and client.server_capabilities.inlayHintProvider then
          map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })) end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    -- Self-destruct the autocmd after it runs once.
    vim.api.nvim_clear_autocmds({ group = 'MiniDeps_LSP' })
  end,
})
