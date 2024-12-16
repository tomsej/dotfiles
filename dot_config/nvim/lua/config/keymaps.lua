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

local function dbt_build_current_file(cmd_type)
  local file_name = get_file_name_without_suffix()
  local command = "dbt " .. cmd_type .. " -s " .. file_name
    if cmd_type == "build" then
        vim.fn.setreg("+", command)
        print("Copied dbt build command to clipboard: " .. command)
    else
        Snacks.terminal.open(command, { win = { position = "right", width = 0.25 }, interactive = false })
    end
end

vim.keymap.set("n", "<leader>dbbc", function() dbt_build_current_file("build") end, { desc = "Copy dbt build" })
vim.keymap.set("n", "<leader>dbbr", function() dbt_build_current_file("build") end, { desc = "Run dbt build" })
vim.keymap.set("n", "<leader>dbc", function() dbt_build_current_file("compile") end, { desc = "dbt compile current file and run in snacks" })
vim.keymap.set("n", "<leader>dbb", function() dbt_build_current_file("build") end, { desc = "dbt build current file and run in snacks" })
vim.keymap.set("n", "<leader>dbr", function() dbt_build_current_file("retry") end, { desc = "dbt retry current file and run in snacks" })
