# Neovim Workflow Cheatsheet

## Core Vim Muscle Memory

| Key Chord | Mode | Action / Command | Definition File |
| :--- | :---: | :--- | :--- |
| `ciw` / `caw` | N | Change inner word / change a word (includes trailing space) | `Native` |
| `dap` / `yap` | N | Delete / yank a paragraph | `Native` |
| `%` | N | Jump to matching bracket/parenthesis | `Native` |
| `qq` / `@q` | N | Record macro to register `q` / Play macro from register `q` | `Native` |
| `m[a-z]` / `'[a-z]`| N | Set local mark / Jump to local mark | `Native` |
| `0` / `^` / `$` | N | Jump to start of line / first non-blank character / end of line | `Native` |
| `gg` / `G` | N | Jump to top of file / bottom of file | `Native` |
| `*` / `#` | N | Search forward / backward for word under cursor | `Native` |
| `C` / `D` | N | Change / Delete from cursor to the end of the line | `Native` |

## Three-Tiered Navigation (Zoxide, Telescope, Mini.files, Yazi, Harpoon 2)

| Key Chord | Mode | Action / Command | Definition File |
| :--- | :---: | :--- | :--- |
| **Tier 1 (Global)** | | | |
| `<leader>cd` | N | Telescope: [C]hange [D]irectory (Zoxide) | `plugins/telescope.lua` |
| **Tier 2 (Discovery)** | | | |
| `<leader>ff` | N | Telescope: [F]ind [F]iles (Discovery) | `plugins/telescope.lua` |
| `<leader>e` | N | Mini.files: Open explorer in current global `cwd` | `plugins/mini.lua` |
| `-` | N | Mini.files: Open parent directory (relative) | `plugins/mini.lua` |
| `<leader>y` | N | Yazi: Open File Manager | `plugins/yazi.lua` |
| **Tier 3 (Action)** | | | |
| `<leader>a` | N | Harpoon: [A]dd File to list | `plugins/harpoon.lua` |
| `<leader>hc` | N | Harpoon: Toggle Quick Menu | `plugins/harpoon.lua` |
| `<M-1>` | N | Harpoon: Navigate to File 1 (Instant) | `plugins/harpoon.lua` |
| `<M-2>` | N | Harpoon: Navigate to File 2 (Instant) | `plugins/harpoon.lua` |
| `<M-3>` | N | Harpoon: Navigate to File 3 (Instant) | `plugins/harpoon.lua` |
| `<M-4>` | N | Harpoon: Navigate to File 4 (Instant) | `plugins/harpoon.lua` |
| `<leader>H` | N | Harpoon: [H]arpoon [C]lear all marks | `plugins/harpoon.lua` |

## Buffer, Window & Session Management

| Key Chord | Mode | Action / Command | Definition File |
| :--- | :---: | :--- | :--- |
| `<C-h>` | N/T | Smart Splits: Move focus to the left split/pane | `plugins/smart-splits.lua` |
| `<C-l>` | N/T | Smart Splits: Move focus to the right split/pane | `plugins/smart-splits.lua` |
| `<C-j>` | N/T | Smart Splits: Move focus to the lower split/pane | `plugins/smart-splits.lua` |
| `<C-k>` | N/T | Smart Splits: Move focus to the upper split/pane | `plugins/smart-splits.lua` |
| `[b` / `]b` | N | Buffer navigation (Previous / Next) | `plugins/mini.lua` |
| `[q` / `]q` | N | Quickfix navigation (Previous / Next) | `plugins/mini.lua` |

## Core Editing & Text Objects (Mini.ai, Mini.surround, Tabout)

| Key Chord | Mode | Action / Command | Definition File |
| :--- | :---: | :--- | :--- |
| `<Esc>` | N | Clear search highlights (`:nohlsearch`) | `core/keymaps.lua` |
| `j` / `k` | N | Smart visual line movement (`gj`/`gk`) for soft-wrapped text | `core/keymaps.lua` |
| `<Up/Down/Left/Right>` | N/V | **Disabled**. Triggers warning to enforce `hjkl` usage | `core/keymaps.lua` |
| `<M-h/j/k/l>` | N/V | Move visually selected text or single line in any direction | `plugins/mini.lua` |
| `v a )` | N | Select around parentheses (Mini.ai) | `plugins/mini.ai` |
| `y i n q` | N | Yank inside next quote (Mini.ai) | `plugins/mini.ai` |
| `s a i w )` | N | Add parentheses around inner word (Mini.surround) | `plugins/mini.surround` |
| `s d '` | N | Delete surrounding single quotes (Mini.surround) | `plugins/mini.surround` |
| `<C-l>` | I | Deterministic jump right/out of brackets (Bypasses Autocomplete) | `plugins/tabout.lua` |
| `<leader>re` | V/X | [R]efactor [E]xtract Function | `plugins/refactoring.lua` |
| `<leader>rf` | V/X | [R]efactor Extract [F]unction to File | `plugins/refactoring.lua` |
| `<leader>rv` | V/X | [R]efactor Extract [V]ariable | `plugins/refactoring.lua` |
| `<leader>ri` | N/V/X | [R]efactor [I]nline Variable | `plugins/refactoring.lua` |
| `<leader>rr` | N/V/X | [R]efactor [R]ing (Telescope) | `plugins/refactoring.lua` |

## Code Intelligence (LSP, Go To, Hover, Renaming, Trouble, Typos)

| Key Chord | Mode | Action / Command | Definition File |
| :--- | :---: | :--- | :--- |
| `<leader>q` | N | Open diagnostic [Q]uickfix list | `core/keymaps.lua` |
| `grn` | N | LSP: [R]e[n]ame | `plugins/lsp.lua` |
| `gra` | N/X | LSP: [G]oto Code [A]ction | `plugins/lsp.lua` |
| `grr` | N | LSP: [G]oto [R]eferences (Telescope) | `plugins/lsp.lua` |
| `gri` | N | LSP: [G]oto [I]mplementation (Telescope) | `plugins/lsp.lua` |
| `grd` | N | LSP: [G]oto [D]efinition (Telescope) | `plugins/lsp.lua` |
| `grD` | N | LSP: [G]oto [D]eclaration | `plugins/lsp.lua` |
| `gO` | N | LSP: Open Document Symbols (Telescope) | `plugins/lsp.lua` |
| `gW` | N | LSP: Open Workspace Symbols (Telescope) | `plugins/lsp.lua` |
| `grt` | N | LSP: [G]oto [T]ype Definition (Telescope) | `plugins/lsp.lua` |
| `<leader>th` | N | LSP: [T]oggle Inlay [H]ints | `plugins/lsp.lua` |
| `<leader>f` | N/V | [F]ormat buffer (Async, Native-First) | `core/format.lua` |
| `:Typos` | N | Project-wide spell check (Quickfix) | `core/commands.lua` |
| `<leader>xx` | N | Diagnostics (Trouble) toggle | `plugins/ui.lua` |
| `<C-space>` | I | Blink: Show/hide documentation | `plugins/completion.lua` |
| `<C-e>` | I | Blink: Hide menu | `plugins/completion.lua` |
| `<CR>` | I | Blink: Accept | `plugins/completion.lua` |
| `<Tab>` / `<S-Tab>` | I | Blink: Select next/prev item | `plugins/completion.lua` |
| `<C-n>` / `<C-p>` | I | Blink: Select next/prev item | `plugins/completion.lua` |
| `<C-b>` / `<C-f>` | I | Blink: Scroll documentation up/down | `plugins/completion.lua` |

## Embedded Execution (Toggleterm, CLI Integrations)\n\n| Key Chord | Mode | Action / Command | Definition File |\n| :--- | :---: | :--- | :--- |\n| `<C-\\>` | N/T | Toggle Terminal | `plugins/toggleterm.lua` |\n| `<leader>tp` | N | Toggle [P]rocess Monitor (btm) | `plugins/toggleterm.lua` |\n| `<leader>pb` | N | PlatformIO: [B]uild Project | `plugins/toggleterm.lua` |\n| `<leader>pu` | N | PlatformIO: [U]pload Firmware | `plugins/toggleterm.lua` |\
| `<leader>pm` | N | PlatformIO: Device [M]onitor | `plugins/toggleterm.lua` |\n| `<leader>pc` | N | PlatformIO: Update [C]ompilation Database | `plugins/toggleterm.lua` |\n| `<leader>tm` | N | Toggle [M]arkdown Preview (glow) | `plugins/toggleterm.lua` |\n| `<leader>ts` | N | Toggle [S]potify Player | `plugins/toggleterm.lua` |\n| `<leader>ta` | N | Toggle [A]ider AI Chat (context-aware) | `plugins/toggleterm.lua` |\n| `<leader>ti` | N | Toggle [I]nfrastructure (podman-tui) | `plugins/toggleterm.lua` |\n| `:Watch <cmd>` | N | Run command continuously on file changes | `core/commands.lua` |\n| `<Esc><Esc>`| T | Exit terminal mode (`<C-\\><C-n>`) | `core/keymaps.lua` |\n
## Hardware Debugging (nvim-dap, lldb-dap, dap-ui)\n\n| Key Chord | Mode | Action / Command | Definition File |\n| :--- | :---: | :--- | :--- |\n| `<F5>` | N | Debug: Start/Continue | `plugins/debug.lua` |\n| `<leader>b` | N | Debug: Toggle Breakpoint | `plugins/debug.lua` |\n| `<leader>B` | N | Debug: Set Breakpoint (Prompts for condition) | `plugins/debug.lua` |\n| `<leader>du` | N | Debug: Toggle UI | `plugins/debug.lua` |\n| `<leader>dr` | N | Debug: Toggle REPL | `plugins/debug.lua` |\n
## Version Control & CLI Integrations

| Key Chord | Mode | Action / Command | Definition File |
| :--- | :---: | :--- | :--- |
| `<leader>gg` | N | Lazy[G]it [G]UI | `plugins/lazygit.lua` |
| `<leader>gd` | N | Toggle [G]it [D]iff overlay | `plugins/mini.lua` |
| `:ToolCheck` | N | Scan for missing binaries (`mise`) | `core/commands.lua` |
| `:Jq` | N | `gojq` on current buffer | `core/commands.lua` |
| `:Sd` | N | `sd` (regex replace) on current buffer | `core/commands.lua` |
| `:Xh` | N | `xh` (HTTP client) on current line/args | `core/commands.lua` |
| `:Jless` | N | `jless` on current JSON file (new tab) | `core/commands.lua` |
| `:Typos` | N | `typos-cli` (Quickfix list) | `core/commands.lua` |

---

## CLI Workflow Integrations

| Key Chord | Mode | Action / Command | Definition File |
| :--- | :---: | :--- | :--- |
| `<leader>y` | N | Yazi File Manager | `plugins/yazi.lua` |
| `<leader>u` | N | Zenith UI Layouts | `plugins/ui_utils.lua` |
| `<leader>z` | N | Cheatsheet | `plugins/ui_utils.lua` |
| `<leader>tm` | N | Toggle Markdown Preview (glow) | `plugins/toggleterm.lua` |
| `<leader>ts` | N | Toggle Spotify Player | `plugins/toggleterm.lua` |
| `<leader>ta` | N | Toggle Aider AI Chat | `plugins/toggleterm.lua` |
| `<leader>ti` | N | Toggle Infrastructure (podman-tui) | `plugins/toggleterm.lua` |
| `:ToolCheck` | N | Scan for missing binaries (`mise`) | `core/commands.lua` |
| `:Jq` | N | `gojq` on current buffer | `core/commands.lua` |
| `:Sd` | N | `sd` (regex replace) on current buffer | `core/commands.lua` |
| `:Xh` | N | `xh` (HTTP client) on current line/args | `core/commands.lua` |
| `:Jless` | N | `jless` (structural JSON viewer) | `core/commands.lua` |
| `:Watch <cmd>` | N | `watchexec` (continuous command execution) | `core/commands.lua` |
| `:Typos` | N | `typos-cli` (project-wide spell check) | `core/commands.lua` |

---

## ⚠️ Architectural Conflicts

1. **`s` Key Override (Mini.surround):**
   - `mini.surround` maps `s` (e.g., `saiw)`) which shadows the native Vim `s` command (Substitute character). Retrain muscle memory to use `cl` or map `mini.surround` to a distinct prefix.

2. **`<C-l>` Multimodal Overloading:**
   - Normal mode: Window right (`core/keymaps.lua`).
   - Insert mode: Deterministic escape hatch for `tabout.nvim` (`plugins/tabout.lua`). Modal context separation makes this safe, but mind the mental shift.

3. **`<Esc>` Native Override:**
   - Normal mode: Mapped to `<cmd>nohlsearch<CR>` (`core/keymaps.lua`). Masks the native terminal bell/escape sequence but greatly improves usability.

4. **`<C-e>` Menu Collision:**
   - Insert mode: Hides completion menu in `blink.cmp`.
   - Normal mode: Toggles Harpoon quick menu (`plugins/harpoon.lua`). Safe modal separation.
