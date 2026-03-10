vim.api.nvim_create_user_command("Format", function(args)
  local range = nil
  if args.count ~= -1 then
    local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
    range = {
      start = { args.line1, 0 },
      ["end"] = { args.line2, end_line:len() },
    }
  end
  require("conform").format({ async = true, lsp_fallback = true, range = range })
end, { range = true })

vim.api.nvim_create_user_command("ConfigHealth", function()
  local ok_count = 0
  local warn_count = 0
  local err_count = 0
  local messages = {}

  local function report(level, msg)
    table.insert(messages, ("[%s] %s"):format(level, msg))
    if level == "OK" then
      ok_count = ok_count + 1
    elseif level == "WARN" then
      warn_count = warn_count + 1
    else
      err_count = err_count + 1
    end
  end

  local config_modules = {
    "devil.plugins.configs.lazy",
    "devil.plugins.configs.lsp",
    "devil.plugins.configs.fmt",
    "devil.plugins.configs.telescope",
  }

  for _, module in ipairs(config_modules) do
    if package.loaded[module] then
      report("OK", ("module loaded: %s"):format(module))
    else
      local module_path = module:gsub("%.", "/")
      local matches = vim.api.nvim_get_runtime_file("lua/" .. module_path .. ".lua", false)
      if #matches == 0 then
        matches = vim.api.nvim_get_runtime_file("lua/" .. module_path .. "/init.lua", false)
      end
      if #matches == 0 then
        report("ERR", ("module not found in runtimepath: %s"):format(module))
      else
        local chunk, load_err = loadfile(matches[1])
        if chunk then
          report("OK", ("module syntax ok: %s"):format(module))
        else
          report("ERR", ("module syntax failed: %s (%s)"):format(module, load_err))
        end
      end
    end
  end

  local has_telescope, telescope = pcall(require, "telescope")
  if has_telescope then
    local ok_ext, err_ext = pcall(telescope.load_extension, "smart_open")
    if ok_ext then
      report("OK", "telescope extension loaded: smart_open")
    else
      report("WARN", ("telescope extension failed: smart_open (%s)"):format(err_ext))
    end
  else
    report("ERR", "telescope module not available")
  end

  local ok_mappings, mappings = pcall(require, "devil.core.mappings")
  if ok_mappings then
    local seen = {}
    for section_name, section in pairs(mappings) do
      for mode, mode_values in pairs(section) do
        if mode ~= "plugin" then
          for lhs, _ in pairs(mode_values) do
            local key = ("%s|%s"):format(mode, lhs)
            seen[key] = seen[key] or {}
            table.insert(seen[key], section_name)
          end
        end
      end
    end

    local conflicts = 0
    for key, sections in pairs(seen) do
      if #sections > 1 then
        conflicts = conflicts + 1
        report("WARN", ("keymap overlap: %s (%s)"):format(key, table.concat(sections, ", ")))
      end
    end
    if conflicts == 0 then
      report("OK", "no keymap overlaps found")
    end
  else
    report("ERR", "failed to load devil.core.mappings")
  end

  vim.notify(
    ("ConfigHealth: %d ok, %d warn, %d err\n%s"):format(ok_count, warn_count, err_count, table.concat(messages, "\n")),
    err_count > 0 and vim.log.levels.ERROR or (warn_count > 0 and vim.log.levels.WARN or vim.log.levels.INFO)
  )
end, {})

vim.api.nvim_create_user_command("TSInjectionDebug", function(opts)
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1
  local col = cursor[2]
  local filetype = vim.bo[bufnr].filetype
  local target_lang = opts.args ~= "" and opts.args or "sql"
  local lines = {}

  local function add(line)
    lines[#lines + 1] = line
  end

  local function add_kv(key, value)
    add(("%-18s %s"):format(key .. ":", value))
  end

  local function list_or_none(items)
    if not items or vim.tbl_isempty(items) then
      return { "  (none)" }
    end
    local out = {}
    for _, item in ipairs(items) do
      out[#out + 1] = "  " .. item
    end
    return out
  end

  local function append_section(title, items)
    add("")
    add(title .. ":")
    for _, item in ipairs(list_or_none(items)) do
      add(item)
    end
  end

  add("Treesitter Injection Debug")
  add(("time: %s"):format(os.date("%Y-%m-%d %H:%M:%S")))
  add("")
  add_kv("buffer", tostring(bufnr))
  add_kv("filetype", filetype)
  add_kv("target_lang", target_lang)
  add_kv("cursor", ("%d:%d"):format(cursor[1], col))

  local parser_ok, parser = pcall(vim.treesitter.get_parser, bufnr, filetype)
  add_kv("host_parser", parser_ok and "ok" or "missing")

  local parser_files = vim.api.nvim_get_runtime_file(("parser/%s.*"):format(filetype), true)
  append_section("host parser files", parser_files)

  local target_parser_files = vim.api.nvim_get_runtime_file(("parser/%s.*"):format(target_lang), true)
  append_section("target parser files", target_parser_files)

  local query_files = {}
  local query_ok, query_err = pcall(function()
    query_files = vim.treesitter.query.get_files(filetype, "injections")
  end)
  add("")
  add_kv("injection_query", query_ok and "ok" or ("error: " .. query_err))
  append_section("injection query files", query_files)

  local captures = {}
  local captures_ok, captures_err = pcall(function()
    captures = vim.treesitter.get_captures_at_pos(bufnr, row, col)
  end)
  add("")
  add_kv("captures", captures_ok and "ok" or ("error: " .. captures_err))
  if captures_ok then
    local capture_lines = {}
    for _, cap in ipairs(captures) do
      local lang = cap.lang or "?"
      local id = cap.capture or "?"
      capture_lines[#capture_lines + 1] = ("%s [%s]"):format(id, lang)
    end
    append_section("captures at cursor", capture_lines)
  end

  local node_ok, node = pcall(vim.treesitter.get_node, { bufnr = bufnr, pos = { row, col }, ignore_injections = false })
  add("")
  if node_ok and node then
    add_kv("node:type", node:type())
    local node_lang = "unknown"
    if type(node.lang) == "function" then
      local ok_lang, lang = pcall(node.lang, node)
      if ok_lang and lang then
        node_lang = lang
      end
    end
    add_kv("node:lang", node_lang)
    local sr, sc, er, ec = node:range()
    add_kv("node:range", ("%d:%d - %d:%d"):format(sr + 1, sc, er + 1, ec))
  else
    add_kv("node", node_ok and "nil" or ("error: " .. node))
  end

  local function collect_langtrees(langtree, indent, acc)
    acc[#acc + 1] = ("%s%s"):format(indent, langtree:lang())
    for _, child in pairs(langtree:children() or {}) do
      collect_langtrees(child, indent .. "  ", acc)
    end
  end

  local langtrees = {}
  if parser_ok and parser then
    collect_langtrees(parser, "", langtrees)
  end
  append_section("language trees", langtrees)

  local out = vim.api.nvim_create_buf(false, true)
  vim.bo[out].bufhidden = "wipe"
  vim.bo[out].buftype = "nofile"
  vim.bo[out].swapfile = false
  vim.bo[out].filetype = "markdown"
  vim.api.nvim_buf_set_lines(out, 0, -1, false, lines)
  vim.api.nvim_set_current_buf(out)
end, {
  nargs = "?",
  desc = "Debug Treesitter language injections for the current buffer",
})
