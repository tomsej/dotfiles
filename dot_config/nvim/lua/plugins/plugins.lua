return {
  ---------- Disabled LazyVim defaults ----------
  { "akinsho/bufferline.nvim", enabled = false },
  { "mfussenegger/nvim-lint", enabled = false },
  { "folke/tokyonight.nvim", enabled = false },
  { "saghen/blink.cmp", enabled = false },
  { "stevearc/conform.nvim", enabled = false },
  { "folke/lazydev.nvim", enabled = false },
  { "nvim-mini/mini.pairs", enabled = false },
  { "folke/ts-comments.nvim", enabled = false },
  { "windwp/nvim-ts-autotag", enabled = false },
  { "catppuccin/nvim", enabled = false },
  { "neovim/nvim-lspconfig", enabled = false },
  { "mason-org/mason.nvim", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },
  { "nvim-treesitter/nvim-treesitter-textobjects", enabled = false },
  { "nvim-mini/mini.ai", enabled = false },
  { "folke/trouble.nvim", enabled = false },
  { "folke/todo-comments.nvim", enabled = false },
  { "MagicDuck/grug-far.nvim", enabled = false },
  { "nvim-neo-tree/neo-tree.nvim", enabled = false },

  ---------- Colorscheme ----------
  { "LazyVim/LazyVim", opts = { colorscheme = "tomsej" } },

  ---------- Statusline ----------
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local theme = require("themes.tomsej").lualine_theme()
      opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
        theme = theme,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      })

      opts.sections = vim.tbl_deep_extend("force", opts.sections or {}, {
        lualine_a = { { "mode", fmt = function(str) return str:sub(1, 1) end } },
        lualine_b = { { "branch", icon = "" } },
        lualine_c = { { "filename", path = 1, symbols = { modified = "", readonly = "", unnamed = "[No Name]" } } },
        lualine_x = { { "diagnostics", symbols = { error = "E:", warn = "W:", info = "I:", hint = "H:" } } },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      })
    end,
  },

  ---------- Diff ----------
  {
    "esmuellert/codediff.nvim",
    cmd = "CodeDiff",
    keys = {
      { "<leader>gd", "<cmd>CodeDiff HEAD<cr>", desc = "Diff vs HEAD" },
    },
    opts = {
      diff = { layout = "side-by-side" },
      keymaps = {
        view = {
          toggle_stage = "s",
          stage_hunk = "<leader>hs",
          unstage_hunk = "<leader>hu",
          discard_hunk = "<leader>hr",
        },
      },
    },
  },

  ---------- Snacks ----------
  {
    "folke/snacks.nvim",
    opts = {
      bigfile = { enabled = true },
      notifier = { enabled = true, style = "fancy" },
      picker = {},
      indent = { enabled = false },
      quickfile = { enabled = true },
      dim = { enabled = true },
      scratch = { enabled = false },
      zen = {
        enabled = true,
        width = 250,
        toggles = { inlay_hints = true, dim = false, diagnostics = true },
        show = { statusline = true },
      },
      lazygit = {
        enabled = true,
        configure = true,
        config = {
          os = { editPreset = "nvim-remote" },
          gui = { nerdFontsVersion = "3" },
        },
      },
      terminal = {
        win = { relative = "editor", position = "float", width = 0.8, height = 0.8, border = "rounded" },
      },
      styles = {
        notification = { wo = { wrap = true } },
        lazygit = { width = 0, height = 0 },
        zen = { width = 180 },
      },
    },
    keys = {
      { "<leader>z", function() Snacks.picker.undo() end, desc = "Undo" },
      { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss Notifications" },
      { "<leader>e", function() Snacks.picker.explorer({ layout = "sidebar", auto_close = true }) end, desc = "Explorer" },
      { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
      { "<leader>gi", function() Snacks.gitbrowse() end, desc = "Git Open in browser" },
      { "<leader>gL", function() Snacks.git.blame_line() end, desc = "Git Blame Line" },
      { "<leader><space>", function() Snacks.picker.smart() end, desc = "Find Files" },
      { "ú", function() Snacks.picker.lines({ layout = "default" }) end, desc = "Buffer Lines" },
      { "<c-p>", function() Snacks.picker.projects() end, desc = "Projects" },
      { "<leader>t", function() Snacks.terminal.toggle(nil, { cwd = vim.fn.getcwd() }) end, desc = "Terminal" },
    },
  },
}
