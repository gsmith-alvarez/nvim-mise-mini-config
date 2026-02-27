--- [[ Treesitter: Advanced Syntax Parsing ]]
--- The core engine for syntax highlighting and code structure analysis.

--[[
EXECUTION STRATEGY: Deferred loading via `BufReadPre`/`BufNewFile`.
- Treesitter is foundational but doesn't need to block the initial UI render.
- We use `packadd` to force the Lua cache to refresh immediately after adding.
--]]

local group = vim.api.nvim_create_augroup('MiniDeps_Treesitter', { clear = true })

vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  group = group,
  pattern = '*',
  callback = function()
    local MiniDeps = require('mini.deps')
    
    -- 1. Add the plugins to the ecosystem
    MiniDeps.add('nvim-treesitter/nvim-treesitter')
    MiniDeps.add('nvim-treesitter/nvim-treesitter-textobjects')

    -- 2. CRITICAL FIX: Force Neovim to refresh its internal module paths
    -- Without this, 'require' will fail to find the newly added folder.
    vim.cmd('packadd nvim-treesitter')

    -- 3. Safely configure using a protected call
    local ok, configs = pcall(require, 'nvim-treesitter.configs')
    if ok then
      configs.setup({
        ensure_installed = {
          'bash', 'c', 'cpp', 'go', 'html', 'json', 'lua', 'markdown',
          'markdown_inline', 'python', 'query', 'regex', 'rust', 'typescript',
          'javascript', 'vim', 'yaml'
        },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ['aa'] = '@parameter.outer',
              ['ia'] = '@parameter.inner',
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
            },
          },
        },
      })

      -- 4. Set global flag and self-destruct
      vim.g.treesitter_loaded = true
      vim.api.nvim_clear_autocmds({ group = group })
    end
  end,
})
