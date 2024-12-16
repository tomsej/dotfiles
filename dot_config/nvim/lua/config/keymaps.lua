-- redo
vim.keymap.set("n", "U", "<c-r>", { desc = "Redo" })

-- delete without yanking
vim.api.nvim_set_keymap("n", "d", '"dd', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "dd", '"ddd', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "D", '"dD', { noremap = true, silent = true })

vim.keymap.set("n", "c", '"cc', { desc = "Change without yanking", noremap = true, silent = true })
vim.keymap.set("n", "C", '"cC', { desc = "Change to end without yanking", noremap = true, silent = true })

-- home row goto end and start of line (same as in Helix editor) {{{
vim.keymap.set({ "n", "v", "o" }, "gh", "^", { desc = "Go to beginning of line" })
vim.keymap.set({ "n", "v", "o" }, "gl", "$", { desc = "Go to end of line" })

-- Search
vim.keymap.set("n", "ú", "/", { desc = "Search" })

-- Functions
local function copy_file_path_to_clipboard()
  local file_path = vim.fn.expand("%:p")
  vim.fn.setreg("+", file_path)
  print("Copied file path to clipboard: " .. file_path)
end

vim.keymap.set("n", "<leader>fp", copy_file_path_to_clipboard, { desc = "Copy file path to clipboard" })

local function copy_file_dir_to_clipboard()
  local file_dir = vim.fn.expand("%:p:h")
  vim.fn.setreg("+", file_dir)
  print("Copied file directory to clipboard: " .. file_dir)
end

vim.keymap.set("n", "<leader>fd", copy_file_dir_to_clipboard, { desc = "Copy file directory to clipboard" })

local function copy_file_name_to_clipboard()
  local file_name = vim.fn.expand("%:t")
  vim.fn.setreg("+", file_name)
  print("Copied file name to clipboard: " .. file_name)
end

vim.keymap.set("n", "<leader>fn", copy_file_name_to_clipboard, { desc = "Copy file name to clipboard" })

-- dbt
local function get_file_name_without_suffix()
  local file_name = vim.fn.expand("%:t:r")
  return file_name
end

local function dbt_build_current_file()
  local file_name = get_file_name_without_suffix()
  local command = "dbt build -s " .. file_name
  vim.fn.setreg("+", command)
  print("Copied file name to clipboard: " .. command)
end

vim.keymap.set("n", "<leader>dbbc", dbt_build_current_file, { desc = "Copy dbt build" })

local function dbt_build_current_file_run()
  local file_name = get_file_name_without_suffix()
  local cmd = "dbt build -s " .. file_name
  Snacks.terminal.open(cmd, { win = { position = "right", width = 0.25 }, interactive = false })
end

vim.keymap.set("n", "<leader>dbbr", dbt_build_current_file_run, { desc = "Run dbt build" })

local function dbt_build_current_file_compile()
  local file_name = get_file_name_without_suffix()
  local cmd = "dbt compile -s " .. file_name
  Snacks.terminal.open(cmd, { win = { position = "right", width = 0.25 }, interactive = false })
end

vim.keymap.set(
  "n",
  "<leader>dbc",
  dbt_build_current_file_compile,
  { desc = "dbt compile current file and run in snacks" }
)
