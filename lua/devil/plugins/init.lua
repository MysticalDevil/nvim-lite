local status_ok, lazy = pcall(require, "lazy")
if not status_ok then
  vim.notify("lazy.nvim not found", vim.log.levels.ERROR)
  return
end

local utils = require("devil.core.utils")

local plugin_sections = {
  require("devil.plugins.specs.core"),
  require("devil.plugins.specs.coding"),
  require("devil.plugins.specs.telescope"),
  require("devil.plugins.specs.ui"),
}

local plugins_list = {}
for _, section in ipairs(plugin_sections) do
  vim.list_extend(plugins_list, section(utils))
end

local lazy_opts = require("devil.plugins.configs.lazy")

lazy.setup(plugins_list, lazy_opts)
