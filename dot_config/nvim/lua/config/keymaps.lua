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

vim.keymap.set("n", "<leader>fp", function() copy_to_clipboard("%:p", "file path") end, { desc = "Copy file path to clipboard" })
vim.keymap.set("n", "<leader>fd", function() copy_to_clipboard("%:p:h", "file directory") end, { desc = "Copy file directory to clipboard" })
vim.keymap.set("n", "<leader>fn", function() copy_to_clipboard("%:t", "file name") end, { desc = "Copy file name to clipboard" })

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
