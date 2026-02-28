-- [[ Core User Commands ]]coman
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
    table.insert(lines,
      '*(For true system dependencies like `make`, `gcc`, use your system package manager if mise cannot install them)*')
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

-- [[ Eradicate Search Highlights ]]
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR><Esc>', { desc = 'Clear search highlights' })

-- [[ Context Exfiltration (Yank Paths) ]]
vim.keymap.set('n', '<leader>yp', function()
  local path = vim.fn.expand('%:p')
  vim.fn.setreg('+', path)
  vim.notify('Copied Absolute Path:\n' .. path, vim.log.levels.INFO)
end, { desc = '[Y]ank Absolute [P]ath' })

vim.keymap.set('n', '<leader>yr', function()
  local path = vim.fn.expand('%:~:.')
  vim.fn.setreg('+', path)
  vim.notify('Copied Relative Path:\n' .. path, vim.log.levels.INFO)
end, { desc = '[Y]ank [R]elative Path' })

-- [[ LSP Defibrillator ]]
vim.keymap.set('n', '<leader>ur', '<cmd>LspRestart<CR>', { desc = '[U]tils [R]estart LSP' })

-- [[ Output Capture Engine ]]
vim.api.nvim_create_user_command('Redir', function(ctx)
  local output = vim.fn.execute(ctx.args)
  vim.cmd('vnew')
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(output, '\n'))
end, { nargs = '+', complete = 'command', desc = 'Redirect command output to buffer' })

-- Usage example: :Redir messages

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
vim.api.nvim_create_user_command('Xh', function(opts)
  -- ... (previous setup code) ...

  local obj = vim.system(cmd, { text = true }):wait()
  vim.cmd('vnew')
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buftype, vim.bo[buf].bufhidden = 'nofile', 'wipe'

  -- DEFENSIVE GUARD: Ensure we have a string, even if it's an empty one.
  -- This satisfies the LSP's "Need check nil" warning.
  local output = (obj.stdout ~= "" and obj.stdout) or obj.stderr or ""
  -- Now vim.split is guaranteed to receive a string
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(output, '\n'))

  -- Basic auto-filetype detection
  -- We check if output is empty before calling :find to be safe
  if output ~= "" then
    if output:find('^{') or output:find('^%[') then
      vim.bo[buf].filetype = 'json'
    elseif output:find('<html') then
      vim.bo[buf].filetype = 'html'
    end
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

-- [[ Watchexec Continuous Daemon (Zellij Integrated with % Expansion) ]]
vim.api.nvim_create_user_command('Watch', function(opts)
  local utils = require('core.utils')
  local watchexec = utils.mise_shim('watchexec')
  if not watchexec then return end

  if opts.args == '' then
    utils.soft_notify('Usage: :Watch <command>', vim.log.levels.WARN)
    return
  end

  -- ERROR CORRECTION: Expand the '%' symbol to the absolute file path
  local cmd_args = opts.args
  if cmd_args:match("%%") then
    local current_file = vim.fn.expand('%:p')
    if current_file == "" then
      utils.soft_notify('No file currently open to expand %', vim.log.levels.WARN)
      return
    end
    -- Replace '%' with the shell-escaped file path
    cmd_args = cmd_args:gsub("%%", vim.fn.shellescape(current_file))
  end

  -- Construct the Zellij command
  local zellij_cmd = string.format("zellij run -d right -- %s -c -- %s", watchexec, cmd_args)

  -- Execute silently in the background
  vim.fn.system(zellij_cmd)

  vim.notify("Spawned watcher in Zellij: " .. cmd_args, vim.log.levels.INFO)
end, { nargs = '+', desc = 'Run command continuously in Zellij via watchexec' })

vim.keymap.set('n', '<leader>cx', function()
  local ft = vim.bo.filetype
  local cmd = ""

  if ft == "python" then
    cmd = "uv run %"
  elseif ft == "c" then
    -- Compile to a temporary binary and run it
    -- Using %:r to get the filename without the .c extension
    local output = vim.fn.expand('%:r')
    cmd = string.format("gcc %% -o %s && ./%s", output, output)
  elseif ft == "cpp" then
    local output = vim.fn.expand('%:r')
    cmd = string.format("g++ %% -o %s && ./%s", output, output)
    -- ... rest of your filetypes
  end

  vim.cmd("Watch " .. cmd)
end, { desc = "[C]ode execute in Zellij Split" })

-- [[ Interactive Single-Run (Bypasses Daemon) ]]
vim.keymap.set('n', '<leader>cr', function()
  local ft = vim.bo.filetype
  local file = vim.fn.expand('%:p') -- Absolute path to current file
  local cmd = ""

  if ft == "python" then
    -- Interactive uv run
    cmd = string.format("uv run %s", vim.fn.shellescape(file))
  elseif ft == "c" then
    local output = vim.fn.expand('%:r')
    -- For compound commands (&&), we wrap it in bash -c so Zellij parses it correctly
    cmd = string.format("bash -c \"gcc %s -o %s && ./%s\"", vim.fn.shellescape(file), output, output)
  elseif ft == "cpp" then
    local output = vim.fn.expand('%:r')
    cmd = string.format("bash -c \"g++ %s -o %s && ./%s\"", vim.fn.shellescape(file), output, output)
  else
    vim.notify("No interactive runner for " .. ft, vim.log.levels.WARN)
    return
  end

  -- Fire directly to Zellij, bypassing watchexec
  local zellij_cmd = string.format("zellij run -d right -- %s", cmd)
  vim.fn.system(zellij_cmd)
end, { desc = "[C]ode [R]un (Interactive) in Zellij" })

-- [[ Xh: HTTP Playground ]]
vim.api.nvim_create_user_command('Xh', function(opts)
  -- ... (previous setup code) ...

  local obj = vim.system(cmd, { text = true }):wait()
  vim.cmd('vnew')
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buftype, vim.bo[buf].bufhidden = 'nofile', 'wipe'

  -- DEFENSIVE GUARD: Ensure we have a string, even if it's an empty one.
  -- This satisfies the LSP's "Need check nil" warning.
  local output = (obj.stdout ~= "" and obj.stdout) or obj.stderr or ""
  -- Now vim.split is guaranteed to receive a string
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(output, '\n'))

  -- Basic auto-filetype detection
  -- We check if output is empty before calling :find to be safe
  if output ~= "" then
    if output:find('^{') or output:find('^%[') then
      vim.bo[buf].filetype = 'json'
    elseif output:find('<html') then
      vim.bo[buf].filetype = 'html'
    end
  end
end, { nargs = '*', desc = 'Execute HTTP request via xh' })

-- [[ Buffer Navigation (The Safe Way) ]]
-- Slide left and right through your open files on the tabline
vim.keymap.set('n', 'H', '<cmd>bprevious<CR>', { desc = 'Go to Previous Buffer' })
vim.keymap.set('n', 'L', '<cmd>bnext<CR>', { desc = 'Go to Next Buffer' })

-- [[ Buffer Close ]]
-- We use <leader>bd (Buffer Delete) for this.
-- This native function safely deletes the buffer without collapsing your Zellij/smart-splits layout.
vim.keymap.set('n', '<leader>bd', function()
  local current = vim.api.nvim_get_current_buf()

  -- If there's only one buffer left, just open an empty one before deleting
  if #vim.fn.getbufinfo({ buflisted = 1 }) == 1 then
    vim.cmd('enew')
  else
    vim.cmd('bprevious')
  end

  vim.cmd('bdelete! ' .. current)
end, { desc = '[B]uffer [D]elete' })

-- [[ Zellij Multiplexer Management (<leader>z) ]]
-- Uses Zellij's RPC CLI to create panes outside of Neovim.
-- Once created, you use your existing <C-h/j/k/l> (smart-splits) to navigate into them.

vim.keymap.set('n', '<leader>zv', function()
  vim.fn.system('zellij action new-pane -d right')
end, { desc = '[Z]ellij Split [V]ertical' })

vim.keymap.set('n', '<leader>zs', function()
  vim.fn.system('zellij action new-pane -d down')
end, { desc = '[Z]ellij [S]plit (Horizontal)' })

vim.keymap.set('n', '<leader>zf', function()
  vim.fn.system('zellij action new-pane -f')
end, { desc = '[Z]ellij [F]loating Pane' })

vim.keymap.set('n', '<leader>zq', function()
  -- Caution: If Neovim is the only process in the current pane, this will kill Neovim.
  vim.fn.system('zellij action close-pane')
end, { desc = '[Z]ellij [Q]uit Current Pane' })


-- [[ Diagnostic Hover ]]
-- Show the error message when your cursor stays on a line for a moment.
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, { focusable = false, scope = "cursor" })
  end,
})
-- Lower the delay from the default 4000ms to 500ms for "Groundbreaking" speed.
vim.opt.updatetime = 500

-- [[ Diagnostic Discovery Toggles ]]

-- Toggle Virtual Text (Inline messages)
vim.keymap.set('n', '<leader>dL', function()
  local current = vim.diagnostic.config().virtual_text
  vim.diagnostic.config({ virtual_text = not current })
  vim.notify("Virtual Text: " .. (not current and "ON" or "OFF"))
end, { desc = '[T]oggle [V]irtual Text' })

-- Toggle Underlines
vim.keymap.set('n', '<leader>dU', function()
  local current = vim.diagnostic.config().underline
  vim.diagnostic.config({ underline = not current })
  vim.notify("Underlines: " .. (not current and "ON" or "OFF"))
end, { desc = '[T]oggle [U]nderlines' })

-- [[ Diagnostic Quickfix ]]
vim.keymap.set('n', '<leader>q', function()
  -- If you have Trouble.nvim (from your 'x' group), use that.
  -- Otherwise, use the native quickfix.
  local has_trouble, _ = pcall(require, 'trouble')
  if has_trouble then
    vim.cmd('Trouble diagnostics toggle')
  else
    vim.diagnostic.setqflist()
  end
end, { desc = '🗒️ Open diagnostic [Q]uickfix list' })
