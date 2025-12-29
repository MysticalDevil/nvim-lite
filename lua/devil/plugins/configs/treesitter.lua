return {
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

  sync_install = false,
  auto_install = true,

  highlight = {
    enable = true,
    use_languagetree = true,
  },

  indent = { enable = true },
  endwise = { enable = true },
  autotag = {
    enable = true,
    enable_rename = true,
    enable_close = true,
    enable_close_on_slash = true,
  },
}
