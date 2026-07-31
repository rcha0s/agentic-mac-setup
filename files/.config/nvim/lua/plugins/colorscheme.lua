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

      -- Snacks picker's directory column defaults to a foreground color that
      -- is nearly invisible on rose-pine moon. Nudge it toward the palette's
      -- "subtle" foreground so file paths are readable in fzf-style pickers.
      -- Fix adapted from Kun Chen's dotfiles config.
      local ok, palette = pcall(require, "rose-pine.palette")
      if ok then
        vim.api.nvim_set_hl(0, "SnacksPickerDir", { fg = palette.subtle })
      end
    end,
  },
}
