-- [[ TYPST-PREVIEW: Instant Visual Feedback ]]
-- Using chomosuke/typst-preview.nvim
--
-- Logic: This plugin communicates directly with the Tinymist binary
-- to provide incremental rendering (milliseconds-fast updates).

local M = {}
local utils = require('core.utils')

local ok, err = pcall(function()
	local MiniDeps = require('mini.deps')
	MiniDeps.add('chomosuke/typst-preview.nvim')
end)
if not ok then
	utils.soft_notify('Failed to load typst-preview: ' .. err, vim.log.levels.ERROR)
	return M
end

local has_typst, typst_preview = pcall(require, 'typst-preview')
if not has_typst then return M end

local tinymist_bin = utils.mise_shim('tinymist') or "tinymist"

typst_preview.setup({
	-- THE ENGINE: Explicitly define the binaries since you aren't using Mason
	-- Replace these strings with absolute paths if they aren't in your $PATH
	bin = tinymist_bin,  -- The LSP/Preview runner
	preview_args = {
		"--port", "9527", -- Fixed port to avoid collisions
		"--input", "main.typ", -- Common entry point
	},

	-- THE INTERFACE
	follow_cursor = true, -- Groundbreaking: Preview scrolls with your Nvim cursor
	invert_colors = "auto", -- Matches your theme's luminosity automatically

	-- THE ROOT PROTOCOL
	-- Essential for multi-file projects so the compiler knows where the "brain" is.
	get_root = function(path)
		local root_files = { 'main.typ', 'typst.toml', '.git' }
		local root = vim.fs.dirname(vim.fs.find(root_files, { path = path, upward = true })[1])
		return root or path
	end,

	-- THE BROWSER
	-- Leave empty to use system default, or specify (e.g., "firefox", "chromium")
	open_cmd = nil,
})

utils.soft_notify('Typst preview setup complete', vim.log.levels.INFO)

-- [[ KEYMAPS ]]
-- Mapped to <leader>tp for "Typst Preview"
vim.api.nvim_create_autocmd("FileType", {
	pattern = "typst",
	callback = function()
		vim.keymap.set("n", "<leader>tp", "<cmd>TypstPreview<cr>",
			{ buffer = true, desc = "Typst: Open Preview" })
		vim.keymap.set("n", "<leader>tc", "<cmd>TypstPreviewStop<cr>",
			{ buffer = true, desc = "Typst: Stop Preview" })

		-- "Sync" map: Force the preview to jump to your current cursor position
		vim.keymap.set("n", "<leader>ts", "<cmd>TypstPreviewSync<cr>",
			{ buffer = true, desc = "Typst: Sync Preview" })
	end,
})

return M
