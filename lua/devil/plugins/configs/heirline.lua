---@diagnostic disable: missing-fields
---Heirline statusline & winbar configuration.
---
--- heirline.nvim uses a declarative Lua-table DSL to build UI components.
--- Each component is a plain table that may contain the following keys:
---   • provider   – string or function(self) returning the text to display.
---   • hl         – highlight group (table with fg/bg/bold/etc.) or function.
---   • condition  – function(self) → boolean; hides the component when false.
---   • init       – function(self) run once before rendering the component.
---   • update     – autocommand spec that triggers a re-render.
---   • static     – table of read-only data shared across renders.
---   • flexible   – integer priority for truncation when space is tight.
---   • children   – nested tables rendered left-to-right (or top-to-bottom).
---
--- For full API see `:h heirline`.

local conditions = require("heirline.conditions")
local utils = require("heirline.utils")
local G_utils = require("devil.core.utils")

-- ---------------------------------------------------------------------------
-- Low-level layout primitives
-- ---------------------------------------------------------------------------

---`%=` is the vim statusline item that pushes everything after it to the right.
local Align = { provider = "%=" }

---A narrow spacer used between components.
local Space = { provider = "%2(%)" }

---A vertical-bar separator with surrounding spaces.
local Separators = { provider = " | " }

-- ---------------------------------------------------------------------------
-- Color palette (extracted from current colorscheme)
-- ---------------------------------------------------------------------------

---Dynamically build a color table from the active colorscheme.
---@return table<string, string|number> mapping of semantic names to highlight values.
local function setup_colors()
  return {
    bright_bg = utils.get_highlight("Folded").bg,
    bright_fg = utils.get_highlight("Folded").fg,
    red = utils.get_highlight("DiagnosticError").fg,
    dark_red = utils.get_highlight("DiffDelete").bg,
    green = utils.get_highlight("String").fg,
    blue = utils.get_highlight("Function").fg,
    gray = utils.get_highlight("NonText").fg,
    orange = utils.get_highlight("Number").fg,
    purple = utils.get_highlight("Include").fg,
    cyan = utils.get_highlight("Constant").fg,
    diag_warn = utils.get_highlight("DiagnosticWarn").fg,
    diag_error = utils.get_highlight("DiagnosticError").fg,
    diag_hint = utils.get_highlight("DiagnosticHint").fg,
    diag_info = utils.get_highlight("DiagnosticInfo").fg,
    diff_del = utils.get_highlight("DiffRemoved").fg,
    diff_add = utils.get_highlight("DiffAdded").fg,
    diff_change = utils.get_highlight("DiffFile").fg,
  }
end

local colors = setup_colors()

-- ---------------------------------------------------------------------------
-- ViMode – shows current editor mode (N/I/V/…)
-- ---------------------------------------------------------------------------

---Component that displays the current Vim mode (Normal, Insert, Visual, …).
---Uses `init` to capture the mode once per render and `update` to redraw on
---`ModeChanged`.
local ViMode = {
  ---Cache the current mode string (e.g. "n", "i", "v").
  ---@param self table component instance
  init = function(self)
    self.mode = vim.fn.mode(1)
  end,

  ---Static lookup tables shared across all renders.
  static = {
    ---Human-readable labels for each mode.
    mode_names = {
      n = "N",
      no = "N?",
      nov = "N?",
      noV = "N?",
      ["no\22"] = "N?",
      niI = "Ni",
      niR = "Nr",
      niV = "Nv",
      nt = "Nt",
      v = "V",
      vs = "Vs",
      V = "V_",
      Vs = "Vs",
      ["\22"] = "^V",
      ["\22s"] = "^V",
      s = "S",
      S = "S_",
      ["\19"] = "^S",
      i = "I",
      ic = "Ic",
      ix = "Ix",
      R = "R",
      Rc = "Rc",
      Rx = "Rx",
      Rv = "Rv",
      Rvc = "Rv",
      Rvx = "Rv",
      c = "C",
      cv = "Ex",
      r = "...",
      rm = "M",
      ["r?"] = "?",
      ["!"] = "!",
      t = "T",
    },
    ---Map the first character of a mode to a semantic color key.
    mode_colors = {
      n = "red",
      i = "green",
      v = "cyan",
      V = "cyan",
      ["\22"] = "cyan",
      c = "orange",
      s = "purple",
      S = "purple",
      ["\19"] = "purple",
      R = "orange",
      r = "orange",
      ["!"] = "red",
      t = "red",
    },
  },

  provider = function(self)
    return " %2(" .. self.mode_names[self.mode] .. "%)"
  end,

  hl = function(self)
    local mode = self.mode:sub(1, 1)
    return { fg = self.mode_colors[mode], bold = true }
  end,

  ---Redraw the statusline immediately after any mode transition.
  update = {
    "ModeChanged",
    pattern = "*:*",
    callback = vim.schedule_wrap(function()
      vim.cmd("redrawstatus")
    end),
  },
}

-- ---------------------------------------------------------------------------
-- FileNameBlock – filename with icon, modification flag, and truncation
-- ---------------------------------------------------------------------------

---Top-level container that stores the current buffer filename in `self.filename`.
local FileNameBlock = {
  init = function(self)
    self.filename = vim.api.nvim_buf_get_name(0)
  end,
}

---File icon fetched from nvim-web-devicons (mocked by mini.icons).
local FileIcon = {
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ":e")
    self.icon, self.icon_color = require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
  end,
  provider = function(self)
    return self.icon and (self.icon .. " ")
  end,
  hl = function(self)
    return { fg = self.icon_color }
  end,
}

---Relative file path (or "[No Name]" for unnamed buffers).
---`flexible = 2` tells heirline this component may be truncated first when
---space is scarce; the second child (`pathshorten`) is the fallback.
local FileName = {
  init = function(self)
    self.lfilename = vim.fn.fnamemodify(self.filename, ":.")
    if self.lfilename == "" then
      self.lfilename = "[No Name]"
    end
  end,
  hl = { fg = utils.get_highlight("Directory").fg },
  flexible = 2,
  {
    provider = function(self)
      return self.lfilename
    end,
  },
  {
    provider = function(self)
      return vim.fn.pathshorten(self.lfilename)
    end,
  },
}

---Indicators for buffer state: modified `[+]` and readonly ``.
local FileFlags = {
  {
    condition = function()
      return vim.bo.modified
    end,
    provider = "[+]",
    hl = { fg = "green" },
  },
  {
    condition = function()
      return not vim.bo.modifiable or vim.bo.readonly
    end,
    provider = "",
    hl = { fg = "orange" },
  },
}

---Highlight wrapper that turns the filename cyan + bold when the buffer is modified.
local FileNameModifer = {
  hl = function()
    if vim.bo.modified then
      return { fg = "cyan", bold = true, force = true }
    end
  end,
}

---Assemble the full filename block: icon → (highlighted) name → flags → truncate-mark.
FileNameBlock =
  utils.insert(FileNameBlock, FileIcon, utils.insert(FileNameModifer, FileName), FileFlags, { provider = "%<" })

-- ---------------------------------------------------------------------------
-- FileInfoBlock – file type, encoding, format, size
-- ---------------------------------------------------------------------------

---Container that mirrors `FileNameBlock` structure for file metadata.
local FileInfoBlock = {
  init = function(self)
    self.filename = vim.api.nvim_buf_get_name(0)
  end,
}

---Upper-case filetype string (e.g. "LUA").
local FileType = {
  provider = function()
    return string.upper(vim.bo.filetype)
  end,
  hl = { fg = utils.get_highlight("Type").fg, bold = true },
}

---Show encoding only when it deviates from utf-8.
local FileEncoding = {
  provider = function()
    local enc = (vim.bo.fenc ~= "" and vim.bo.fenc) or vim.o.enc
    return enc ~= "utf-8" and enc:upper()
  end,
}

---Show file format only when it deviates from unix.
local FileFormat = {
  provider = function()
    local fmt = vim.bo.fileformat
    return fmt ~= "unix" and fmt:upper()
  end,
}

---Human-readable file size (b/k/M/G/…).
local FileSize = {
  provider = function()
    local suffix = { "b", "k", "M", "G", "T", "P", "E" }
    local fsize = vim.fn.getfsize(vim.api.nvim_buf_get_name(0))
    fsize = (fsize < 0 and 0) or fsize
    if fsize < 1024 then
      return fsize .. suffix[1]
    end
    local i = math.floor((math.log(fsize or 0) / math.log(1024)))
    return string.format("%.2g%s", fsize / math.pow(1024, i), suffix[i + 1])
  end,
}

---Dynamically build the metadata block; optional fields are inserted only when relevant.
---@return table heirline component tree
local function get_file_info()
  local info = { FileIcon, FileType, Space, FileSize }
  if vim.bo.fileencoding ~= "utf-8" then
    table.insert(info, Space)
    table.insert(info, FileEncoding)
  end
  if vim.bo.fileformat ~= "unix" then
    table.insert(info, Space)
    table.insert(info, FileFormat)
  end
  table.insert(info, { provider = "%<" })
  return utils.insert(FileInfoBlock, unpack(info))
end

FileInfoBlock = get_file_info()

-- ---------------------------------------------------------------------------
-- Ruler & ScrollBar
-- ---------------------------------------------------------------------------

---Cursor position indicator: `  42/120:5 45%`.
local Ruler = {
  provider = "%7(%l/%3L%):%2c %P",
}

---Tiny scrollbar built from Unicode block characters.
local ScrollBar = {
  static = {
    sbar = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" },
  },
  provider = function(self)
    local curr_line = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_line_count(0)
    -- Guard against empty buffers (division by zero).
    local i = lines > 0 and (math.floor((curr_line - 1) / lines * #self.sbar) + 1) or 1
    return string.rep(self.sbar[i], 2)
  end,
  hl = { fg = "blue", bg = "bright_bg" },
}

-- ---------------------------------------------------------------------------
-- LSP & Diagnostics
-- ---------------------------------------------------------------------------

---Show active LSP client names (e.g. " [gopls lua_ls]").
local LSPActive = {
  condition = conditions.lsp_attached,
  update = { "LspAttach", "LspDetach" },
  provider = function()
    return G_utils.get_lsp_info()
  end,
  hl = { fg = "green", bold = true },
}

---Diagnostic counts with color-coded icons.
---Only renders when diagnostics exist (`condition`).
local Diagnostics = {
  condition = conditions.has_diagnostics,

  static = {
    error_icon = (vim.fn.sign_getdefined("DiagnosticSignError")[1] or { text = "E" }).text,
    warn_icon = (vim.fn.sign_getdefined("DiagnosticSignWarn")[1] or { text = "W" }).text,
    info_icon = (vim.fn.sign_getdefined("DiagnosticSignInfo")[1] or { text = "I" }).text,
    hint_icon = (vim.fn.sign_getdefined("DiagnosticSignHint")[1] or { text = "H" }).text,
  },

  ---Count diagnostics by severity on every render.
  init = function(self)
    self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
    self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
  end,

  update = { "DiagnosticChanged", "BufEnter" },

  {
    provider = function(self)
      return self.errors > 0 and (self.error_icon .. self.errors .. " ")
    end,
    hl = { fg = "diag_error" },
  },
  {
    provider = function(self)
      return self.warnings > 0 and (self.warn_icon .. self.warnings .. " ")
    end,
    hl = { fg = "diag_warn" },
  },
  {
    provider = function(self)
      return self.info > 0 and (self.info_icon .. self.info .. " ")
    end,
    hl = { fg = "diag_info" },
  },
  {
    provider = function(self)
      return self.hints > 0 and (self.hint_icon .. self.hints)
    end,
    hl = { fg = "diag_hint" },
  },
}

-- ---------------------------------------------------------------------------
-- Git status (gitsigns integration)
-- ---------------------------------------------------------------------------

---Show branch name and change counts (added/removed/changed) from gitsigns.
local Git = {
  condition = conditions.is_git_repo,

  init = function(self)
    self.status_dict = vim.b.gitsigns_status_dict
    self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
  end,

  hl = { fg = "orange" },

  {
    provider = function(self)
      return " " .. self.status_dict.head
    end,
    hl = { bold = true },
  },
  {
    condition = function(self)
      return self.has_changes
    end,
    provider = "(",
  },
  {
    provider = function(self)
      local count = self.status_dict.added or 0
      return count > 0 and (" " .. count)
    end,
    hl = { fg = "diff_add" },
  },
  {
    provider = function(self)
      local count = self.status_dict.removed or 0
      return count > 0 and (" " .. count)
    end,
    hl = { fg = "diff_del" },
  },
  {
    provider = function(self)
      local count = self.status_dict.changed or 0
      return count > 0 and (" " .. count)
    end,
    hl = { fg = "diff_change" },
  },
  {
    condition = function(self)
      return self.has_changes
    end,
    provider = ")",
  },
}

-- ---------------------------------------------------------------------------
-- Special-purpose statusline segments
-- ---------------------------------------------------------------------------

---Terminal buffer name (strips the `term://` prefix).
local TerminalName = {
  provider = function()
    local tname, _ = vim.api.nvim_buf_get_name(0):gsub(".*:", "")
    return " " .. tname
  end,
  hl = { fg = "blue", bold = true },
}

---Show the help file title for `:help` buffers.
local HelpFileName = {
  condition = function()
    return vim.bo.filetype == "help"
  end,
  provider = function()
    local filename = vim.api.nvim_buf_get_name(0)
    return vim.fn.fnamemodify(filename, ":t")
  end,
  hl = { fg = colors.blue },
}

-- ---------------------------------------------------------------------------
-- Statusline assembly
-- ---------------------------------------------------------------------------

---Wrap ViMode in rounded separators ( N ).
ViMode = utils.surround({ "", "" }, "bright_bg", { ViMode })

---Default statusline shown for normal active buffers.
local DefaultStatusline = {
  ViMode,
  Space,
  FileNameBlock,
  Space,
  Git,
  Space,
  Diagnostics,
  Space,
  Align,
  Align,
  LSPActive,
  Separators,
  FileInfoBlock,
  Separators,
  Ruler,
  Space,
  ScrollBar,
}

---Minimal statusline for inactive windows.
local InactiveStatusline = {
  condition = conditions.is_not_active,
  FileType,
  Space,
  FileName,
  Align,
}

---Statusline for special buffers (help, quickfix, git, …).
local SpecialStatusline = {
  condition = function()
    return conditions.buffer_matches({
      buftype = { "nofile", "prompt", "help", "quickfix" },
      filetype = { "^git.*", "fugitive" },
    })
  end,
  FileType,
  Space,
  HelpFileName,
  Align,
}

---Statusline for terminal buffers.
local TerminalStatusline = {
  condition = function()
    return conditions.buffer_matches({ buftype = { "terminal" } })
  end,
  hl = { bg = "dark_red" },
  { condition = conditions.is_active, ViMode, Space },
  FileType,
  Space,
  TerminalName,
  Align,
}

---Root statusline component.
---`fallthrough = false` means heirline stops at the first component whose
---`condition` returns true. The order is therefore significant:
---special → terminal → inactive → default.
local StatusLines = {
  hl = function()
    if conditions.is_active() then
      return "StatusLine"
    else
      return "StatusLineNC"
    end
  end,
  fallthrough = false,
  SpecialStatusline,
  TerminalStatusline,
  InactiveStatusline,
  DefaultStatusline,
}

-- ---------------------------------------------------------------------------
-- ColorScheme autocommand – re-extract colors on theme switch
-- ---------------------------------------------------------------------------

vim.api.nvim_create_augroup("Heirline", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    utils.on_colorscheme(setup_colors)
  end,
  group = "Heirline",
})

-- ---------------------------------------------------------------------------
-- Public configuration returned to heirline.setup()
-- ---------------------------------------------------------------------------

return {
  statusline = StatusLines,
  opts = {
    colors = colors,
  },
}
