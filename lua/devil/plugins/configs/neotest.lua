return {
  adapters = {
    require("neotest-python")({
      dap = { justMyCode = false },
    }),
    require("neotest-plenary"),
    require("neotest-go"),
    require("rustaceanvim.neotest"),
    require("neotest-zig"),
    require("neotest-jest"),
  },
}
