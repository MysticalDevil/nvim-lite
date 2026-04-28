local M = {}

M.blankline = {
  exclude = {
    filetypes = {
      "null-ls-info",
      "dashboard",
      "packer",
      "terminal",
      "help",
      "log",
      "markdown",
      "TelescopePrompt",
      "mason",
      "mason-lspconfig",
      "lspinfo",
      "toggleterm",
      "text",
      "checkhealth",
      "man",
      "gitcommit",
      "TelescopePrompt",
      "TelescopeResults",
    },
    buftypes = {
      "terminal",
      "nofile",
      "quickfix",
      "prompt",
    },
  },
}

M.gitsigns = {
  signs = {
    add = { text = "│" },
    change = { text = "│" },
    delete = { text = "_" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
    untracked = { text = "┆" },
  },
  on_attach = function(bufnr)
    local opts = { buffer = bufnr }
    local keymap = vim.keymap.set

    keymap("n", "]c", function()
      if vim.wo.diff then
        return "]c"
      end
      vim.schedule(function()
        require("gitsigns").nav_hunk("next")
      end)
      return "<Ignore>"
    end, vim.tbl_extend("force", opts, { expr = true, desc = "Jump to next hunk" }))

    keymap("n", "[c", function()
      if vim.wo.diff then
        return "[c"
      end
      vim.schedule(function()
        require("gitsigns").nav_hunk("prev")
      end)
      return "<Ignore>"
    end, vim.tbl_extend("force", opts, { expr = true, desc = "Jump to prev hunk" }))

    keymap("n", "<leader>rh", function()
      require("gitsigns").reset_hunk()
    end, vim.tbl_extend("force", opts, { desc = "Reset hunk" }))

    keymap("n", "<leader>ph", function()
      require("gitsigns").preview_hunk_inline()
    end, vim.tbl_extend("force", opts, { desc = "Preview hunk" }))

    keymap("n", "<leader>gB", function()
      require("gitsigns").blame_line()
    end, vim.tbl_extend("force", opts, { desc = "Blame line" }))

    keymap("n", "<leader>td", function()
      require("gitsigns").preview_hunk_inline()
    end, vim.tbl_extend("force", opts, { desc = "Preview hunk inline" }))

    keymap("n", "<leader>tl", function()
      require("gitsigns").toggle_numhl()
      require("gitsigns").toggle_linehl()
    end, vim.tbl_extend("force", opts, { desc = "Toggle gitsigns line highlight" }))

    keymap("n", "<leader>tw", function()
      require("gitsigns").toggle_word_diff()
    end, vim.tbl_extend("force", opts, { desc = "Toggle different word" }))
  end,
}

return M
