-- [[ TELEMETRY DOMAIN: STATUSLINE ]]
-- Plugin: echasnovski/mini.statusline
-- Architecture: Passive State Reflection & Context-Aware Polling
--
-- PHILOSOPHY: Eliminate telemetry bloat. The UI should only display actionable
-- intelligence. We strip legacy file encodings and redundant language names,
-- distilling the right side down to Motions, LSP Name, and Toolchain Version.

local M = {}
local utils = require('core.utils')

local ok, err = pcall(function()
	local MiniDeps = require('mini.deps')

	-- 1. Register Engine
	MiniDeps.add('echasnovski/mini.statusline')
	local statusline = require('mini.statusline')

	-- 2. Context-Aware Tool Mapping (O(1) Lookup)
	local ft_to_tool = {
		python          = "python",
		javascript      = "node",
		typescript      = "node",
		javascriptreact = "node",
		typescriptreact = "node",
		go              = "go",
		rust            = "rust",
		zig             = "zig",
		ruby            = "ruby",
		php             = "php",
		java            = "java",
		lua             = "lua",
		c               = "clang",
		cpp             = "clang",
	}

	-- 3. Non-Blocking Context Poller (Version Only)
	local telemetry_group = vim.api.nvim_create_augroup("MiniStatuslineTelemetry", { clear = true })
	if vim.fn.executable('mise') == 1 then
		vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "DirChanged" }, {
			group = telemetry_group,
			callback = function(event)
				local buf = event.buf
				if not vim.api.nvim_buf_is_valid(buf) or vim.b[buf]._mise_polling then return end

				local ft = vim.bo[buf].filetype
				local target_tool = ft_to_tool[ft]

				if not target_tool then
					vim.b[buf].mise_status = ""
					vim.cmd('redrawstatus')
					return
				end

				vim.b[buf]._mise_polling = true

				vim.system({ 'mise', 'current', target_tool }, { text = true }, function(out)
					if out.code == 0 and out.stdout and out.stdout ~= "" then
						-- Sanitize output: Strip newlines and grab just the version
						-- E.g., '5.1\n' becomes 'v5.1'
						local version = out.stdout:gsub("\n", ""):gsub("%s+$", "")
						-- Fallback regex just in case mise returns 'tool@version'
						version = version:match("([^@%s]+)$") or version

						vim.b[buf].mise_status = "🛠 " .. version
					else
						vim.b[buf].mise_status = ""
					end

					vim.schedule(function()
						if vim.api.nvim_buf_is_valid(buf) then
							vim.b[buf]._mise_polling = false
							vim.cmd('redrawstatus')
						end
					end)
				end)
			end,
			desc = "Targeted Mise Version Poller"
		})
	end

	-- 4. Custom Render Pipeline
	local function render_telemetry()
		local mode, mode_hl  = statusline.section_mode({ trunc_width = 120 })
		local git            = statusline.section_git({ trunc_width = 40 })
		local diagnostics    = statusline.section_diagnostics({ trunc_width = 75 })
		local filename       = statusline.section_filename({ trunc_width = 140 })
		local location       = statusline.section_location({ trunc_width = 75 })

		-- Keystroke / Motion Telemetry
		-- %10S pads the command to 10 characters so the statusline doesn't
		-- jitter left and right as you type different length commands.
		local showcmd        = '%10S'

		-- Intelligent LSP Attach Tracker
		local lsp_status     = ""
		local active_clients = vim.lsp.get_clients({ bufnr = 0 })
		if #active_clients > 0 then
			lsp_status = "⚡ " .. active_clients[1].name
		end

		local mise_status = vim.b.mise_status or ""

		-- 5. Strict Positional Rendering
		--
		return statusline.combine_groups({
			-- Left: Mode, Git, Diagnostics
			{ hl = mode_hl,                 strings = { mode } },
			{ hl = 'MiniStatuslineDevinfo', strings = { git, diagnostics } },

			'%<', -- Truncation point

			-- Center: File Context
			{ hl = 'MiniStatuslineFilename', strings = { filename } },

			'%=', -- Right Alignment

			-- Right: Motions -> Intelligence -> Location
			{ hl = 'MiniStatuslineFilename', strings = { showcmd } },
			{ hl = 'MiniStatuslineDevinfo',  strings = { lsp_status, mise_status } },
			{ hl = mode_hl,                  strings = { location } },
		})
	end

	statusline.setup({
		content = { active = render_telemetry },
		use_icons = true,
		set_vim_settings = false,
	})

	-- Ensure C-core routes motions to the statusline
	vim.opt.showcmdloc = 'statusline'
end)

-- 6. Diagnostics
if not ok then
	if utils and utils.soft_notify then
		utils.soft_notify('Statusline engine failure: ' .. err, vim.log.levels.ERROR)
	else
		vim.notify('Statusline engine failure: ' .. err, vim.log.levels.ERROR)
	end
end

return M
