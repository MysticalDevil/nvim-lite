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
