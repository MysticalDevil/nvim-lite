return {
  -- Map of filetype to formatters
  formatters_by_ft = {
    c = { "clang_format" },
    clojure = { "zprint" },
    cmake = { "cmake_format" },
    cpp = { "clang_format" },
    cs = { "csharpier" },
    dart = { "dart_format" },
    elixir = { "mix" },
    fish = { "fish_indent" },
    go = { "gofumpt", "goimports-reviser", "golines" },
    java = { "google-java-format" },
    javascript = { "prettier" },
    javascriptreact = { "prettier" },
    json = { "jq" },
    kotlin = { "ktlint" },
    lua = { "stylua" },
    nix = { "nixpkgs_fmt" },
    perl = { "perlimports", "perltidy" },
    php = { "php_cs_fixer" },
    python = function(bufnr)
      if require("conform").get_formatter_info("ruff_format", bufnr).available then
        return { "ruff_format" }
      else
        return { "isort", "black" }
      end
    end,
    scala = { "scalafmt" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
    zig = { "zigfmt" },
    markdown = { "codespell" },
    text = { "codespell" },
    gitcommit = { "codespell" },
    -- Use the "_" filetype to run formatters on filetypes that don't
    -- have other formatters configured.
    ["_"] = { "trim_whitespace" },
  },
  -- Use pre-save formatting to keep one predictable formatting trigger.
  format_on_save = {
    lsp_fallback = true,
  },
  -- Set the log level. Use `:ConformInfo` to see the location of the log file.
  log_level = vim.log.levels.ERROR,
  -- Conform will notify you when a formatter errors
  notify_on_error = true,
  -- Define custom formatters here
  formatters = {},
}
