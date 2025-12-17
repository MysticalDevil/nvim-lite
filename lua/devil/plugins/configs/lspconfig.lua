local utils = require("devil.core.utils")
local lsp_util = require("lspconfig.util")

require("mason-lspconfig").setup({
  automatic_installation = true,
  ensure_installed = { "clangd", "gopls", "lua_ls", "rust_analyzer", "tsgo", "zls" },
})

local default_config = utils.default_config()
default_config.capabilities = require("blink.cmp").get_lsp_capabilities(default_config.capabilities)

local noconfig_servers = {
  "bashls",
  "cssls",
  "cssmodules_ls",
  "emmet_language_server",
  "golangci_lint_ls",
  "html",
  "lemminx",
  "marksman",
  "neocmake",
  "ruff",
  "svelte",
  "tailwindcss",
  "taplo",
  "vimls",
}

for _, server in pairs(noconfig_servers) do
  vim.lsp.config(server, default_config)
  vim.lsp.enable(server)
end

-- clangd, clang official lsp. https://github.com/clangd/clangd
local clangd_capabilities = require("blink.cmp").get_lsp_capabilities(utils.capabilities)
clangd_capabilities.offsetEncoding = { "utf-16" } ---@diagnostic disable-line
vim.lsp.config("clangd", {
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false

    require("lsp_signature").on_attach({
      bind = true,
      handler_opts = {
        border = "single",
      },
    }, bufnr)

    utils.set_inlay_hints(client, bufnr)

    utils.load_mappings("lspconfig", { buffer = bufnr })

    vim.api.nvim_set_option_value("formatexpr", "v:lua.require'conform'.formatexpr()", { buf = bufnr })
    vim.api.nvim_set_option_value("omnifunc", "v:lua.vim.lsp.omnifunc", { buf = bufnr })
    vim.api.nvim_set_option_value("tagfunc", "v:lua.vim.lsp.tagfunc", { buf = bufnr })
  end,
  capabilities = clangd_capabilities,

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
})

-- lua-language-server(sumneko). https://github.com/LuaLS/lua-language-server
local runtime_path = vim.split(package.path, ";", {})
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/>/init.lua")

local lua_ls = {
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
        path = runtime_path,
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = {
          [vim.fn.expand("$VIMRUNTIME/lua")] = true,
          [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
          [vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy"] = true,
        },
        maxPreload = 100000,
        preloadFileSize = 10000,
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
    },
  },
}

-- gopls, golang official lsp. https://github.com/golang/tools/blob/master/gopls
local gopls = {
  settings = {
    gopls = {
      experimentalPostfixCompletions = true,
      analyses = {
        shadow = true,
        fieldalignment = true,
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
      codelenses = {
        gc_details = false,
        generate = true,
        regenerate_cgo = true,
        run_govulncheck = true,
        test = true,
        tidy = true,
        upgrade_dependency = true,
        vendor = true,
      },
      usePlaceholders = true,
      completeUnimported = true,
      staticcheck = true,
      directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
      semanticTokens = true,
    },
  },
}

-- zls, zigtools provide's lsp. https://github.com/zigtools/zls
local zls = {
  settings = {
    zls = {
      enable_snippets = true,
      enable_argument_placeholders = true,
      enable_ast_check_diagnostics = true,
      enable_build_on_save = true,
      enable_autofix = false,
      semantic_tokens = "full",
      enable_inlay_hints = true,
      inlay_hints_show_variable_type_hints = true,
      inlay_hints_show_parameter_name = true,
      inlay_hints_show_builtin = true,
      inlay_hints_exclude_single_argument = true,
      inlay_hints_hide_redundant_param_names = false,
      inlay_hints_hide_redundant_param_names_last_token = false,
      warn_style = false,
      highlight_global_var_declarations = false,
      dangerous_comptime_experiments_do_not_enable = false,
      skip_std_references = false,
      prefer_ast_check_as_child_process = true,
      record_session = false,
      record_session_path = nil,
      replay_session_path = nil,
      builtin_path = nil,
      zig_lib_path = nil,
      zig_exe_path = nil,
      build_runner_path = nil,
      global_cache_path = nil,
      build_runner_global_cache_path = nil,
      completions_with_replace = true,
    },
  },
}

-- denols. deno official lsp. https://github.com/denoland/deno/blob/main/cli/lsp
local denols = {
  settings = {
    deno = {
      enable = true,
      suggest = {
        imports = {
          hosts = {
            ["https://deno.land"] = true,
          },
        },
      },
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
}

-- eslint. eslint official lsp. https://github.com/eslint/eslint
local eslint = {
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
}

-- jsonls, the popular json lsp. https://github.com/json-transformations/jsonls
local jsonls = {
  settings = {
    json = {
      schemas = require("schemastore").json.schemas({
        ignore = {},
      }),
      validate = { enable = true },
      format = { enable = true },
    },
  },
}

-- rust-analyzer, rust offical lsp. https://github.com/rust-lang/rust-analyzer
local rust_analyzer = {
  settings = {
    rust_analyzer = {
      checkOnSave = {
        allFeatures = true,
        overrideCommand = {
          "cargo",
          "clippy",
          "--workspace",
          "--message-format=json",
          "--all-targets",
          "--all-features",
        },
      },
      cargo = {
        loadOutDirsFromCheck = true,
      },
      procMacro = {
        enable = true,
      },
      inlayHints = {
        bindingModeHints = {
          enable = false,
        },
        chainingHints = {
          enable = true,
        },
        closingBraceHints = {
          enable = true,
          minLines = 25,
        },
        closureReturnTypeHints = {
          enable = "never",
        },
        lifetimeElisionHints = {
          enable = "never",
          useParameterNames = false,
        },
        maxLength = 25,
        parameterHints = {
          enable = true,
        },
        reborrowHints = {
          enable = "never",
        },
        renderColons = true,
        typeHints = {
          enable = true,
          hideClosureInitialization = false,
          hideNamedConstructor = false,
        },
      },
    },
  },
}

-- svelte-language-server, sveltejs official lsp. https://github.com/sveltejs/language-tools
local svelte = {
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
}

-- tsgo, typescript7.0 official native compiler(rewrite with go). https://github.com/microsoft/typescript-go
local tsgo = {
  settings = {
    typescript = {
      inlayHints = {
        parameterNames = { enabled = "literals" }, -- "none" | "literals" | "all"
        parameterTypes = { enabled = true },
        variableTypes = { enabled = true },
        propertyDeclarationTypes = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        enumMemberValues = { enabled = true },
      },
    },
  },
}

-- vue_ls, vue.js official lsp. https://github.com/vuejs/language-tools
local vue_ls = {
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
}

-- tailwindcss, tailwindcss's official lsp. https://github.com/tailwindlabs/tailwindcss-intellisense
local tailwindcss = {
  root_dir = function(fname)
    return lsp_util.root_pattern(
      "tailwind.config.js",
      "tailwind.config.cjs",
      "tailwind.config.mjs",
      "tailwind.config.ts",
      "postcss.config.js",
      "postcss.config.cjs",
      "postcss.config.mjs",
      "postcss.config.ts"
    )(fname) or vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
  end,
}

-- ty, an extremely fast Python type checker and language server, written in Rust. https://github.com/astral-sh/ty
local ty = {
  settings = {
    ty = {
      diagnosticsMode = "openFilesOnly",
      inlayHints = {
        variableTypes = true,
        callArgumentNames = true,
      },
      completions = {
        autoImport = true,
      }
    }
  }
}

-- yaml-language-server, redhat provided lsp. https://github.com/redhat-developer/yaml-language-server
local yamlls = {
  settings = {
    yaml = {
      schemaStore = {
        -- You must disable built-in schemaStore support if you want to use
        -- this plugin and its advanced options like `ignore`.
        enable = false,
        -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
        url = "",
      },
      schemas = require("schemastore").yaml.schemas(),
    },
  },
}

local lsp_configs = {
  ["denols"] = denols,
  ["eslint"] = eslint,
  ["gopls"] = gopls,
  ["jsonls"] = jsonls,
  ["lua_ls"] = lua_ls,
  ["rust-analyzer"] = rust_analyzer,
  ["svelte"] = svelte,
  ["tailwindcss"] = tailwindcss,
  ["tsgo"] = tsgo,
  ["ty"] = ty,
  ["vue_ls"] = vue_ls,
  ["yamlls"] = yamlls,
  ["zls"] = zls,
}

for lsp_name, lsp_config in pairs(lsp_configs) do
  vim.lsp.config(lsp_name, lsp_config)
  vim.lsp.enable(lsp_name)
end
