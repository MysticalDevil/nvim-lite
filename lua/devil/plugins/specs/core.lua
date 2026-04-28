return function()
  return {
    { "nvim-lua/plenary.nvim", lazy = false },
    { "folke/lazy.nvim", lazy = false },
    { "olimorris/onedarkpro.nvim" },
    { "folke/tokyonight.nvim" },

    -- Replaced nvim-web-devicons with mini.icons (lighter and compatible)
    {
      "nvim-mini/mini.icons",
      lazy = true,
      opts = {},
      init = function()
        package.preload["nvim-web-devicons"] = function()
          require("mini.icons").mock_nvim_web_devicons()
          return package.loaded["nvim-web-devicons"]
        end
      end,
    },

    {
      "kylechui/nvim-surround",
      event = "VeryLazy",
    },

    {
      "romus204/tree-sitter-manager.nvim",
      lazy = false,
      opts = function()
        local ensure_installed = {
          "c",
          "c_sharp",
          "cpp",
          "css",
          "dockerfile",
          "go",
          "html",
          "javascript",
          "json",
          "just",
          "lua",
          "make",
          "markdown",
          "rust",
          "sql",
          "toml",
          "tsx",
          "typescript",
          "zig",
        }

        return {
          ensure_installed = #vim.api.nvim_list_uis() > 0 and ensure_installed or {},
        }
      end,
      config = function(_, opts)
        require("tree-sitter-manager").setup(opts)

        vim.api.nvim_create_autocmd("FileType", {
          group = vim.api.nvim_create_augroup("devil_treesitter", { clear = true }),
          callback = function(args)
            pcall(vim.treesitter.start, args.buf)
          end,
        })
      end,
    },

    {
      "nvim-treesitter/nvim-treesitter-context",
      lazy = false,
    },

    {
      "windwp/nvim-ts-autotag",
      lazy = false,
      opts = {
        opts = {
          enable_rename = true,
          enable_close = true,
          enable_close_on_slash = true,
        },
      },
    },

    {
      "MysticalDevil/ts-inject.nvim",
      event = { "BufReadPost", "BufNewFile" },
      opts = {
        enable = {
          rust = true,
          zig = true,
          go = true,
          python = true,
          bash = true,
        },
      },
    },

    {
      "mason-org/mason.nvim",
      lazy = false,
      dependencies = {
        "mason-org/mason-lspconfig.nvim",
        { "jay-babu/mason-nvim-dap.nvim", cmd = { "DapInstall", "DapUninstall" } },
        "rshkarin/mason-nvim-lint",
      },
      cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate" },
      opts = require("devil.plugins.configs.mason"),
    },

    {
      "neovim/nvim-lspconfig",
      priority = 1000,
      lazy = false,
      dependencies = { "saghen/blink.cmp" },
      config = function()
        require("devil.plugins.configs.lsp")
      end,
    },

    {
      "folke/noice.nvim",
      event = "VeryLazy",
      dependencies = { "MunifTanjim/nui.nvim" },
      opts = {
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
          lsp_doc_border = true,
        },
      },
    },

    {
      "folke/snacks.nvim",
      priority = 1000,
      lazy = false,
      opts = require("devil.plugins.configs.snacks"),
      keys = {
        {
          "<c-\\>",
          function()
            Snacks.terminal.toggle()
          end,
          desc = "Toggle Terminal",
          mode = { "n", "t" },
        },
        {
          "<leader>cR",
          function()
            Snacks.rename.rename_file()
          end,
          desc = "Rename File",
        },
        {
          "<leader>z",
          function()
            Snacks.zen()
          end,
          desc = "Toggle Zen Mode",
        },
        {
          "<leader>Z",
          function()
            Snacks.zen.zoom()
          end,
          desc = "Toggle Zoom",
        },
        {
          "<leader>ps",
          function()
            Snacks.profiler.startup({})
          end,
          desc = "Startup Profiler",
        },
        {
          "<leader>nh",
          function()
            Snacks.notifier.show_history()
          end,
          desc = "Notification History",
        },
        {
          "<leader>N",
          function()
            Snacks.win({
              file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
              width = 0.6,
              height = 0.6,
              wo = {
                spell = false,
                wrap = false,
                signcolumn = "yes",
                statuscolumn = " ",
                conceallevel = 3,
              },
            })
          end,
          desc = "Neovim News",
        },
      },
    },

    {
      "folke/trouble.nvim",
      event = "LspAttach",
      cmd = "Trouble",
      dependencies = "nvim-mini/mini.icons",
      opts = { use_diagnostic_signs = true },
      keys = {
        {
          "<leader>xx",
          "<cmd>Trouble diagnostics toggle<cr>",
          desc = "Diagnostics (Trouble)",
        },
        {
          "<leader>xX",
          "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
          desc = "Buffer Diagnostics (Trouble)",
        },
        {
          "<leader>cs",
          "<cmd>Trouble symbols toggle focus=false<cr>",
          desc = "Symbols (Trouble)",
        },
        {
          "<leader>cl",
          "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
          desc = "LSP Definitions / references / ... (Trouble)",
        },
        {
          "<leader>xL",
          "<cmd>Trouble loclist toggle<cr>",
          desc = "Location List (Trouble)",
        },
        {
          "<leader>xQ",
          "<cmd>Trouble qflist toggle<cr>",
          desc = "Quickfix List (Trouble)",
        },
      },
    },
  }
end
