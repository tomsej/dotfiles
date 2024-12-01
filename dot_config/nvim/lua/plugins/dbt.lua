return {
  { "3fonov/dbt-nvim", config = true },
  {
    "PedramNavid/dbtpal",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    ft = {
      "sql",
      "md",
      "yaml",
    },
    config = function()
      require("dbtpal").setup({
        extended_path_search = true,
        protect_compiled_files = true,
      })
      require("telescope").load_extension("dbtpal")
    end,
  },
}
