return {
  adapters = {
    require("neotest-python")({
      dap = { justMyCode = false },
    }),
    require("neotest-plenary"),
    require("neotest-vim-test")({
      ignore_file_types = { "python", "vim", "lua" },
    }),
    require("neotest-go"),
    require("neotest-rust"),
    require("neotest-zig"),
    require("neotest-jest"),
  },
}
