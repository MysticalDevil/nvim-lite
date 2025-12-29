local M = {}
local merge_tb = vim.tbl_deep_extend

-- Auto install plugins by git
---@param path string
---@param repository string
---@param branch string
function M.bootstrap(path, repository, branch)
  if not vim.loop.fs_stat(path) then
    vim.notify(("Bootstarting %s is being installed, please wait..."):format(repository), vim.log.levels.INFO)
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      ("https://github.com/%s"):format(repository),
      ("--branch=%s"):format(branch),
      path,
    })
  end
  vim.opt.rtp:prepend(path)
end

-- Load mappings
function M.load_mappings(section, mapping_opt)
  vim.schedule(function()
    local function set_section_map(section_values)
      if section_values.plugin then
        return
      end

      section_values.plugin = nil

      for mode, mode_values in pairs(section_values) do
        local default_opts = merge_tb("force", { mode = mode }, mapping_opt or {})
        for keybind, mapping_info in pairs(mode_values) do
          -- merge default + user opts
          local opts = merge_tb("force", default_opts, mapping_info.opts or {})

          mapping_info.opts, opts.mode = nil, nil
          opts.desc = mapping_info[2]

          vim.keymap.set(mode, keybind, mapping_info[1], opts)
        end
      end
    end

    local mappings = require("devil.core.mappings")

    if type(section) == "string" then
      mappings[section]["plugin"] = nil
      mappings = { mappings[section] }
    end

    for _, sect in pairs(mappings) do
      set_section_map(sect)
    end
  end)
end

-- Lazy load plugins
function M.lazy_load(plugin)
  vim.api.nvim_create_autocmd({ "BufRead", "BufWinEnter", "BufNewFile" }, {
    group = vim.api.nvim_create_augroup("BeLazyOnFileOpen" .. plugin, {}),
    callback = function()
      local file = vim.fn.expand("%")
      local condition = file ~= "neo-tree filesystem [1]" and file ~= "[lazy]" and file ~= ""

      if condition then
        vim.api.nvim_del_augroup_by_name("BeLazyOnFileOpen" .. plugin)

        -- dont defer for treesitter as it will show slow highlighting
        -- This deferring only happens only when we do "nvim filename"
        if plugin ~= "nvim-treesitter" then
          vim.schedule(function()
            require("lazy").load({ plugins = plugin })

            if plugin == "nvim-lspconfig" or plugin == "neo-tree" then
              vim.cmd("silent! do FileType")
            end
          end)
        else
          require("lazy").load({ plugins = plugin })
        end
      end
    end,
  })
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

-- Proxy LSP name
local proxy_lsps = {
  ["null-ls"] = true,
  ["ast_grep"] = true,
  ["efm"] = true,
}
-- Determine whether the obtained LSP is a proxy LSP
---@param name string
---@return boolean
function M.not_proxy_lsp(name)
  return not proxy_lsps[name]
end

-- Format getted LSP name
---@param name string
---@return string
local function format_client_name(name)
  return (" [%s]"):format(name)
end

-- Function to get current activated LSP name
---@return string
function M.get_lsp_info()
  local buf_ft = vim.api.nvim_get_option_value("filetype", { scope = "local" })

  local clients = vim.lsp.get_clients()
  if not clients then
    return "No Active LSP"
  end

  local lsp_names = {}
  for _, client in ipairs(clients) do
    if client.config["filetypes"] and vim.tbl_contains(client.config["filetypes"], buf_ft) then
      if M.not_proxy_lsp(client.name) then
        table.insert(lsp_names, client.name)
      end
    end
  end

  if #lsp_names > 0 then
    return format_client_name(table.concat(lsp_names, " "))
  else
    return "No Active LSP"
  end
end

local inlay_hint = vim.lsp.inlay_hint

---@param client lsp.Client
---@param bufnr number
-- Enable inlay hints for supported LSP
function M.set_inlay_hints(client, bufnr)
  if not client then
    vim.notify_once("LSP inlay hints attached failed: nil client.", vim.log.levels.ERROR)
    return
  end

  if client.name == "zls" then
    vim.g.zig_fmt_autosave = 1
  end

  if client.supports_method("textDocument/inlayHint") or client.server_capabilities.inlayHintProvider then
    inlay_hint.enable(true, { bufnr = bufnr })
  end
end

---@param client lsp.Client
---@param bufnr number
function M.on_attach(client, bufnr)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false

  M.set_inlay_hints(client, bufnr)

  M.load_mappings("lspconfig", { buffer = bufnr })

  vim.api.nvim_set_option_value("formatexpr", "v:lua.require'conform'.formatexpr()", { buf = bufnr })
  vim.api.nvim_set_option_value("omnifunc", "v:lua.vim.lsp.omnifunc", { buf = bufnr })
  vim.api.nvim_set_option_value("tagfunc", "v:lua.vim.lsp.tagfunc", { buf = bufnr })
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

---@param lsp_name string
---@param lsp_config table
-- Setup user's lsp custom configs
function M.setup_custom_settings(lsp_name, lsp_config)
  require("lspconfig")[lsp_name].setup(merge_tb("force", M.default_config(), lsp_config))
end

return M
