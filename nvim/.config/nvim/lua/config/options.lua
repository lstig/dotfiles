vim.g.editorconfig = false

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.listchars:append({
  tab = "→ ",
  trail = "·",
  extends = ">",
  precedes = "<",
  space = "·",
})
vim.opt.list = true
