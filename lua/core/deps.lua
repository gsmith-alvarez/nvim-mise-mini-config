-- [[ SYSTEM DEPENDENCY BOOTSTRAPPER ]]
-- Location: lua/core/deps.lua
--
-- STRATEGY: Imperative Package Management
-- This module ensures the presence of 'mini.deps' and initializes the
-- global 'MiniDeps' handle used by all other plugin modules.

local M = {}
local utils = require('core.utils')

-- 1. Path Definition
local deps_path = vim.fn.stdpath('data') .. '/mini.deps'

-- 2. Automated Installation (The Bootstrap)
if not vim.loop.fs_stat(deps_path) then
	vim.notify("Installing mini.deps...", vim.log.levels.INFO)
	vim.fn.system({ 'git', 'clone', '--filter=blob:none', 'https://github.com/echasnovski/mini.deps', deps_path })
end

-- 3. Runtime Integration
vim.opt.rtp:prepend(deps_path)

-- 4. Protected Initialization
local ok, mini_deps = pcall(require, 'mini.deps')
if ok then
	mini_deps.setup({ path = { package = deps_path } })
	-- Export the handle for global use across your config
	_G.MiniDeps = mini_deps
else
	utils.soft_notify("CRITICAL: mini.deps failed to initialize.", vim.log.levels.ERROR)
end

return M
