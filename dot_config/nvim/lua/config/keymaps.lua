-- redo
vim.keymap.set("n", "U", "<c-r>", { desc = "Redo" })

-- delete without yanking
vim.keymap.set("n", "c", '"cc', { desc = "Change without yanking", noremap = true, silent = true })
vim.keymap.set("n", "C", '"cC', { desc = "Change to end without yanking", noremap = true, silent = true })

--: home row goto end and start of line (same as in Helix editor) {{{
vim.keymap.set({ "n", "v", "o" }, "gh", "^", { desc = "Go to beginning of line" })
vim.keymap.set({ "n", "v", "o" }, "gl", "$", { desc = "Go to end of line" })
--: }}}

-- Buffer navigation
vim.keymap.set("n", "<C-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
vim.keymap.set("n", "<C-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- Functions
local function copy_file_path_to_clipboard()
  local file_path = vim.fn.expand("%:p")
  vim.fn.setreg("+", file_path)
  print("Copied file path to clipboard: " .. file_path)
end

vim.keymap.set("n", "<leader>fp", copy_file_path_to_clipboard, { desc = "Copy file path to clipboard" })
vim.keymap.set("n", "ú", "/", { desc = "Search" })
