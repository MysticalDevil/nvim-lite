local utils = require("devil.core.utils")

local lazy_path = ("%s/lazy/lazy.nvim"):format(vim.fn.stdpath("data"))
utils.bootstrap(lazy_path, "folke/lazy.nvim", "stable")

require("devil.core")

require("devil.plugins")

require("devil.core.keymaps")

require("devil.core.commands")
require("devil.core.colorscheme")
