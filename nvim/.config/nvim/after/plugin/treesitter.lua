if not pcall(require, "nvim-treesitter") then
  return
end

local _ = require("nvim-treesitter.configs").setup {
  ensure_installed = {
    "c", 
    "go",
    "html",
    "javascript",
    "json",
    "lua", 
    "markdown",
    "pkl",
    "python",
    "query",
    "rust",
    "toml",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
    "yaml",
  },
  
  highlight = {
    enable = true,
  },

  indent = {
    enable = true
  }
}