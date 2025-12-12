local metals_config = require("metals").bare_config()
local utils = require("devil.core.utils")

metals_config.on_attach = utils.on_attach
metals_config.capabilities = utils.capabilities

return metals_config
