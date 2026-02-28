-- [[ SYSTEM DEPENDENCY BOOTSTRAPPER ]]
-- Location: lua/core/deps.lua
--
-- STRATEGY: Imperative Package Management

local M = {}
local utils = require 'core.utils'

-- 1. Path Definition
local deps_path = vim.fn.stdpath 'data' .. '/mini.deps'

-- 2. Automated Installation (The Bootstrap)
if not vim.loop.fs_stat(deps_path) then
  vim.notify('Installing mini.deps...', vim.log.levels.INFO)
  vim.fn.system { 'git', 'clone', '--filter=blob:none', 'https://github.com/echasnovski/mini.deps', deps_path }
end

-- 3. Runtime Integration
vim.opt.rtp:prepend(deps_path)

-- [[ PROFILER INJECTION (Conditional) ]]
-- Only runs if the Neovim command is prefixed with PROFILE=1
if vim.env.PROFILE then
  local snacks_path = deps_path .. '/pack/deps/opt/snacks.nvim'
  if vim.loop.fs_stat(snacks_path) then
    vim.opt.rtp:prepend(snacks_path)
    local ok_snacks, snacks_profiler = pcall(require, 'snacks.profiler')
    if ok_snacks then
      snacks_profiler.startup()
    end
  end
end

local ok, mini_deps = pcall(require, 'mini.deps')
if ok then
  mini_deps.setup { path = { package = deps_path } }
  _G.MiniDeps = mini_deps
end

return M
