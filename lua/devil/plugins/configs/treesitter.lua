local options = {
  ensure_installed = {
    "bash",
    "c",
    "cpp",
    "css",
    "dart",
    "go",
    "html",
    "java",
    "javascript",
    "json",
    "lua",
    "markdown",
    "markdown_inline",
    "python",
    "rust",
    "ruby",
    "tsx",
    "typescript",
    "yaml",
    "zig",
  },

  highlight = {
    enable = true,
    use_languagetree = true,
  },

  indent = { enable = true },

  -- https://github.com/RRethy/nvim-treesitter-endwise
  endwise = { enable = true },
  -- http://github.com/windwp/nvim-ts-autotag
  autotag = {
    enable = true,
    enable_rename = true,
    enable_close = true,
    enable_close_on_slash = true,
  },
  -- nvim-treesitter/nvim-treesitter-refactor
  refactor = {
    highlight_definitions = { enable = true },
    smart_rename = {
      enable = true,
      keymaps = {
        smart_rename = "grr",
      },
    },
  },
  -- nvim-treesitter/nvim-treesitter-textobjects
  textobjects = { enable = true },
}

return options
