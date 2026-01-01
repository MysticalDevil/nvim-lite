local utils = require("devil.core.utils")

local lazy_path = ("%s/lazy/lazy.nvim"):format(vim.fn.stdpath("data"))
utils.bootstrap(lazy_path, "folke/lazy.nvim", "stable")

require("devil.core")

require("devil.plugins")

utils.load_mappings()

require("devil.core.commands")
require("devil.core.colorscheme")
