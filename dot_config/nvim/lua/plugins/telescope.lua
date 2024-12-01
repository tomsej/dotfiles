local actions = require("telescope.actions")

return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      layout_strategy = "horizontal",
      layout_config = { prompt_position = "top" },
      sorting_strategy = "ascending",
      winblend = 0,
      mappings = {
        i = {
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
          ["<C-d>"] = require("telescope.actions").delete_buffer,
        },
        n = {
          ["d"] = require("telescope.actions").delete_buffer,
        },
      },
    },
  },
}
