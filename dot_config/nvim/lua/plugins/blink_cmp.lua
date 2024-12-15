return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      preset = "super-tab",
      ["<Tab>"] = { "select_and_accept" },
      ["<C-j>"] = { "select_next" },
      ["<C-k>"] = { "select_prev" },
    },
  },
}
