return function(utils)
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
      "nvim-treesitter/nvim-treesitter",
      lazy = false,
      build = ":TSUpdate",
      opts = {
        install_languages = {
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
          "just",
          "lua",
          "make",
          "markdown",
          "markdown_inline",
          "python",
          "ruby",
          "rust",
          "sql",
          "toml",
          "tsx",
          "typescript",
          "yaml",
          "zig",
        },
      },
      config = function(_, opts)
        local treesitter = require("nvim-treesitter")

        local function set_indentexpr(bufnr)
          local filetype = vim.bo[bufnr].filetype
          if filetype == "" then
            return
          end

          local ok_lang, lang = pcall(vim.treesitter.language.get_lang, filetype)
          if not ok_lang or not lang then
            lang = filetype
          end

          local ok_query, query = pcall(vim.treesitter.query.get, lang, "indents")
          if ok_query and query then
            vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end

        treesitter.setup()

        if #opts.install_languages > 0 and #vim.api.nvim_list_uis() > 0 then
          vim.schedule(function()
            treesitter.install(opts.install_languages)
          end)
        end

        vim.api.nvim_create_autocmd("FileType", {
          group = vim.api.nvim_create_augroup("devil_treesitter", { clear = true }),
          callback = function(args)
            pcall(vim.treesitter.start, args.buf)
            pcall(set_indentexpr, args.buf)
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
        "zapling/mason-conform.nvim",
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
      keys = utils.get_lazy_keys("snacks"),
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
