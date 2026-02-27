-- ============================================================================\n-- MODULE: LaTeX Snippet Payload (Zero-G Logic)\n-- CONTEXT: Standardizes triggers as instant Appendages or safe Operators.\n-- ============================================================================\n\nlocal M = {}\n\nlocal ls = require(\"luasnip\")\nlocal s, t, i, d, f = ls.s, ls.t, ls.i, ls.d, ls.f\nlocal fmt = require(\"luasnip.extras.fmt\").fmt\nlocal pipe = require(\"snippets.latex_utils\").pipe\n\n-- ============================================================================\n-- FORCE MULTIPLIER: Regex Capture Extractor\n-- NOTE: This helper function is the core of our dynamic regex snippets.\n--   It wraps LuaSnip\'s `function_node` (f) to create a reusable utility for\n--   pulling capture groups out of a `regTrig` match.\n--\n-- IMPORTANT: The empty table `{}` as the second argument to `f()` is critical.\n--   It tells LuaSnip that this function node does not depend on any other\n--   nodes, preventing it from being re-evaluated unnecessarily.\n-- ============================================================================\nlocal cap = function(index)\n  return f(function(_, snip) return snip.captures[index] or \"\" end, {})\nend\n\n-- ============================================================================\n-- FORCE MULTIPLIER: Operator Snippet Factory\n-- NOTE: This function programmatically generates our \"Operator\" snippets,\n--   which are designed to prevent trigger masking (e.g., \"in\" firing inside \"int\").\n--\n-- IMPORTANT: It creates two distinct snippets for each operator:\n--   1. Mid-line: `([^%a])` + trigger + `(%s)` requires a non-alphabetic\n--      character *before* and a whitespace character *after*.\n--   2. Start-of-line: `^` + trigger + `(%s)` only requires whitespace *after*.\n--   The captures are then re-inserted to preserve typing flow.\n-- ============================================================================\nlocal make_operator = function(snips, trig, expansion)\n  -- Mid-line case\n  table.insert(snips, s({ trig = \"([^%a])\" .. trig .. \"(%s)\", regTrig = true, snippetType = \"autosnippet\", condition = in_mathzone },\n    f(function(_, snip) return snip.captures[1] .. expansion .. snip.captures[2] end, {})\n  ))\n  -- Start-of-line case\n  table.insert(snips, s({ trig = \"^\" .. trig .. \"(%s)\", regTrig = true, snippetType = \"autosnippet\", condition = in_mathzone },\n    f(function(_, snip) return expansion .. snip.captures[1] end, {})\n  ))\nend\n\n-- ============================================================================\n-- 1. Vault Path & Context Detection\n-- ============================================================================\nlocal vault_path = vim.fn.expand(\"~/Documents/Obsidian\")\n\n-- NOTE: This is the anti-fragile, hallucination-free math context detector.\n--   It uses Neovim\'s native Tree-sitter API to traverse the syntax tree\n--   upwards from the cursor.\n--\n-- IMPORTANT: `ignore_injections = false` is critical. It allows the function\n--   to \"step into\" injected language blocks, like LaTeX math inside Markdown.\n--   The `pcall` (protected call) prevents Neovim from crashing if a Tree-sitter\n--   parser is missing or fails to attach to the buffer.\nlocal in_mathzone = function()\n  local bufnr = vim.api.nvim_get_current_buf()\n  local cursor = vim.api.nvim_win_get_cursor(0)\n  local ok, node = pcall(vim.treesitter.get_node, { bufnr = bufnr, pos = { cursor[1] - 1, cursor[2] }, ignore_injections = false })\n  if not ok or not node then return false end\n  while node do\n    if node:type():find(\"math\") or node:type():find(\"formula\") then return true end\n    node = node:parent()\n  end\n  return false\nend\n\n-- NOTE: A simple context detector that returns true if the current file\n--   is located anywhere inside the defined Obsidian vault path.\nlocal in_vault = function()\n  return vim.api.nvim_buf_get_name(0):find(vault_path, 1, true) ~= nil\nend\n\n-- ============================================================================\n-- 2. Data Tables (Source of Truth)\n-- NOTE: These tables are the single source of truth for programmatic snippet\n--   generation. Adding a new symbol or Greek letter here will automatically\n--   create all its associated snippets.\n-- ============================================================================\nlocal GREEK_MAP = {\n  alpha = \"a\", beta = \"b\", gamma = \"g\", Gamma = \"G\", delta = \"d\", Delta = \"D\",\n  epsilon = \"e\", zeta = \"z\", theta = \"t\", Theta = \"T\", iota = \"i\", kappa = \"k\",\n  lambda = \"l\", Lambda = \"L\", sigma = \"s\", Sigma = \"S\", upsilon = \"u\", Upsilon = \"U\",\n  omega = \"o\", Omega = \"O\", varepsilon = \"ve\", vartheta = \"vt\"\n}\n\nlocal SYMBOLS = {\n  \"infty\", \"sum\", \"prod\", \"lim\", \"pm\", \"mp\", \"dots\", \"nabla\", \"times\",\n  \"parallel\", \"equiv\", \"neq\", \"geq\", \"leq\", \"gg\", \"ll\", \"sim\", \"simeq\",\n  \"propto\", \"leftrightarrow\", \"to\", \"mapsto\", \"implies\", \"impliedby\",\n  \"cap\", \"cup\", \"setminus\", \"subseteq\", \"supseteq\", \"emptyset\"\n}\n\n-- ============================================================================\n-- 3. Snippet Retrieval Function\n-- NOTE: This is the main payload function called by the JIT loader.\n--   It defines snippet decorators and then programmatically builds and returns\n--   the final table of over 200 snippets.\n-- ============================================================================\nfunction M.retrieve()\n  local snips = {}\n\n  -- ==========================================================================\n  -- Snippet Decorators\n  -- NOTE: `extend_decorator` is a powerful LuaSnip utility that allows us\n  --   to create \"templates\" for our snippets. This is the cornerstone of\n  --   our Appendage/Operator architecture.\n  -- ==========================================================================\n  \n  -- IMPORTANT: `wordTrig = false` is the key to Appendage snippets. It allows\n  --   triggers like `sr` to fire even when attached to a character (e.g., `x` in `xsr`).\n  local math_auto = ls.extend_decorator.apply(ls.parser.parse_snippet, { condition = in_mathzone, snippetType = \"autosnippet\", wordTrig = false })\n  \n  -- NOTE: Text snippets use `wordTrig = true` to ensure they only fire on\n  --   whole words, preventing \"btw\" from triggering inside \"between\".\n  local text_auto = ls.extend_decorator.apply(ls.parser.parse_snippet, { condition = function() return not in_mathzone() end, snippetType = \"autosnippet\", wordTrig = true })\n  \n  local global_auto = ls.extend_decorator.apply(ls.parser.parse_snippet, { snippetType = \"autosnippet\", wordTrig = false })\n  \n  local vault_callout = ls.extend_decorator.apply(ls.parser.parse_snippet, { condition = pipe({ function() return not in_mathzone() end, in_vault }), snippetType = \"autosnippet\", wordTrig = true })\n\n  -- ==========================================================================\n  -- SNIPPET CHUNKS\n  -- ==========================================================================\n\n  -- [CHUNK 1]: STRUCTURAL APPENDAGES (Fire instantly)\n  table.insert(snips, math_auto({ trig = \"seq\" }, \"\\\\{${1:a_n}\\\\}_{${2:n}=${3:1}}^{\\\\infty} $0\"))\n  table.insert(snips, s({ trig = \"beg\", snippetType = \"autosnippet\", condition = in_mathzone, wordTrig = false }, {\n    t(\"\\\\begin{\"), i(1), t({ \"}\", \"\\t\" }), i(0), t({ \"\", \"\\\\end{\" }), f(function(args) return args[1][1] end, {1}), t(\"}\")\n  }))\n  table.insert(snips, math_auto({ trig = \"sr\" }, \"^{2}\"))\n  table.insert(snips, math_auto({ trig = \"cb\" }, \"^{3}\"))\n  table.insert(snips, math_auto({ trig = \"rd\" }, \"^{$1}$0\"))\n  table.insert(snips, math_auto({ trig = \"us\" }, \"_{$1}$0\"))\n  table.insert(snips, math_auto({ trig = \"sts\" }, \"_\\\\text{$1}$0\"))\n  table.insert(snips, math_auto({ trig = \"sq\" }, \"\\\\sqrt{ $1 }$0\"))\n  table.insert(snips, math_auto({ trig = \"//\" }, \"\\\\frac{$1}{$2}$0\"))\n  table.insert(snips, math_auto({ trig = \"ee\" }, \"e^{ $1 }$0\"))\n  table.insert(snips, math_auto({ trig = \"invs\" }, \"^{-1}\"))\n\n  -- [CHUNK 2]: OPERATORS (Boundary-safe)\n  local ops = {\n    [\"in\"] = \"\\\\in\", notin = \"\\\\not\\\\in\", as = \"\\\\forall\", es = \"\\\\exists\",\n    [\"if\"] = \"\\\\infty\", sum = \"\\\\sum\", prod = \"\\\\prod\", lim = \"\\\\lim\",\n    det = \"\\\\det\", trace = \"\\\\mathrm{Tr}\", [\"and\"] = \"\\\\cap\", orr = \"\\\\cup\",\n    sin = \"\\\\sin\", cos = \"\\\\cos\", tan = \"\\\\tan\", csc = \"\\\\csc\", \n    sec = \"\\\\sec\", cot = \"\\\\cot\", sinh = \"\\\\sinh\", cosh = \"\\\\cosh\",\n    tanh = \"\\\\tanh\", coth = \"\\\\coth\",\n    arcsin = \"\\\\arcsin\", arccos = \"\\\\arccos\", arctan = \"\\\\arctan\"\n  }\n  for trig, exp in pairs(ops) do make_operator(snips, trig, exp) end\n\n  -- [CHUNK 3]: PROGRAMMATIC GREEK (Hybrid Logic)\n  for name, short in pairs(GREEK_MAP) do\n    table.insert(snips, math_auto({ trig = \"@\" .. short }, \"\\\\\" .. name))\n    make_operator(snips, name, \"\\\\\" .. name)\n    table.insert(snips, math_auto({ trig = name .. \"bb\" }, \"\\\\boldsymbol{\\\\\" .. name .. \"}\"))\n    table.insert(snips, math_auto({ trig = \"\\\\\\\\\" .. name .. \"%.%.\" }, \"\\\\boldsymbol{\\\\\" .. name .. \"}\"))\n    \n    -- AUTOMATIC BACKSLASH & SPACING\n    table.insert(snips, s({ trig = \"([^%s\\\\])\" .. name, regTrig = true, wordTrig = false, snippetType = \"autosnippet\", condition = in_mathzone },\n      f(function(_, snip) return snip.captures[1] .. \"\\\\\" .. name end, {})\n    ))\n    table.insert(snips, s({ trig = \"\\\\\" .. name .. \"([A-Za-z])\", regTrig = true, wordTrig = false, snippetType = \"autosnippet\", condition = in_mathzone },\n      f(function(_, snip) return \"\\\\\" .. name .. \" \" .. snip.captures[1] end, {})\n    ))\
    \
    -- Shorthand modifiers\
    table.insert(snips, math_auto({ trig = '\' .. name .. ' sr' }, [[' .. name .. '^{2}]]))\
    table.insert(snips, math_auto({ trig = '\' .. name .. ' cb' }, [[' .. name .. '^{3}]]))\
    for t_mod, c_mod in pairs({ hat = \"\\\\hat\", dot = \"\\\\dot\", bar = \"\\\\bar\", vec = \"\\\\vec\", tilde = \"\\\\tilde\", und = \"\\\\underline\" }) do\
      table.insert(snips, math_auto({ trig = '\' .. name .. ' ' .. t_mod }, c_mod .. '{\' .. name .. '}')))\
    end\
  end\
  table.insert(snips, math_auto({ trig = ":e" }, [[arepsilon]]))\
  table.insert(snips, math_auto({ trig = ":t" }, [[artheta]]))\
  table.insert(snips, math_auto({ trig = \"ome\" }, [[\omega]]))\
  table.insert(snips, math_auto({ trig = \"Ome\" }, [[\Omega]]))\
\
  -- [CHUNK 4]: SYMBOLS & LOGIC (Standard Symbols)\
  local syms = {\
    [\"+-\"] = { res = \"\\\\pm\" },\
    [\"-+\"] = { res = \"\\\\mp\", pri = 2000 },\
    [\"...\"] = { res = \"\\\\dots\" },\
    nabl = { res = \"\\\\nabla\" },\
    del = { res = \"\\\\nabla\" },\
    xx = { res = \"\\\\times\" },\
    [\"*\"] = { res = \"\\\\cdot \" },\
    para = { res = \"\\\\parallel\" },\
    [\"===\"] = { res = \"\\\\equiv\", pri = 2000 },\
    [\"!=\"] = { res = \"\\\\neq\" },\
    [\">=\"] = { res = \"\\\\geq\", pri = 2000 },\
    [\"<=\"] = { res = \"\\\\leq\" },\
    [\">>\"] = { res = \"\\\\gg\", pri = 2000 },\
    [\"<<\"] = { res = \"\\\\ll\", pri = 2000 },\
    simm = { res = \"\\\\sim\" },\
    [\"sim=\"] = { res = \"\\\\simeq\", pri = 2000 },\
    prop = { res = \"\\\\propto\" },\
    [\"<->\"] = { res = \"\\\\leftrightarrow \", pri = 3000 },\
    [\"->\"] = { res = \"\\\\to\", pri = 2000 },\
    [\"!>\"] = { res = \"\\\\mapsto\" },\
    [\"=>\"] = { res = \"\\\\implies\", pri = 2000 },\
    [\"=<\"] = { res = \"\\\\impliedby\", pri = 2000 },\
    [\"\\\\\\\\\\\\\"] = { res = \"\\\\setminus\" },\
    [\"sub=\"] = { res = \"\\\\subseteq\" },\
    [\"sup=\"] = { res = \"\\\\supseteq\" },\
    eset = { res = \"\\\\emptyset\" }\
  }\
  for trig, data in pairs(syms) do\
    table.insert(snips, math_auto({ trig = trig, priority = data.pri }, data.res))\
  end\
  \
  -- Post-Symbol Spacing\
  for _, name in ipairs(SYMBOLS) do\
    table.insert(snips, s({ trig = \"\\\\\" .. name .. \"([A-Za-z])\", regTrig = true, wordTrig = false, snippetType = \"autosnippet\", condition = in_mathzone },\
      f(function(_, snip) return \"\\\\\" .. name .. \" \" .. snip.captures[1] end, {})\
    ))\
  end\
\
  -- [CHUNK 5]: CALLOUTS & SHORTHANDS (Vault-Aware)\
  local callouts = { cdef = \"definition\", cex = \"example\", csol = \"success]-\", cimp = \"warning\", cque = \"question\" }\
  for trig, type in pairs(callouts) do\
    table.insert(snips, vault_callout({ trig = trig }, \"> [!\" .. type .. \"] ${1:Title}\\n> $0\"))\
  end\
  table.insert(snips, text_auto({ trig = \"btw\" }, \"between\"))\
  table.insert(snips, text_auto({ trig = \"bc\" }, \"because\"))\
  table.insert(snips, text_auto({ trig = \"wrt\" }, \"with respect to\"))\
  table.insert(snips, text_auto({ trig = \"hwe\" }, \"however\"))\
  table.insert(snips, text_auto({ trig = \"cnt\" }, \"connect\"))\
  table.insert(snips, vault_callout({ trig = \"cweb\" }, \"<iframe src=\\\"${1:URL}\\\" width=\\\"100%\\\" height=\\\"${2:500px}\\\" style=\\\"border:none; border-radius: 8px;\\\"></iframe>\\n$0\"))\
\
  -- [CHUNK 6]: CALCULUS & INTEGRALS (Hybrid Logic)\
  table.insert(snips, math_auto({ trig = \"par\" }, \"\\\\frac{ \\\\partial ${1:y} }{ \\\\partial ${2:x} } $0\"))\
  table.insert(snips, s({ trig = \"pa([A-Za-z])([A-Za-z])\", regTrig = true, wordTrig = false, snippetType = \"autosnippet\", condition = in_mathzone },\
    fmt(\"\\\\frac{{ \\\\partial {1} }}{{ \\\\partial {2} }} \", { cap(1), cap(2) })\
  ))\
  table.insert(snips, math_auto({ trig = \"ddt\" }, \"\\\\frac{d}{dt} \"))\
\
  -- Instant Appendages (mA)\
  table.insert(snips, math_auto({ trig = \"oint\" }, \"\\\\oint\"))\
  table.insert(snips, math_auto({ trig = \"iint\" }, \"\\\\iint\"))\
  table.insert(snips, math_auto({ trig = \"iiint\" }, \"\\\\iiint\"))\
  table.insert(snips, math_auto({ trig = \"dint\" }, \"\\\\int_{${1:0}}^{${2:1}} $3 \\\\, d${4:x} $0\"))\
  table.insert(snips, math_auto({ trig = \"oinf\" }, \"\\\\int_{0}^{\\\\infty} $1 \\\\, d${2:x} $0\"))\
  table.insert(snips, math_auto({ trig = \"infi\" }, \"\\\\int_{-\\\\infty}^{\\\\infty} $1 \\\\, d${2:x} $0\"))\
\
  -- Boundary-Safe \'int\' Operator (requires space)\
  table.insert(snips, s({ trig = \"([^%a])int(%s)\", regTrig = true, wordTrig = false, snippetType = \"autosnippet\", condition = in_mathzone },\
    fmt(\"{1}\\\\int {2} \\\\, d{3}{4}\", {\
      f(function(_, snip) return snip.captures[1] end, {1}),\
      i(1),\
      i(2, \"x\"),\
      f(function(_, snip) return snip.captures[2] end, {2})\
    })\
  ))\
  table.insert(snips, s({ trig = \"^int(%s)\", regTrig = true, wordTrig = false, snippetType = \"autosnippet\", condition = in_mathzone },\
    fmt(\"\\\\int {1} \\\\, d{2}{3}\", {\
      i(1),\
      i(2, \"x\"),\
      f(function(_, snip) return snip.captures[1] end, {1})\
    })\
  ))\
\
  -- [CHUNK 7]: COMPLEX NATIVE LOGIC (Captures & Decorators)\
  table.insert(snips, s({ trig = \"([A-Za-z])(%d)\", regTrig = true, snippetType = \"autosnippet\", condition = in_mathzone, wordTrig = false, priority = -1 },\
    fmt(\"{1}_{{{2}}}\", { cap(1), cap(2) })\
  ))\
  table.insert(snips, s({ trig = \"([A-Za-z])_(%d%d)\", regTrig = true, snippetType = \"autosnippet\", condition = in_mathzone, wordTrig = false },\
    fmt(\"{1}_{{{2}}}\", { cap(1), cap(2) })\
  ))\
  local decs = { hat = \"\\\\hat\", bar = \"\\\\bar\", dot = \"\\\\dot\", tilde = \"\\\\tilde\", vec = \"\\\\vec\" }\
  for trig, cmd in pairs(decs) do\
    table.insert(snips, s({ trig = \"([a-zA-Z])\" .. trig, regTrig = true, wordTrig = false, snippetType = \"autosnippet\", condition = in_mathzone },\
      fmt(cmd .. \"{{{1}}}\", { cap(1) })\
    ))\
  end\
  table.insert(snips, math_auto({ trig = \"bf\" }, \"\\\\mathbf{$1}\"))\
  table.insert(snips, math_auto({ trig = \"rm\" }, \"\\\\mathrm{$1}$0\"))\
  table.insert(snips, math_auto({ trig = \"txt\" }, \"\\\\text{$1}$0\"))\
  table.insert(snips, math_auto({ trig = \"conj\" }, \"^{*}\"))\
  table.insert(snips, math_auto({ trig = \"Re\" }, \"\\\\mathrm{Re}\"))\
  table.insert(snips, math_auto({ trig = \"Im\" }, \"\\\\mathrm{Im}\"))\
\
  -- [CHUNK 8]: VISUAL WRAPPERS\n  local visuals = { U = \"underbrace\", O = \"overbrace\", C = \"cancel\", S = \"sqrt\" }\
  for trig, cmd in pairs(visuals) do\n    table.insert(snips, math_auto({ trig = trig }, \"\\\\\" .. cmd .. \"{ ${1:${TM_SELECTED_TEXT}} } $0\"))\
  end\n  table.insert(snips, math_auto({ trig = \"B\" }, \"\\\\underset{ $1 }{ ${2:${TM_SELECTED_TEXT}} }\"))\
  table.insert(snips, math_auto({ trig = \"K\" }, \"\\\\cancelto{ $1 }{ ${2:${TM_SELECTED_TEXT}} }\"))\
\
  -- [CHUNK 9]: FONT SHORTCUTS\n  for char, cmd in pairs({ L = \"mathcal{L}\", H = \"mathcal{H}\", C = \"mathbb{C}\", R = \"mathbb{R}\", Z = \"mathbb{Z}\", N = \"mathbb{N}\" }) do\n    table.insert(snips, math_auto({ trig = char .. char }, \"\\\\\" .. cmd))\n  end\n\
  -- [CHUNK 10]: GLOBAL TRIGGERS\n  table.insert(snips, global_auto({ trig = \"mk\" }, \"$$1$\"))\n  table.insert(snips, global_auto({ trig = \"dm\" }, \"$$\\n$1\\n$$\"))\n  table.insert(snips, global_auto({ trig = \"--\" }, \"–\"))\n  table.insert(snips, global_auto({ trig = \"–-\" }, \"—\"))\n\
  -- [CHUNK 11]: CODING BLOCKS & CHECKLISTS (Vault-Aware)\n  table.insert(snips, vault_callout({ trig = \"pypy\" }, \"```python\\n$0\\n```\"))\n  table.insert(snips, vault_callout({ trig = \"ii\" }, \"`$0`$1\"))\n  table.insert(snips, vault_callout({ trig = \"jmain\" }, \"```java\\npublic class ${1:Main} {\\n    public static void main(String[] args) {\\n        $0\\n    }\\n}\\n```\"))\n  table.insert(snips, vault_callout({ trig = \"clog\" }, \"```c\\n$0\\n```\"))\n  table.insert(snips, vault_callout({ trig = \"cpp\" }, \"```cpp\\n$0\\n```\"))\n  table.insert(snips, vault_callout({ trig = \"-c \" }, \"- [ ] $0\"))\n\
  -- [CHUNK 12]: TRIGONOMETRY SPACING & AUTO-BACKSLASH\n  local trig_funcs = { \"arcsin\", \"sin\", \"arccos\", \"cos\", \"arctan\", \"tan\", \"csc\", \"sec\", \"cot\", \"sinh\", \"cosh\", \"tanh\", \"coth\" }\
  for _, func in ipairs(trig_funcs) do\
    table.insert(snips, s({ trig = \"([^\\\\\\\\])\" .. func, regTrig = true, wordTrig = false, snippetType = \"autosnippet\", condition = in_mathzone },\
      f(function(_, snip) return snip.captures[1] .. \"\\\\\" .. func end, {})\
    ))\
    local space_pattern = func:find(\"h$\") and \"([A-Za-z])\" or \"([A-Za-gi-z])\"\
    table.insert(snips, s({ trig = \"\\\\\" .. func .. space_pattern, regTrig = true, wordTrig = false, snippetType = \"autosnippet\", condition = in_mathzone },\
      f(function(_, snip) return \"\\\\\" .. func .. \" \" .. snip.captures[1] end, {})\
    ))\
  end\
\
  -- [CHUNK 13]: PHYSICS & CHEMISTRY (mA)\
  table.insert(snips, math_auto({ trig = \"kbt\" }, \"k_{B}T\"))\
  table.insert(snips, math_auto({ trig = \"msun\" }, \"M_{\\\\odot}\"))\
  table.insert(snips, math_auto({ trig = \"pu\" }, \"\\\\pu{ $1 }$0\"))\
  table.insert(snips, math_auto({ trig = \"cee\" }, \"\\\\ce{ $1 }$0\"))\
  table.insert(snips, math_auto({ trig = \"he4\" }, \"{}^{4}_{2}He \"))\
  table.insert(snips, math_auto({ trig = \"he3\" }, \"{}^{3}_{2}He \"))\
  table.insert(snips, math_auto({ trig = \"iso\" }, \"{}^{${1:4}}_{${2:2}}${3:He}$0\"))\
\
  -- [CHUNK 14]: QUANTUM MECHANICS (mA)\
  table.insert(snips, math_auto({ trig = \"dag\" }, \"^{\\\\dagger}\"))\
  table.insert(snips, math_auto({ trig = \"o+\" }, \"\\\\oplus \"))\
  table.insert(snips, math_auto({ trig = \"ox\" }, \"\\\\otimes \"))\
  table.insert(snips, math_auto({ trig = \"bra\" }, \"\\\\bra{$1} $0\"))\
  table.insert(snips, math_auto({ trig = \"ket\" }, \"\\\\ket{$1} $0\"))\
  table.insert(snips, math_auto({ trig = \"brk\" }, \"\\\\braket{ $1 | $2 } $0\"))\
  table.insert(snips, math_auto({ trig = \"outer\" }, \"\\\\ket{${1:\\\\psi}} \\\\bra{${1:\\\\psi}} $0\"))\
\
  -- [CHUNK 15]: MATRIX ENVIRONMENTS (Appendages)\n  local matrices = { pmat = \"pmatrix\", bmat = \"bmatrix\", Bmat = \"Bmatrix\", vmat = \"vmatrix\", Vmat = \"Vmatrix\", matrix = \"matrix\" }\
  for trig, env in pairs(matrices) do\
    table.insert(snips, math_auto({ trig = trig }, \"\\\\begin{\" .. env .. \"}\\n\\t$0\\n\\\\end{\" .. env .. \"}\"))\
    table.insert(snips, math_auto({ trig = trig .. \"n\" }, \"\\\\begin{\" .. env .. \"}$0\\\\end{\" .. env .. \"}\"))\
  end\
\
  -- [CHUNK 16]: STRUCTURAL ENVIRONMENTS (Appendages)\n  table.insert(snips, math_auto({ trig = \"cases\" }, \"\\\\begin{cases}\\n\\t$0\\n\\\\end{cases}\"))\
  table.insert(snips, math_auto({ trig = \"align\" }, \"\\\\begin{align}\\n\\t$0\\n\\\\end{align}\"))\
  table.insert(snips, math_auto({ trig = \"array\" }, \"\\\\begin{array}\\n\\t$0\\n\\\\end{array}\"))\
\
  -- [CHUNK 17]: BRACKETS & ENCLOSURES (Appendages)\n  local bracket_map = {\
    avg = { \"\\\\langle \", \" \\\\rangle\" },\
    norm = { \"\\\\lvert \", \" \\\\rvert\", pri = 1 },\
    Norm = { \"\\\\lVert \", \" \\\\rVert\", pri = 1 },\
    ceil = { \"\\\\lceil \", \" \\\\rceil\" },\
    floor = { \"\\\\lfloor \", \" \\\\rfloor\" },\
    mod = { \"|\", \"|\" },\
    [\"lr(\"] = { \"\\\\left( \", \" \\\\right)\" },\
    [\"lr{\"] = { \"\\\\left\\\\{ \", \" \\\\right\\\\}\" },\
    [\"lr[\"] = { \"\\\\left[ \", \" \\\\right]\" },\
    [\"lr|\"] = { \"\\\\left| \", \" \\\\right|\" },\
    lra = { \"\\\\left< \", \" \\\\right>\" }\
  }\
  for trig, data in pairs(bracket_map) do\
    table.insert(snips, math_auto({ trig = trig, priority = data.pri }, data[1] .. \"${1:${TM_SELECTED_TEXT}}\" .. data[2] .. \"$0\"))\
  end\
\
  -- [CHUNK 18]: AUTO-ENCLOSURES (Global Appendages)\n  local auto_enclosures = { [\"(\"] = { \"(\", \")\" }, [\"[\"] = { \"[\", \"]\" }, [\"{\"] = { \"{\", \"}\" } }\
  for trig, pair in pairs(auto_enclosures) do\
    table.insert(snips, global_auto({ trig = trig }, pair[1] .. \"${1:${TM_SELECTED_TEXT}}\" .. pair[2] .. \"$0\"))\
  end\
\
  -- [CHUNK 19]: TEXT-TO-MATH CONVERSIONS (Complex Regex)\n  table.insert(snips, s({ trig = \"([^\']) ([B-HJ-Zb-z]) ([%s.,?!:\'])\", regTrig = true, snippetType = \"autosnippet\" },\
    fmt(\"{1}${2}${3}\", { cap(1), cap(2), cap(3) })\
  ))\
  for name, _ in pairs(GREEK_MAP) do\
    table.insert(snips, s({ trig = \" \" .. name .. \"([%s.,?!:\'])\", regTrig = true, snippetType = \"autosnippet\", condition = function() return not in_mathzone() end },\
      f(function(_, snip) return \" \\\\$\\\\\" .. name .. \"\\\\$\" .. snip.captures[1] end, {})\
    ))\
  end\
  table.insert(snips, s({ trig = \"([A-Za-z]=[A-Za-z0-9%s%+%-%*/%^]+)([%s.,?!:\'])\", regTrig = true, snippetType = \"autosnippet\", condition = function() return not in_mathzone() end },\
    fmt(\"${1}${2}\", { cap(1), cap(2) })\
  ))\
\
  -- [CHUNK 20]: ADVANCED MATH LOGIC\n  table.insert(snips, math_auto({ trig = \"tayl\" }, \"${1:f}(${2:x} + ${3:h}) = ${1:f}(${2:x}) + ${1:f}\'(${2:x})${3:h} + ${1:f}\'\'(${2:x}) \\\\\\\\frac{${3:h}^{2}}{2!} + \\\\\\\\dots $0\"))\
  table.insert(snips, s({ trig = \"iden(%d+)\", regTrig = true, snippetType = \"autosnippet\", condition = in_mathzone, wordTrig = false },\
    d(1, function(_, snip)\
      local n = tonumber(snip.captures[1])\
      if not n or n < 1 then return s(nil, { t(\"\") }) end\
      local nodes = {}\
      for j = 1, n do\
        for k = 1, n do\
          table.insert(nodes, t(j == k and \"1\" or \"0\"))\
          if k < n then table.insert(nodes, t(\" & \")) end\
        end\
        if j < n then table.insert(nodes, t({ \" \\\\\\\\\", \"\" })) end\
      end\
      return s(nil, { t({ \"\\\\begin{pmatrix}\", \"\" }), unpack(nodes), t({ \"\", \"\\\\end{pmatrix}\" }) })\
    end, {1})\
  ))\
\
  return snips\
end\
\
return M\
