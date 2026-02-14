return function(utils)
  return {
    {
      "saghen/blink.cmp",
      event = "VeryLazy",
      dependencies = "rafamadriz/friendly-snippets",
      version = "*",
      opts = function()
        return require("devil.plugins.configs.cmp")
      end,
      opts_extend = { "sources.default" },
    },

    {
      "folke/lazydev.nvim",
      ft = "lua",
      opts = {
        library = {
          "lazy.nvim",
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          { path = "snacks.nvim", words = { "Snacks" } },
        },
      },
    },

    { "b0o/schemastore.nvim", ft = { "json", "yaml" } },
    { "vuki656/package-info.nvim", event = "BufRead package.json" },

    {
      "mrcjkb/rustaceanvim",
      ft = "rust",
      lazy = false,
      version = "^7",
    },
    {
      "saecki/crates.nvim",
      tag = "stable",
      event = "BufRead Cargo.toml",
    },

    {
      "stevearc/conform.nvim",
      event = { "BufWritePre" },
      cmd = { "ConformInfo" },
      keys = {
        {
          "<leader>f",
          function()
            require("conform").format({ async = true, lsp_fallback = true })
          end,
          mode = "",
          desc = "Format buffer",
        },
      },
      opts = require("devil.plugins.configs.fmt"),
      init = function()
        vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
      end,
    },

    {
      "mfussenegger/nvim-lint",
      event = "BufWritePost",
      config = function()
        require("devil.plugins.configs.lint")
      end,
    },

    {
      "nvim-neotest/neotest",
      dependencies = {
        "antoinemadec/FixCursorHold.nvim",
        "nvim-neotest/nvim-nio",
        "nvim-neotest/neotest-python",
        "nvim-neotest/neotest-jest",
        "nvim-neotest/neotest-plenary",
        "nvim-neotest/neotest-go",
        "nvim-neotest/neotest-vim-test",
        "rouge8/neotest-rust",
        "lawrence-laz/neotest-zig",
      },
      opts = function()
        return require("devil.plugins.configs.neotest")
      end,
    },

    {
      "mfussenegger/nvim-dap",
      lazy = true,
      dependencies = {
        "rcarriga/nvim-dap-ui",
        "theHamsta/nvim-dap-virtual-text",
        "LiadOz/nvim-dap-repl-highlights",
      },
      keys = utils.get_lazy_keys("dap"),
      config = function()
        require("devil.plugins.configs.dap")
      end,
    },
  }
end
