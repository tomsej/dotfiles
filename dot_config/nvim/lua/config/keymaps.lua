-- redo
vim.keymap.set("n", "U", "<c-r>", { desc = "Redo" })

-- delete without yanking
vim.api.nvim_set_keymap("n", "d", '"dd', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "dd", '"ddd', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "D", '"dD', { noremap = true, silent = true })

vim.api.nvim_set_keymap("v", "d", '"dd', { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "dd", '"ddd', { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "D", '"dD', { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "c", '"cc', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "C", '"cC', { noremap = true, silent = true })

--: home row goto end and start of line (same as in Helix editor) {{{
vim.keymap.set({ "n", "v", "o" }, "gh", "^", { desc = "Go to beginning of line" })
vim.keymap.set({ "n", "v", "o" }, "gl", "$", { desc = "Go to end of line" })
--: }}}

-- Buffer navigation
vim.keymap.set("n", "<C-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
vim.keymap.set("n", "<C-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
