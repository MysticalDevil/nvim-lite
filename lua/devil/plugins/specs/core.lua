return function(utils)
  return {
    { "nvim-lua/plenary.nvim", lazy = false },
    { "folke/lazy.nvim", lazy = false },
    { "olimorris/onedarkpro.nvim" },
    { "folke/tokyonight.nvim" },

    -- Replaced nvim-web-devicons with mini.icons (lighter and compatible)
    {
      "echasnovski/mini.icons",
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
      version = "*",
      event = "VeryLazy",
    },

    {
      "nvim-treesitter/nvim-treesitter",
      event = { "BufReadPost", "BufNewFile" },
      dependencies = {
        {
          "nvim-treesitter/nvim-treesitter-textobjects",
          branch = "main",
          init = function()
            vim.g.no_plugin_maps = true
          end,
        },
        "nvim-treesitter/nvim-treesitter-context",
        "windwp/nvim-ts-autotag",
        "RRethy/nvim-treesitter-endwise",
      },
      build = ":TSUpdate",
      opts = function()
        return require("devil.plugins.configs.treesitter")
      end,
      config = function(_, opts)
        local ok_ts, ts = pcall(require, "nvim-treesitter")
        if ok_ts and type(ts.setup) == "function" then
          ts.setup(opts)
        else
          local ok_configs, configs = pcall(require, "nvim-treesitter.configs")
          if ok_configs and type(configs.setup) == "function" then
            configs.setup(opts)
          else
            vim.notify("nvim-treesitter setup module not found", vim.log.levels.WARN)
            return
          end
        end

        vim.api.nvim_create_autocmd("FileType", {
          group = vim.api.nvim_create_augroup("devil_treesitter_start", { clear = true }),
          callback = function(args)
            pcall(vim.treesitter.start, args.buf)
          end,
        })
      end,
    },

    {
      "williamboman/mason.nvim",
      lazy = true,
      event = "LspAttach",
      dependencies = {
        "williamboman/mason-lspconfig.nvim",
        { "jay-babu/mason-nvim-dap.nvim", cmd = { "DapInstall", "DapUninstall" } },
        "zapling/mason-conform.nvim",
        "rshkarin/mason-nvim-lint",
      },
      cmd = { "Mason", "MasonInstall", "MasonInstallAll", "MasonUpdate" },
      opts = require("devil.plugins.configs.mason"),
    },

    {
      "neovim/nvim-lspconfig",
      priority = 1000,
      lazy = false,
      cmd = { "LspInfo", "LspInstall", "LspStart" },
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
      keys = utils.get_lazy_keys("snacks"),
    },

    {
      "folke/trouble.nvim",
      event = "LspAttach",
      cmd = "Trouble",
      dependencies = "echasnovski/mini.icons",
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
