local get_hex = require("cokeline.hlgroups").get_hl_attr
local mappings = require("cokeline.mappings")

-- Use highlight groups for colors to ensure theme consistency
-- Fallback to hardcoded colors only if highlight retrieval fails
local red = get_hex("DiagnosticError", "fg") or "#E06C75"
local yellow = get_hex("DiagnosticWarn", "fg") or "#E5C07B"
local green = get_hex("String", "fg") or "#98C379"

local comments_fg = get_hex("Comment", "fg") or "#5C6370"
local errors_fg = get_hex("DiagnosticError", "fg") or "#E06C75"
local warnings_fg = get_hex("DiagnosticWarn", "fg") or "#E5C07B"
local normal_bg = get_hex("Normal", "bg") or "#1E222A"

local components = {
  space = {
    text = " ",
    truncation = { priority = 1 },
  },

  two_spaces = {
    text = "  ",
    truncation = { priority = 1 },
  },

  separator = {
    text = function(buffer)
      return buffer.index ~= 1 and "▏" or ""
    end,
    truncation = { priority = 1 },
  },

  devicon = {
    text = function(buffer)
      return (mappings.is_picking_focus() or mappings.is_picking_close()) and buffer.pick_letter .. " "
        or buffer.devicon.icon
    end,
    fg = function(buffer)
      if mappings.is_picking_focus() then
        return yellow
      elseif mappings.is_picking_close() then
        return red
      end
      return buffer.devicon.color
    end,
    style = function(_)
      return (mappings.is_picking_focus() or mappings.is_picking_close()) and "italic,bold" or nil
    end,
    truncation = { priority = 1 },
  },

  index = {
    text = function(buffer)
      return buffer.index .. ":" .. buffer.number .. " 󰁎 "
    end,
    truncation = { priority = 1 },
  },

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

  filename = {
    text = function(buffer)
      return buffer.filename
    end,
    style = function(buffer)
      return ((buffer.is_focused and buffer.diagnostics.errors ~= 0) and "bold,underline")
        or (buffer.is_focused and "bold")
        or (buffer.diagnostics.errors ~= 0 and "underline")
        or nil
    end,
    truncation = {
      priority = 2,
      direction = "left",
    },
  },

  diagnostics = {
    text = function(buffer)
      return (buffer.diagnostics.errors ~= 0 and "  " .. buffer.diagnostics.errors) -- Icon synced with LSP
        or (buffer.diagnostics.warnings ~= 0 and "  " .. buffer.diagnostics.warnings)
        or ""
    end,
    fg = function(buffer)
      return (buffer.diagnostics.errors ~= 0 and errors_fg) or (buffer.diagnostics.warnings ~= 0 and warnings_fg) or nil
    end,
    truncation = { priority = 1 },
  },

  close_or_unsaved = {
    text = function(buffer)
      return buffer.is_modified and "●" or "󰅖"
    end,
    fg = function(buffer)
      return buffer.is_modified and green or nil
    end,
    delete_buffer_on_left_click = true,
    truncation = { priority = 1 },
  },
}

return {
  show_if_buffers_are_at_least = 1,

  buffers = {
    focus_on_delete = "next",
    filter_valid = function(buffer)
      return buffer.filetype ~= "netrw"
    end,
    filter_visible = function(buffer)
      return buffer.filename ~= "netrw"
    end,
    new_buffers_position = "last",
    delete_on_right_click = true,
  },

  mappings = {
    cycle_prev_next = true,
    disable_mouse = false,
  },

  history = {
    enabled = true,
    size = 2,
  },

  rendering = {
    max_buffer_width = 999,
  },

  pick = {
    use_filename = true,
    letters = "asdfjkl;ghnmxcvbziowerutyqpASDFJKLGHNMXCVBZIOWERTYQP",
  },

  default_hl = {
    fg = function(buffer)
      return buffer.is_focused and get_hex("Normal", "fg") or get_hex("Comment", "fg")
    end,
    bg = function()
      return get_hex("ColorColumn", "bg")
    end,
  },

  fill_hl = "TabLineFill",

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

  tabs = {
    placement = "right",
    components = {
      components.tabs_index,
    },
  },

  sidebar = {
    filetype = { "neo-tree" },
    components = {
      {
        text = "  EXPLORER",
        fg = function()
          return get_hex("NeoTreeDirectoryName", "fg") or get_hex("Directory", "fg", "#7AA2F7")
        end,
        bg = function()
          return get_hex("NeoTreeNormal", "bg") or normal_bg
        end,
        bold = true,
      },
    },
  },
}
