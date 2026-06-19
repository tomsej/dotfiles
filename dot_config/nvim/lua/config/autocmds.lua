-- Autocmds are automatically loaded on the VeryLazy event
pcall(vim.api.nvim_del_augroup_by_name, "lazyvim_wrap_spell")
