-- oil.nvim: edit the filesystem like a buffer. Kun uses this for filesystem
-- navigation instead of a tree sidebar.
return {
  {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory (oil)" },
      { "<leader>e", "<cmd>Oil<cr>", desc = "Explorer (oil)" },
    },
    opts = {
      default_file_explorer = true,
      delete_to_trash = true,
      skip_confirm_for_simple_edits = false,
      view_options = {
        show_hidden = true,
      },
      float = {
        padding = 2,
        max_width = 100,
        max_height = 30,
      },
      keymaps = {
        ["<C-h>"] = false,
        ["<C-l>"] = false,
        ["q"] = "actions.close",
      },
    },
  },
}
