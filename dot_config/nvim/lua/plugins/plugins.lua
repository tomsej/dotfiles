local icons = LazyVim.config.icons

return {
  -- Coding
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "super-tab",
        ["<CR>"] = { "select_and_accept" },
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
    -- opts = { transparent_background = true },
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
      debounce_delay = 1000,
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
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = true,
    version = false, -- set this if you want to always pull the latest change
    opts = {
      -- add any opts here
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    -- build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
  },
  -- Which Key
  {
    "folke/which-key.nvim",
    opts = function()
      require("which-key").add({
        { "<leader>db", group = "+dbt", icon = "󰆼" }, -- group
        { "<leader>fp", group = "+copy filepath" }, -- group
      })
    end,
  },
  -- Lualine
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local colors = {
        red = "#f38ba8", -- Catppuccin Mocha red
        yellow = "#f9e2af", -- Catppuccin Mocha yellow
        blue = "#89b4fa", -- Catppuccin Mocha blue
        green = "#a6e3a1", -- Catppuccin Mocha green
        gray = "#6c7086", -- Catppuccin Mocha gray
        white = "#cdd6f4", -- Catppuccin Mocha white
      }

      opts.theme = "catppuccin"
      opts.options = opts.options or {}
      opts.options.component_separators = { left = "", right = "" }
      opts.options.always_divide_middle = false
      opts.options.always_show_tabline = false
      opts.sections = {
        lualine_a = { "mode" },
        lualine_b = {
          {
            "branch",
          },
          {
            function()
              local function run_git_cmd(cmd)
                local handle = io.popen(cmd)
                if handle then
                  local result = handle:read("*a")
                  handle:close()
                  return result:gsub("\n", "")
                end
                return ""
              end

              -- Check if in git repo
              local is_git = run_git_cmd("git rev-parse --is-inside-work-tree 2>/dev/null")
              if is_git == "" then
                return ""
              end

              local ahead = tonumber(run_git_cmd("git rev-list --count HEAD @{u}..HEAD 2>/dev/null") or "0")
              local behind = tonumber(run_git_cmd("git rev-list --count HEAD..@{u} 2>/dev/null") or "0")

              local status = ""
              if behind then
                status = status .. "↓" .. behind
              end
              if ahead then
                status = status .. " ↑" .. ahead
              end

              return status
            end,
          },
        },
        lualine_c = {
          {
            "buffers",
            icons_enabled = false,
            modified_status = false,
            symbols = {
              modified = "", -- Text to show when the buffer is modified
              alternate_file = "", -- Text to show to identify the alternate file
              directory = "", -- Text to show when the buffer is a directory
            },
          },
        },
        lualine_x = {
          {
            "diagnostics",
            sources = { "nvim_diagnostic" },
            symbols = {
              error = icons.diagnostics.Error,
              warn = icons.diagnostics.Warn,
              info = icons.diagnostics.Info,
              hint = icons.diagnostics.Hint,
            },
            diagnostics_color = {
              error = { fg = colors.red },
              warn = { fg = colors.yellow },
              info = { fg = colors.blue },
            },
            padding = { right = 1 },
          },
          {
            function()
              local path = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":.:h")
              return path == "." and "" or path
            end,
            color = { fg = colors.gray },
            gui = "bold",
          },
        },
        lualine_y = {
          {
            "filename",
            path = 0,
            icons_enabled = false,
            gui = "bold",
            color = { fg = colors.white },
          },
        },
        lualine_z = {
          {
            function()
              return #vim.fn.getbufinfo({ buflisted = 1 })
            end,
          },
        },
      }
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
  {
    "echasnovski/mini.move",
    opts = {
      mappings = {
        -- move visual selection in visual mode
        left = "<S-Left>",
        right = "<S-Right>",
        down = "<S-Down>",
        up = "<S-Up>",

        -- move current line in normal mode
        line_left = "<s-Left>",
        line_down = "<s-Down>",
        line_right = "<s-Right>",
        line_up = "<s-Up>",
      },
    },
  },
}
