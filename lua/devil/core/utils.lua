local M = {}

-- Auto install plugins by git
---@param path string
---@param repository string
---@param branch string
function M.bootstrap(path, repository, branch)
  if not vim.uv.fs_stat(path) then
    vim.notify(("Bootstarting %s is being installed, please wait..."):format(repository), vim.log.levels.INFO)
    local output = vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      ("https://github.com/%s"):format(repository),
      ("--branch=%s"):format(branch),
      path,
    })
    if vim.v.shell_error ~= 0 or not vim.uv.fs_stat(path) then
      error(("Failed to bootstrap %s: %s"):format(repository, output), 0)
    end
  end
  vim.opt.rtp:prepend(path)
end

-- A full icon for lsp label kinds
M.kind_icons = {
  Array = "󰅪 ",
  Boolean = " ",
  BreakStatement = "󰙧 ",
  Call = "󰃷 ",
  CaseStatement = "󱃙 ",
  Class = " ",
  Color = "󰏘 ",
  Constant = "󰏿 ",
  Constructor = " ",
  ContinueStatement = "→ ",
  Copilot = " ",
  Declaration = "󰙠 ",
  Delete = "󰩺 ",
  DoStatement = "󰑖 ",
  Enum = " ",
  EnumMember = " ",
  Event = " ",
  Field = " ",
  File = "󰈙 ",
  Folder = "󰉋 ",
  ForStatement = "󰑖 ",
  Function = "󰊕 ",
  H1Marker = "󰉫 ", -- Used by markdown treesitter parser
  H2Marker = "󰉬 ",
  H3Marker = "󰉭 ",
  H4Marker = "󰉮 ",
  H5Marker = "󰉯 ",
  H6Marker = "󰉰 ",
  Identifier = "󰀫 ",
  IfStatement = "󰇉 ",
  Interface = " ",
  Keyword = "󰌋 ",
  List = "󰅪 ",
  Log = "󰦪 ",
  Lsp = " ",
  Macro = "󰁌 ",
  MarkdownH1 = "󰉫 ", -- Used by builtin markdown source
  MarkdownH2 = "󰉬 ",
  MarkdownH3 = "󰉭 ",
  MarkdownH4 = "󰉮 ",
  MarkdownH5 = "󰉯 ",
  MarkdownH6 = "󰉰 ",
  Method = "󰆧 ",
  Module = "󰏗 ",
  Namespace = "󰌗 ",
  Null = "󰢤 ",
  Number = "󰎠 ",
  Object = "󰅩 ",
  Operator = "󰆕 ",
  Package = "󰆦 ",
  Pair = "󰅪 ",
  Property = " ",
  Reference = "󰦾 ",
  Regex = " ",
  Repeat = "󰑖 ",
  Scope = "󰅩 ",
  Snippet = "󰩫 ",
  Specifier = "󰦪 ",
  Statement = "󰅩 ",
  String = " ",
  Text = "󰉿 ",
  Unit = "󰑭 ",
  Value = "󰎠 ",
  Variable = " ",
  Struct = " ",
  TypeParameter = "󰊄 ",
}

-- Excluded filetypes
M.exclude_ft = {
  "lazy",
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
}

-- HTML and HTML Templates
M.html_files = {
  "aspnetcorerazor", -- *.cshtml (CSharp - ASP.Net)
  "astro", -- *.astro (JavaScript - Astro SFC)
  "blade", -- *.blade.php (PHP - Laravel)
  "html",
  "edge", -- *.edge (NodeJS optional)
  "ejs", -- *.ejs (Embedded JavaScript templating)
  "eruby", -- *.html.erb (Ruby - Rails)
  "gohtmltmpl", -- *.gohtml (Go official)
  "haml", -- *.haml (Rails optional)
  "handlebars", -- *.html.hbs (Rust - Rocket)
  "heex", -- *.heex (Elixir - Phoenix)
  "htmldjango", -- (Python - Django)
  "leaf", -- *.leaf (Swift - Vapor)
  "liquid", -- *.liquid (Ruby optional)
  "mustache", -- (Ruby optional)
  "njk", -- (Nunjucks - NodeJS optional)
  "php",
  "pug", -- *.pug (NodeJS optional)
  "razor", -- *.razor (CSharp - Blazor)
  "slim", -- *.slim (Ruby optional)
  "svelte", -- *.svelte (JavaScript - Svelte SFC)
  "templ",
  "twig", -- *.twig (PHP - Symfony)
  "vue", -- *.vue (JavaScript - Vue SFC)
}

-- Format getted LSP name
---@param name string
---@return string
local function format_client_name(name)
  return (" [%s]"):format(name)
end

-- Function to get current activated LSP name
---@return string
function M.get_lsp_info()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    return "No Active LSP"
  end

  local lsp_names = {}
  for _, client in ipairs(clients) do
    table.insert(lsp_names, client.name)
  end

  if #lsp_names > 0 then
    return format_client_name(table.concat(lsp_names, " "))
  else
    return "No Active LSP"
  end
end

---@param client vim.lsp.Client
---@param bufnr number
-- Enable inlay hints for supported LSP
function M.set_inlay_hints(client, bufnr)
  if not client then
    vim.notify_once("LSP inlay hints attached failed: nil client.", vim.log.levels.ERROR)
    return
  end

  -- Filtering unstable LSPs
  local blocker_lsps = {
    ["null-ls"] = true,
    ["phpactor"] = true,
    ["zls"] = false,
  }
  if blocker_lsps[client.name] then
    vim.notify("Skip inlay hints for LSP: " .. client.name, vim.log.levels.WARN)
    return
  end

  -- Enabled only it supported
  local ok = client:supports_method("textDocument/inlayHint")
    or (client.server_capabilities and client.server_capabilities.inlayHintProvider)
  if not ok then
    return
  end

  -- Enable inlay hint
  pcall(function()
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end)
end

---Jump to the next diagnostic and open a float for the new cursor location.
---@param count integer
local function jump_diag(count)
  vim.diagnostic.jump({
    count = count,
    on_jump = function(diagnostic, _)
      if not diagnostic then
        return
      end

      vim.diagnostic.open_float({
        border = "single",
        scope = "cursor",
      })
    end,
  })
end

---@param bufnr number
local function set_lsp_keymaps(bufnr)
  local opts = { buffer = bufnr }
  local keymap = vim.keymap.set

  keymap("n", "gD", function()
    vim.lsp.buf.declaration({ reuse_win = true })
  end, vim.tbl_extend("force", opts, { desc = "LSP declaration" }))

  keymap("n", "gd", function()
    local telescope_builtin = require("telescope.builtin")
    local cursor_theme = require("telescope.themes").get_cursor({ reuse_win = true })
    telescope_builtin.lsp_definitions(cursor_theme)
  end, vim.tbl_extend("force", opts, { desc = "LSP definition" }))

  keymap("n", "K", function()
    vim.lsp.buf.hover()
  end, vim.tbl_extend("force", opts, { desc = "LSP hover" }))

  keymap("n", "gi", function()
    require("telescope.builtin").lsp_implementations(require("telescope.themes").get_cursor({ reuse_win = true }))
  end, vim.tbl_extend("force", opts, { desc = "LSP implementation" }))

  keymap("n", "<leader>ls", function()
    vim.lsp.buf.signature_help()
  end, vim.tbl_extend("force", opts, { desc = "LSP signature help" }))

  keymap("n", "<leader>D", function()
    require("telescope.builtin").lsp_type_definitions(require("telescope.themes").get_cursor({ reuse_win = true }))
  end, vim.tbl_extend("force", opts, { desc = "LSP definition type" }))

  keymap({ "n", "v" }, "<leader>ca", function()
    vim.lsp.buf.code_action()
  end, vim.tbl_extend("force", opts, { desc = "LSP code action" }))

  keymap("n", "gr", function()
    require("telescope.builtin").lsp_references(require("telescope.themes").get_cursor({ reuse_win = true }))
  end, vim.tbl_extend("force", opts, { desc = "LSP references" }))

  keymap("n", "<leader>lf", function()
    vim.diagnostic.open_float({ border = "single" })
  end, vim.tbl_extend("force", opts, { desc = "Floating diagnostic" }))

  keymap("n", "[d", function()
    jump_diag(-1)
  end, vim.tbl_extend("force", opts, { desc = "Goto prev" }))

  keymap("n", "]d", function()
    jump_diag(1)
  end, vim.tbl_extend("force", opts, { desc = "Goto next" }))

  keymap("n", "<leader>ds", function()
    vim.diagnostic.setloclist()
  end, vim.tbl_extend("force", opts, { desc = "Diagnostic setloclist" }))

  keymap("n", "<leader>wa", function()
    vim.lsp.buf.add_workspace_folder()
  end, vim.tbl_extend("force", opts, { desc = "Add workspace folder" }))

  keymap("n", "<leader>wr", function()
    vim.lsp.buf.remove_workspace_folder()
  end, vim.tbl_extend("force", opts, { desc = "Remove workspace folder" }))

  keymap("n", "<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, vim.tbl_extend("force", opts, { desc = "List workspace folders" }))

  keymap("n", "<leader>L", function()
    local current_buf = vim.api.nvim_get_current_buf()
    local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = current_buf })
    vim.lsp.inlay_hint.enable(not enabled, { bufnr = current_buf })
  end, vim.tbl_extend("force", opts, { desc = "Toggle LSP inlay hints" }))
end

---@param client vim.lsp.Client
---@param bufnr number
function M.on_attach(client, bufnr)
  M.set_inlay_hints(client, bufnr)

  set_lsp_keymaps(bufnr)

  vim.api.nvim_set_option_value("formatexpr", "v:lua.require'conform'.formatexpr()", { buf = bufnr })
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()

M.capabilities.textDocument.completion.completionItem = {
  documentationFormat = { "markdown", "plaintext" },
  snippetSupport = true,
  preselectSupport = true,
  insertReplaceSupport = true,
  labelDetailsSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  tagSupport = { valueSet = { 1 } },
  resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  },
}

function M.default_config()
  return {
    on_attach = M.on_attach,
    capabilities = M.capabilities,
  }
end

return M
