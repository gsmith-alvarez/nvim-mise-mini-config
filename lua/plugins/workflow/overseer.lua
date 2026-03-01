-- [[ OVERSEER: Background Task Orchestration ]]
-- Domain: Workflow & Project Automation
--
-- PHILOSOPHY: Asynchronous Industrialization (JIT)
-- Don't wait for compilers or uploaders to finish. Overseer runs tasks
-- in the background. We defer its massive filesystem scanning until the
-- exact moment you request a task operation.

local M = {}
local utils = require('core.utils')

local loaded = false

-- [[ THE JIT ENGINE ]]
local function bootstrap_overseer()
  if loaded then return true end

  local ok, err = pcall(function()
    require('mini.deps').add('stevearc/overseer.nvim')

    require('overseer').setup({
      -- Strategy: Piped to Toggleterm (Ensure Toggleterm is installed)
      strategy = "toggleterm",

      -- We keep "builtin" to allow it to auto-detect Makefiles,
      -- VSCode tasks.json, and cargo files automatically when needed.
      templates = { "builtin" },

      task_list = {
        direction = "right",
        bindings = {
          ["<C-l>"] = false, -- Prevent collision with Smart-Splits navigation
          ["q"] = "Close",
        },
      },
    })
  end)

  if not ok then
    utils.soft_notify('Overseer Infrastructure failed: ' .. err, vim.log.levels.ERROR)
    return false
  end

  loaded = true
  return true
end

-- [[ THE PROXY KEYMAPS ]]
-- These stubs act as tripwires. The first time you press one, it installs/loads
-- Overseer, scans your directory for build files, and executes the command.

local actions = {
  { "<leader>Ot", "OverseerToggle",     "Task: [T]oggle [O]verseer" },
  { "<leader>Or", "OverseerRun",        "Task: Template [R]un" },
  { "<leader>Oi", "OverseerInfo",       "Task: Task Config [I]nfo" },
  { "<leader>Oa", "OverseerTaskAction", "Task: Task [A]ction Menu" },
}

for _, action in ipairs(actions) do
  vim.keymap.set("n", action[1], function()
    if bootstrap_overseer() then
      vim.cmd(action[2])
    end
  end, { desc = action[3] })
end

-- THE CONTRACT: Return the module to satisfy the Workflow Orchestrator
return M
