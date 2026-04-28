return function()
  return {
    {
      "saghen/blink.cmp",
      event = "VeryLazy",
      dependencies = "rafamadriz/friendly-snippets",
      version = "1.*",
      opts = function()
        return require("devil.plugins.configs.cmp")
      end,
      opts_extend = { "sources.default" },
    },

    {
      "milanglacier/minuet-ai.nvim",
      event = "InsertEnter",
      opts = {
        provider = "openai_fim_compatible",
        request_timeout = 3,
        blink = {
          enable_auto_complete = false,
        },
        cmp = {
          enable_auto_complete = false,
        },
        virtualtext = {
          auto_trigger_ft = {},
          keymap = {
            accept = "<A-y>",
            accept_line = "<A-l>",
            accept_n_lines = "<A-z>",
            prev = "<A-[>",
            next = "<A-]>",
            dismiss = "<A-e>",
          },
          show_on_completion_menu = false,
        },
        provider_options = {
          openai_fim_compatible = {
            api_key = "DEEPSEEK_API_KEY",
            name = "Deepseek",
            end_point = "https://api.deepseek.com/beta/completions",
            model = "deepseek-v4-flash",
            optional = {
              max_tokens = 256,
              top_p = 0.9,
            },
          },
        },
      },
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

    { "b0o/SchemaStore.nvim", ft = { "json", "yaml" } },
    { "vuki656/package-info.nvim", event = "BufRead package.json" },

    {
      "mrcjkb/rustaceanvim",
      ft = "rust",
      lazy = false,
      version = "^9",
    },
    {
      "saecki/crates.nvim",
      event = "BufRead Cargo.toml",
      config = function()
        require("crates").setup({})
      end,
    },

    {
      "stevearc/conform.nvim",
      event = { "BufWritePre" },
      cmd = { "ConformInfo" },
      keys = {
        {
          "<leader>f",
          function()
            require("conform").format({ async = true, lsp_format = "fallback" })
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
        "lawrence-laz/neotest-zig",
      },
      keys = {
        {
          "<leader>tt",
          function()
            require("neotest").summary.toggle()
          end,
          desc = "Toggle test summary",
        },
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
      keys = {
        {
          "de",
          function()
            local dap = require("dap")
            local dap_ui = require("dapui")
            dap.close()
            dap.terminate()
            dap.repl.close()
            dap_ui.close()
            dap.clear_breakpoints()
          end,
          desc = "End debugger",
        },
        {
          "dc",
          function()
            require("dap").continue()
          end,
          desc = "Continue debug",
        },
        {
          "dt",
          function()
            require("dap").toggle_breakpoint()
          end,
          desc = "Set breakpoint",
        },
        {
          "dT",
          function()
            require("dap").clear_breakpoints()
          end,
          desc = "Clear breakpoint",
        },
        {
          "dj",
          function()
            require("dap").step_over()
          end,
          desc = "Step over",
        },
        {
          "dk",
          function()
            require("dap").step_out()
          end,
          desc = "Step out",
        },
        {
          "dl",
          function()
            require("dap").step_into()
          end,
          desc = "Step into",
        },
        {
          "dh",
          function()
            require("dapui").eval()
          end,
          desc = "Popups dapUI eval",
        },
      },
      config = function()
        require("devil.plugins.configs.dap")
      end,
    },
  }
end
