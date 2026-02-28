# Neovim Workflow Cheatsheet

A quick reference for the keybindings and commands in this configuration.

If you are looking for anymore of them you can use <leader>uk to find all the commands via fzf.

For benchmarking run PROFILE=1 nvim

and then <leader>zp

---

## 1. Core Vim Muscle Memory (The "Native" Tier)

| Key Chord | Mode | Action / Command | Source |
| :--- | :---: | :--- | :--- |
| `ciw` / `caw` | N | Change inner word / change a word | Native |
| `dap` / `yap` | N | Delete / yank a paragraph | Native |
| `%` | N | Jump to matching bracket/parenthesis | Native |
| `qq` / `@q` | N | Record / Play macro (register q) | Native |
| `m[a-z]` / `'[a-z]` | N | Set / Jump to local mark | Native |
| `0` / `^` / `$` | N | Start of line / first char / end of line | Native |
| `gg` / `G` | N | Top / Bottom of file | Native |
| `*` / `#` | N | Search forward / backward for word under cursor | Native |
| `C` / `D` | N | Change / Delete to end of line | Native |
| `j` / `k` | N | Smart visual line movement (`gj`/`gk`) | Core |

---

## 2. Window, Panel & Buffer Management

| Key Chord | Mode | Action | Plugin/Source |
| :--- | :---: | :--- | :--- |
| `<C-w>v` | N | Split window vertically | Native |
| `<C-w>s` | N | Split window horizontally | Native |
| `<C-w>q` / `<C-w>c` | N | Close current window/panel | Native |
| `<C-w>o` | N | Close all other windows (maximize current) | Native |
| `<C-w>=` | N | Equalize all window sizes | Native |
| `<C-h/j/k/l>` | N | Move focus to Left/Down/Up/Right window | `smart-splits` |
| `[b` / `]b` | N | Go to previous / next buffer | `mini.bracketed` |

---

## 3. Multi-Tiered Navigation

### Tier 1: Global (Zoxide & Telescope)

| Key Chord | Mode | Action | Plugin |
| :--- | :---: | :--- | :--- |
| `<leader>cd` | N | [C]hange [D]irectory (Zoxide) | `telescope.lua` |
| `<leader>ff` | N | [F]ind [F]iles (Discovery) | `telescope.lua` |
| `<leader><leader>` | N | Find existing buffers | `telescope.lua` |

### Tier 2: Discovery (File Browsers)

| Key Chord | Mode | Action | Plugin |
| :--- | :---: | :--- | :--- |
| `-` | N | Open parent directory (relative) | `mini.files` |
| `<leader>y` | N | Open Full TUI File Manager | `yazi.lua` |

### Tier 3: Action (Harpoon - Fixed)

| Key Chord | Mode | Action | Plugin |
| :--- | :---: | :--- | :--- |
| `<M-a>` | N | [A]dd File to Harpoon | `harpoon.lua` |
| `<M-e>` | N | Toggle Harpoon Quick Menu | `harpoon.lua` |
| `<M-1...4>` | N | Instant Jump to Marks 1-4 | `harpoon.lua` |

---

## 4. Editing, Refactoring & Notetaking

### Text Objects & Surround (Fixed)

| Key Chord | Mode | Action | Plugin |
| :--- | :---: | :--- | :--- |
| `v a )` | N | Select around parentheses | `mini.ai` |
| `y i n q` | N | Yank inside next quote | `mini.ai` |
| `gza` / `gzd` | N | Add / Delete surround | `mini.surround` |
| `gzr` / `gzh` | N | Replace / Highlight surround | `mini.surround` |
| `<C-j>` / `<C-k>` | I | Jump forward/backward (Snippets/Brackets)| `luasnip.lua` |

### Refactoring & Notes (Obsidian)

| Key Chord | Mode | Action | Plugin |
| :--- | :---: | :--- | :--- |
| `<leader>re` | V | [R]efactor [E]xtract Function | `refactoring.lua` |
| `<leader>oq` | N | Obsidian: [Q]uick Switch | `obsidian.lua` |
| `<leader>on` | N | Obsidian: [N]ew Note | `obsidian.lua` |
| `gf` | N | Follow link under cursor | `obsidian.lua` |

---

## 5. Code Intelligence & Debugging

| Key Chord | Mode | Action | Plugin |
| :--- | :---: | :--- | :--- |
| `grn` | N | LSP: [R]e[n]ame | `lsp/init.lua` |
| `gra` | N/X | LSP: Code [A]ction | `lsp/init.lua` |
| `grr` | N | LSP: [G]oto [R]eferences | `telescope` |
| `<leader>xx` | N | Toggle Workspace Diagnostics | `trouble.nvim` |
| `<leader>xd` | N | Toggle Document Diagnostics | `trouble.nvim` |
| `<F5>` | N | Debug: Start/Continue | `nvim-dap` |
| `<leader>b` | N | Debug: Toggle Breakpoint | `nvim-dap` |
| '<leader>cr' | N | Runs code in Zellij split | 'zellij' |
| '<leader>cx' | N | Get output code in Zellij Split | 'zellij |


---

## 6. User Commands & CLI Integration

### Commands
| Command | Action | Source |
| :--- | :--- | :--- |
| `:ToolCheck` | Scan for missing binaries (mise) | `commands.lua` |
| `:Watch <cmd>` | Run command on file change (watchexec) | `commands.lua` |
| `:Jq` | Run jq on current buffer (opens in Trouble) | `commands.lua` |
| `:Typos` | Project-wide spell check (opens in Trouble) | `format.lua` |

### Key Chords
| Key Chord | Mode | Action | Plugin |
| :--- | :---: | :--- | :--- |
| `<leader>gg` | N | Open LazyGit GUI | `lazygit.lua` |
