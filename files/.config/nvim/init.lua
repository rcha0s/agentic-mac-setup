-- Neovim entry point. Kun's stated stack: oil.nvim for filesystem, neogit for
-- git, snacks.nvim for pickers/dashboard/notifier. Heavy lifting lives in
-- those plugins; init.lua stays minimal.

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.termguicolors = true
opt.undofile = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.ignorecase = true
opt.smartcase = true
opt.splitright = true
opt.splitbelow = true
opt.scrolloff = 8
opt.updatetime = 200
opt.timeoutlen = 400
opt.clipboard = "unnamedplus"
opt.mouse = "a"
opt.wrap = false
opt.cursorline = true              -- highlight the current line
opt.cursorlineopt = "number,line"  -- highlight number column + line body
-- Make the block cursor visible on top of dark plugin backgrounds (Neogit,
-- oil, snacks). Vertical bar in insert mode; block elsewhere; blink on.
opt.guicursor = "n-v-c-sm:block-blinkwait700-blinkoff400-blinkon250,i-ci-ve:ver25,r-cr-o:hor20"

-- lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = { { import = "plugins" } },
  install = { colorscheme = { "habamax" } },
  checker = { enabled = true, notify = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "matchit", "matchparen", "netrwPlugin",
        "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
  },
})
