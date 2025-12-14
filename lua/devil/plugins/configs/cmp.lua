local function cmp_ghost_text()
  local ctx = require("blink.cmp").get_context()
  local item = require("blink.cmp").get_selected_item()
  if ctx == nil or item == nil then return { "s", "n" } end

  local item_text = item.textEdit ~= nil and item.textEdit.newText or item.insertText or item.label
  local is_multi_line = item_text:find("\n") ~= nil

  if is_multi_line or vim.g.blink_cmp_upwards_ctx_id == ctx.id then
    vim.g.blink_cmp_upwards_ctx_id = ctx.id
    return { "n", "s" }
  end

  return { "s", "n" }
end

return {
  -- 'default' for mappings similar to built-in completion
  -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
  -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
  -- See the full "keymap" documentation for information on defining your own keymap.
  keymap = { preset = "super-tab" },

  appearance = {
    -- Sets the fallback highlight groups to nvim-cmp's highlight groups
    -- Useful for when your theme doesn't support blink.cmp
    -- Will be removed in a future release
    use_nvim_cmp_as_default = true,
    -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
    -- Adjusts spacing to ensure icons are aligned
    nerd_font_variant = "mono",
  },
  -- Default list of enabled providers defined so that you can extend it
  -- elsewhere in your config, without redefining it, due to `opts_extend`
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
    cmdline = function()
      local type = vim.fn.getcmdtype()
      -- Search forward and backward
      if type == "/" or type == "?" then
        return { "buffer" }
      end
      -- Commands
      if type == ":" then
        return { "cmdline" }
      end
      return {}
    end,
    providers = {
      lsp = {
        min_keyword_length = 2, -- Number of characters to trigger porvider
        score_offset = 0,       -- Boost/penalize the score of the items
      },
      path = {
        min_keyword_length = 0,
      },
      snippets = {
        min_keyword_length = 2,
      },
      buffer = {
        min_keyword_length = 5,
        max_items = 5,
      },
    },
  },
  completion = {
    ghost_text = { enabled = true },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 250,
      treesitter_highlighting = true,
      window = { border = "single" },
    },
    menu = {
      border = "single",
      -- Don't automatically show the completion menu
      auto_show = true,
      -- Delay before showing the completion menu while typing
      auto_show_delay_ms = 500,

      -- nvim-cmp style menu
      draw = {
        columns = {
          { "label",     "label_description", gap = 1 },
          { "kind_icon", "kind",              gap = 1 },
        },
        components = {
          kind_icon = {
            text = function(ctx)
              local icon = ctx.kind_icon
              if vim.tbl_contains({ "Path" }, ctx.source_name) then
                local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
                if dev_icon then
                  icon = dev_icon
                end
              else
                icon = require("lspkind").symbolic(ctx.kind, {
                  mode = "symbol",
                })
              end

              return icon .. ctx.icon_gap
            end,

            -- Optionally, use the highlight groups from nvim-web-devicons
            -- You can also add the same function for `kind.highlight` if you want to
            -- keep the highlight groups in sync with the icons.
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
          }
        }
      },

      -- Avoid multi-line completion ghost text
      direction_priority = cmp_ghost_text
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
    }
  }
}
