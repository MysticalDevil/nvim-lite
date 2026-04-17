local utils = require("devil.core.utils")
local lsp_util = require("lspconfig.util")

---Return whether the current machine is Linux on ARM64/AArch64.
---@return boolean
local function is_linux_arm64()
  local uname = vim.uv.os_uname()
  local sysname = (uname.sysname or ""):lower()
  local machine = (uname.machine or ""):lower()
  return sysname == "linux" and (machine:match("^arm64") ~= nil or machine:match("^aarch64") ~= nil)
end

---Find an executable in PATH while skipping Mason-managed directories.
---@param name string
---@return string|nil
local function find_system_bin(name)
  local path_sep = (vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1) and ";" or ":"
  local mason_root = vim.fs.normalize(vim.fn.stdpath("data") .. "/mason")

  for _, dir in ipairs(vim.split(vim.env.PATH or "", path_sep, { trimempty = true })) do
    local normalized_dir = vim.fs.normalize(dir)
    if not vim.startswith(normalized_dir, mason_root) then
      local candidate = vim.fs.joinpath(normalized_dir, name)
      if vim.fn.executable(candidate) == 1 then
        return candidate
      end
    end
  end

  return nil
end

-- Mason's clangd is not installable on some ARM platforms, at least Linux aarch64.
local system_clangd = nil
if is_linux_arm64() then
  system_clangd = find_system_bin("clangd")
  if not system_clangd then
    vim.notify_once(
      "Linux ARM64 platform detected but no non-Mason clangd was found in PATH; skipping clangd setup.",
      vim.log.levels.WARN
    )
  end
end

local capabilities = utils.capabilities
local has_blink, blink = pcall(require, "blink.cmp")
if has_blink then
  capabilities = blink.get_lsp_capabilities(capabilities)
end

local ensure_servers = { "gopls", "lua_ls", "rust_analyzer", "tsgo", "zls" }

local install_requirements = {
  gopls = { "go" },
  tsgo = { "node", "npm" },
}

---@param servers string[]
---@return string[], string[]
local function filter_installable_servers(servers)
  local enabled = {}
  local warnings = {}

  for _, server in ipairs(servers) do
    local requirements = install_requirements[server]
    if not requirements then
      table.insert(enabled, server)
    else
      local missing = {}
      for _, bin in ipairs(requirements) do
        if vim.fn.executable(bin) ~= 1 then
          table.insert(missing, bin)
        end
      end

      if #missing == 0 then
        table.insert(enabled, server)
      else
        table.insert(
          warnings,
          ("%s skipped: missing install dependency %s"):format(server, table.concat(missing, ", "))
        )
      end
    end
  end

  return enabled, warnings
end

local ensured_servers, install_warnings = filter_installable_servers(ensure_servers)
if #install_warnings > 0 then
  vim.schedule(function()
    vim.notify_once(
      "Mason auto-install skipped some LSP servers:\n" .. table.concat(install_warnings, "\n"),
      vim.log.levels.WARN
    )
  end)
end

require("mason-lspconfig").setup({
  automatic_installation = true,
  ensure_installed = ensured_servers,
})

local servers = {
  bashls = {},
  cssls = {},
  cssmodules_ls = {},
  docker_language_server = {},
  emmet_language_server = {},
  html = {},

  hls = {
    settings = {
      haskell = {
        formattingProvider = "ormolu",
        cabalFormattingProvider = "cabalfmt",
        plugin = {
          stan = { globalOn = false },
        },
      },
    },
  },

  lemminx = {},
  marksman = {},
  neocmake = {},
  nil_ls = {},
  ruff = {},
  tailwindcss = {},
  taplo = {},
  vimls = {},

  clangd = {
    cmd = system_clangd and { system_clangd } or nil,
    enabled = not is_linux_arm64() or system_clangd ~= nil,
    settings = {
      clangd = {
        InlayHints = {
          Designators = true,
          Enabled = true,
          ParameterNames = true,
          DeducedTypes = true,
        },
        fallbackFlags = { "-std=c++20" },
      },
    },
  },

  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        workspace = {
          maxPreload = 100000,
          preloadFileSize = 10000,
          checkThirdParty = false,
        },
        hint = {
          enable = true,
          arrayIndex = "Auto",
          await = true,
          paramName = "All",
          paramType = true,
          semicolon = "SameLine",
          setType = false,
        },
        telemetry = { enable = false },
      },
    },
  },

  gopls = {
    settings = {
      gopls = {
        experimentalPostfixCompletions = true,
        analyses = {
          shadow = true,
          nilness = true,
          unusedparams = true,
          unusedwrite = true,
          useany = true,
        },
        gofumpt = true,
        hints = {
          rangeVariableTypes = true,
          parameterNames = true,
          constantValues = true,
          assignVariableTypes = true,
          compositeLiteralFields = true,
          compositeLiteralTypes = true,
          functionTypeParameters = true,
        },
        usePlaceholders = true,
        completeUnimported = true,
        staticcheck = true,
        directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
        semanticTokens = false,
        noSemanticTokens = true,
      },
    },
  },

  zls = {
    settings = {
      zls = {
        enable_snippets = true,
        enable_argument_placeholders = true,
        enable_ast_check_diagnostics = true,
        enable_build_on_save = true,
        enable_inlay_hints = true,
        inlay_hints_show_variable_type_hints = true,
        inlay_hints_show_parameter_name = true,
        inlay_hints_show_builtin = true,
        warn_style = false,
        highlight_global_var_declarations = false,
      },
    },
  },

  denols = {
    settings = {
      deno = {
        enable = true,
        suggest = { imports = { hosts = { ["https://deno.land"] = true } } },
        inlayHints = {
          parameterNames = { enabled = "all", suppressWhenArgumentMatchesName = true },
          parameterTypes = { enabled = true },
          variableTypes = { enabled = true, suppressWhenTypeMatchesName = true },
          propertyDeclarationTypes = { enabled = true },
          functionLikeReturnTypes = { enable = true },
          enumMemberValues = { enabled = true },
        },
      },
    },
  },

  eslint = {
    root_dir = function(fname)
      local root_file = lsp_util.insert_package_json({
        ".eslintrc",
        ".eslintrc.js",
        ".eslintrc.cjs",
        ".eslintrc.yaml",
        ".eslintrc.yml",
        ".eslintrc.json",
        "eslint.config.js",
        "eslint.config.mjs",
      }, "eslintConfig", fname)
      return lsp_util.root_pattern(unpack(root_file))(fname)
    end,
  },

  jsonls = {
    settings = {
      json = {
        schemas = require("schemastore").json.schemas({ ignore = {} }),
        validate = { enable = true },
        format = { enable = true },
      },
    },
  },

  rust_analyzer = {
    settings = {
      rust_analyzer = {
        checkOnSave = {
          command = "clippy",
        },
        inlayHints = {
          chainingHints = { enable = true },
          typeHints = { enable = true },
          parameterHints = { enable = true },
        },
      },
    },
  },

  svelte = {
    settings = {
      typescript = {
        inlayHints = {
          parameterNames = { enabled = "all" },
          parameterTypes = { enabled = true },
          variableTypes = { enabled = true },
          propertyDeclarationTypes = { enabled = true },
          functionLikeReturnTypes = { enabled = true },
          enumMemberValues = { enabled = true },
        },
      },
    },
  },

  tsgo = {
    settings = {
      typescript = {
        inlayHints = {
          parameterNames = { enabled = "literals" },
          parameterTypes = { enabled = true },
          variableTypes = { enabled = true },
          propertyDeclarationTypes = { enabled = true },
          functionLikeReturnTypes = { enabled = true },
          enumMemberValues = { enabled = true },
        },
      },
    },
  },

  vue_ls = {
    settings = {
      vue = {
        inlayHints = {
          inlineHandlerLeading = true,
          missingProps = true,
          optionsWrapper = true,
          vBindShorthand = true,
        },
      },
    },
  },

  ty = {
    settings = {
      ty = {
        diagnosticsMode = "openFilesOnly",
        inlayHints = { variableTypes = true, callArgumentNames = true },
        completions = { autoImport = true },
      },
    },
  },

  yamlls = {
    settings = {
      yaml = {
        schemaStore = { enable = false, url = "" },
        schemas = require("schemastore").yaml.schemas(),
      },
    },
  },
}

for name, opts in pairs(servers) do
  local enabled = opts.enabled
  opts.enabled = nil

  if enabled == false then
    goto continue
  end

  -- Merge capabilities (unless specifically overridden like in clangd)
  if not opts.capabilities then
    opts.capabilities = capabilities
  end

  -- Wrap on_attach to ensure core utils.on_attach is always called
  local original_on_attach = opts.on_attach
  opts.on_attach = function(client, bufnr)
    -- Call the common setup (keymaps, inlay hints helper, etc.)
    utils.on_attach(client, bufnr)

    -- Call server-specific on_attach if it exists
    if original_on_attach then
      original_on_attach(client, bufnr)
    end
  end

  -- Explicitly configure and enable
  vim.lsp.config(name, opts)
  vim.lsp.enable(name)

  ::continue::
end
