return {
  -- Coding
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "super-tab",
        ["<Tab>"] = { "select_and_accept" },
        ["<C-j>"] = { "select_next" },
        ["<C-k>"] = { "select_prev" },
      },
    },
  },

  -- Colorscheme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = { transparent_background = true },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },

  -- Editor
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>e",
        "<cmd>Yazi<cr>",
        desc = "Open yazi at the current file",
      },
      {
        "<leader>E",
        "<cmd>Yazi cwd<cr>",
        desc = "Open the file manager in nvim's working directory",
      },
      {
        "<c-up>",
        "<cmd>Yazi toggle<cr>",
        desc = "Resume the last yazi session",
      },
    },
    opts = {
      open_for_directories = false,
      keymaps = {
        show_help = "<f1>",
      },
    },
  },

  -- Formatting
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts.formatters.sqlfluff = {
        args = { "format", "--dialect=ansi", "-t", "jinja", "-" },
      }
      for _, ft in ipairs({ "sql", "mysql", "plsql" }) do
        opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
        table.insert(opts.formatters_by_ft[ft], "sqlfluff")
      end
    end,
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers.basedpyright = {
        root_dir = function(fname)
          local util = require("lspconfig/util")
          local root_files = {
            "pyproject.toml",
          }
          return util.find_git_ancestor(fname) or util.root_pattern(unpack(root_files))(fname) or vim.fs.dirname(fname)
        end,
        settings = {
          basedpyright = {
            typeCheckingMode = "standard",
          },
        },
      }
      opts.servers.ruff = {
        root_dir = function(fname)
          local util = require("lspconfig/util")
          local root_files = {
            "pyproject.toml",
          }
          return util.find_git_ancestor(fname) or util.root_pattern(unpack(root_files))(fname) or vim.fs.dirname(fname)
        end,
      }
      opts.servers.pyright = {
        enabled = false,
      }
      opts.servers.sqlls = {
        settings = {},
      }
      opts.setup = {
        sqlls = function()
          if vim.fn.has("nvim-0.10") == 0 then
            LazyVim.lsp.on_attach(function(client, _)
              if client.name == "sqlls" then
                client.server_capabilities.documentFormattingProvider = true
              end
            end)
          end
        end,
      }
    end,
  },

  -- TreeSitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "sql" })
      end
    end,
  },

  -- Util
  {
    "okuuva/auto-save.nvim",
    event = { "InsertLeave", "TextChanged" },
    opts = {
      debounce_delay = 5000,
    },
  },
  {
    "rmagatti/auto-session",
    lazy = false,
    opts = {
      suppressed_dirs = { "~/Downloads", "/" },
      bypass_session_save_cmds = { "tabnew", "foldmethod" },
    },
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      notifier = {
        enabled = true,
        style = "fancy",
      },
      indent = { enabled = false },
      quickfile = { enabled = true },
      dim = { enabled = true },
      lazygit = {
        enabled = true,
        configure = true,
        open_on_setup = true,
        config = {
          os = { editPreset = "nvim-remote" },
          gui = { nerdFontsVersion = "3" },
        },
      },
      terminal = {
        win = {
          relative = "editor",
          position = "float",
          width = 0.8,
          height = 0.8,
          border = "rounded",
        },
      },
      styles = {
        notification = {
          wo = { wrap = true },
        },
        lazygit = {
          width = 0,
          height = 0,
        },
      },
    },
    keys = {
      {
        "<leader>un",
        function()
          Snacks.notifier.hide()
        end,
        desc = "Dismiss All Notifications",
      },
      {
        "<leader>bx",
        function()
          Snacks.bufdelete()
        end,
        desc = "Delete Buffer",
      },
      {
        "<leader>gg",
        function()
          Snacks.lazygit()
        end,
        desc = "Lazygit",
      },
      {
        "<leader>gi",
        function()
          Snacks.gitbrowse()
        end,
        desc = "Git Open on browser",
      },
      {
        "<leader>gL",
        function()
          Snacks.git.blame_line()
        end,
        desc = "Git Blame Line",
      },
      {
        "<c-t>",
        function()
          Snacks.terminal.toggle(nil, { cwd = vim.fn.getcwd() })
        end,
        desc = "Toggle Terminal",
      },
    },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          _G.dd = function(...)
            Snacks.debug.inspect(...)
          end
          _G.bt = function()
            Snacks.debug.backtrace()
          end
          vim.print = _G.dd

          Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
          Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
          Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
          Snacks.toggle.diagnostics():map("<leader>ud")
          Snacks.toggle.line_number():map("<leader>ul")
          Snacks.toggle
            .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
            :map("<leader>uc")
          Snacks.toggle.treesitter():map("<leader>uT")
          Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
          Snacks.toggle.inlay_hints():map("<leader>uh")
        end,
      })
    end,
  },

  -- Lualine
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.theme = "catppuccin" -- Set lualine theme to catppuccin
      opts.sections = {
        lualine_a = {
          {
            function()
              local path = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":.:h")
              return path == "." and "" or path
            end,
            color = { fg = "#a6adc8" }, -- Catppuccin Mocha subtext0 (brighter gray)
            gui = "bold",
          },
        },
        lualine_b = {
          {
            "filename",
            path = 0, -- Show only filename
            icons_enabled = false,
            gui = "bold",
            color = { fg = "#cdd6f4" }, -- Catppuccin Mocha text (white)
          },
        },
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = { 'branch' }, -- Move branch here
      }
      -- Remove the winbar settings since we moved them to the statusline
      opts.winbar = nil
    end,
  },

  -- Mason
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "basedpyright",
        "ruff",
        "sqlfmt",
      })
    end,
  },
}
