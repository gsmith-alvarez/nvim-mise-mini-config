--- [[ Autocompletion Engine (blink.cmp) ]]
--- High-performance Rust-based completion and snippet engine.

--[[
EXECUTION STRATEGY: Deferred loading via `VimEnter` autocmd.
- The entire completion suite is dormant at boot.
- When Neovim is fully loaded, a one-shot autocommand triggers.
- This JIT-loads blink.cmp and all its sources (LSP, snippets, paths).
- This ensures the completion UI is instantly available when Neovim is ready,
  and provides `blink.cmp` capabilities for LSP earlier.
--]]

local group = vim.api.nvim_create_augroup('MiniDeps_Completion', { clear = true })
vim.api.nvim_create_autocmd('VimEnter', {
  group = group,
  pattern = '*',
  callback = function()
    -- Load blink.cmp and its dependencies
    local MiniDeps = require('mini.deps')
    local utils = require('core.utils')

    MiniDeps.add('rafamadriz/friendly-snippets')
    MiniDeps.add('folke/lazydev.nvim')
    
    MiniDeps.add({
      source = 'saghen/blink.cmp',
      -- FORCE MULTIPLIER: Use the shell build script directly.
      -- This bypasses the need for the :BlinkCmp command to exist yet.
      hooks = {
        post_install = function(args)
          utils.soft_notify("Building blink.cmp binary...")
          vim.system({ 'cargo', 'build', '--release' }, { cwd = args.path }):wait()
        end,
        -- We use post_checkout to handle updates (git pulls)
        post_checkout = function(args)
          vim.system({ 'cargo', 'build', '--release' }, { cwd = args.path }):wait()
        end,
      },
    })
    
    -- CRITICAL: Ensure Neovim sees the newly added plugin files immediately
    vim.cmd('packadd blink.cmp')
    -- Configure LazyDev first
    require('lazydev').setup({
      library = { { path = '${3rd}/luv/library', words = { 'vim%.uv' } } },
    })

    -- Configure Blink
    require('blink.cmp').setup({
      keymap = {
        -- Clean slate, zero interference with native Neovim keys
        preset = 'none',
        
        ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-e>'] = { 'hide' },

        -- The Home-Row Navigation Protocol
        ['<C-j>'] = { 'select_next', 'fallback' },
        ['<C-k>'] = { 'select_prev', 'fallback' },
        
        -- Accept current selection (or the first one instantly)
        ['<C-l>'] = { 'accept', 'fallback' },
        
        -- Instantly dismiss the menu without modifying the buffer
        ['<C-h>'] = { 'hide', 'fallback' },

        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
      },
      appearance = { nerd_font_variant = 'mono' },
      completion = {
        list = { 
          selection = { 
            -- CRITICAL CHANGES HERE:
            preselect = true,   -- Auto-targets the first item so <C-l> works the millisecond the menu opens
            auto_insert = false -- Prevents ghost text from bleeding into your code as you scroll
          } 
        },
        documentation = { auto_show = false, auto_show_delay_ms = 500 },
        menu = { draw = { columns = { { 'label', 'label_description', gap = 1 }, { 'kind_icon', 'kind' } } } },
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'lazydev' },
        providers = { lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink', score_offset = 100 } },
      },
      snippets = { preset = 'default' },
      signature = { enabled = true },
    })

    vim.api.nvim_clear_autocmds({ group = 'MiniDeps_Completion' })
  end,
})
