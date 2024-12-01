-- redo
vim.keymap.set("n", "U", "<c-r>", { desc = "Redo" })

-- delete without yanking
vim.api.nvim_set_keymap("n", "d", '"dd', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "dd", '"ddd', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "D", '"dD', { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "c", '"cc', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "C", '"cC', { noremap = true, silent = true })

-- DBT
vim.keymap.set("n", "<leader>tc", ":DbtCompile<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>ty", ":DbtModelYaml<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>tr", ":DbtRun<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>tf", ":DbtRunFull<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>tt", ":DbtTest<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>t+", ":DbtListUpstreamModels<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>t-", ":DbtListDownstreamModels<CR>", { noremap = true, silent = true })

--: home row goto end and start of line (same as in Helix editor) {{{
vim.keymap.set({ "n", "v", "o" }, "gh", "^", { desc = "Go to beginning of line" })
vim.keymap.set({ "n", "v", "o" }, "gl", "$", { desc = "Go to end of line" })
--: }}}
