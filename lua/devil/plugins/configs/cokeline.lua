---nvim-cokeline configuration.
---
--- cokeline renders a configurable tabline (buffer line) at the top of each window.
--- Each "component" is a Lua table describing a visual segment of a buffer tab.
--- Component fields:
---   • text       – string | fun(buffer): string   what to display
---   • fg         – string | fun(buffer): string   foreground color
---   • bg         – string | fun(buffer): string   background color
---   • style      – string | fun(buffer): string   "bold", "italic", "underline", …
---   • bold       – boolean                        shorthand for style = "bold"
---   • truncation – { priority = int, direction = "left"|"right" }
---   • on_click   – fun(mouse_btn, clicks, btn, modifiers, buffer)
---
--- The `buffer` argument passed to callbacks is a cokeline Buffer object:
---   • index, number, filename, filetype, bufnr
---   • is_focused, is_modified, is_first, is_last
---   • devicon = { icon, color }
---   • diagnostics = { errors, warnings }
---   • unique_prefix, pick_letter, …

local get_hex = require("cokeline.hlgroups").get_hl_attr
local mappings = require("cokeline.mappings")

-- ---------------------------------------------------------------------------
-- Palette (extracted from current colorscheme, with hardcoded fallbacks)
-- ---------------------------------------------------------------------------

local red = get_hex("DiagnosticError", "fg") or "#E06C75"
local yellow = get_hex("DiagnosticWarn", "fg") or "#E5C07B"
local green = get_hex("String", "fg") or "#98C379"

local comments_fg = get_hex("Comment", "fg") or "#5C6370"
local errors_fg = get_hex("DiagnosticError", "fg") or "#E06C75"
local warnings_fg = get_hex("DiagnosticWarn", "fg") or "#E5C07B"
local normal_bg = get_hex("Normal", "bg") or "#1E222A"

-- ---------------------------------------------------------------------------
-- Component definitions (left-to-right order inside each buffer tab)
-- ---------------------------------------------------------------------------

---@type table<string, table> Mapping of component names to cokeline component specs.
local components = {

  ---Single-space padding.
  space = {
    text = " ",
    truncation = { priority = 1 },
  },

  ---Double-space padding.
  two_spaces = {
    text = "  ",
    truncation = { priority = 1 },
  },

  ---Vertical bar separator between tabs (omitted for the first tab).
  separator = {
    text = function(buffer)
      return buffer.index ~= 1 and "▏" or ""
    end,
    truncation = { priority = 1 },
  },

  ---File icon or pick-letter indicator.
  ---When the user triggers buffer-pick mode (`<Plug>(cokeline-pick-focus)`
  ---or `<Plug>(cokeline-pick-close)`), shows the single-letter shortcut
  ---instead of the filetype icon.
  devicon = {
    text = function(buffer)
      local is_picking = mappings.is_picking_focus() or mappings.is_picking_close()
      return is_picking and buffer.pick_letter .. " " or buffer.devicon.icon
    end,
    fg = function(_)
      if mappings.is_picking_focus() then
        return yellow
      elseif mappings.is_picking_close() then
        return red
      end
      -- Default: use the icon color assigned by nvim-web-devicons / mini.icons.
      return nil
    end,
    style = function(_)
      local is_picking = mappings.is_picking_focus() or mappings.is_picking_close()
      return is_picking and "italic,bold" or nil
    end,
    truncation = { priority = 1 },
  },

  ---Buffer ordinal index + Neovim buffer number + arrow separator.
  ---Example: `3:12 󰁎 `
  index = {
    text = function(buffer)
      return buffer.index .. ":" .. buffer.number .. " 󰁎 "
    end,
    truncation = { priority = 1 },
  },

  ---Tab index displayed on the far right (only when more than one tab exists).
  tabs_index = {
    text = function(buffer)
      if buffer.is_first and buffer.is_last then
        return ""
      end
      return " " .. buffer.index .. " "
    end,
    truncation = { priority = 2 },
    bg = function()
      return normal_bg
    end,
  },

  ---Parent directory prefix that disambiguates files with identical names.
  ---`direction = "left"` means this part is truncated from the left when space
  ---runs out, keeping the filename visible.
  unique_prefix = {
    text = function(buffer)
      return buffer.unique_prefix
    end,
    fg = comments_fg,
    style = "italic",
    truncation = {
      priority = 3,
      direction = "left",
    },
  },

  ---Base filename with dynamic styling based on focus and diagnostic state.
  ---Bold when focused; underlined when there are errors.
  filename = {
    text = function(buffer)
      return buffer.filename
    end,
    style = function(buffer)
      local has_errors = buffer.diagnostics.errors ~= 0
      local focused = buffer.is_focused
      if focused and has_errors then
        return "bold,underline"
      elseif focused then
        return "bold"
      elseif has_errors then
        return "underline"
      end
      return nil
    end,
    truncation = {
      priority = 2,
      direction = "left",
    },
  },

  ---Diagnostic count badge (errors first, then warnings).
  diagnostics = {
    text = function(buffer)
      if buffer.diagnostics.errors ~= 0 then
        return "  " .. buffer.diagnostics.errors
      elseif buffer.diagnostics.warnings ~= 0 then
        return "  " .. buffer.diagnostics.warnings
      end
      return ""
    end,
    fg = function(buffer)
      if buffer.diagnostics.errors ~= 0 then
        return errors_fg
      elseif buffer.diagnostics.warnings ~= 0 then
        return warnings_fg
      end
      return nil
    end,
    truncation = { priority = 1 },
  },

  ---Close button or unsaved indicator.
  ---Clicking deletes the buffer via Snacks.bufdelete.
  close_or_unsaved = {
    text = function(buffer)
      return buffer.is_modified and "●" or "󰅖"
    end,
    fg = function(buffer)
      return buffer.is_modified and green or nil
    end,
    on_click = function(_, _, _, _, buffer)
      Snacks.bufdelete(buffer.number)
    end,
    truncation = { priority = 1 },
  },
}

-- ---------------------------------------------------------------------------
-- Global cokeline configuration returned to setup()
-- ---------------------------------------------------------------------------

return {
  ---Always show the tabline, even with a single buffer.
  show_if_buffers_are_at_least = 1,

  buffers = {
    ---After closing a buffer, focus the next one (not previous).
    focus_on_delete = "next",

    ---Exclude netrw buffers from the tabline.
    filter_valid = function(buffer)
      return buffer.filetype ~= "netrw"
    end,
    filter_visible = function(buffer)
      return buffer.filename ~= "netrw"
    end,

    ---Newly opened buffers are appended to the end.
    new_buffers_position = "last",

    delete_on_right_click = false,
  },

  mappings = {
    ---Enable `<S-h>` / `<S-l>` cycling through buffers.
    cycle_prev_next = true,
    disable_mouse = false,
  },

  ---Keep a short history of recently focused buffers (used by `cokeline-switch-prev/next`).
  history = {
    enabled = true,
    size = 2,
  },

  rendering = {
    max_buffer_width = 999,
  },

  ---Buffer-pick mode: press a letter to jump to or close a buffer.
  pick = {
    use_filename = true,
    letters = "asdfjkl;ghnmxcvbziowerutyqpASDFJKLGHNMXCVBZIOWERTYQP",
  },

  ---Default highlight for every buffer tab.
  default_hl = {
    fg = function(buffer)
      return buffer.is_focused and get_hex("Normal", "fg") or get_hex("Comment", "fg")
    end,
    bg = function()
      return get_hex("ColorColumn", "bg")
    end,
  },

  ---Highlight for the empty area to the right of the last buffer tab.
  fill_hl = "TabLineFill",

  ---Left-to-right component order inside each buffer tab.
  components = {
    components.space,
    components.separator,
    components.space,
    components.unique_prefix,
    components.index,
    components.devicon,
    components.filename,
    components.diagnostics,
    components.two_spaces,
    components.close_or_unsaved,
    components.space,
  },

  rhs = {},

  ---Tab indicators (Neovim :tabs) shown on the far right.
  tabs = {
    placement = "right",
    components = {
      components.tabs_index,
    },
  },

  ---Special sidebar label shown when neo-tree is open on the left.
  sidebar = {
    filetype = { "neo-tree" },
    components = {
      {
        text = "  EXPLORER",
        fg = function()
          return get_hex("NeoTreeDirectoryName", "fg") or get_hex("Directory", "fg") or "#7AA2F7"
        end,
        bg = function()
          return get_hex("NeoTreeNormal", "bg") or normal_bg
        end,
        bold = true,
      },
    },
  },
}
