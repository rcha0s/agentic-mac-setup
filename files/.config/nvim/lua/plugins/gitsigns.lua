-- gitsigns: always-on git context. Sign column shows +/-/~ per changed line;
-- `current_line_blame` shows the last-touch author/message on the current
-- line only, low-noise. Complements Neogit (which is modal) — gitsigns is
-- what you look at while writing code.
return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 500,
        virt_text_pos = "eol",
      },
      signs = {
        add          = { text = "+" },
        change       = { text = "~" },
        delete       = { text = "_" },
        topdelete    = { text = "‾" },
        changedelete = { text = "~" },
        untracked    = { text = "┆" },
      },
    },
    keys = {
      { "]c", function() require("gitsigns").nav_hunk("next") end, desc = "Next hunk" },
      { "[c", function() require("gitsigns").nav_hunk("prev") end, desc = "Prev hunk" },
      { "<leader>hp", function() require("gitsigns").preview_hunk() end, desc = "Preview hunk" },
      { "<leader>hb", function() require("gitsigns").blame_line({ full = true }) end, desc = "Blame line (full)" },
    },
  },
}
