-- redo
vim.keymap.set("n", "U", "<c-r>", { desc = "Redo" })

-- delete without yanking
vim.keymap.set({ "n", "v" }, "d", '"dd', { desc = "Delete without yanking", noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "dd", '"ddd', { desc = "Delete line without yanking", noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "D", '"dD', { desc = "Delete to end without yanking", noremap = true, silent = true })

-- change without yanking (normal mode only)
vim.keymap.set("n", "c", '"cc', { desc = "Change without yanking", noremap = true, silent = true })
vim.keymap.set("n", "C", '"cC', { desc = "Change to end without yanking", noremap = true, silent = true })

--: home row goto end and start of line (same as in Helix editor) {{{
vim.keymap.set({ "n", "v", "o" }, "gh", "^", { desc = "Go to beginning of line" })
vim.keymap.set({ "n", "v", "o" }, "gl", "$", { desc = "Go to end of line" })
--: }}}

-- Buffer navigation
vim.keymap.set("n", "<C-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
vim.keymap.set("n", "<C-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
