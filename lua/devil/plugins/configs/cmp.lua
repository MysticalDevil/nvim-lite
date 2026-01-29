local function cmp_ghost_text()
  local ctx = require("blink.cmp").get_context()
  local item = require("blink.cmp").get_selected_item()
  if ctx == nil or item == nil then
    return { "s", "n" }
  end

  local item_text = item.textEdit ~= nil and item.textEdit.newText or item.insertText or item.label
  local is_multi_line = item_text:find("\n") ~= nil

  if is_multi_line or vim.g.blink_cmp_upwards_ctx_id == ctx.id then
    vim.g.blink_cmp_upwards_ctx_id = ctx.id
    return { "n", "s" }
  end

  return { "s", "n" }
end

return {
  -- Sync keymaps with nvim project
  keymap = {
    preset = "enter",
    -- Navigation
    ["<C-k>"] = { "select_prev", "fallback" },
    ["<C-j>"] = { "select_next", "fallback" },
    -- Scroll docs
    ["<C-u>"] = { "scroll_documentation_up", "fallback" },
    ["<C-d>"] = { "scroll_documentation_down", "fallback" },
    -- Trigger / Hide
    ["<A-.>"] = { "show", "fallback" },
    ["<A-,>"] = { "hide", "fallback" },
    -- Super-tab behavior (Snippet jump or Next item)
    ["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
    ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
  },

  appearance = {
    use_nvim_cmp_as_default = true,
    nerd_font_variant = "mono",
  },

  cmdline = {
    sources = function()
      local type = vim.fn.getcmdtype()
      if type == "/" or type == "?" then
        return { "buffer" }
      end
      if type == ":" then
        return { "cmdline" }
      end
      return {}
    end,
  },

  sources = {
    default = { "lazydev", "lsp", "path", "snippets", "buffer" },
    providers = {
      lazydev = {
        name = "Lua", -- Display as [Lua] like nvim
        module = "lazydev.integrations.blink",
        score_offset = 100,
      },
      lsp = {
        name = "LSP", -- Display as [LSP]
        module = "blink.cmp.sources.lsp",
        score_offset = 0,
      },
      path = {
        name = "Path",
        module = "blink.cmp.sources.path",
        min_keyword_length = 0,
      },
      snippets = {
        name = "Snip",
        module = "blink.cmp.sources.snippets",
        opts = {
          friendly_snippets = true,
          extended_filetypes = {
            sh = { "shelldoc" },
          },
        },
      },
      buffer = {
        name = "Buf",
        module = "blink.cmp.sources.buffer",
        min_keyword_length = 5,
        max_items = 5,
      },
      cmdline = {
        name = "CMD",
        module = "blink.cmp.sources.cmdline",
      },
    },
  },

  completion = {
    accept = {
      auto_brackets = { enabled = true },
    },
    ghost_text = { enabled = true },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 250,
      treesitter_highlighting = true,
      window = { border = "single" }, -- Synced border style
    },
    menu = {
      border = "single", -- Synced border style
      auto_show = true,
      auto_show_delay_ms = 200,

      -- Customize draw to mimic nvim's lspkind formatting
      draw = {
        columns = {
          { "label", "label_description", gap = 1 },
          { "kind_icon", "kind", gap = 1 },
          { "source_name" }, -- Add source label column
        },
        components = {
          source_name = {
            text = function(ctx)
              return "[" .. ctx.source_name .. "]"
            end,
            highlight = "Comment",
          },
          kind_icon = {
            text = function(ctx)
              local icon = ctx.kind_icon
              -- Use devicons for Path source if available
              if vim.tbl_contains({ "Path" }, ctx.source_name) then
                local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
                if dev_icon then
                  icon = dev_icon
                end
              end
              return icon .. ctx.icon_gap
            end,
            highlight = function(ctx)
              local hl = ctx.kind_hl
              if vim.tbl_contains({ "Path" }, ctx.source_name) then
                local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
                if dev_icon then
                  hl = dev_hl
                end
              end
              return hl
            end,
          },
        },
      },

      direction_priority = cmp_ghost_text,
    },
  },

  fuzzy = {
    sorts = {
      function(a, b)
        if (a.client_name == nil or b.client_name == nil) or (a.client_name == b.client_name) then
          return
        end
        return b.client_name == "emmet_ls"
      end,
      "score",
      "sort_text",
    },
  },
}
