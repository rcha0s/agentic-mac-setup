-- Colorscheme. Rose Pine Moon matches the WezTerm color scheme so both
-- environments feel consistent. This also fixes the "invisible cursor on
-- gray background" issue that plugins like Neogit hit with Neovim's default.
return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    opts = {
      variant = "moon",
      dark_variant = "moon",
      styles = {
        italic = false,
        transparency = false,
      },
    },
    config = function(_, opts)
      require("rose-pine").setup(opts)
      vim.cmd.colorscheme("rose-pine")
    end,
  },
}
