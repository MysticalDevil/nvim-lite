local status_ok, lazy = pcall(require, "lazy")
if not status_ok then
  vim.notify("lazy.nvim not found", vim.log.levels.ERROR)
  return
end

local utils = require("devil.core.utils")

local plugins_list = {
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
    event = { "BufReadPost", "BufNewFile" },
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
        bottom_search = true, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        lsp_doc_border = true, -- add a border to hover docs and signature help
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
    -- mini.icons mocks web-devicons, so explicit dependency works fine
    dependencies = "echasnovski/mini.icons",
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
      opts = { use_diagnostic_signs = true },
    },

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
      ft = "lua", -- only load on lua files
      opts = {
        library = {
          -- See the configuration section for more details
          -- Load luvit types when the `vim.uv` word is found
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
          -- Customize or remove this keymap to your liking
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
        -- If you want the formatexpr, here is the place to set it
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

    {
      "lewis6991/gitsigns.nvim",
      ft = { "gitcommit", "diff" },
      event = { "BufReadPre", "BufNewFile" },
      opts = require("devil.plugins.configs.others").gitsigns,
    },

    {
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v3.x",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "echasnovski/mini.icons",
        "MunifTanjim/nui.nvim",
      },
      cmd = "Neotree",
      keys = utils.get_lazy_keys("neo_tree"),
      opts = require("devil.plugins.configs.neo-tree"),
    },

    {
      "rebelot/heirline.nvim",
      event = "UIEnter",
      opts = function()
        return require("devil.plugins.configs.heirline")
      end,
    },

    {
      "willothy/nvim-cokeline",
      event = "VeryLazy",
      dependencies = "famiu/bufdelete.nvim",
      keys = utils.get_lazy_keys("cokeline"),
      opts = function()
        return require("devil.plugins.configs.cokeline")
      end,
    },

    {
      "Bekaboo/dropbar.nvim",
      event = "LspAttach",
      dependencies = {
        "nvim-telescope/telescope-fzf-native.nvim",
      },
      opts = {
        bar = {},
      },
    },

    {
      "hedyhli/outline.nvim",
      cmd = { "Outline", "OutlineOpen" },
      keys = {
        { "<leader>o", "<cmd>Outline<CR>", desc = "Toggle outline" },
      },
      opts = {
        symbols = {
          icon_source = "lspkind",
        },
      },
    },

    -- Replacement for Comment.nvim
    {
      "folke/ts-comments.nvim",
      opts = {},
      event = "VeryLazy",
      enabled = vim.fn.has("nvim-0.10.0") == 1,
    },

    {
      "folke/todo-comments.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
      opts = {},
    },

    {
      "nvim-telescope/telescope.nvim",
      lazy = false,
      dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-lua/plenary.nvim",
        "LinArcX/telescope-env.nvim",
        "debugloop/telescope-undo.nvim",
        "Marskey/telescope-sg",
        "nvim-telescope/telescope-file-browser.nvim",
        "nvim-telescope/telescope-project.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      },
      cmd = "Telescope",
      keys = utils.get_lazy_keys("telescope"),
      opts = function()
        return require("devil.plugins.configs.telescope")
      end,
    },
    {
      "danielfalk/smart-open.nvim",
      lazy = true,
      branch = "0.2.x",
      dependencies = {
        "kkharji/sqlite.lua",
        -- Only required if using match_algorithm fzf
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        -- Optional.  If installed, native fzy will be used when match_algorithm is fzy
        { "nvim-telescope/telescope-fzy-native.nvim" },
      },
    },

    -- Only load whichkey after all the gui
    {
      "folke/which-key.nvim",
      keys = { "<leader>", "<c-r>", "<c-w>", '"', "'", "`", "c", "v", "g" },
      cmd = "WhichKey",
    },
  },
}

local lazy_opts = require("devil.plugins.configs.lazy") ---@diagnostic disable-line

lazy.setup(plugins_list, lazy_opts)
