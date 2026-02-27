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
4. **Imperative Plugin Management (Mini.deps):** `lazy.nvim` has been purged in favor of `mini.deps`. Plugins are now loaded imperatively with explicit `MiniDeps.add()` calls, often via JIT keymap/command stubs or self-destructing autocommands, ensuring a sub-30ms "time to interactive."

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

This configuration uses a strictly categorized modular structure to separate core editor logic from plugin-specific setup, mirroring the functional groups in this README.

```plaintext
~/.config/nvim/
├── init.lua
└── lua/
    ├── core/
    │   ├── settings/
    │   │   ├── options.lua
    │   │   ├── keymaps.lua
    │   │   ├── autocmds.lua
    │   │   └── commands.lua
    │   ├── format.lua
    │   └── lint.lua
    ├── plugins/
    │   ├── ui/
    │   │   ├── init.lua      # Noice, Nui setup
    │   │   ├── colors.lua
    │   │   ├── which-key.lua
    │   │   └── treesitter.lua
    │   ├── lsp/
    │   │   ├── init.lua      # Core lspconfig
    │   │   └── completion.lua # blink.cmp
    │   ├── editing/
    │   │   ├── mini.lua      # mini.nvim loader
    │   │   ├── mini/         # individual mini modules
    │   │   ├── smart-splits.lua
    │   │   ├── refactoring.lua
    │   │   ├── tabout.lua
    │   │   └── indent.lua
    │   ├── finding/
    │   │   └── telescope.lua
    │   ├── git/
    │   │   └── lazygit.lua
    │   ├── workflow/
    │   │   ├── harpoon.lua
    │   │   ├── toggleterm.lua
    │   │   ├── vim-be-good.lua
    │   │   └── yazi.lua
    │   ├── notetaking/
    │   │   ├── obsidian.lua  # JIT-loaded Obsidian
    │   │   ├── luasnips.lua  # JIT-loaded Snippet Engine
    │   │   ├── history.lua   # mini.visits & extra
    │   └── dap/
    │       └── debug.lua
    └── snippets/
        └── latex.lua         # Massive 150+ Snippet Payload
```

## 4. The Plugin Ecosystem

### Core LSP, Completion & Formatting (Native-First)
- **`neovim/nvim-lspconfig`**: Core setup for Language Server Protocol integrations. Now directly configures `vim.lsp.config`.
- **`saghen/blink.cmp`**: High-performance, low-latency autocompletion engine (with native snippet engine). Loaded on `VimEnter`. Keymaps: `<C-j>` (next), `<C-k>` (prev), `<C-l>` (accept).
- **`folke/lazydev.nvim`**: Specialized setup for Neovim Lua API completions (dependency for `blink.cmp`).
- **`rafamadriz/friendly-snippets`**: Standard boilerplate snippets for all languages (dependency for `blink.cmp`).
- **`j-hui/fidget.nvim`**: Unobtrusive UI for LSP progress (the spinner in the corner).
- **Native Formatting Bridge (`core/format.lua`)**: Replaces `conform.nvim`. Uses `vim.system()` for CLI formatters (`stylua`, `oxfmt`, `markdownlint-cli2`) and `vim.lsp.buf.format()` for LSP-driven formatting, with cursor position preservation.
- **Native Diagnostic Bridge (`core/lint.lua`)**: Replaces `mfussenegger/nvim-lint`. Uses `vim.system()` to run async CLI linters (`shellcheck`, `markdownlint-cli2`) and injects results into `vim.diagnostic.set()`.

### Notetaking & Second Brain (JIT-Loaded)
- **`epwalsh/obsidian.nvim`**: Zero-overhead integration. Bootstrapped only when opening Markdown files or via `<leader>o` stubs. Integrated with `mini.pick` to prevent Telescope bloat. Keymaps: `<leader>oq` (Quick Switch), `<leader>os` (Search), `<leader>on` (New Note), `gf` (Follow Link), `<leader>ov` (V-Split Link), `<leader>oh` (H-Split Link).
- **`L3MON4D3/LuaSnip`**: High-performance, LaTeX auto-expansion engine. JIT loaded only for Markdown/TeX files to preserve sub-30ms startup. Keymaps: `<Tab>` (expand/jump), `<S-Tab>` (jump back).
- **`LaTeX Suite (snippets/latex.lua)`**: A custom, 200+ snippet payload for sub-millisecond LaTeX entry, featuring context-aware math zone detection, programmatic Greek and symbol generation, boundary-safe operators (e.g., `in`, `sum`), auto-backslashing, and visual wrappers (e.g., `underbrace`).
- **`mini.visits` & `mini.extra`**: Automated history tracking for files. Keymaps: `<leader>fr` (Find Recent), `<leader>fc` (Contextual History), `<leader>so` (Omnisearch).

### Navigation & Core Editing
- **`mrjones2014/smart-splits.nvim`**: Seamlessly navigates between Neovim splits and Zellij panes for both movement (`<C-h/j/k/l>`) and resizing (`<M-h/j/k/l>`). Utilizes a hotswap stub pattern to defer loading.
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
  - `mini.statusline`: High-performance statusline with `mise` environment status. 
  - `mini.tabline`: Minimalist tabline.
  - `mini.files`: Fast, tree-style file explorer.
  - `mini.pick`: Omnisearch and Obsidian integration.
- **`ThePrimeagen/refactoring.nvim`**: Advanced, automated codebase refactoring (extract, inline, etc.). Deferred via keymap stubs.
- **`ThePrimeagen/harpoon`**: Instant file marking and jumping. Uses Alt (Meta) keys.

### Telescope (Fuzzy Finding)
- **`nvim-telescope/telescope.nvim`**: Highly extensible fuzzy finder for files, strings, and LSP symbols. Deferred via JIT keymap stubs. Keymaps: `<leader>ff` (Find Files), `<leader>rr` (LSP References), `<leader>gd` (LSP Definitions), `<leader>ws` (LSP Workspace Symbols).
- **`jvgrootveld/telescope-zoxide`**: Integration with Zoxide for rapid directory hopping. Keymap: `<leader>cd` (Change Directory).
- **`nvim-telescope/telescope-fzf-native.nvim`**: C-port of fzf for dramatically faster Telescope searches.
- **`nvim-telescope/telescope-ui-select.nvim`**: Reroutes standard Neovim UI popups into Telescope.

### Git Integration
- **`kdheepak/lazygit.nvim`**: Terminal UI for Git. Gracefully mapped to your `mise` binary. Deferred via keymap stub. Keymap: `<leader>gg`.
- **`mini.diff` (part of `mini.nvim`)**: Shows git diff markers in the gutter and provides a toggleable diff overlay. Keymap: `<leader>gd`.

### UI & Aesthetics
- **`catppuccin/nvim` (Mocha)**: Primary high-contrast, modern colorscheme. Immediately loaded.
- **`folke/noice.nvim`**: Modern, high-contrast floating UI for the command line, search, and messages. Loaded on `VimEnter`.
- **`folke/which-key.nvim`**: Popup keybinding discovery menu. Deferred via `VimEnter` autocmd. Keymap: `<leader>?` (Show Workflow Cheatsheet).

### Utilities & Diagnostics (CLI Integrations)
- **`NMAC427/guess-indent.nvim`**: Detects and applies the correct indentation size. Deferred via `BufReadPre`.
- **`gojq` (`:Jq`)**: Live scratchpad to query JSON. Command: `:Jq <query>`.
- **`ouch` (Transparent Archive Explorer)**: Intercepts archive file openings (`.zip`, `.tar.gz`, etc.) and displays contents. Automatic.
- **`sd` (`:Sd`)**: Surgical regex find-and-replace. Command: `:Sd <find> <replace>`.
- **`xh` (`:Xh`)**: HTTP client. Command: `:Xh <request_args>`.
- **`glow` (`<leader>tm`)**: Floating Markdown preview. Keymap: `<leader>tm`.
- **`aider-chat` (`<leader>ta`)**: Context-aware AI pair programmer. Keymap: `<leader>ta`.
- **`watchexec` (`:Watch`)**: Continuous execution daemon. Command: `:Watch <command>`.
- **`podman-tui` (`<leader>ti`)**: Floating TUI for container management. Keymap: `<leader>ti`.
- **`jless` (`:Jless`)**: Structural JSON viewer. Command: `:Jless`.
- **`typos-cli` (`:Typos`)**: Project-wide spell checker. Command: `:Typos`.
- **`bottom` (`<leader>vp`)**: CLI process monitor.
- **`spotify_player` (`<leader>vs`)**: CLI Spotify player.

### Debugging (DAP)
- **`mfussenegger/nvim-dap`**: Core Debug Adapter Protocol client. Keymap: `<F5>` (Start/Continue), `<leader>b` (Toggle Breakpoint), `<leader>du` (Toggle UI).
- **`rcarriga/nvim-dap-ui`**: Visual debugging interface overlay.
- **PlatformIO Hardware Debug**: Restored custom configuration for LLDB/OpenOCD. Deferred via keymap stubs.

## 5. Neovim Key Notation (Cheat Sheet)

- **`<C-...>`**: Control key (e.g., `<C-l>` means `Ctrl + l`)
- **`<M-...>`** / **`<A-...>`**: Meta or Alt key (e.g., `<M-j>` means `Alt + j`)
- **`<S-...>`**: Shift key (e.g., `<S-Tab>` means `Shift + Tab`)
- **`<CR>`**: Carriage Return (the `Enter` key)
- **`<Esc>`**: Escape key
- **`<leader>`**: The designated Leader key (mapped to **`Spacebar`**).

## 6. Three-Tiered Navigation Architecture

1. **Tier 1: Global Layer (Zoxide)**: Macro-navigation between projects via `<leader>cd`.
2. **Tier 2: Discovery Layer (Telescope / Mini.files)**: Locating files within a project via `<leader>ff` or `<leader>e` (`-` for parent directory).
3. **Tier 3: Action Layer (Harpoon 2)**: Instant jumps between tight coupled files via `<leader>a` (add) and `Ctrl-1` to `Ctrl-4` (jump).

## 7. Key Workflows

### Obsidian JIT Flow
Pressing `<leader>oq`, `<leader>os`, or `<leader>on` dynamically boots Obsidian.nvim, configures your vault at `~/Documents/Obsidian`, and executes the command. Opening any Markdown file also triggers an automatic, once-per-session boot to ensure note-taking tools are ready. Buffer-local keymaps like `gf` (follow link) and `<leader>ov`/`<leader>oh` (split links) are available within notes.

### Omnisearch & History
- **`<leader>so`**: [S]earch [O]mni. Uses `mini.pick` and `ripgrep` for full-text indexing across the vault.
- **`<leader>fr`**: [F]ind [R]ecent Files (Global).
- **`<leader>fc`**: [F]ind [C]ontextual (Directory-scoped visits).

### The Dependency Audit (`:ToolCheck`)
Run `:ToolCheck` to scan for required binaries. It provides a pass/fail checklist and `mise install` commands for missing tools.

### Smart Auto-Pair & Tab-Out
`mini.pairs` handles closing. `<Tab>` expands LuaSnip snippets or jumps to the next node. `<S-Tab>` jumps to the previous node. `<C-l>` is the **Deterministic Escape Hatch** that unconditionally jumps out of brackets without triggering snippets.

### AI & Continuous Execution
- **AI Pair Programmer (`<leader>ta`)**: Toggles a floating terminal with `aider-chat`. The current file's path is automatically injected into `aider`'s context.
- **Continuous Execution (`:Watch <cmd>`)**: Uses `watchexec` to re-run commands (e.g., tests) on file save.

## ⚠️ Architectural Conflicts

1. **`s` Key Override (Mini.surround):** `mini.surround` maps `s` (e.g., `saiw)`) which shadows the native Vim `s` command (Substitute character). Retrain muscle memory to use `cl` or map `mini.surround` to a distinct prefix.
2. **`<C-l>` Multimodal Overloading:** In Normal mode, it moves focus to the right window (`plugins/editing/smart-splits.lua`). In Insert mode, it's the Deterministic Escape Hatch for `tabout.nvim` (`plugins/editing/tabout.lua`). Modal context separation makes this safe, but mind the mental shift.
3. **`<Esc>` Native Override:** In Normal mode, it clears search highlights (`:nohlsearch`). Masks the native terminal bell/escape sequence but greatly improves usability.
4. **`<C-e>` Completion Overloading:** In Insert mode, it hides the completion menu in `blink.cmp`. This is safe modal separation.
