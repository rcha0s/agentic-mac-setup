-- neogit: Magit-style git UI. Diff review + staging + commit from Neovim.
return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    cmd = { "Neogit", "DiffviewOpen", "DiffviewClose" },
    keys = {
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit" },
      { "<leader>gc", "<cmd>Neogit commit<cr>", desc = "Neogit commit" },
      { "<leader>gp", "<cmd>Neogit pull<cr>", desc = "Neogit pull" },
      { "<leader>gP", "<cmd>Neogit push<cr>", desc = "Neogit push" },
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview open" },
      { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Diffview close" },
    },
    opts = {
      graph_style = "unicode",
      integrations = {
        telescope = true,
        diffview = true,
      },
    },
  },
}
