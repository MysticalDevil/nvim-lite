local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local commonAugroup = augroup("commonAugroup", { clear = true })
local prog = augroup("prog", { clear = true })

autocmd("TermOpen", {
  group = commonAugroup,
  command = "startinsert",
  desc = "when in term mode automatical enter insert mode",
})

autocmd("BufEnter", {
  group = commonAugroup,
  callback = function()
    vim.opt.formatoptions = vim.opt.formatoptions - "o" + "r"
  end,
  desc = "newlines with `o` do not continue comments",
})

autocmd("FileType", {
  group = commonAugroup,
  pattern = { "nvim-docs-view" },
  desc = "Auto disable side line number for some filetypes",
  callback = function()
    vim.opt.number = false
  end,
})

autocmd("TextYankPost", {
  group = commonAugroup,
  callback = function()
    vim.highlight.on_yank()
  end,
  desc = "Highlight on yank",
})

autocmd("BufReadPost", {
  group = commonAugroup,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
  desc = "Go to last loc when opening a buffer",
})

autocmd("FileType", {
  group = prog,
  pattern = { "cs", "java", "kotlin", "php" },
  desc = "Use 4 spaces indent for some filetypes",
  callback = function()
    vim.o.shiftwidth = 4
    vim.o.tabstop = 4
    vim.o.expandtab = true
  end,
})
