local utils = require("devil.core.utils")
local lsp_util = require("lspconfig.util")

local capabilities = utils.capabilities
local has_blink, blink = pcall(require, "blink.cmp")
if has_blink then
  capabilities = blink.get_lsp_capabilities(capabilities)
end

require("mason-lspconfig").setup({
  automatic_installation = true,
  ensure_installed = { "gopls", "lua_ls", "rust_analyzer", "tsgo", "zls" },
})

local servers = {
  bashls = {},
  cssls = {},
  cssmodules_ls = {},
  docker_language_server = {},
  emmet_language_server = {},
  html = {},
  lemminx = {},
  marksman = {},
  neocmake = {},
  nixd = {},
  ruff = {},
  tailwindcss = {},
  taplo = {},
  vimls = {},

  clangd = {
    on_attach = function(client, _)
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end,
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
        semanticTokens = true,
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
end
