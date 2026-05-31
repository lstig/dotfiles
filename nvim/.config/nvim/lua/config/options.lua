-- tab settings
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- whitespace characters
vim.opt.listchars:append {
  tab = "→ ",
  trail = "·",
  extends = ">",
  precedes = "<",
  space = "·",
}
vim.opt.list = true
