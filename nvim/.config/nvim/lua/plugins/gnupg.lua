return {
  {
    "jamessan/vim-gnupg",
    -- Must load at startup: vim-gnupg registers BufReadCmd autocmds for
    -- *.gpg/*.asc/*.pgp, which have to exist before the file is read.
    -- Lazy-loading on `ft` is too late (filetype is set after the read).
    lazy = false,
    init = function()
      -- Write encrypted files back as ASCII-armored (matches .asc).
      vim.g.GPGPreferArmor = 1
    end,
  },
}
