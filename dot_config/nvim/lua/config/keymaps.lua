-- Keymaps are automatically loaded on the VeryLazy event

-- Redo
vim.keymap.set("n", "U", "<c-r>", { desc = "Redo" })

-- Delete/change without yanking
vim.keymap.set({ "n", "v" }, "d", '"dd', { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "dd", '"ddd', { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "D", '"dD', { noremap = true, silent = true })
vim.keymap.set("n", "c", '"cc', { noremap = true, silent = true })
vim.keymap.set("n", "C", '"cC', { noremap = true, silent = true })

-- Home row line navigation (like Helix)
vim.keymap.set({ "n", "v", "o" }, "gh", "^", { desc = "Go to beginning of line" })
vim.keymap.set({ "n", "v", "o" }, "gl", "$", { desc = "Go to end of line" })

-- Delete buffer
vim.keymap.set("n", "<c-x>", function() Snacks.bufdelete() end, { desc = "Delete buffer" })

-- Czech keyboard shortcuts
vim.keymap.set("n", "í", "{")
vim.keymap.set("n", "é", "}")
vim.keymap.set("n", "č", "$")
vim.keymap.set("n", "ž", "^")

-- Copy file path variants
local function copy(expr, desc)
  local val = vim.fn.expand(expr)
  vim.fn.setreg("+", val)
  print("Copied " .. desc .. ": " .. val)
end

vim.keymap.set("n", "<leader>fpp", function() copy("%:p", "file path") end, { desc = "Path" })
vim.keymap.set("n", "<leader>fpd", function() copy("%:p:h", "directory") end, { desc = "Directory" })
vim.keymap.set("n", "<leader>fpn", function() copy("%:t", "file name") end, { desc = "Name" })
vim.keymap.set("n", "<leader>fps", function() copy("%:t:r", "stem") end, { desc = "Name (no suffix)" })

-- Session
vim.keymap.set("n", "<leader>r", function() require("persistence").select() end, { desc = "Load session" })
