-- Non-plugin keymaps. Plugin keys stay with their plugin spec (see
-- lua/plugins/*.lua and each spec's `keys = { ... }` list).
--
-- Rule of thumb: put a binding here only if it doesn't belong to any specific
-- plugin. If it depends on Snacks/Neogit/oil/gitsigns/etc., put it there.

-- Register-preserving paste in visual mode. Default `p` overwrites the
-- unnamed register with the replaced text, which breaks "yank once, paste
-- many times." This restores the yanked register after the paste.
-- expr=true requires the function to return keystrokes; vim.v.register must
-- be evaluated at press-time, so it lives inside the callback body.
vim.keymap.set("x", "p", function()
  return 'pgv"' .. vim.v.register .. "y"
end, {
  expr = true,
  desc = "Paste over selection, keep register",
})

-- Select the entire buffer with Ctrl-A. Doesn't override any default that
-- users hit day-to-day (default <C-a> is increment-number, which most people
-- never invoke; <C-x> for decrement remains untouched).
vim.keymap.set("n", "<C-a>", "ggVG", { desc = "Select all" })
