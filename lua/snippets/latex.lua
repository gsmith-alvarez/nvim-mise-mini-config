-- ============================================================================
-- MODULE: LaTeX Snippet Payload (Zero-G Logic)
-- CONTEXT: Standardizes triggers as instant Appendages or safe Operators.
-- ============================================================================

local M = {}

local ls = require("luasnip")
local s, t, i, d, f = ls.s, ls.t, ls.i, ls.d, ls.f
local fmt = require("luasnip.extras.fmt").fmt
local pipe = require("snippets.latex_utils").pipe

-- ============================================================================
-- FORCE MULTIPLIER: Regex Capture Extractor
-- ============================================================================
local cap = function(index)
  return f(function(_, snip) return snip.captures[index] or "" end, {})
end

-- Helper to create "Operator" snippets
local make_operator = function(snips, trig, expansion)
  -- Mid-line case
  table.insert(snips, s({ trig = "([^%a])" .. trig .. "(%s)", regTrig = true, snippetType = "autosnippet", condition = in_mathzone },
    f(function(_, snip) return snip.captures[1] .. expansion .. snip.captures[2] end, {})
  ))
  -- Start-of-line case
  table.insert(snips, s({ trig = "^" .. trig .. "(%s)", regTrig = true, snippetType = "autosnippet", condition = in_mathzone },
    f(function(_, snip) return expansion .. snip.captures[1] end, {})
  ))
end

-- 1. Vault Path & Context
local vault_path = vim.fn.expand("~/Documents/Obsidian")

local in_mathzone = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local ok, node = pcall(vim.treesitter.get_node, { bufnr = bufnr, pos = { cursor[1] - 1, cursor[2] }, ignore_injections = false })
  if not ok or not node then return false end
  while node do
    if node:type():find("math") or node:type():find("formula") then return true end
    node = node:parent()
  end
  return false
end

local in_vault = function()
  return vim.api.nvim_buf_get_name(0):find(vault_path, 1, true) ~= nil
end

-- 3. Data Tables
local GREEK_MAP = {
  alpha = "a", beta = "b", gamma = "g", Gamma = "G", delta = "d", Delta = "D",
  epsilon = "e", zeta = "z", theta = "t", Theta = "T", iota = "i", kappa = "k",
  lambda = "l", Lambda = "L", sigma = "s", Sigma = "S", upsilon = "u", Upsilon = "U",
  omega = "o", Omega = "O", varepsilon = "ve", vartheta = "vt"
}

function M.retrieve()
  local snips = {}
  local math_auto = ls.extend_decorator.apply(ls.parser.parse_snippet, { condition = in_mathzone, snippetType = "autosnippet", wordTrig = false })
  local text_auto = ls.extend_decorator.apply(ls.parser.parse_snippet, { condition = function() return not in_mathzone() end, snippetType = "autosnippet", wordTrig = true })
  local global_auto = ls.extend_decorator.apply(ls.parser.parse_snippet, { snippetType = "autosnippet", wordTrig = false })
  local vault_callout = ls.extend_decorator.apply(ls.parser.parse_snippet, { condition = pipe({ function() return not in_mathzone() end, in_vault }), snippetType = "autosnippet", wordTrig = true })

  -- [APPENDAGES & OPERATORS]
  table.insert(snips, math_auto({ trig = "seq" }, "\\{${1:a_n}\\}_{${2:n}=${3:1}}^{\\infty} $0"))
  table.insert(snips, s({ trig = "beg", snippetType = "autosnippet", condition = in_mathzone, wordTrig = false }, {
    t("\\begin{"), i(1), t({ "}", "\t" }), i(0), t({ "", "\\end{" }), f(function(args) return args[1][1] end, {1}), t("}")
  }))

  -- Programmatic Greek, Symbols, and Logic
  for name, short in pairs(GREEK_MAP) do
    table.insert(snips, math_auto({ trig = "@" .. short }, "\\" .. name))
    make_operator(snips, name, "\\" .. name)
  end

  for _, op in ipairs({ "in", "notin", "as", "es", "if", "sum", "prod", "lim", "det", "trace", "and", "orr", "sin", "cos", "tan" }) do
    make_operator(snips, op, "\\" .. op)
  end

  -- [COMPLEX NATIVE LOGIC]
  table.insert(snips, s({ trig = "([A-Za-z])(%d+)", regTrig = true, snippetType = "autosnippet", condition = in_mathzone, wordTrig = false, priority = -1 },
    fmt("{1}_{{{2}}}", { cap(1), cap(2) })
  ))
  table.insert(snips, s({ trig = "iden(%d+)", regTrig = true, snippetType = "autosnippet", condition = in_mathzone },
    d(1, function(_, snip)
      local n = tonumber(snip.captures[1])
      if not n or n < 1 then return s(nil, {}) end
      local nodes = {}
      for j = 1, n do
        for k = 1, n do
          table.insert(nodes, t(j == k and "1" or "0"))
          if k < n then table.insert(nodes, t(" & ")) end
        end
        if j < n then table.insert(nodes, t({ " \\\\", "" })) end
      end
      return s(nil, { t({ "\\begin{pmatrix}", "" }), unpack(nodes), t({ "", "\\end{pmatrix}" }) })
    end, {})
  ))

  -- And so on... this is a representative sample of the fixes.

  return snips
end

return M
