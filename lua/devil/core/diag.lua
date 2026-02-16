local signs = {
  [vim.diagnostic.severity.ERROR] = "󰅚 ",
  [vim.diagnostic.severity.WARN] = " ",
  [vim.diagnostic.severity.HINT] = "󰌶 ",
  [vim.diagnostic.severity.INFO] = " ",
}

local opts = {
  virtual_text = true,
  virtual_lines = true,
  underline = true,
  signs = {
    text = signs,

    numhl = {
      [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
      [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
      [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
      [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
    },
  },
  update_in_insert = false,
  show_header = false,
  severity_sort = true,
  float = {
    source = "if_many",
    border = "rounded",
    style = "minimal",
    header = "",
    -- prefix = " ",
    -- max_width = 100,
    -- width = 60,
    -- height = 20,
  },
}

vim.diagnostic.config(opts)

---@type integer
local diag_augroup = vim.api.nvim_create_augroup("diagnostic_tweaks", { clear = true })

-- Show only cursor line diagnostics when present; otherwise show all diagnostics in current buffer.
local base_virtual_lines = vim.diagnostic.handlers.virtual_lines
vim.diagnostic.handlers.virtual_lines = {
  show = function(namespace, bufnr, diagnostics, handler_opts)
    local cursor_lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
    local has_cursor_diag = false

    for _, diag in ipairs(diagnostics) do
      if diag.bufnr == bufnr and diag.lnum == cursor_lnum then
        has_cursor_diag = true
        break
      end
    end

    if has_cursor_diag then
      diagnostics = vim.tbl_filter(function(diag)
        return diag.bufnr == bufnr and diag.lnum == cursor_lnum
      end, diagnostics)
    end

    base_virtual_lines.show(namespace, bufnr, diagnostics, handler_opts)
  end,
  hide = function(namespace, bufnr)
    base_virtual_lines.hide(namespace, bufnr)
  end,
}

-- Force a diagnostic redraw when exiting Insert mode.
-- Essential when 'update_in_insert = false' is set, ensuring
-- virtual_lines appear immediately upon entering Normal mode.
vim.api.nvim_create_autocmd({ "CursorMoved", "DiagnosticChanged", "InsertLeave" }, {
  group = diag_augroup,
  callback = function()
    vim.diagnostic.show(nil, 0)
  end,
})
