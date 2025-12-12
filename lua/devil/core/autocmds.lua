local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local common = augroup("common", { clear = true })
local prog = augroup("prog", { clear = true })

autocmd("TermOpen", {
  group = common,
  command = "startinsert",
  desc = "when in term mode automatical enter insert mode",
})

autocmd("BufEnter", {
  group = common,
  callback = function()
    vim.opt.formatoptions = vim.opt.formatoptions - "o" + "r"
  end,
  desc = "newlines with `o` do not continue comments",
})

autocmd("FileType", {
  group = common,
  pattern = { "nvim-docs-view" },
  desc = "Auto disable side line number for some filetypes",
  callback = function()
    vim.opt.number = false
  end,
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
