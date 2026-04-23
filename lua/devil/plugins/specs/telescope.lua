return function(utils)
  return {
    {
      "nvim-telescope/telescope.nvim",
      lazy = false,
      dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-lua/plenary.nvim",
        "debugloop/telescope-undo.nvim",
        "Marskey/telescope-sg",
        "nvim-telescope/telescope-project.nvim",
        "nvim-telescope/telescope-ui-select.nvim",
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
      dependencies = {
        "kkharji/sqlite.lua",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      },
    },
  }
end
