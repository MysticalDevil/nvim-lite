local status_ok, lazy = pcall(require, "lazy")
if not status_ok then
  vim.notify("lazy.nvim not found", vim.log.levels.ERROR)
  return
end

local utils = require("devil.core.utils")

local plugins_list = {
  { "nvim-lua/plenary.nvim",  lazy = false },
  { "folke/lazy.nvim",        lazy = false },
  { "stevearc/dressing.nvim", lazy = false },

  {
    "navarasu/onedark.nvim",
    config = function()
      require("onedark").setup({ style = "darker" })
    end,
  },
  {
    "EdenEast/nightfox.nvim",
    config = function()
      require("nightfox").setup()
    end,
  },

  {
    "nvim-tree/nvim-web-devicons",
    opts = {
      override = {
        zsh = {
          icon = "",
          color = "#428850",
          cterm_color = "65",
          name = "Zsh",
        },
      },
    },
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "UIEnter",
    init = function()
      utils.lazy_load("indent-blankline.nvim")
    end,
    opts = require("devil.plugins.configs.others").blankline,
  },

  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
  },

  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    dependencies = {
      -- "nvim-treesitter/nvim-treesitter-refactor",
      "nvim-treesitter/nvim-treesitter-textobjects",
      "nvim-treesitter/nvim-treesitter-context",
      "nvim-treesitter/playground",
      "windwp/nvim-ts-autotag",
      "RRethy/nvim-treesitter-endwise",
      "ziontee113/syntax-tree-surfer",
    },
    init = function()
      utils.lazy_load("nvim-treesitter")
    end,
    cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
    build = ":TSUpdate",
    opts = function()
      return require("devil.plugins.configs.treesitter")
    end,
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  {
    "williamboman/mason.nvim",
    lazy = true,
    event = "LspAttach",
    dependencies = {
      "neovim/nvim-lspconfig",
      "stevearc/conform.nvim",
      "mfussenegger/nvim-lint",
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
    init = function()
      require("devil.core.utils").lazy_load("nvim-lspconfig")
    end,
    dependencies = { "saghen/blink.cmp" },
    config = function()
      require("devil.plugins.configs.lspconfig")
    end,
  },

  {
    "saghen/blink.cmp",
    dependencies = "rafamadriz/friendly-snippets",
    version = "*",
    opts = require("devil.plugins.configs.cmp"),
    opts_extend = { "sources.default" },
  },

  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      progress = {
        display = {
          progress_icon = { pattern = "dots", period = 1 },
        },
      },
    },
  },

  {
    "folke/neodev.nvim",
    ft = "lua",
    opts = {
      library = {
        enabled = true, -- when not enabled, neodev will not change any settings to the LSP server
        -- these settings will be used for your Neovim config directory
        runtime = true, -- runtime path
        types = true,   -- full signature, docs and completion of vim.api, vim.treesitter, vim.lsp and others
        -- you can also specify the list of plugins to make available as a workspace library
        plugins = { "nvim-treesitter", "plenary.nvim", "telescope.nvim", "nvim-dap-ui" },
      },
      setup_jsonls = true, -- configures jsonls to provide completion for project specific .luarc.json files
      -- for your Neovim config directory, the config.library settings will be used as is
      -- for plugin directories (root_dirs having a /lua directory), config.library.plugins will be disabled
      -- for any other directory, config.library.enabled will be set to false
      -- override = function(root_dir, options) end,
      -- With lspconfig, Neodev will automatically setup your lua-language-server
      -- If you disable this, then you have to set {before_init=require("neodev.lsp").before_init}
      -- in your lsp start options
      lspconfig = true,
      -- much faster, but needs a recent built of lua-language-server
      -- needs lua-language-server >= 3.6.0
      pathStrict = true,
    },
  },

  { "b0o/schemastore.nvim",      ft = { "json", "yaml" } },

  {
    "ray-x/go.nvim",
    ft = { "go", "gomod", "gowork", "gosum" },
    event = { "CmdlineEnter" },
    build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
    dependencies = {                                        -- optional packages
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup()
    end,
  },

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
    "Wansmer/symbol-usage.nvim",
    event = "BufReadPre", -- need run before LspAttach if you use nvim 0.9. On 0.10 use 'LspAttach'
    opts = function()
      return require("devil.plugins.configs.symbol-usage")
    end,
  },

  {
    "onsails/lspkind.nvim",
    event = "LspAttach",
    opts = require("devil.plugins.configs.others").lspkind,
    config = function(_, opts)
      require("lspkind").init(opts)
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
    init = function()
      utils.load_mappings("dap")
    end,
    config = function()
      require("devil.plugins.configs.dap")
    end,
  },

  {
    "lewis6991/gitsigns.nvim",
    ft = { "gitcommit", "diff" },
    init = function()
      -- load gitsigns only when a git file is opened
      vim.api.nvim_create_autocmd({ "BufRead" }, {
        group = vim.api.nvim_create_augroup("GitSignsLazyLoad", { clear = true }),
        callback = function()
          vim.fn.jobstart({ "git", "-C", vim.loop["cwd"](), "rev-parse" }, {
            on_exit = function(_, return_code)
              if return_code == 0 then
                vim.api.nvim_del_augroup_by_name("GitSignsLazyLoad")
                vim.schedule(function()
                  require("lazy").load({ plugins = { "gitsigns.nvim" } })
                end)
              end
            end,
          })
        end,
      })
    end,
    opts = require("devil.plugins.configs.others").gitsigns,
  },

  {
    "ray-x/lsp_signature.nvim",
    event = "LspAttach",
    keys = {
      {
        "<C-k>",
        function()
          require("lsp_signature").toggle_float_win()
        end,
      },
    },
    opts = {
      bind = true, -- This is mandatory, otherwise border config won't get registered.
      handler_opts = {
        border = "single",
      },
      hint_enable = false,
    },
    config = function(_, opts)
      require("lsp_signature").setup(opts)
    end,
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    lazy = false,
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    init = function()
      utils.load_mappings("neo_tree")
    end,
    opts = require("devil.plugins.configs.neo-tree"),
  },

  {
    "rebelot/heirline.nvim",
    lazy = false,
    config = function()
      require("devil.plugins.configs.heirline")
    end,
  },

  {
    "willothy/nvim-cokeline",
    lazy = false,
    dependencies = "famiu/bufdelete.nvim",
    init = function()
      utils.load_mappings("cokeline")
    end,
    opts = function()
      require("devil.plugins.configs.cokeline")
    end,
  },

  {
    "Bekaboo/dropbar.nvim",
    event = "LspAttach",
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
    },
    opts = {
      bar = {
        attach_events = { "BufWinEnter", "BufWritePost" },
        update_events = {
          win = { "CursorMoved", "CursorMovedI", "WinResized" },
        },
      },
      icons = { kinds = { symbols = utils.kind_icons } },
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
    "smjonas/inc-rename.nvim",
    event = "LspAttach",
    keys = {
      {
        "<leader>rn",
        function()
          return ":IncRename " .. vim.fn.expand("<cword>")
        end,
        expr = true,
      },
    },
    opts = {
      input_buffer_type = "dressing",
    },
  },

  {
    "rcarriga/nvim-notify",
    lazy = false,
    opts = {
      stages = "slide",
      timeout = 5000,
      render = "default",
    },
    config = function(_, opts)
      require("notify").setup(opts)
      vim.notify = require("notify")
    end,
  },

  {
    "petertriho/nvim-scrollbar",
    opts = {
      handlers = {
        cursor = true,
        diagnostic = true,
        gitsigns = true, -- Requires gitsigns
        handle = true,
        search = true,   -- Requires hlslens
        ale = false,     -- Requires ALE
      },
    },
  },

  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    opts = function()
      return require("devil.plugins.configs.alpha")
    end,
    config = function(_, dashboard)
      -- close Lazy and re-open when the dashboard is ready
      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        vim.api.nvim_create_autocmd("User", {
          pattern = "AlphaReady",
          callback = function()
            require("lazy").show()
          end,
        })
      end

      require("alpha").setup(dashboard.opts) ---@diagnostic disable-line

      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        callback = function()
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          local version = "  󰥱 v" .. vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch
          local plugins = "⚡Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms"
          local footer = version .. "\t" .. plugins .. "\n"
          dashboard.section.footer.val = footer
          pcall(vim.cmd.AlphaRedraw)
        end,
      })
    end,
  },

  {
    "numToStr/Comment.nvim",
    keys = {
      { "gcc", mode = "n",          desc = "Comment toggle current line" },
      { "gc",  mode = { "n", "o" }, desc = "Comment toggle linewise" },
      { "gc",  mode = "x",          desc = "Comment toggle linewise (visual)" },
      { "gbc", mode = "n",          desc = "Comment toggle current block" },
      { "gb",  mode = { "n", "o" }, desc = "Comment toggle blockwise" },
      { "gb",  mode = "x",          desc = "Comment toggle blockwise (visual)" },
    },
    init = function()
      utils.load_mappings("comment")
    end,
  },

  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },

  {
    "folke/trouble.nvim",
    branch = "dev",
    cmd = { "Trouble" },
    init = function()
      utils.load_mappings("trouble")
    end,
    dependencies = { "nvim-tree/nvim-web-devicons" },
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
      "nvim-telescope/telescope-ui-select.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
      "nvim-telescope/telescope-project.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    cmd = "Telescope",
    init = function()
      utils.load_mappings("telescope")
    end,
    opts = function()
      return require("devil.plugins.configs.telescope")
    end,
    config = function(_, opts)
      local telescope = require("telescope") ---@diagnostic disable-line
      telescope.setup(opts)

      -- load extensions
      for _, ext in ipairs(opts.extensions_list) do
        telescope.load_extension(ext)
      end
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

  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = "ToggleTerm",
    keys = {
      { "<C-\\>", "<cmd>ToggleTerm<CR>", desc = "Open ToggleTerm" },
    },
    opts = require("devil.plugins.configs.toggleterm"),
  },

  {
    "lewis6991/satellite.nvim",
    event = "VeryLazy",
    opts = {},
  },

  {
    'altermo/ultimate-autopair.nvim',
    event = { 'InsertEnter', 'CmdlineEnter' },
    branch = 'v0.6', --recommended as each new version will have breaking changes
    opts = {},
  },

  -- Only load whichkey after all the gui
  {
    "folke/which-key.nvim",
    keys = { "<leader>", "<c-r>", "<c-w>", '"', "'", "`", "c", "v", "g" },
    init = function()
      utils.load_mappings("whichkey")
    end,
    cmd = "WhichKey",
  },
}

local lazy_opts = require("devil.plugins.configs.lazy") ---@diagnostic disable-line

lazy.setup(plugins_list, lazy_opts)
