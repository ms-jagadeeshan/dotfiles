-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "lua",
      "vim",
      "json",
      "xml",
      "bash",
      "python",
      "dockerfile",
      "cpp",
      "markdown",
      "make",
      "cmake",
  
      -- add more arguments for adding more treesitter parsers
    },
  },
}
