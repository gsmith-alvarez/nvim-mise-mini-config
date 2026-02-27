-- [[ Core User Commands ]]
-- This file defines global user commands for utility and auditing purposes.

-- [[ Dependency Auditing: :ToolCheck ]]
-- A custom command to scan for all required external tools and LSPs.
-- Outputs a clean summary telling you exactly what mise install commands to run.
vim.api.nvim_create_user_command('ToolCheck', function()
  local utils = require('core.utils')
  local tools = {
    -- LSPs
    'pyright-langserver',
    'ruff',
    'rust-analyzer',
    'bash-language-server',
    'vscode-json-languageserver',
    'lua-language-server',
    'marksman',
    'gopls',
    'typescript-language-server',
    'clangd',

    -- Formatters
    'stylua',
    'oxfmt',

    -- Linters
    'markdownlint-cli2',
    'shellcheck',

    -- System / Core Dependencies
    'rg',
    'fd',
    'make',
    'gcc',
    'lazygit',
    'btm',
    'dlv',
  }

  local missing = {}
  local found = {}

  for _, tool in ipairs(tools) do
    local path = utils.mise_shim(tool)
    if path then
      table.insert(found, tool)
    else
      table.insert(missing, tool)
    end
  end

  -- Create a new temporary buffer to display the results cleanly
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].filetype = 'markdown'

  local lines = {
    '# Dependency Audit Results',
    '',
  }

  if #missing == 0 then
    table.insert(lines, '✅ All tools are correctly installed and available!')
  else
    table.insert(lines, '❌ Missing dependencies found!')
    table.insert(lines, '')
    table.insert(lines, '## Missing Tools')
    for _, tool in ipairs(missing) do
      table.insert(lines, '- ' .. tool)
    end
    table.insert(lines, '')
    table.insert(lines, '## Recommended Fix')
    table.insert(lines, 'You can install missing tools globally with mise by running the following commands:')
    table.insert(lines, '```bash')
    for _, tool in ipairs(missing) do
      -- Assuming standard mise plugin names for demonstration; adjust as necessary based on actual mise plugins.
      table.insert(lines, 'mise install -g ' .. tool)
    end
    table.insert(lines, '```')
    table.insert(lines, '*(For true system dependencies like `make`, `gcc`, use your system package manager if mise cannot install them)*')
  end

  table.insert(lines, '')
  table.insert(lines, '## Found Tools')
  for _, tool in ipairs(found) do
    table.insert(lines, '- ' .. tool .. ' ✅')
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Open the buffer in a split
  vim.cmd('vsplit')
  vim.api.nvim_win_set_buf(0, buf)
  vim.bo[buf].modifiable = false
end, { desc = 'Audit required dependencies and suggest installation steps' })

vim.keymap.set('n', '<leader>ut', '<cmd>ToolCheck<CR>', { desc = '[T]ool [C]heck (Mise)' })

-- [[ User Command Keymaps for Views/External ]]
vim.keymap.set('n', '<leader>vq', '<cmd>Jq<CR>', { desc = '[J]q Live Scratchpad' })
vim.keymap.set('n', '<leader>sr', '<cmd>Sd<CR>', { desc = '[S]earch & [R]eplace (Sd)' })
vim.keymap.set('n', '<leader>vx', '<cmd>Xh<CR>', { desc = '[X]h HTTP Client' })
vim.keymap.set('n', '<leader>vw', '<cmd>Watch<CR>', { desc = '[W]atchexec Continuous Daemon' })
vim.keymap.set('n', '<leader>vj', '<cmd>Jless<CR>', { desc = '[J]less JSON Viewer' })

-- [[ GoJQ Live Scratchpad ]]
-- This command pipes the current buffer into gojq and displays the result in a split.
-- It turns Neovim into a native, high-performance JSON query tool.
vim.api.nvim_create_user_command('Jq', function(opts)
  local utils = require('core.utils')
  local gojq = utils.mise_shim('gojq')
  
  if not gojq then
    utils.soft_notify('gojq is missing! Install via mise.', vim.log.levels.WARN)
    return
  end

  -- Default to '.' (identity) if no query is provided
  local query = opts.args == '' and '.' or opts.args

  -- Extract the current buffer's contents into a single string
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local input = table.concat(lines, '\n')

  -- Execute gojq synchronously. 
  -- Anti-Fragility: We wait for the process to finish and capture stdout/stderr natively.
  local obj = vim.system({ gojq, query }, { stdin = input, text = true }):wait()

  if obj.code ~= 0 then
    utils.soft_notify('gojq error: ' .. (obj.stderr or 'Unknown error'), vim.log.levels.ERROR)
    return
  end

  -- Populate native quickfix list first
  local qf_items = {}
  local output_lines = vim.split(obj.stdout, '\n')
  for i, line in ipairs(output_lines) do
    table.insert(qf_items, { text = line, lnum = i, filename = 'gojq-output' })
  end
  vim.fn.setqflist(qf_items, 'r')

  -- Then open in Trouble or native quickfix
  local has_trouble, _ = pcall(require, 'trouble')
  if has_trouble then
    vim.cmd('Trouble quickfix toggle')
  else
    vim.cmd('copen')
  end
  vim.notify('JQ Query: ' .. query, vim.log.levels.INFO)
end, { nargs = '?', desc = 'Run gojq on current buffer' })

-- [[ Sd: Surgical Buffer Replace ]]
-- Uses the 'sd' CLI tool (a modern sed replacement) to perform regex
-- replacements on the current buffer with standard regex syntax.
vim.api.nvim_create_user_command('Sd', function(opts)
  local utils = require('core.utils')
  local sd = utils.mise_shim('sd')
  if not sd then return end
  
  local args = vim.split(opts.args, ' ')
  if #args < 2 then
    utils.soft_notify('Usage: :Sd <find> <replace>', vim.log.levels.WARN)
    return
  end
  
  local find, replace = args[1], args[2]
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local input = table.concat(lines, '\n')
  
  local obj = vim.system({ sd, find, replace }, { stdin = input, text = true }):wait()
  if obj.code == 0 then
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(obj.stdout, '\n'))
    vim.notify('sd: Replaced "' .. find .. '" with "' .. replace .. '"', vim.log.levels.INFO)
  else
    utils.soft_notify('sd error: ' .. (obj.stderr or 'Unknown'), vim.log.levels.ERROR)
  end
end, { nargs = '+', desc = 'Surgical replace via sd' })

-- [[ Xh: HTTP Playground ]]
-- Pipes arguments (or the current line) to 'xh' and displays the result in a split.
-- Great for testing APIs without leaving the editor.
vim.api.nvim_create_user_command('Xh', function(opts)
  local utils = require('core.utils')
  local xh = utils.mise_shim('xh')
  if not xh then return end
  
  local cmd = { xh, '--color=always' }
  for _, arg in ipairs(vim.split(opts.args, ' ')) do
    if arg ~= "" then table.insert(cmd, arg) end
  end
  
  -- If no args provided, use the current line as the URL/command
  if #cmd == 2 then table.insert(cmd, vim.api.nvim_get_current_line()) end

  local obj = vim.system(cmd, { text = true }):wait()
  vim.cmd('vnew')
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buftype, vim.bo[buf].bufhidden = 'nofile', 'wipe'
  
  local output = obj.stdout ~= "" and obj.stdout or obj.stderr
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(output, '\n'))
  
  -- Basic auto-filetype detection for the response buffer
  if output:find('^{') or output:find('^%[') then 
    vim.bo[buf].filetype = 'json' 
  elseif output:find('<html') then
    vim.bo[buf].filetype = 'html'
  end
end, { nargs = '*', desc = 'Execute HTTP request via xh' })

-- [[ Typos-CLI to Quickfix Pipeline ]]
-- Uses 'typos' to scan the entire project for spelling errors in code.
-- It filters for 'typo' types in the JSON output and populates the Quickfix list.
vim.api.nvim_create_user_command('Typos', function()
  local utils = require('core.utils')
  local typos = utils.mise_shim('typos')
  if not typos then 
    utils.soft_notify('typos is missing. Install via cargo/mise.', vim.log.levels.WARN)
    return 
  end

  -- Run typos-cli in JSON mode over the entire project
  local obj = vim.system({ typos, '--format', 'json' }, { text = true }):wait()
  
  if obj.stdout == '' then
    vim.notify('No typos found project-wide!', vim.log.levels.INFO)
    return
  end

  local qf_items = {}
  for _, line in ipairs(vim.split(obj.stdout, '\n')) do
    if line ~= '' then
      local ok, data = pcall(vim.json.decode, line)
      if ok and data.type == 'typo' then
        table.insert(qf_items, {
          filename = data.path,
          lnum = data.line_num,
          col = data.byte_offset,
          -- Format the quickfix text: "Typo: 'teh' -> the"
          text = string.format("Typo: '%s' -> %s", data.typo, table.concat(data.corrections, ", ")),
        })
      end
    end
  end

  if #qf_items > 0 then
    vim.fn.setqflist(qf_items, 'r')
    local has_trouble, _ = pcall(require, 'trouble')
    if has_trouble then
        vim.cmd('Trouble quickfix toggle')
    else
        vim.cmd('copen') -- Open the quickfix window automatically
    end
  else
    vim.notify('No typos found!', vim.log.levels.INFO)
  end
end, { desc = 'Populate Quickfix with project typos' })

vim.keymap.set('n', '<leader>xt', '<cmd>Typos<CR>', { desc = 'Run Project [T]ypos' })

-- [[ Watchexec Continuous Daemon ]]
-- Marries watchexec with a horizontal toggleterm for a zero-friction TDD loop.
vim.api.nvim_create_user_command('Watch', function(opts)
  local utils = require('core.utils')
  local watchexec = utils.mise_shim('watchexec')
  if not watchexec then return end

  if opts.args == '' then
    utils.soft_notify('Usage: :Watch <command>', vim.log.levels.WARN)
    return
  end

  local Terminal = require('toggleterm.terminal').Terminal
  local watcher = Terminal:new({
    -- -c clears the screen before each run. `--` separates watchexec flags from your command.
    cmd = watchexec .. ' -c -- ' .. opts.args,
    direction = 'horizontal',
    hidden = false,
    close_on_exit = false,
  })
  
  watcher:toggle()
end, { nargs = '+', desc = 'Run command continuously on file changes via watchexec' })

-- [[ Jless: Structural JSON Explorer ]]
-- Suspends the current buffer and opens the file in jless (a Rust-based structural JSON viewer)
-- in a new tab for deep navigation of massive files.
vim.api.nvim_create_user_command('Jless', function()
  local utils = require('core.utils')
  local jless = utils.mise_shim('jless')
  if not jless then return end

  local file = vim.fn.expand('%:p')
  if file == '' or not vim.fn.filereadable(file) then
    utils.soft_notify('Current buffer is not a readable file on disk.', vim.log.levels.WARN)
    return
  end

  -- Use Neovim's native terminal for a full-tab takeover.
  vim.cmd('tabnew')
  vim.fn.termopen(jless .. ' ' .. vim.fn.shellescape(file), {
    on_exit = function()
      -- Automatically close the tab when jless exits
      vim.cmd('tabclose')
    end
  })
  vim.cmd('startinsert')
end, { desc = 'Open current JSON file in jless' })
