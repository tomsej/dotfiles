local M = {}

M.palette = {
  bg = "#16131E",
  bg_alt = "#1E1829",
  bg_float = "#16131E",
  surface = "#22173D",
  surface2 = "#302B44",
  line_nr = "#302B44",
  line_nr_active = "#4B436A",
  text = "#cdd6f4",
  muted = "#6c7086",
  subtle = "#45475a",
  blue = "#89b4fa",
  cyan = "#89dceb",
  teal = "#94e2d5",
  green = "#a6e3a1",
  yellow = "#f9e2af",
  peach = "#fab387",
  pink = "#f5c2e7",
  mauve = "#cba6f7",
  red = "#f38ba8",
  lavender = "#b4befe",
  cursor = "#FFCA27",
  none = "NONE",
}

local function set(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

function M.lualine_theme()
  local c = M.palette

  return {
    normal = {
      a = { fg = c.muted, bg = c.bg, bold = true },
      b = { fg = c.muted, bg = c.bg },
      c = { fg = c.muted, bg = c.bg },
    },
    insert = {
      a = { fg = c.blue, bg = c.bg, bold = true },
      b = { fg = c.muted, bg = c.bg },
      c = { fg = c.muted, bg = c.bg },
    },
    visual = {
      a = { fg = c.mauve, bg = c.bg, bold = true },
      b = { fg = c.muted, bg = c.bg },
      c = { fg = c.muted, bg = c.bg },
    },
    replace = {
      a = { fg = c.red, bg = c.bg, bold = true },
      b = { fg = c.muted, bg = c.bg },
      c = { fg = c.muted, bg = c.bg },
    },
    command = {
      a = { fg = c.yellow, bg = c.bg, bold = true },
      b = { fg = c.muted, bg = c.bg },
      c = { fg = c.muted, bg = c.bg },
    },
    inactive = {
      a = { fg = c.subtle, bg = c.bg },
      b = { fg = c.subtle, bg = c.bg },
      c = { fg = c.subtle, bg = c.bg },
    },
  }
end

function M.apply()
  local c = M.palette

  vim.opt.termguicolors = true
  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end
  vim.g.colors_name = "tomsej"

  vim.g.terminal_color_0 = c.subtle
  vim.g.terminal_color_1 = c.red
  vim.g.terminal_color_2 = c.green
  vim.g.terminal_color_3 = c.yellow
  vim.g.terminal_color_4 = c.blue
  vim.g.terminal_color_5 = c.pink
  vim.g.terminal_color_6 = c.teal
  vim.g.terminal_color_7 = "#bac2de"
  vim.g.terminal_color_8 = c.muted
  vim.g.terminal_color_9 = c.red
  vim.g.terminal_color_10 = c.green
  vim.g.terminal_color_11 = c.yellow
  vim.g.terminal_color_12 = c.blue
  vim.g.terminal_color_13 = c.pink
  vim.g.terminal_color_14 = c.teal
  vim.g.terminal_color_15 = "#a6adc8"

  -- Core UI
  set("Normal", { fg = c.text, bg = c.bg })
  set("NormalNC", { fg = c.text, bg = c.bg })
  set("NormalFloat", { fg = c.text, bg = c.bg_float })
  set("FloatBorder", { fg = c.surface, bg = c.bg_float })
  set("FloatTitle", { fg = c.lavender, bg = c.bg_float, bold = true })
  set("ColorColumn", { bg = c.bg_alt })
  set("Cursor", { fg = c.bg, bg = c.cursor })
  set("lCursor", { fg = c.bg, bg = c.cursor })
  set("CursorIM", { fg = c.bg, bg = c.cursor })
  set("CursorLine", { bg = c.bg_alt })
  set("CursorColumn", { bg = c.bg_alt })
  set("CursorLineNr", { fg = c.line_nr_active, bg = c.bg_alt, bold = true })
  set("LineNr", { fg = c.line_nr, bg = c.bg })
  set("SignColumn", { bg = c.bg })
  set("EndOfBuffer", { fg = c.subtle, bg = c.bg })
  set("VertSplit", { fg = c.surface, bg = c.bg })
  set("WinSeparator", { fg = c.surface, bg = c.bg })
  set("MatchParen", { fg = c.yellow, bg = c.surface, bold = true })
  set("Visual", { bg = c.surface2 })
  set("VisualNOS", { bg = c.surface2 })
  set("Search", { fg = c.bg, bg = c.yellow })
  set("IncSearch", { fg = c.bg, bg = c.peach })
  set("CurSearch", { fg = c.bg, bg = c.peach, bold = true })
  set("Substitute", { fg = c.bg, bg = c.red })
  set("StatusLine", { fg = c.text, bg = c.surface })
  set("StatusLineNC", { fg = c.muted, bg = c.surface })
  set("TabLine", { fg = c.muted, bg = c.bg })
  set("TabLineFill", { bg = c.bg })
  set("TabLineSel", { fg = c.text, bg = c.surface })
  set("Pmenu", { fg = c.text, bg = c.surface })
  set("PmenuSel", { fg = c.bg, bg = c.lavender, bold = true })
  set("PmenuSbar", { bg = c.surface })
  set("PmenuThumb", { bg = c.surface2 })
  set("Folded", { fg = c.muted, bg = c.bg })
  set("FoldColumn", { fg = c.muted, bg = c.bg })
  set("Whitespace", { fg = c.surface2 })
  set("NonText", { fg = c.subtle })
  set("SpecialKey", { fg = c.subtle })
  set("Directory", { fg = c.blue })
  set("Title", { fg = c.blue, bold = true })
  set("Question", { fg = c.green })
  set("MoreMsg", { fg = c.green })
  set("ModeMsg", { fg = c.green })
  set("WarningMsg", { fg = c.yellow })
  set("ErrorMsg", { fg = c.red })

  -- Syntax
  set("Comment", { fg = c.muted, italic = true })
  set("Constant", { fg = c.peach })
  set("String", { fg = c.green })
  set("Character", { fg = c.green })
  set("Number", { fg = c.peach })
  set("Boolean", { fg = c.peach })
  set("Float", { fg = c.peach })
  set("Identifier", { fg = c.text })
  set("Function", { fg = c.blue })
  set("Statement", { fg = c.mauve })
  set("Conditional", { fg = c.mauve })
  set("Repeat", { fg = c.mauve })
  set("Label", { fg = c.cyan })
  set("Operator", { fg = c.cyan })
  set("Keyword", { fg = c.mauve })
  set("Exception", { fg = c.mauve })
  set("PreProc", { fg = c.pink })
  set("Include", { fg = c.pink })
  set("Define", { fg = c.pink })
  set("Macro", { fg = c.pink })
  set("PreCondit", { fg = c.pink })
  set("Type", { fg = c.yellow })
  set("StorageClass", { fg = c.mauve })
  set("Structure", { fg = c.teal })
  set("Typedef", { fg = c.yellow })
  set("Special", { fg = c.cyan })
  set("SpecialChar", { fg = c.pink })
  set("Tag", { fg = c.mauve })
  set("Delimiter", { fg = "#9399b2" })
  set("SpecialComment", { fg = c.muted, italic = true })
  set("Debug", { fg = c.red })

  -- Treesitter / semantic tokens
  set("@comment", { link = "Comment" })
  set("@comment.documentation", { link = "Comment" })
  set("@string", { link = "String" })
  set("@string.regex", { fg = c.pink })
  set("@string.escape", { fg = c.pink })
  set("@string.special", { fg = c.pink })
  set("@string.special.symbol", { fg = c.yellow })
  set("@number", { link = "Number" })
  set("@boolean", { link = "Boolean" })
  set("@constant", { link = "Constant" })
  set("@constant.builtin", { fg = c.peach })
  set("@constant.macro", { fg = c.pink })
  set("@module", { fg = c.text })
  set("@label", { fg = c.cyan })
  set("@keyword", { link = "Keyword" })
  set("@keyword.function", { fg = c.mauve })
  set("@keyword.return", { fg = c.mauve })
  set("@keyword.operator", { fg = c.mauve })
  set("@keyword.import", { fg = c.pink })
  set("@operator", { link = "Operator" })
  set("@function", { link = "Function" })
  set("@function.call", { link = "Function" })
  set("@function.builtin", { fg = c.peach })
  set("@method", { fg = c.blue })
  set("@method.call", { fg = c.blue })
  set("@constructor", { fg = c.blue })
  set("@parameter", { fg = c.red, italic = true })
  set("@variable", { fg = c.text })
  set("@variable.builtin", { fg = c.red })
  set("@variable.parameter", { fg = c.red, italic = true })
  set("@variable.member", { fg = c.cyan })
  set("@property", { fg = c.cyan })
  set("@field", { fg = c.cyan })
  set("@type", { link = "Type" })
  set("@type.builtin", { fg = c.yellow })
  set("@type.definition", { fg = c.blue })
  set("@attribute", { fg = c.yellow })
  set("@tag", { fg = c.mauve })
  set("@tag.attribute", { fg = c.green })
  set("@tag.delimiter", { fg = "#9399b2" })
  set("@punctuation", { fg = "#9399b2" })
  set("@punctuation.bracket", { fg = "#9399b2" })
  set("@punctuation.delimiter", { fg = "#9399b2" })
  set("@markup.heading", { fg = c.red, bold = true })
  set("@markup.link", { fg = c.blue, underline = true })
  set("@markup.raw", { fg = c.cyan })
  set("@markup.quote", { fg = c.green, italic = true })

  set("@lsp.type.class", { fg = c.teal })
  set("@lsp.type.enumMember", { fg = c.teal })
  set("@lsp.type.function", { fg = c.blue })
  set("@lsp.type.interface", { fg = c.teal })
  set("@lsp.type.method", { fg = c.blue })
  set("@lsp.type.namespace", { fg = c.text })
  set("@lsp.type.parameter", { fg = c.red, italic = true })
  set("@lsp.type.property", { fg = c.cyan })
  set("@lsp.type.struct", { fg = c.teal })
  set("@lsp.type.variable", { fg = c.text })

  -- Diagnostics / diff / git
  set("DiagnosticError", { fg = c.red })
  set("DiagnosticWarn", { fg = c.yellow })
  set("DiagnosticInfo", { fg = c.blue })
  set("DiagnosticHint", { fg = c.teal })
  set("DiagnosticOk", { fg = c.green })
  set("DiagnosticUnderlineError", { undercurl = true, sp = c.red })
  set("DiagnosticUnderlineWarn", { undercurl = true, sp = c.yellow })
  set("DiagnosticUnderlineInfo", { undercurl = true, sp = c.blue })
  set("DiagnosticUnderlineHint", { undercurl = true, sp = c.teal })
  set("DiffAdd", { bg = "#1E2A1E" })
  set("DiffChange", { bg = "#1E2430" })
  set("DiffDelete", { bg = "#2A1E1E" })
  set("DiffText", { bg = c.surface2 })
  set("Added", { fg = c.green })
  set("Changed", { fg = c.yellow })
  set("Removed", { fg = c.red })
  set("GitSignsAdd", { fg = c.green, bg = c.bg })
  set("GitSignsChange", { fg = c.yellow, bg = c.bg })
  set("GitSignsDelete", { fg = c.red, bg = c.bg })

  -- Common plugin groups
  set("BlinkCmpMenu", { fg = c.text, bg = c.surface })
  set("BlinkCmpMenuSelection", { fg = c.bg, bg = c.lavender, bold = true })
  set("SnacksNormal", { fg = c.text, bg = c.bg_float })
  set("SnacksPickerBoxBorder", { fg = c.surface, bg = c.bg_float })
  set("SnacksPickerTitle", { fg = c.lavender, bg = c.bg_float, bold = true })
  set("SnacksPickerDir", { fg = "#9399b2" })
  set("SnacksPickerFile", { fg = c.text })
  set("WhichKey", { fg = c.mauve })
  set("WhichKeyDesc", { fg = c.blue })
  set("WhichKeyGroup", { fg = c.yellow })
  set("WhichKeySeparator", { fg = c.muted })
end

return M
