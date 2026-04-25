-- Load .env file
local function load_dotenv(path)
  local file = io.open(path, "r")
  if not file then
    return
  end
  for line in file:lines() do
    local key, value = line:match("^([A-Za-z0-9_]+)=(.*)$")
    if key and value then
      value = value:gsub("^%s*", ""):gsub("%s*$", "")
      value = value:gsub("^\"(.-)\"$", "%1")
      value = value:gsub("^'(.-)'$", "%1")
      vim.env[key] = value
    end
  end
  file:close()
end

local config_dir = vim.fn.stdpath("config")
load_dotenv(config_dir .. "/.env")

-- Basic options
require("devil.core.options")
require("devil.core.autocmds")
-- UI config
require("devil.core.diag")
