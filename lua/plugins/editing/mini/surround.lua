--- [[ Mini.nvim: Surround ]]
--- Adds/changes/deletes surrounding pairs (e.g., quotes, brackets).
require('mini.surround').setup({ -- Use 'gz' as the prefix to reclaim native 's'
  mappings = {
    add = 'gza',            -- Add surrounding
    delete = 'gzd',         -- Delete surrounding
    find = 'gzf',           -- Find surrounding (to the right)
    find_left = 'gzF',      -- Find surrounding (to the left)
    highlight = 'gzh',      -- Highlight surrounding
    replace = 'gzr',        -- Replace surrounding
    update_n_lines = 'gzn', -- Update `n_lines`
  }
})