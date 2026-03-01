It's kind of broken right now I have to go through things fyi

# Ground Truth Neovim Configuration

This README documents the architecture, logic, keybindings, and dependencies of this high-performance, net-multiplier Neovim configuration.

## The Architecture Map

```lua
-- /home/gsmith-alvarez/.config/nvim/
-- ├───init.lua
-- └───lua/
--     ├───autocmd/
--     │   ├───basic.lua
--     │   ├───external.lua
--     │   ├───init.lua
--     │   └───jit.lua
--     ├───commands/
--     │   ├───auditing.lua
--     │   ├───building.lua
--     │   ├───diagnostics.lua
--     │   ├───init.lua
--     │   ├───mux.lua
--     │   └───utilities.lua
--     ├───core/
--     │   ├───deps.lua
--     │   ├───format.lua
--     │   ├───init.lua
--     │   ├───keymaps.lua
--     │   ├───libs.lua
--     │   ├───lint.lua
--     │   ├───options.lua
--     │   └───utils.lua
--     └───plugins/
--         ├───dap/
--         │   ├───debug.lua
--         │   ├───init.lua
--         │   ├───nvim-dap-virtual-text.lua
--         │   └───persistent-breakpoint.lua
--         ├───editing/
--         │   ├───inc-rename.lua
--         │   ├───indent.lua
--         │   ├───indentscope.lua
--         │   ├───init.lua
--         │   ├───mini-ai.lua
--         │   ├───mini-hipatterns.lua
--         │   ├───mini-move.lua
--         │   ├───pairs.lua
--         │   ├───refactoring.lua
--         │   └───surround.lua
--         ├───finding/
--         │   ├───aerial.lua
--         │   ├───init.lua
--         │   └───telescope.lua
--         ├───git/
--         │   ├───diff.lua
--         │   ├───init.lua
--         │   └───lazygit.lua
--         ├───lsp/
--         │   ├───blink.lua
--         │   ├───init.lua
--         │   └───native-lsp.lua
--         ├───navigation/
--         │   ├───harpoon.lua
--         │   ├───history.lua
--         │   ├───mini-bracketed.lua
--         │   ├───mini-files.lua
--         │   ├───smart-splits.lua
--         │   ├───tabout.lua
--         │   └───yazi.lua
--         ├───notetaking/
--         │   ├───luasnips.lua
--         │   └───obsidian.lua
--         └───ui/
--             ├───mini-colors.lua
--             ├───mini-icons.lua
--             ├───mini-starter.lua
--             ├───mini-statusline.lua
--             ├───mini-tabline.lua
--             ├───noice.lua
--             ├───quotes.lua
--             ├───render-markdown.lua
--             ├───treesitter.lua
--             ├───trouble.lua
--             └───which-key.lua
--         └───workflow/
--             ├───init.lua
--             ├───overseer.lua
--             ├───persistence.lua
--             ├───toggleterm.lua
--             └───vim-be-good.lua
```

## The Logic Report

### `lua/core/deps.lua`
**Philosophy:** Imperative Package Management
Ensures the presence of 'mini.deps' and initializes the global 'MiniDeps' handle. It automates installation and manages the runtime path.

### `lua/core/format.lua`
**Philosophy:** Native-First Formatting Architecture
Bypasses "middleman" plugins for direct CLI/LSP control using `BufWritePre` and `vim.system`. Includes fallback formatting and whitespace eradication.

### `lua/core/init.lua`
**Philosophy:** Fault-Tolerant System Boot
Orchestrates core module loading via `pcall` to prevent cascading failures. Implements a self-correcting hot-reload mechanism.

### `lua/core/keymaps.lua`
**Philosophy:** Home-Row Efficiency
Prioritizes hands-on-home-row navigation and surgical window management.

### `lua/core/libs.lua`
**Philosophy:** Pre-emptive Injection
Ensures foundational libraries like `plenary.nvim` are available globally before high-level plugins load.

### `lua/core/lint.lua`
**Philosophy:** Native-First Diagnostic Bridge
Bypasses monolithic linting plugins by executing CLI linters asynchronously via `vim.system` and parsing results directly into Neovim diagnostics.

### `lua/core/options.lua`
**Philosophy:** Environment Prioritization
Prioritizes `mise` shims and configures essential editor behavior (numbers, clipboard, splits, encoding).

### `lua/core/utils.lua`
**Philosophy:** Anti-Fragility
Shared utilities for binary resolution (prioritizing `mise`) and persistent diagnostic logging.

### `lua/autocmd/basic.lua`
**Philosophy:** Protected Event Loops
Non-blocking hooks for UI feedback (yank highlight), layout (auto-resize), and I/O (auto-create directories).

### `lua/autocmd/external.lua`
**Philosophy:** Resource Protection
Uses "Defensive Interceptors" to handle massive files (disabling LSP/Treesitter) and binary archives (using `ouch` for listing).

### `lua/autocmd/init.lua`
**Philosophy:** Fault-Tolerant Module Loading
Dispatcher for all custom autocommands with instant hot-reloading on save.

### `lua/autocmd/jit.lua`
**Philosophy:** Asymmetric Resource Allocation
Implements stubs and proxy autocmds to defer loading heavy modules (Obsidian, LuaSnip) until required.

### `lua/commands/auditing.lua`
**Philosophy:** Dependency Auditing
Provides `:ToolCheck` for environment validation and `:Redir` for capturing command output.

### `lua/commands/building.lua`
**Philosophy:** Process Handoff
Offloads heavy compilation/execution to Zellij panes, keeping Neovim responsive.

### `lua/commands/diagnostics.lua`
**Philosophy:** Managed Intelligence
Toggles for visual noise (virtual text, underlines) and intelligent routing of workspace errors to Trouble/Quickfix.

### `lua/commands/init.lua`
**Philosophy:** Sandboxed Execution
Central dispatcher for user commands using `pcall` for absolute crash resistance.

### `lua/commands/mux.lua`
**Philosophy:** RPC-based Layout Control
Orchestrates terminal environments via Zellij's 'action' CLI instead of built-in terminals.

### `lua/commands/utilities.lua`
**Philosophy:** CLI Workbench
Transforms Neovim into a high-performance workbench for tools like `gojq`, `sd`, and `xh`.

### `lua/plugins/dap/debug.lua`
**Philosophy:** Action-Triggered Instrumentation
DAP remains dormant until a breakpoint is set. Includes PlatformIO-specific hardware debugging logic.

### `lua/plugins/dap/init.lua`
**Philosophy:** The "Second Brain" Principle
Dispatcher for the DAP domain with circuit-breaker loading.

### `lua/plugins/dap/nvim-dap-virtual-text.lua`
**Philosophy:** Zero-Latency State Mapping
Renders variable values directly in the buffer virtual space.

### `lua/plugins/editing/inc-rename.lua`
**Philosophy:** Precision JIT Loading
Loads LSP renaming logic only when `<leader>rn` is pressed.

### `lua/plugins/editing/indent.lua`
**Philosophy:** Defer to Buffer Read
Automatic indentation detection that activates only when a file is opened.

### `lua/plugins/editing/indentscope.lua`
**Philosophy:** Visual Indentation Feedback
Uses `mini.indentscope` for high-performance visual guides.

### `lua/plugins/editing/mini-hipatterns.lua`
**Philosophy:** Non-Blocking Visual Cues
Asynchronous semantic highlighting for patterns like TODO, FIXME, and HEX colors.

### `lua/plugins/editing/mini-move.lua`
**Philosophy:** Ergonomic Refactoring
Visual block movement with automatic scope-aware re-indentation.

### `lua/plugins/editing/pairs.lua`
**Philosophy:** Context-Aware Typing Automation
Managing auto-pairs with specific exclusions for terminal and command modes.

### `lua/plugins/editing/refactoring.lua`
**Philosophy:** Action-Driven JIT Execution
Heavy AST-based refactoring tools load only during active transformation tasks.

### `lua/plugins/editing/surround.lua`
**Philosophy:** Surroundings as Objects
Surgical manipulation of quotes, brackets, and tags using the `gz` prefix.

### `lua/plugins/finding/aerial.lua`
**Philosophy:** Spatial Awareness
Persistent, hierarchical view of symbols with Treesitter/LSP backends.

### `lua/plugins/finding/init.lua`
**Philosophy:** Centralized Discovery
Master orchestrator for search engines (Telescope, Aerial).

### `lua/plugins/git/diff.lua`
**Philosophy:** Immediate Context
Ambient awareness of Git changes via sign column cues.

### `lua/plugins/git/init.lua`
**Philosophy:** Ambient Versioning
Unified Git status and manipulation without context switching.

### `lua/plugins/git/lazygit.lua`
**Philosophy:** Seamless Context-Switch
Floating integration of the high-performance Lazygit TUI.

### `lua/plugins/lsp/blink.lua`
**Philosophy:** Pre-Emptive Capability Injection
High-performance autocompletion that broadcasts capabilities before servers attach.

### `lua/plugins/lsp/init.lua`
**Philosophy:** The "Second Brain" Principle
Dispatcher for the LSP domain with synchronous-priority completion.

### `lua/plugins/lsp/native-lsp.lua`
**Philosophy:** Native Capability Injection
Uses Neovim 0.10's native `vim.lsp.config` for the lowest possible memory overhead.

### `lua/plugins/navigation/harpoon.lua`
**Philosophy:** Stub and Hotswap
Stateless navigation that overwrites its own keymaps with high-performance native calls upon first use.

### `lua/plugins/navigation/history.lua`
**Philosophy:** Pain-Driven History
Navigates by recency and frequency via `mini.visits` and `mini.pick`.

### `lua/plugins/navigation/mini-bracketed.lua`
**Philosophy:** Implicit Structural Jumps
Native-feeling bracketed motions for buffers and diagnostics.

### `lua/plugins/navigation/smart-splits.lua`
**Philosophy:** Anti-Fragile Proxy Execution
Directional movement and resizing that bridges Neovim and Zellij.

### `lua/plugins/navigation/tabout.lua`
**Philosophy:** Seamless Typing Flow
Tab-driven escape hatch from brackets/quotes with intelligent completion yielding.

### `lua/plugins/notetaking/luasnips.lua`
**Philosophy:** JIT Setup
Aggressive snippet auto-expansion engine for Markdown and LaTeX.

### `lua/plugins/ui/mini-colors.lua`
**Philosophy:** Synchronous Safe Rendering
Catppuccin Mocha theme with robust native fallback.

### `lua/plugins/ui/mini-icons.lua`
**Philosophy:** Ubiquitous Visual Anchors
foundation icons with `nvim-web-devicons` polyfill.

### `lua/plugins/ui/mini-starter.lua`
**Philosophy:** Zero-Friction Ignition
Instant dashboard with dynamic quotes and project shortcuts.

### `lua/plugins/ui/mini-statusline.lua` / `mini-tabline.lua`
**Philosophy:** Peripheral Pattern Recognition
Minimalistheads-up display for editor state and workspace working set.

### `lua/plugins/ui/noice.lua`
**Philosophy:** Immediate UI Interception
Replaces legacy UI for messages, cmdline, and popups.

### `lua/plugins/workflow/init.lua`
**Philosophy:** Mise-en-Place
Ensures all tools and sessions are ready for use.

### `lua/plugins/workflow/overseer.lua`
**Philosophy:** Asynchronous Industrialization
Background task orchestration and project monitoring.

### `lua/plugins/workflow/persistence.lua`
**Philosophy:** Automatic State Recovery
Automated session management and workspace restoration.

### `lua/plugins/workflow/toggleterm.lua`
**Philosophy:** Action-Driven JIT Infrastructure
modular TUI factory for Lazygit, Spotify, and more.

### `lua/plugins/workflow/vim-be-good.lua`
**Philosophy:** Zero-Overhead Skill Development
Motion training engine that exists as a "Ghost Command" until used.

## The Keymap Registry

| Mode(s) | Keybind           | Description                         |
|---------|-------------------|-------------------------------------|
| n       | `<leader><space>` | Clear search highlights             |
| t       | `<Esc><Esc>`      | Exit terminal mode                  |
| n       | `<leader>wv`      | Window: [V]ertical Split            |
| n       | `<leader>ws`      | Window: [S]plit Horizontal          |
| n       | `<leader>wq`      | Window: [Q]uit Current              |
| n       | `<leader>wo`      | Window: [O]nly (Close others)       |
| n       | `<leader>w=`      | Window: [=] Equalize Sizes          |
| n       | `<leader>wx`      | Window: [X] Swap Next               |
| n       | `k`               | Move visually (word wrap)           |
| n       | `j`               | Move visually (word wrap)           |
| n       | `<leader>rn`      | [R]e[n]ame Symbol (JIT)             |
| n       | `<leader>?`       | Show Workflow Cheatsheet            |
| n, v    | `<leader>cf`      | ✨ [C]ode [F]ormat buffer           |
| n       | `<leader>oq`      | Obsidian: [Q]uick Switch (JIT)      |
| n       | `<leader>os`      | Obsidian: [S]earch Notes (JIT)      |
| n       | `<leader>on`      | Obsidian: [N]ew Note (JIT)          |
| n       | `<leader>ut`      | Tools: Check Toolchain (Mise)       |
| n       | `<leader>xt`      | Audit: Run Project [T]ypos          |
| n       | `<leader>cx`      | 󱓞 [C]ode [X]ecute (Continuous Watch)      |
| n       | `<leader>cr`      | 󰑮 [C]ode [R]un (Interactive)        |
| n       | `<leader>vw`      | View: [W]atchexec (Manual)          |
| n       | `<leader>dL`      | Diagnostics: Toggle Virtual [L]ines |\n| n       | `<leader>dU`      | Diagnostics: Toggle [U]nderlines    |\n| n       | `<leader>Dq`      | Diagnostics: Open [q]uickfix        |\n| n       | `<leader>zv`      | Zellij: Vertical Split              |\n| n       | `<leader>zs`      | Zellij: Horizontal Split            |\n| n       | `<leader>zf`      | Zellij: Floating Pane               |\n| n       | `<leader>zq`      | Zellij: Close Pane                  |\n| n       | `<leader>vq`      | JQ: Live Scratchpad                 |\n| n       | `<leader>sR`      | Search & [R]eplace (SD)             |\n| n       | `<leader>vx`      | XH: HTTP Client                     |\n| n       | `<leader>vj`      | JLess: JSON Viewer                  |\n| n       | `<leader>yp`      | [Y]ank Absolute [P]ath            |\n| n       | `<leader>yr`      | [Y]ank [R]elative Path            |\n| n       | `<leader>ur`      | Restart LSP                         |\n| n       | `H`               | Go to Previous Buffer               |\n| n       | `L`               | Go to Next Buffer                   |\n| n       | `<leader>bd`      | [B]uffer [D]elete                   |\n| n, x    | `<leader>rr`      | Refactor: Select (UI)               |\n| x       | `<leader>re`      | Refactor: Extract Variable          |\n| x       | `<leader>rf`      | Refactor: Extract Function          |\n| n, x    | `<leader>ri`      | Refactor: Inline Variable           |\n| v, V    | `<M-h/j/k/l>`     | Move highlighted block              |\n| n       | `gz[a/d/r/f/F/h/n]`| Surround manipulation              |\n| n       | `<leader>va`      | Toggle Aerial Structure             |\n| n       | `<leader>ff`      | Search: Find Files                  |\n| n       | `<leader>sg`      | Search: Live Grep                   |\n| n       | `]c` / `[c`       | Next/Prev Git Change                |\n| n       | `<leader>gg`      | Lazygit TUI                         |\n| n       | `<leader>db`      | Toggle Persistent Breakpoint        |\n| n       | `<leader>dc`      | Start/Continue Debugging            |\n| i       | `<C-j/k/l/h>`     | Completion navigation               |\n| n       | `<M-a>` / `<M-e>` | Harpoon: Mark / UI                  |\n| n       | `<leader>so`      | OmniSearch (Ripgrep)                |\n| n, t    | `<C-h/j/k/l>`     | Smart Pane Move                     |\n| n, t    | `<M-h/j/k/l>`     | Smart Pane Resize                   |\n| n       | `<leader>y`       | Yazi Explorer                       |\n| i, s    | `<C-j/k>`         | Snippet Expand/Jump                 |\n| n       | `<leader>Ot`      | Overseer: [T]oggle [O]verseer       |\n| n       | `<leader>Or`      | Overseer: Template [R]un            |\n| n       | `<leader>Oi`      | Overseer: Task Config [I]nfo        |\n| n       | `<leader>Oa`      | Overseer: Task [A]ction Menu        |\n| n       | `<leader>qs`      | Session: Restore Current            |\n| n       | `<leader>ql`      | Session: Restore Last               |\n| n, t    | `<C-\>`           | Toggle Terminal                     |\n| n       | `<leader>pb`      | PIO: Build Project                  |\n| n       | `<leader>pu`      | PIO: Upload Firmware                |\n| n       | `<leader>pm`      | PIO: Serial Monitor                 |\n| n       | `<leader>pc`      | PIO: Update [C]ompilation Database  |\n| n       | `<leader>tm`      | 📝 Markdown Preview                 |\n| n       | `<leader>ts`      | 🎧 Spotify Player                   |\n| n       | `<leader>tp`      | 📊 Process Monitor                  |\n| n       | `<leader>ta`      | 🤖 Aider AI Chat                    |\n| n       | `<leader>ti`      | 📦 Infrastructure (Podman)          |\n| n       | `<leader>th`      | 💡 LSP: Inlay Hints                 |\n| n       | `<leader>sd`      | Search: [D]iagnostics               |\n| n       | `<leader>sn`      | Search: [N]eovim files              |\n| n       | `<leader>sr`      | Search: [R]esume Last Search        |\n| n       | `<leader>ss`      | Search: [S]elect Telescope          |\n| n       | `<leader>sw`      | Search: [W]ord Under Cursor         |\n| n       | `<leader>sk`      | Search: [K]eymaps                   |\n| n       | `<leader>sh`      | Search: [H]elp Tags                 |\n| n       | `<leader>cd`      | [C]hange [D]irectory (Zoxide)     |\n| n       | `<leader>du`      | Toggle DAP UI                       |\n| n       | `<leader>dr`      | Toggle DAP REPL                     |\n| n       | `<leader><leader>` | [ ] Find existing buffers           |

## The Dependency Graph

### Plugins (via `mini.deps`)

*   `echasnovski/mini.deps` (Infrastructure)
*   `echasnovski/mini.icons` (Icons & Web-Devicons Polyfill)
*   `echasnovski/mini.nvim` (Provides: `ai`, `bracketed`, `diff`, `extra`, `files`, `hipatterns`, `indentscope`, `move`, `pairs`, `pick`, `starter`, `statusline`, `surround`, `tabline`, `visits`)
*   `nvim-lua/plenary.nvim` (Stdlib)
*   `folke/lazydev.nvim` (Lua API Intelligence)
*   `saghen/blink.cmp` (Completion Engine)
*   `neovim/nvim-lspconfig` (LSP Stub Registry)
*   `j-hui/fidget.nvim` (LSP Progress)
*   `nvim-treesitter/nvim-treesitter` (Parsing Engine)
*   `ThePrimeagen/harpoon` (Navigation)
*   `mrjones2014/smart-splits.nvim` (Multiplexer Integration)
*   `abecodes/tabout.nvim` (Typing Flow)
*   `mikavilpas/yazi.nvim` (File Management)
*   `L3MON4D3/LuaSnip` (Snippet Engine)
*   `epwalsh/obsidian.nvim` (Notetaking)
*   `catppuccin/nvim` (Colorscheme)
*   `folke/noice.nvim` (UI Replacement)
*   `folke/trouble.nvim` (Diagnostic Aggregator)
*   `folke/which-key.nvim` (Keymap Discovery)
*   `stevearc/overseer.nvim` (Task Runner)
*   `folke/persistence.nvim` (Session Management)
*   `akinsho/toggleterm.nvim` (Terminal Management)
*   `ThePrimeagen/vim-be-good` (Training)
*   `mfussenegger/nvim-dap` (Debugger)

### External Binaries (via `mise`)

*   **Languages/LSPs:** `pyright`, `ruff`, `rust-analyzer`, `gopls`, `zls`, `clangd`, `lua-language-server`, `marksman`, `taplo`, `bash-language-server`.
*   **Formatters/Linters:** `stylua`, `oxfmt`, `markdownlint-cli2`, `shellcheck`.
*   **Utilities:** `rg`, `fd`, `make`, `gcc`, `lazygit`, `btm`, `dlv`, `watchexec`, `uv`, `go`, `zig`, `zellij`, `gojq`, `sd`, `xh`, `eza`, `bat`, `zoxide`, `cargo`, `curl`, `spotify_player`, `podman-tui`, `aider`, `glow`, `pio`.
