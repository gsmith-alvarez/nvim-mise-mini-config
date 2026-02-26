# Neovim: Mise-First, Mason-Free Architecture

A high-performance, modular, and extremely resilient Neovim configuration engineered for deterministic toolchain management through a **Mise-First** approach and massive plugin consolidation via the **mini.nvim** ecosystem, managed imperatively with **mini.deps**.

## 1. Architectural Philosophy

This configuration completely purges `lazy.nvim`, `mason.nvim`, and bloated standalone plugins. It operates on four foundational pillars:

**Why remove Mason & Lazy.nvim?**
- **Deterministic Control:** Your toolchain is defined outside of Neovim with `mise`, and plugins are managed explicitly with `mini.deps`, ensuring consistency.
- **Environmental Purity:** Neovim acts strictly as a consumer of binaries. This avoids the common "it works in Neovim but not in my terminal" discrepancy.
- **Performance:** No runtime overhead from plugin-driven binary management (`mason`) or complex declarative plugin loading (`lazy.nvim`). `mini.deps` is a simple dependency fetcher, not a manager.

1. **Deterministic Environment (Mise):** Your toolchain (LSPs, linters, formatters, and debuggers) is defined outside of Neovim using the OS-level environment manager, [**mise**](https://mise.jdx.dev/). Neovim acts strictly as a consumer of these binaries, leveraging a native `mise_shim`.
2. **Graceful Degradation & Anti-Fragility:** Every external integration is wrapped in `require('core.utils').mise_shim('binary_name')` checks. If a binary is missing, Neovim suppresses Lua errors and boots cleanly, providing a warning or an itemized `:ToolCheck` audit report.
3. **Consolidated Core (Mini.nvim):** Dozens of plugins have been replaced by the modular `mini.nvim` ecosystem, dramatically improving startup time and UI cohesion.
4. **Imperative Plugin Management (Mini.deps):** `lazy.nvim` has been purged in favor of `mini.deps`. Plugins are now loaded imperatively with explicit `MiniDeps.add()` calls, often via JIT keymap/command stubs or self-destructing autocommands, ensuring a sub-30ms "time to interactive." Pain-Driven Learning: Native options disable the mouse and arrow keys to enforce keyboard-only mastery.

## 2. Prerequisites & Toolchain Setup

This configuration requires certain tools to be installed at the system level. **Note:** While `mise` is exceptional for managing runtimes (Node, Go, Python), it is not a system package manager. Core build tools must be installed via your OS package manager (e.g., `apt`, `dnf`, `brew`).

### System Dependencies
The following must be available in your system path:
- **Neovim (>= 0.10.0)**
- **Git** (For plugin cloning)
- **Make, GCC, or Clang** (Required to build native C components for plugins like `telescope-fzf-native` and `treesitter`)
- **A Nerd Font** (e.g., JetBrainsMono Nerd Font)
- **mise-en-place (mise)** (For all other toolchain management)

### Global Toolchain Setup (Mise)
To populate your environment with the required binaries, execute these commands:

```bash
# Install required core CLI utilities
mise install -g ripgrep fd lazygit bottom delve zoxide gojq sd xh typos watchexec ouch glow spotify_player aider podman-tui

# Install the language ecosystems
mise install -g node@latest python@latest go@latest rust@latest

# Install LSPs, Formatters, and Linters
mise install -g pyright ruff rust-analyzer bash-language-server \
            vscode-json-languageserver lua-language-server \
            marksman gopls typescript-language-server \
            stylua oxfmt markdownlint-cli2 shellcheck
```

*Note: On Linux, it is recommended to install `clangd` via your system package manager (e.g., `dnf install clang-tools-extra` or `apt install clangd`).*

## 3. Directory Structure

This configuration uses a strictly modular structure to separate core editor logic from plugin-specific setup. Every plugin has its own dedicated file (or logical grouping) for maximum maintainability.

```plaintext
~/.config/nvim/
├── init.lua
└── lua/
    ├── core/
    │   ├── options.lua
    │   ├── keymaps.lua
    │   ├── autocmds.lua
    │   ├── commands.lua
    │   ├── format.lua
    │   └── lint.lua
    └── plugins/
        ├── colors.lua
        ├── completion.lua
        ├── debug.lua
        ├── harpoon.lua
        ├── indent.lua
        ├── lazygit.lua
        ├── lsp.lua
        ├── mini/
        │   ├── ai.lua
        │   ├── bracketed.lua
        │   ├── diff.lua
        │   ├── files.lua
        │   ├── hipatterns.lua
        │   ├── icons.lua
        │   ├── indentscope.lua
        │   ├── move.lua
        │   ├── notify.lua
        │   ├── pairs.lua
        │   ├── statusline.lua
        │   ├── surround.lua
        │   └── tabline.lua
        ├── mini.lua
        ├── noice.lua
        ├── refactoring.lua
        ├── smart-splits.lua
        ├── tabout.lua
        ├── telescope.lua
        ├── toggleterm.lua
        ├── training.lua
        ├── treesitter.lua
        ├── ui.lua
        ├── ui_utils.lua
        ├── vim-be-good.lua
        ├── which-key.lua
        └── yazi.lua
``````

## 4. The Plugin Ecosystem

The following plugins are managed imperatively by `mini.deps` and native Neovim logic.

### Core LSP, Completion & Formatting (Native-First)
- **`neovim/nvim-lspconfig`**: Core setup for Language Server Protocol integrations. Now directly configures `vim.lsp.config`.
- **`saghen/blink.cmp`**: High-performance, low-latency autocompletion engine (with native snippet engine). Loaded on `VimEnter`.
- **`folke/lazydev.nvim`**: Specialized setup for Neovim Lua API completions (dependency for `blink.cmp`).
- **`rafamadriz/friendly-snippets`**: Standard boilerplate snippets for all languages (dependency for `blink.cmp`).
- **`j-hui/fidget.nvim`**: Unobtrusive UI for LSP progress (the spinner in the corner).
- **Native Formatting Bridge (`core/format.lua`)**: Replaces `conform.nvim`. Uses `vim.system()` for CLI formatters (`stylua`, `oxfmt`, `markdownlint-cli2`) and `vim.lsp.buf.format()` for LSP-driven formatting, with cursor position preservation.
- **Native Diagnostic Bridge (`core/lint.lua`)**: Replaces `mfussenegger/nvim-lint`. Uses `vim.system()` to run async CLI linters (`shellcheck`, `markdownlint-cli2`) and injects results into `vim.diagnostic.set()`.

### Pain-Driven Learning & Workflows
- **`ThePrimeagen/vim-be-good`**: A minigame training tool for practicing Vim motions. Deferred via command stub.

### Navigation & Core Editing
- **`mrjones2014/smart-splits.nvim`**: Seamlessly navigates between Neovim splits and Zellij panes for both movement (`<C-h/j/k/l>`) and resizing (`<M-h/j/k/l>`). Utilizes a hotswap stub pattern to defer loading and ensure Zellij binary checks via `mise_shim` for graceful degradation.- **`mini.files` (part of `echasnovski/mini.nvim`)**: Replaces `stevearc/oil.nvim`. File explorer that lets you edit the filesystem like a normal Neovim buffer. Scoped to global `cwd`. Keymaps: `<leader>e` (explorer in cwd), `-` (parent directory).
- **`abecodes/tabout.nvim`**: Uses `<Tab>` or `<C-l>` (Deterministic Escape Hatch) to seamlessly jump out of brackets and quotes. Immediately loaded.
- **`echasnovski/mini.nvim`**: Core editing suite replacing dozens of plugins:
  - `mini.ai`: Advanced text objects (`va)`, `yinq`).
  - `mini.surround`: Add/delete/replace surroundings (brackets, quotes).
  - `mini.pairs`: Minimal, fast auto-closing of brackets/quotes.
  - `mini.bracketed`: Essential `[ ]` navigation for buffers, quickfix, and history.
  - `mini.move`: Visual selection movement via `<Alt-hjkl>`. 
  - `mini.indentscope`: Visual vertical lines for indentation. 
  - `mini.icons`: Fast, cached icons (mocking `nvim-web-devicons`).
  - `mini.diff`: Git diff markers in the gutter and toggleable diff overlay. 
  - `mini.statusline`: Replaces `lualine.nvim` for a high-performance statusline with `mise` environment status.
  - `mini.tabline`: Replaces `bufferline.nvim` for a minimalist tabline.
  - `mini.notify`: Replaces `rcarriga/nvim-notify` for non-blocking notifications.
  - `mini.clue`: Replaces `folke/which-key.nvim` for keymap hints. 
- **`ThePrimeagen/refactoring.nvim`**: Advanced, automated codebase refactoring (extract, inline, etc.). Deferred via keymap stubs.

### Telescope (Fuzzy Finding)
- **`nvim-telescope/telescope.nvim`**: Highly extensible fuzzy finder for files, strings, and LSP symbols. Deferred via JIT keymap stubs.
- **`jvgrootveld/telescope-zoxide`**: Integration with Zoxide for rapid directory hopping (dependency for Telescope).
- **`nvim-telescope/telescope-fzf-native.nvim`**: C-port of fzf for dramatically faster Telescope searches (dependency for Telescope).
- **`nvim-telescope/telescope-ui-select.nvim`**: Reroutes standard Neovim UI popups into Telescope (dependency for Telescope).

### Git Integration
- **`kdheepak/lazygit.nvim`**: Terminal UI for Git. Gracefully mapped to your `mise` binary. Deferred via keymap stub.
- **`mini.diff` (part of `mini.nvim`)**: Shows git diff markers in the gutter and provides a toggleable diff overlay.

### UI & Aesthetics
- **`catppuccin/nvim` (Mocha)**: Primary high-contrast, modern colorscheme. Immediately loaded.
- **`folke/noice.nvim`**: Replaces the command line, LSP hover, and system messages with a modern, high-contrast floating UI. Deferred via `VimEnter` autocmd.
- **`folke/which-key.nvim`**: Popup keybinding discovery menu to help you learn your shortcuts, now with emojis. Deferred via `VimEnter` autocmd.
- **`folke/trouble.nvim`**: A pretty list/panel for all errors, warnings, and TODOs in your project. Deferred via `BufEnter` autocmd.
- **`nvim-treesitter/nvim-treesitter`**: Powerful AST parser for superior syntax highlighting and code structure analysis. Deferred via `BufReadPre`.
- **`mikavilpas/yazi.nvim`**: Rust-based terminal file manager (integrated via command stub for `<leader>y`).

### Utilities & Diagnostics (CLI Integrations)
- **`nvim-lua/plenary.nvim`**: Essential Lua utility library used by almost all major plugins.
- **`MunifTanjim/nui.nvim`**: UI component library (dependency for `noice`).
- **`NMAC427/guess-indent.nvim`**: Automatically detects and applies the correct indentation size. Deferred via `BufReadPre`.
- **`sudormrfbin/cheatsheet.nvim`**: A quick-reference cheatsheet for keybindings and commands. Deferred via keymap stub for `<leader>z`.
- **`gojq` (`:Jq`)**: Live scratchpad to query JSON directly from the current buffer into a split window.
- **`ouch` (Transparent Archive Explorer)**: Intercepts archive file openings (`.zip`, `.tar.gz`) and displays contents in a Neovim buffer.
- **`sd` (`:Sd`)**: Surgical regex find-and-replace on the current buffer with `sd`.
- **`xh` (`:Xh`)**: HTTP client to execute requests from the current line/arguments and display responses in a split.
- **`glow` (`<leader>tm`)**: Floating Markdown preview for the current buffer.
- **`spotify_player` (`<leader>ts`)**: Floating TUI for Spotify media control.
- **`aider-chat` (`<leader>ta`)**: Context-aware AI pair programmer in a floating terminal.
- **`watchexec` (`:Watch`)**: Continuous execution daemon for tests/builds in a horizontal split.
- **`podman-tui` (`<leader>ti`)**: Floating TUI for container management.
- **`jless` (`:Jless`)**: Structural JSON viewer for massive files in a new tab.
- **`typos-cli` (`:Typos`)**: Project-wide spell checker that populates the Quickfix list.

### Debugging (DAP)
- **`mfussenegger/nvim-dap`**: The core Debug Adapter Protocol client.
- **`rcarriga/nvim-dap-ui`**: A visual debugging interface overlay.
- **`nvim-neotest/nvim-nio`**: Asynchronous I/O library (required by `dap-ui`).
- **PlatformIO Hardware Debug**: Restored custom configuration for LLDB/OpenOCD. Deferred via keymap stubs.

## 5. Neovim Key Notation (Cheat Sheet)

If you are new to Neovim's documentation and keybindings, you will often see keystrokes represented in angle brackets. Here is how to read them:

- **`<C-...>`**: Control key (e.g., `<C-l>` means `Ctrl + l`)
- **`<M-...>`** / **`<A-...>`**: Meta or Alt key (e.g., `<M-j>` means `Alt + j`)
- **`<S-...>`**: Shift key (e.g., `<S-Tab>` means `Shift + Tab`)
- **`<CR>`**: Carriage Return (the `Enter` key)
- **`<Esc>`**: Escape key
- **`<leader>`**: The designated Leader key. In this configuration, it is mapped to the **`Spacebar`**. (e.g., `<leader>tp` means pressing `Spacebar`, then `t`, then `p`).

## 6. Three-Tiered Navigation Architecture

To eliminate cognitive friction, this configuration implements a strict hierarchical navigation system:

### Tier 1: Global Layer (Zoxide -> Telescope)
- **Tool:** `jvgrootveld/telescope-zoxide`
- **Action:** Changes Neovim's global working directory (`cd`) immediately.
- **Keymap:** `<leader>cd`
- **Purpose:** Macro-navigation between projects and major sub-directories.

### Tier 2: Discovery Layer (Telescope / Mini.files)
- **Tools:** `nvim-telescope/telescope.nvim` and `echasnovski/mini.nvim` (`mini.files` module)
- **Action:** Discover files within the current global state.
- **Keymaps:** `<leader>ff` (Find Files), `<leader>e` (Mini.files explorer in `cwd`), `-` (Mini.files explorer in parent directory).
- **Purpose:** Locating specific files within a scoped project context.

### Tier 3: Action Layer (Harpoon 2)
- **Tool:** `ThePrimeagen/harpoon` (harpoon2)
- **Action:** Volatile, high-speed micro-navigation between tightly coupled files.
- **Keymaps:** 
  - `<leader>a`: Add file to Harpoon.
  - `<leader>hc`: Toggle quick menu.
  - `Ctrl-1`, `Ctrl-2`, `Ctrl-3`, `Ctrl-4`: Instant jumps.
  - `<leader>H`: Clear all marks (Force Multiplier).
- **Purpose:** Eliminating all movement latency during active task execution.

## 7. Key Workflows

### The Dependency Audit (`:ToolCheck`)
Run `:ToolCheck` to scan your system for required binaries (`rg`, `fd`, `lazygit`, `btm`, `dlv`, `gojq`, `sd`, `xh`, `typos`, `watchexec`, `ouch`, `glow`, `spotify_player`, `aider`, `podman-tui`, and all LSPs). It opens a split buffer with a pass/fail checklist and provides copy-pasteable `mise install` commands for anything missing.

### Smart Auto-Pair & Tab-Out
When you type an opening bracket, `mini.pairs` closes it. To escape, you can press `<Tab>` (which yields gracefully to `blink.cmp`'s autocomplete menu). If you need absolute certainty, press `<C-l>` in Insert mode—this is the **Deterministic Escape Hatch** that unconditionally jumps out of brackets without triggering snippets.

### The Process Viewer (`<leader>tp`)
Pressing `<leader>tp` spawns a floating background terminal running `btm` (bottom). This gives you an AstroNvim-style system monitor that persists in the background across toggles.

### GoJQ Live Scratchpad (`:Jq <query>`)
Run `:Jq` (or `:Jq '.some.path'`) on a JSON buffer to pipe its contents through `gojq` and display the processed output in a new split. Turns Neovim into a real-time JSON query tool.

### Transparent Archive Explorer (Auto-Triggered)
Opening common archive files (`.zip`, `.tar.gz`, `.rar`, etc.) will automatically trigger `ouch l <file>` and display the archive contents directly in a Neovim buffer.

### Surgical Buffer Replace (`:Sd <find> <replace>`)
Use `:Sd` to perform lightning-fast, standard regex-based find-and-replace operations directly on the current buffer, leveraging the `sd` CLI tool.

### HTTP Playground (`:Xh <request_args>`)
Run `:Xh` (with `xh` arguments or just a URL on the current line) to execute HTTP requests via the `xh` CLI client. The colorized response is displayed in a new split buffer.

### Floating Markdown Preview (`<leader>tm`)
Press `<leader>tm` to toggle a floating terminal window that renders your current Markdown buffer into a beautiful, `glow`-powered preview.

### Spotify Media Control (`<leader>ts`)
Press `<leader>ts` to toggle a floating terminal window running `spotify_player`, allowing you to control your music directly from Neovim.

### AI Pair Programmer (`<leader>ta`)
Press `<leader>ta` to toggle a floating terminal running `aider-chat`. The current file's path is automatically injected into `aider`'s context, making it an instantly productive AI coding assistant.

### Continuous Execution Daemon (`:Watch <command>`)
Use `:Watch <command>` (e.g., `:Watch cargo test`) to spawn a horizontal `toggleterm` split that uses `watchexec` to automatically clear and re-run your specified command every time you save a file.

### Container Infrastructure Control (`<leader>ti`)
Press `<leader>ti` to toggle a floating terminal window running `podman-tui`, giving you a full-featured TUI for managing Podman containers, images, and networks directly within Neovim.

### Structural JSON Explorer (`:Jless`)
For massive JSON files, run `:Jless` to suspend Neovim and open the current buffer in `jless` (a Rust-based structural JSON viewer) in a new terminal tab, allowing efficient navigation of complex data.

### Project-Wide Spell Checker (`:Typos`)
Execute `:Typos` to run `typos-cli` across your entire project. It populates Neovim's Quickfix list with detected spelling errors, allowing for bulk corrections without intrusive in-buffer highlighting.
