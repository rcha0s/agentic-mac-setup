-- Vim options. Extracted from init.lua so bootstrap stays bootstrap-only.
-- Order: general → indentation → search → splits → timing → clipboard/mouse →
-- cursor. Anything cursor/appearance related has an inline WHY because those
-- values are easy to break accidentally.

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
