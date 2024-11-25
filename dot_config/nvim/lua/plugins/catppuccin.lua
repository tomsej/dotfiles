return {
  -- add catppuccin
  { "catppuccin/nvim", name = "catppuccin", priority = 1000, opts = { transparent_background = true } },
  -- Configure LazyVim to load catppuccin
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}

