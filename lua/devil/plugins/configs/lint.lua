local lint = require("lint")

lint.linters_by_ft = {
  css = { "stylelint" },
  lua = { "selene" },
  vim = { "vint" },
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  desc = "Lint code on write post",
  callback = function()
    require("lint").try_lint()
  end,
})
