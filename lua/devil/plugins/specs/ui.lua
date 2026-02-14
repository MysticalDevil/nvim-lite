return function(utils)
  return {
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
