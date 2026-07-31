-- which-key: popup that lists the possible completions of a partial keymap.
-- With <leader>g* (neogit) and <leader>f* (snacks pickers) and <leader>h*
-- (gitsigns) all active, the leader tree is deep enough to justify the aid.
--
-- Adopts modern (v3+) API: `spec` describes the groups; individual keymap
-- descriptions still come from each plugin's `desc =` on its own bindings.
return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      spec = {
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>h", group = "hunk" },
      },
    },
  },
}
