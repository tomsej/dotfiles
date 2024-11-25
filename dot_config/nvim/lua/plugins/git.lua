return {
  {
    "sindrets/diffview.nvim",
    -- requires = 'nvim-lua/plenary.nvim',
    dependencies = "nvim-lua/plenary.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>df", "<cmd>DiffviewFileHistory %<cr>", desc = "DiffviewFileHistory" },
      { "<leader>do", "<cmd>DiffviewOpen<cr>", desc = "DiffviewOpen" },
      { "<leader>dc", "<cmd>DiffviewClose<cr>", desc = "DiffviewClose" },
      { "<leader>dr", "<cmd>DiffviewRefresh<cr>", desc = "DiffviewRefresh" },
    },
    config = function()
      local opts = {
        view = {
          merge_tool = {
            layout = "diff3_vertical",
          },
        },
      }
      if vim.fn.winwidth(0) <= 120 then
        opts.view.file_history = { layout = "diff2_vertical" }
      end
      require("diffview").setup(opts)
    end,
  },
}
