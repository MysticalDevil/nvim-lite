local opts = { noremap = true, silent = true }
local keymap = vim.keymap.set

-- Remap space as leader key
keymap("", "<space>", "<nop>", opts)

-- magic search logic from nvim
local enable_magic_search = true
if enable_magic_search then
  keymap({ "n", "v" }, "/", "/\\v", { remap = false, silent = false })
else
  keymap({ "n", "v" }, "/", "/", { remap = false, silent = false })
end

local M = {}

M.general = {
  i = {
    -- go to begging and end
    ["<C-b>"] = { "<ESC>^i", "Begging of line" },
    ["<C-e>"] = { "<End>", "End of line" },

    -- navigate within insert mode
    ["<C-h>"] = { "<Left>", "Move left" },
    ["<C-l>"] = { "<Right>", "Move right" },
    ["<C-j>"] = { "<Down>", "Move down" },
    ["<C-k>"] = { "<Up>", "Move up" },
  },

  n = {
    ["<Esc>"] = { "<cmd> noh <CR>", "Clear highlights" },
    ["<C-d>"] = { "10j", "Five lines down" },
    ["<C-u>"] = { "10k", "Five lines up" },

    -- switch between windows
    ["<C-h>"] = { "<C-w>h", "Window left" },
    ["<C-l>"] = { "<C-w>l", "Window right" },
    ["<C-j>"] = { "<C-w>j", "Window down" },
    ["<C-k>"] = { "<C-w>k", "Window up" },

    -- line numbers
    ["<leader><leader>n"] = { "<cmd> set nu! <CR>", "Toggle line number" },
    ["<leader><leader>rn"] = { "<cmd> set rnu! <CR>", "Toggle relative number" },

    -- Allow moving the cursor through wrapped lines with j, k, <Up> and <Down>
    ["j"] = { 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', "Move down", opts = { expr = true } },
    ["k"] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', "Move up", opts = { expr = true } },
    ["<Up>"] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', "Move up", opts = { expr = true } },
    ["<Down>"] = { 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', "Move down", opts = { expr = true } },

    ["<leader>ff"] = {
      function()
        vim.lsp.buf.format({ async = true })
      end,
      "LSP formatting",
    },

    -- new buffer
    ["<leader>bn"] = { "<cmd> enew <CR>", "New buffer" },

    -- s_windows (Synced with nvim: s -> <leader>w)
    ["<leader>wv"] = { ":vsp<CR>", "Split window vertically" },
    ["<leader>wh"] = { ":sp<CR>", "Split window horizontally" },
    ["<leader>wc"] = { "<C-w>c", "Close picked split window" },
    ["<leader>wo"] = { "<C-w>o", "Close other split window" },
    ["<leader>w,"] = { ":vertical resize -10<CR>", "Reduce vertical window size" },
    ["<leader>w."] = { ":vertical resize +10<CR>", "Increase vertical window size" },
    ["<leader>wj"] = { ":horizontal resize -5<CR>", "Reduce horizontal window size" },
    ["<leader>wk"] = { ":horizontal resize +5<CR>", "Increase vertical window size" },
    ["<leader>w="] = { "<C-w>=", "Make split windows equal in size" },

    -- tabs (Synced with nvim: t -> <leader><Tab>)
    ["<leader><Tab>s"] = { "<cmd>tab split<CR>", "Split window use tab" },
    ["<leader><Tab>h"] = { "<cmd>tabprev<CR>", "Switch to previous tab" },
    ["<leader><Tab>j"] = { "<cmd>tabnext<CR>", "Switch to next tab" },
    ["<leader><Tab>f"] = { "<cmd>tabfirst<CR>", "Switch to first tab" },
    ["<leader><Tab>l"] = { "<cmd>tablast<CR>", "Switch to last tab" },
    ["<leader><Tab>c"] = { "<cmd>tabclose<CR>", "Close tab" },

    ["zo"] = { "<CMD>foldopen<CR>", "Open fold" },
    ["zc"] = { "<CMD>foldclose<CR>", "Close fold" },
  },

  t = {
    ["<ESC>"] = { "<C-\\><C-n>", "Back to normal mode" },
    ["<C-x>"] = { vim.api.nvim_replace_termcodes("<C-\\><C-N>", true, true, true), "Escape terminal mode" },
  },

  v = {
    ["<C-j>"] = { "5j", "Five lines down" },
    ["<C-k>"] = { "5k", "Five lines up" },
    ["<C-d>"] = { "10j", "Five lines down" },
    ["<C-u>"] = { "10k", "Five lines up" },

    ["<Up>"] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', "Move up", opts = { expr = true } },
    ["<Down>"] = { 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', "Move down", opts = { expr = true } },
    ["<"] = { "<gv", "Indent line" },
    [">"] = { ">gv", "Indent line" },
  },

  x = {
    ["j"] = { 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', "Move down", opts = { expr = true } },
    ["k"] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', "Move up", opts = { expr = true } },
    -- Don't copy the replaced text after pasting in visual mode
    ["p"] = { 'p:let @+=@0<CR>:let @"=@0<CR>', "Dont copy replaced text", opts = { silent = true } },
  },
}

M.comment = {
  plugin = true,

  -- toggle comment in both modes
  n = {
    ["<leader>/"] = {
      function()
        require("Comment.api").toggle.linewise.current()
      end,
      "Toggle comment",
    },
  },

  v = {
    ["<leader>/"] = {
      "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
      "Toggle comment",
    },
  },
}

M.lspconfig = {
  plugin = true,

  n = {
    ["gD"] = {
      function()
        vim.lsp.buf.declaration({ reuse_win = true })
      end,
      "LSP declaration",
    },

    ["gd"] = {
      function()
        if vim.bo.filetype == "cs" then
          require("csharpls_extended").lsp_definitions()
        else
          -- Synced with nvim: prefer telescope for definition
          require("telescope.builtin").lsp_definitions(require("telescope.themes").get_cursor({ reuse_win = true }))
        end
      end,
      "LSP definition",
    },

    ["K"] = {
      function()
        vim.lsp.buf.hover()
      end,
      "LSP hover",
    },

    ["gi"] = {
      function()
        require("telescope.builtin").lsp_implementations(require("telescope.themes").get_cursor({ reuse_win = true }))
      end,
      "LSP implementation",
    },

    ["<leader>ls"] = {
      function()
        vim.lsp.buf.signature_help()
      end,
      "LSP signature help",
    },

    ["<leader>D"] = {
      function()
        require("telescope.builtin").lsp_type_definitions(require("telescope.themes").get_cursor({ reuse_win = true }))
      end,
      "LSP definition type",
    },

    ["<leader>ca"] = {
      function()
        vim.lsp.buf.code_action()
      end,
      "LSP code action",
    },

    ["gr"] = {
      function()
        require("telescope.builtin").lsp_references(require("telescope.themes").get_cursor({ reuse_win = true }))
      end,
      "LSP references",
    },

    ["<leader>lf"] = {
      function()
        vim.diagnostic.open_float({ border = "single" })
      end,
      "Floating diagnostic",
    },

    ["[d"] = {
      function()
        vim.diagnostic.jump({ count = -1, float = { border = "single" } })
      end,
      "Goto prev",
    },

    ["]d"] = {
      function()
        vim.diagnostic.jump({ count = 1, float = { border = "single" } })
      end,
      "Goto next",
    },

    ["<leader>ds"] = {
      function()
        vim.diagnostic.setloclist()
      end,
      "Diagnostic setloclist",
    },

    ["<leader>wa"] = {
      function()
        vim.lsp.buf.add_workspace_folder()
      end,
      "Add workspace folder",
    },

    ["<leader>wr"] = {
      function()
        vim.lsp.buf.remove_workspace_folder()
      end,
      "Remove workspace folder",
    },

    ["<leader>wl"] = {
      function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end,
      "List workspace folders",
    },

    ["<leader>L"] = {
      function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ 0 }), { 0 })
      end,
      "Toggle LSP inlay hints",
    },
  },

  v = {
    ["<leader>ca"] = {
      function()
        vim.lsp.buf.code_action()
      end,
      "LSP code action",
    },
  },
}

M.neo_tree = {
  plugin = true,

  n = {
    ["<A-m>"] = {
      "<cmd> Neotree toggle <CR>",
      "Toggle neotree",
    },
  },
}

M.telescope = {
  plugin = true,

  n = {
    -- find
    ["<leader>ff"] = {
      function()
        require("telescope").extensions.smart_open.smart_open()
      end,
      "Find files",
    },
    ["<leader>fa"] = { "<cmd> Telescope find_files follow=true no_ignore=true hidden=true <CR>", "Find all" },
    ["<leader>fw"] = { "<cmd> Telescope live_grep <CR>", "Live grep" },
    ["<leader>fb"] = { "<cmd> Telescope buffers <CR>", "Find buffers" },
    ["<leader>fh"] = { "<cmd> Telescope help_tags <CR>", "Help page" },
    ["<leader>fo"] = { "<cmd> Telescope oldfiles <CR>", "Find oldfiles" },
    ["<leader>fz"] = { "<cmd> Telescope current_buffer_fuzzy_find <CR>", "Find in current buffer" },
    ["<leader>fp"] = { "<cmd> Telescope project <CR>", "Find recently projects" },
    ["<leader>fe"] = { "<cmd> Telescope file_browser <CR>", "Open file browser" },
    ["<leader>sg"] = { "<cmd> Telescope ast_grep <CR>", "Use ast-grep to search" },

    -- git
    ["<leader>cm"] = { "<cmd> Telescope git_commits <CR>", "Git commits" },
    ["<leader>gt"] = { "<cmd> Telescope git_status <CR>", "Git status" },

    -- pick a hidden term
    ["<leader>pt"] = { "<cmd> Telescope terms <CR>", "Pick hidden term" },

    ["<leader>ma"] = { "<cmd> Telescope marks <CR>", "telescope bookmarks" },
  },
}

M.blankline = {
  plugin = true,
}

M.gitsigns = {
  plugin = true,

  n = {
    -- Navigation through hunks
    ["]c"] = {
      function()
        if vim.wo.diff then
          return "]c"
        end
        vim.schedule(function()
          require("gitsigns").nav_hunk("next")
        end)
        return "<Ignore>"
      end,
      "Jump to next hunk",
      opts = { expr = true },
    },

    ["[c"] = {
      function()
        if vim.wo.diff then
          return "[c"
        end
        vim.schedule(function()
          require("gitsigns").nav_hunk("prev")
        end)
        return "<Ignore>"
      end,
      "Jump to prev hunk",
      opts = { expr = true },
    },

    -- Actions
    ["<leader>rh"] = {
      function()
        require("gitsigns").reset_hunk()
      end,
      "Reset hunk",
    },

    ["<leader>ph"] = {
      function()
        require("gitsigns").preview_hunk()
      end,
      "Preview hunk",
    },

    ["<leader>gb"] = {
      function()
        require("gitsigns").blame_line()
      end,
      "Blame line",
    },

    ["<leader>td"] = {
      function()
        require("gitsigns").preview_hunk()
      end,
      "Toggle deleted",
    },
    ["<leader>tl"] = {
      function()
        require("gitsigns").toggle_numhl()
        require("gitsigns").toggle_linehl()
      end,
      "Toggle gitsigns line highlight",
    },
    ["<leader>tw"] = {
      function()
        require("gitsigns").toggle_word_diff()
      end,
      "Toggle different word",
    },
  },
}

M.bufferline = {
  plugin = true,

  n = {
    ["<C-h>"] = { "<CMD>BufferLineCyclePrev<CR>", "Cycle previous buffer" },
    ["<C-l>"] = { "<CMD>BufferLineCycleNext<CR>", "Cycle next buffer" },
    ["<C-w>"] = { "<CMD>Bdelete!<CR>", "Delete buffer" },
    ["<A-<>"] = { "<CMD>BufferLineMovePrev<CR>", "Move buffer to previous" },
    ["<A->>"] = { "<CMD>BufferLineMoveNext<CR>", "Move buffer to next" },
    ["<A-1>"] = { "<CMD>BufferLineGoToBuffer 1<CR>", "Go to 1 buffer" },
    ["<A-2>"] = { "<CMD>BufferLineGoToBuffer 2<CR>", "Go to 2 buffer" },
    ["<A-3>"] = { "<CMD>BufferLineGoToBuffer 3<CR>", "Go to 3 buffer" },
    ["<A-4>"] = { "<CMD>BufferLineGoToBuffer 4<CR>", "Go to 4 buffer" },
    ["<A-5>"] = { "<CMD>BufferLineGoToBuffer 5<CR>", "Go to 5 buffer" },
    ["<A-6>"] = { "<CMD>BufferLineGoToBuffer 6<CR>", "Go to 6 buffer" },
    ["<A-7>"] = { "<CMD>BufferLineGoToBuffer 7<CR>", "Go to 7 buffer" },
    ["<A-8>"] = { "<CMD>BufferLineGoToBuffer 8<CR>", "Go to 8 buffer" },
    ["<A-9>"] = { "<CMD>BufferLineGoToBuffer 9<CR>", "Go to 9 buffer" },
    ["<A-0>"] = { "<CMD>BufferLineGoToBuffer -1<CR>", "Go to first buffer" },
    ["<A-p>"] = { "<CMD>BufferLineTogglePin<CR>", "Toggle pinned buffer" },
    ["<Space>bt"] = { "<CMD>BufferLineSortByTabs<CR>", "Sory buffers by tabs" },
    ["<Space>bd"] = { "<CMD>BufferLineSortByDirectory<CR>", "Sort buffers by directories" },
    ["<Space>be"] = { "<CMD>BufferLineSortByExtension<CR>", "Sort buffers by extensions" },
    ["<leader>bh"] = { "<CMD>BufferLineCloseLeft<CR>", "Close left buffer" },
    ["<leader>bl"] = { "<CMD>BufferLineCloseRight<CR>", "Close right buffer" },
    ["<leader>bp"] = { "<CMD>BufferLinePick<CR>", "Pick buffer" },
    ["<leader>bo"] = { "<CMD>BufferLineCloseRight<CR><CMD>BufferLineCloseLeft<CR>", "Close other buffer" },
    ["<leader>bc"] = { "<CMD>BufferLinePickClose<CR>", "Close picked buffer" },
  },
}

M.cokeline = {
  plugin = true,

  n = {
    ["<C-h>"] = { "<Plug>(cokeline-focus-prev)", "Cycle focus previous buffer" },
    ["<C-l>"] = { "<Plug>(cokeline-focus-next)", "Cycle focus next buffer" },
    -- ["<C-w>"] = { "<CMD>Bdelete!<CR>", "Delete buffer" },
    ["<C-w>"] = { "<Plug>(cokeline-pick-close)", "Close buffer" },
    ["<leader>p"] = { "<Plug>(cokeline-switch-prev)", "Cycle switch previous buffer but not focus" },
    ["<leader>n"] = { "<Plug>(cokeline-switch-next)", "Cycle switch next buffer but not focus" },
    ["<A-1>"] = { "<Plug>(cokeline-focus-1)", "Go to 1 buffer" },
    ["<A-2>"] = { "<Plug>(cokeline-focus-2)", "Go to 2 buffer" },
    ["<A-3>"] = { "<Plug>(cokeline-focus-3)", "Go to 3 buffer" },
    ["<A-4>"] = { "<Plug>(cokeline-focus-4)", "Go to 4 buffer" },
    ["<A-5>"] = { "<Plug>(cokeline-focus-5)", "Go to 5 buffer" },
    ["<A-6>"] = { "<Plug>(cokeline-focus-6)", "Go to 6 buffer" },
    ["<A-7>"] = { "<Plug>(cokeline-focus-7)", "Go to 7 buffer" },
    ["<A-8>"] = { "<Plug>(cokeline-focus-8)", "Go to 8 buffer" },
    ["<A-9>"] = { "<Plug>(cokeline-focus-9)", "Go to 9 buffer" },
  },
}

M.dap = {
  plugin = true,

  n = {
    -- debug
    ["de"] = {
      function()
        local dap = require("dap")
        local dap_ui = require("dapui")
        dap.close()
        dap.terminate()
        dap.repl.close()
        dap_ui.close()
        dap.clear_breakpoints()
      end,
      "End debugger",
    },
    ["dc"] = {
      function()
        require("dap").continue()
      end,
      "Continue debug",
    },
    ["dt"] = {
      function()
        require("dap").toggle_breakpoint()
      end,
      "Set breakpoint",
    },
    ["dT"] = {
      function()
        require("dap").clear_breakpoints()
      end,
      "Clear breakpoint",
    },
    ["dj"] = {
      function()
        require("dap").step_over()
      end,
      "Step over",
    },
    ["dk"] = {
      function()
        require("dap").step_out()
      end,
      "Step out",
    },
    ["dl"] = {
      function()
        require("dap").step_into()
      end,
      "Step into",
    },
    ["dh"] = {
      function()
        require("dapui").eval()
      end,
      "Popups dapUI eval",
    },
  },
}

M.trouble = {
  plugin = true,

  n = {
    ["<leader>xx"] = {
      "<CMD>Trouble diagnostics toggle<CR>",
      "Diagnostics (Trouble)",
    },
    ["<leader>xX"] = {
      "<CMD>Trouble diagnostics toggle filter.buf=0<CR>",
      "",
    },
  },
}

M.snacks = {
  plugin = true,
  n = {
    ["<c-\\>"] = {
      function()
        Snacks.terminal.toggle()
      end,
      "Toggle Terminal",
    },
    ["<leader>cR"] = {
      function()
        Snacks.rename.rename_file()
      end,
      "Rename File",
    },
    ["<leader>z"] = {
      function()
        Snacks.zen()
      end,
      "Toggle Zen Mode",
    },
    ["<leader>Z"] = {
      function()
        Snacks.zen.zoom()
      end,
      "Toggle Zoom",
    },
    ["<leader>ps"] = {
      function()
        Snacks.profiler.startup({})
      end,
      "Startup Profiler",
    },
    ["<leader>n"] = {
      function()
        Snacks.notifier.show_history()
      end,
      "Notification History",
    },
    ["<leader>gb"] = {
      function()
        Snacks.git.blame_line()
      end,
      "Git Blame Line",
    },
    ["<leader>N"] = {
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
      "Neovim News",
    },
  },
  t = {
    ["<c-\\>"] = {
      function()
        Snacks.terminal.toggle()
      end,
      "Toggle Terminal",
    },
  },
}

M.flash = {
  plugin = true,
  n = {
    ["S"] = {
      function()
        require("flash").treesitter()
      end,
      "Flash Treesitter",
    },
  },
  x = {
    ["S"] = {
      function()
        require("flash").treesitter()
      end,
      "Flash Treesitter",
    },
    ["R"] = {
      function()
        require("flash").treesitter_search()
      end,
      "Treesitter Search",
    },
  },
  o = {
    ["S"] = {
      function()
        require("flash").treesitter()
      end,
      "Flash Treesitter",
    },
    ["r"] = {
      function()
        require("flash").remote()
      end,
      "Remote Flash",
    },
    ["R"] = {
      function()
        require("flash").treesitter_search()
      end,
      "Treesitter Search",
    },
  },
  c = {
    ["<c-s>"] = {
      function()
        require("flash").toggle()
      end,
      "Toggle Flash Search",
    },
  },
}

M.inc_rename = {
  plugin = true,

  n = {
    ["<leader>rn"] = {
      function()
        return ":IncRename " .. vim.fn.expand("<cword>")
      end,
      "Incremental Rename",
      opts = { expr = true },
    },
  },
}

return M
