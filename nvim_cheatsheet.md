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
| `<leader>cd` | N | Telescope: [C]hange [D]irectory (Zoxide) | `plugins/finding/telescope.lua` |
| **Tier 2 (Discovery)** | | | |
| `<leader>ff` | N | Telescope: [F]ind [F]iles (Discovery) | `plugins/finding/telescope.lua` |
| `<leader>e` | N | Mini.files: Open explorer in current global `cwd` | `plugins/editing/mini/files.lua` |
| `-` | N | Mini.files: Open parent directory (relative) | `plugins/editing/mini/files.lua` |
| `<leader>y` | N | Yazi: Open File Manager | `plugins/workflow/yazi.lua` |
| **Tier 3 (Action)** | | | |
| `<leader>a` | N | Harpoon: [A]dd File to list | `plugins/workflow/harpoon.lua` |
| `<leader>hc` | N | Harpoon: Toggle Quick Menu | `plugins/workflow/harpoon.lua` |
| `Ctrl-1...4` | N | Harpoon: Navigate to Files 1-4 (Instant) | `plugins/workflow/harpoon.lua` |
| `<leader>H` | N | Harpoon: [H]arpoon [C]lear all marks | `plugins/workflow/harpoon.lua` |

## Notetaking & Second Brain (Obsidian, LuaSnip, History)

| Key Chord | Mode | Action / Command | Definition File |
| :--- | :---: | :--- | :--- |
| `<leader>oq` | N | Obsidian: [Q]uick Switch (Fuzzy find titles) | `plugins/notetaking/obsidian.lua` |
| `<leader>os` | N | Obsidian: [S]earch (Ripgrep Full Text) | `plugins/notetaking/obsidian.lua` |
| `<leader>on` | N | Obsidian: [N]ew Note | `plugins/notetaking/obsidian.lua` |
| `gf` | N | Obsidian: Follow link under cursor | `plugins/notetaking/obsidian.lua` |
| `<leader>ov` | N | Obsidian: Follow Link (Vertical Split) | `plugins/notetaking/obsidian.lua` |
| `<leader>oh` | N | Obsidian: Follow Link (Horizontal Split) | `plugins/notetaking/obsidian.lua` |
| `<leader>so` | N | History: [S]earch [O]mni (Full text vault search) | `plugins/notetaking/history.lua` |
| `<leader>fr` | N | History: [F]ind [R]ecent Files (Global) | `plugins/notetaking/history.lua` |
| `<leader>fc` | N | History: [F]ind [C]ontextual (Directory-scoped) | `plugins/notetaking/history.lua` |
| `<Tab>` | I/S | LuaSnip: Jump to next snippet node | `plugins/notetaking/luasnips.lua` |
| `<S-Tab>` | I/S | LuaSnip: Jump to previous snippet node | `plugins/notetaking/luasnips.lua` |

## Buffer, Window & Session Management

| Key Chord | Mode | Action / Command | Definition File |
| :--- | :---: | :--- | :--- |
| `<C-h>` | N/T | Smart Splits: Move focus to the left split/pane | `plugins/editing/smart-splits.lua` |
| `<C-l>` | N/T | Smart Splits: Move focus to the right split/pane | `plugins/editing/smart-splits.lua` |
| `<C-j>` | N/T | Smart Splits: Move focus to the lower split/pane | `plugins/editing/smart-splits.lua` |
| `<C-k>` | N/T | Smart Splits: Move focus to the upper split/pane | `plugins/editing/smart-splits.lua` |
| `[b` / `]b` | N | Buffer navigation (Previous / Next) | `plugins/editing/mini/bracketed.lua` |
| `[q` / `]q` | N | Quickfix navigation (Previous / Next) | `plugins/editing/mini/bracketed.lua` |

## Core Editing & Text Objects (Mini.ai, Mini.surround, Tabout)

| Key Chord | Mode | Action / Command | Definition File |
| :--- | :---: | :--- | :--- |
| `<Esc>` | N | Clear search highlights (`:nohlsearch`) | `core/settings/keymaps.lua` |
| `j` / `k` | N | Smart visual line movement (`gj`/`gk`) | `core/settings/keymaps.lua` |
| `<Up/Down/Left/Right>` | N/V | **Disabled**. Triggers warning to enforce `hjkl` usage | `core/settings/keymaps.lua` |
| `<M-h/j/k/l>` | N/V | Move visually selected text or single line in any direction | `plugins/editing/mini/move.lua` |
| `v a )` | N | Select around parentheses (Mini.ai) | `plugins/editing/mini/ai.lua` |
| `y i n q` | N | Yank inside next quote (Mini.ai) | `plugins/editing/mini/ai.lua` |
| `s a i w )` | N | Add parentheses around inner word (Mini.surround) | `plugins/editing/mini/surround.lua` |
| `s d '` | N | Delete surrounding single quotes (Mini.surround) | `plugins/editing/mini/surround.lua` |
| `<C-l>` | I | Deterministic jump right/out of brackets (Bypasses Autocomplete) | `plugins/editing/tabout.lua` |
| `<leader>re` | V/X | [R]efactor [E]xtract Function | `plugins/editing/refactoring.lua` |
| `<leader>rf` | V/X | [R]efactor Extract [F]unction to File | `plugins/editing/refactoring.lua` |
| `<leader>rv` | V/X | [R]efactor Extract [V]ariable | `plugins/editing/refactoring.lua` |
| `<leader>ri` | N/V/X | [R]efactor [I]nline Variable | `plugins/editing/refactoring.lua` |
| `<leader>rr` | N/V/X | [R]efactor [R]ing (Telescope) | `plugins/editing/refactoring.lua` |

## Code Intelligence (LSP, Go To, Hover, Renaming, Trouble, Typos)

| Key Chord | Mode | Action / Command | Definition File |
| :--- | :---: | :--- | :--- |
| `<leader>q` | N | Open diagnostic [Q]uickfix list | `core/settings/keymaps.lua` |
| `grn` | N | LSP: [R]e[n]ame | `plugins/lsp/init.lua` |
| `gra` | N/X | LSP: [G]oto Code [A]ction | `plugins/lsp/init.lua` |
| `grr` | N | LSP: [G]oto [R]eferences (Telescope) | `plugins/lsp/init.lua` |
| `gri` | N | LSP: [G]oto [I]mplementation (Telescope) | `plugins/lsp/init.lua` |
| `grd` | N | LSP: [G]oto [D]efinition (Telescope) | `plugins/lsp/init.lua` |
| `grD` | N | LSP: [G]oto [D]eclaration | `plugins/lsp/init.lua` |
| `gO` | N | LSP: Open Document Symbols (Telescope) | `plugins/lsp/init.lua` |
| `gW` | N | LSP: Open Workspace Symbols (Telescope) | `plugins/lsp/init.lua` |
| `grt` | N | LSP: [G]oto [T]ype Definition (Telescope) | `plugins/lsp/init.lua` |
| `<leader>th` | N | LSP: [T]oggle Inlay [H]ints | `plugins/lsp/init.lua` |
| `<leader>f` | N/V | [F]ormat buffer (Async, Native-First) | `core/format.lua` |
| `:Typos` | N | Project-wide spell check (Quickfix) | `core/format.lua` |
| `<leader>xx` | N | Diagnostics (Trouble) toggle | `plugins/ui/init.lua` |
| `<C-space>` | I | Blink: Show/hide documentation | `plugins/lsp/completion.lua` |
| `<C-e>` | I | Blink: Hide menu | `plugins/lsp/completion.lua` |
| `<CR>` | I | Blink: Accept | `plugins/lsp/completion.lua` |
| `<Tab>` / `<S-Tab>` | I | Blink: Select next/prev item | `plugins/lsp/completion.lua` |
| `<C-n>` / `<C-p>` | I | Blink: Select next/prev item | `plugins/lsp/completion.lua` |
| `<C-b>` / `<C-f>` | I | Blink: Scroll documentation up/down | `plugins/lsp/completion.lua` |

## Embedded Execution & Debugging

| Key Chord | Mode | Action / Command | Definition File |
| :--- | :---: | :--- | :--- |
| `<C-\>` | N/T | Toggle Terminal | `plugins/workflow/toggleterm.lua` |
| `<leader>tp` | N | Toggle [P]rocess Monitor (btm) | `plugins/workflow/toggleterm.lua` |
| `<leader>tm` | N | Toggle [M]arkdown Preview (glow) | `plugins/workflow/toggleterm.lua` |
| `<leader>ts` | N | Toggle [S]potify Player | `plugins/workflow/toggleterm.lua` |
| `<leader>ta` | N | Toggle [A]ider AI Chat (context-aware) | `plugins/workflow/toggleterm.lua` |
| `<leader>ti` | N | Toggle [I]nfrastructure (podman-tui) | `plugins/workflow/toggleterm.lua` |
| `:Watch <cmd>` | N | Run command continuously on file changes | `core/settings/commands.lua` |
| `<F5>` | N | Debug: Start/Continue | `plugins/dap/debug.lua` |
| `<leader>b` | N | Debug: Toggle Breakpoint | `plugins/dap/debug.lua` |
| `<leader>du` | N | Debug: Toggle UI | `plugins/dap/debug.lua` |

## Version Control & CLI Integrations

| Key Chord | Mode | Action / Command | Definition File |
| :--- | :---: | :--- | :--- |
| `<leader>gg` | N | Lazy[G]it [G]UI | `plugins/git/lazygit.lua` |
| `<leader>gd` | N | Toggle [G]it [D]iff overlay | `plugins/editing/mini/diff.lua` |
| `:ToolCheck` | N | Scan for missing binaries (`mise`) | `core/settings/commands.lua` |
| `:Jq` | N | `gojq` on current buffer | `core/settings/commands.lua` |
| `:Sd` | N | `sd` (regex replace) on current buffer | `core/settings/commands.lua` |
| `:Xh` | N | `xh` (HTTP client) on current line/args | `core/settings/commands.lua` |
| `:Jless` | N | `jless` on current JSON file (new tab) | `core/settings/commands.lua` |

---

## ⚠️ Architectural Conflicts

1. **`s` Key Override (Mini.surround):** Shadows native `s`. Retrain muscle memory to use `cl`.
2. **`<C-l>` Multimodal Overloading:** Window right (Normal) vs. Deterministic escape hatch (Insert).
3. **`<Esc>` Native Override:** Clears search highlights. Masks native terminal bell.
4. **`<C-e>` Menu Collision:** Hides completion (Insert) vs. Harpoon quick menu (Normal).
