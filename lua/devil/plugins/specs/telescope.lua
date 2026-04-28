return function()
  return {
    {
      "nvim-telescope/telescope.nvim",
      lazy = false,
      dependencies = {
        "nvim-lua/plenary.nvim",
        "debugloop/telescope-undo.nvim",
        "Marskey/telescope-sg",
        "nvim-telescope/telescope-project.nvim",
        "nvim-telescope/telescope-ui-select.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      },
      cmd = "Telescope",
      keys = {
        {
          "<leader>ff",
          function()
            require("telescope").extensions.smart_open.smart_open()
          end,
          desc = "Find files",
        },
        { "<leader>fa", "<cmd> Telescope find_files follow=true no_ignore=true hidden=true <CR>", desc = "Find all" },
        { "<leader>fw", "<cmd> Telescope live_grep <CR>", desc = "Live grep" },
        { "<leader>fb", "<cmd> Telescope buffers <CR>", desc = "Find buffers" },
        { "<leader>fh", "<cmd> Telescope help_tags <CR>", desc = "Help page" },
        { "<leader>fo", "<cmd> Telescope oldfiles <CR>", desc = "Find oldfiles" },
        { "<leader>fz", "<cmd> Telescope current_buffer_fuzzy_find <CR>", desc = "Find in current buffer" },
        { "<leader>fp", "<cmd> Telescope project <CR>", desc = "Find recently projects" },
        { "<leader>fe", "<cmd> Telescope file_browser <CR>", desc = "Open file browser" },
        { "<leader>sg", "<cmd> Telescope ast_grep <CR>", desc = "Use ast-grep to search" },
        { "<leader>cm", "<cmd> Telescope git_commits <CR>", desc = "Git commits" },
        { "<leader>gt", "<cmd> Telescope git_status <CR>", desc = "Git status" },
        { "<leader>pt", "<cmd> Telescope terms <CR>", desc = "Pick hidden term" },
        { "<leader>ma", "<cmd> Telescope marks <CR>", desc = "telescope bookmarks" },
      },
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
