return {
  {
    "rmagatti/auto-session",
    lazy = false,

    opts = {
      suppressed_dirs = { "~/Downloads", "/" },
      -- log_level = 'debug',
      bypass_session_save_cmds = { "tabnew", "foldmethod" },
    },
  },
}
