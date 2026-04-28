return function()
  return {
    {
      "lewis6991/gitsigns.nvim",
      ft = { "gitcommit", "diff" },
      event = { "BufReadPre", "BufNewFile" },
      opts = require("devil.plugins.configs.others").gitsigns,
    },

    {
      "nvim-neo-tree/neo-tree.nvim",
      lazy = false,
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-mini/mini.icons",
        "MunifTanjim/nui.nvim",
      },
      cmd = "Neotree",
      keys = {
        { "<A-m>", "<cmd> Neotree toggle <CR>", desc = "Toggle neotree" },
      },
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
      keys = {
        { "<S-h>", "<Plug>(cokeline-focus-prev)", desc = "Cycle focus previous buffer" },
        { "<S-l>", "<Plug>(cokeline-focus-next)", desc = "Cycle focus next buffer" },
        {
          "<leader>bd",
          function()
            Snacks.bufdelete()
          end,
          desc = "Delete buffer",
        },
        {
          "<leader>ba",
          function()
            Snacks.bufdelete.all()
          end,
          desc = "Delete all buffers",
        },
        {
          "<leader>bo",
          function()
            Snacks.bufdelete.other()
          end,
          desc = "Delete other buffers",
        },
        { "<leader>bc", "<Plug>(cokeline-pick-close)", desc = "Pick buffer to close" },
        { "<leader>p", "<Plug>(cokeline-switch-prev)", desc = "Cycle switch previous buffer but not focus" },
        { "<leader>n", "<Plug>(cokeline-switch-next)", desc = "Cycle switch next buffer but not focus" },
        { "<A-1>", "<Plug>(cokeline-focus-1)", desc = "Go to 1 buffer" },
        { "<A-2>", "<Plug>(cokeline-focus-2)", desc = "Go to 2 buffer" },
        { "<A-3>", "<Plug>(cokeline-focus-3)", desc = "Go to 3 buffer" },
        { "<A-4>", "<Plug>(cokeline-focus-4)", desc = "Go to 4 buffer" },
        { "<A-5>", "<Plug>(cokeline-focus-5)", desc = "Go to 5 buffer" },
        { "<A-6>", "<Plug>(cokeline-focus-6)", desc = "Go to 6 buffer" },
        { "<A-7>", "<Plug>(cokeline-focus-7)", desc = "Go to 7 buffer" },
        { "<A-8>", "<Plug>(cokeline-focus-8)", desc = "Go to 8 buffer" },
        { "<A-9>", "<Plug>(cokeline-focus-9)", desc = "Go to 9 buffer" },
      },
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
      "folke/which-key.nvim",
      keys = { "<leader>", "<c-r>", "<c-w>", '"', "'", "`", "c", "v", "g" },
      cmd = "WhichKey",
    },
  }
end
