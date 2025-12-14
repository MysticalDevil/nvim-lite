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
  },
  completion = {
    ghost_text = { enabled = true },
    menu = {
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
      },

      direction_priority = cmp_ghost_text
    },
  },
}
