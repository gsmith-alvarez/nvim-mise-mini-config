-- [[ Setting options ]]
-- See `:help vim.o`
--
-- This file contains the general configuration settings for Neovim.
-- These settings define the behavior and appearance of the editor.
--
-- Unlike standard Kickstart which places everything in `init.lua`,
-- this modular configuration isolates core Neovim options into this
-- dedicated file (`lua/core/options.lua`), keeping things organized.
--
-- NOTE: You can change these options as you wish!
-- For more options, you can see `:help option-list`

-- [[ Environment Setup ]]
-- Prepend mise shims to the path so Neovim finds mise-managed binaries first.
-- This ensures that when Neovim or any plugin tries to run an external command,
-- it hits the mise shims before any system-wide or Mason-installed versions.
local mise_shim_path = vim.fn.expand '~/.local/share/mise/shims'
if vim.fn.isdirectory(mise_shim_path) == 1 then
  vim.env.PATH = mise_shim_path .. ':' .. vim.env.PATH
end

-- Use mise-managed interpreters for Neovim's internal Node and Python providers.
-- This prevents Neovim from searching for system-wide versions that might not
-- have the necessary dependencies for Neovim plugins.
vim.g.python3_host_prog = vim.fn.expand '~/.local/share/mise/shims/python'
vim.g.node_host_prog = vim.fn.expand '~/.local/share/mise/shims/node'

-- [[ Leader Key configuration ]]
-- Set <space> as the leader key
-- See `:help mapleader`
-- NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
-- The "leader" key is a special prefix key used for custom keybindings.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
-- Nerd Fonts contain special icons used by many plugins to make Neovim look better!
vim.g.have_nerd_font = true

-- [[ Editor Behavior and UI ]]

-- Disable mouse support entirely to enforce keyboard-only navigation.
-- Using the mouse in Neovim slows down your workflow by forcing you to move
-- your hand away from the home row. Disabling it is the first step toward
-- true keyboard mastery.
vim.opt.mouse = ""

-- Make line numbers default and shown on the left side
vim.o.number = true
-- Enable relative line numbers, to help with jumping.
-- This creates a hybrid line number setup where the current line is absolute,
-- and all other lines are relative to the current line!
vim.o.relativenumber = true

-- Don't show the mode (e.g., "-- INSERT --") on the last line,
-- since it's already shown in the status line plugin (like lualine or mini.statusline).
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
-- This makes it so copying in Neovim copies to your computer's clipboard,
-- and pasting from your computer pastes into Neovim.
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- Enable break indent
-- When a line is wrapped, this ensures the wrapped line has the same indentation.
vim.o.breakindent = true

-- Save undo history
-- This lets you undo changes even after you close and reopen a file!
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
-- e.g., searching for "hello" matches "Hello", but searching for "Hello" only matches "Hello"
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
-- The signcolumn is the space to the left of the line numbers where git signs
-- and error icons are displayed. Keeping it always on prevents text from shifting.
vim.o.signcolumn = 'yes'

-- Decrease update time
-- Time in milliseconds before saving swap files or triggering `CursorHold` events.
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
-- Time in milliseconds to wait for a mapped key sequence to complete.
-- e.g., if you press the leader key, this is how long it waits for the next key.
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
-- When opening horizontal/vertical splits, where should they go?
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-options-guide`
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
-- When you type `:%s/foo/bar/g`, this shows you the changes before you hit enter!
vim.o.inccommand = 'split'

-- Show which line your cursor is on (adds a subtle background highlight)
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
-- This prevents the cursor from hitting the very top or bottom of the screen.
vim.o.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- [[ Soft Wrap Settings ]]
-- These settings control how long lines are displayed (wrapped) without actually
-- inserting newlines into your file.
vim.opt.wrap = true -- Enable soft wrapping
vim.opt.linebreak = true -- Wrap at words, not characters, so words aren't split
vim.opt.breakindent = true -- Wrapped lines retain indentation
vim.opt.showbreak = '↪ ' -- Visual marker for wrapped lines

-- [[ Concealing Latex/Mathjax Rendering ]]
-- Hides certain markup syntax elements for a cleaner look when viewing files like Markdown.
vim.opt.conceallevel = 2


vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
