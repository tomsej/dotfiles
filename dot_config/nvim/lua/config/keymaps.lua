-- redo
vim.keymap.set("n", "U", "<c-r>", { desc = "Redo" })

-- delete without yanking
vim.keymap.set({ "n", "v" }, "d", '"_d', { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "dd", '"_dd', { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "D", '"_D', { noremap = true, silent = true })

vim.keymap.set("n", "c", '"cc', { desc = "Change without yanking", noremap = true, silent = true })
vim.keymap.set("n", "C", '"cC', { desc = "Change to end without yanking", noremap = true, silent = true })

-- home row goto end and start of line (same as in Helix editor) {{{
vim.keymap.set({ "n", "v", "o" }, "gh", "^", { desc = "Go to beginning of line" })
vim.keymap.set({ "n", "v", "o" }, "gl", "$", { desc = "Go to end of line" })

-- Search
vim.keymap.set("n", "ú", "/", { desc = "Search" })

-- Functions
local function copy_to_clipboard(expression, description)
  local value = vim.fn.expand(expression)
  vim.fn.setreg("+", value)
  print("Copied " .. description .. " to clipboard: " .. value)
end

vim.keymap.set("n", "<leader>fpp", function()
  copy_to_clipboard("%:p", "file path")
end, { desc = "File path to clipboard" })
vim.keymap.set("n", "<leader>fd", function()
  copy_to_clipboard("%:p:h", "file directory")
end, { desc = "File directory to clipboard" })
vim.keymap.set("n", "<leader>fn", function()
  copy_to_clipboard("%:t", "file name")
end, { desc = "File name to clipboard" })
vim.keymap.set("n", "<leader>fr", function()
  copy_to_clipboard("%:t:r", "file name without suffix")
end, { desc = "Copy file name without suffix to clipboard" })

-- dbt
local function get_file_name_without_suffix()
  local file_name = vim.fn.expand("%:t:r")
  return file_name
end

local function dbt(cmd_type, copy)
  local file_name = get_file_name_without_suffix()
  local command = "dbt " .. cmd_type .. " -s " .. file_name
  if copy == true then
    vim.fn.setreg("+", command)
    print("Copied dbt command to clipboard: " .. command)
  else
    Snacks.terminal.open(command, { win = { position = "right", width = 0.25 }, interactive = false })
  end
end

vim.keymap.set("n", "<leader>dbp", function()
  dbt("build", true)
end, { desc = "Copy dbt build" })
vim.keymap.set("n", "<leader>dbb", function()
  dbt("build", false)
end, { desc = "Run dbt build" })
vim.keymap.set("n", "<leader>dbc", function()
  dbt("compile", false)
end, { desc = "Run dbt compile" })
vim.keymap.set("n", "<leader>dbr", function()
  dbt("retry", false)
end, { desc = "Run dbt retry" })
