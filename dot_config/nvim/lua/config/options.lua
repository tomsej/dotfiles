-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.lazyvim_python_lsp = "basedpyright"
-- Set to "ruff_lsp" to use the old LSP implementation version.
vim.g.lazyvim_python_ruff = "ruff"
vim.opt.relativenumber = false
vim.g.snacks_animate = false
vim.opt.spell = false

vim.api.nvim_set_hl(0, "FlashMatch", { bg = "#17131F", fg = "#8EDD95", bold = false })
vim.api.nvim_set_hl(0, "FlashLabel", { bg = "#17131F", fg = "#FF84A8", bold = true })
vim.api.nvim_set_hl(0, "FlashCurrent", { bg = "#17131F", fg = "#8EDD95", bold = false })
