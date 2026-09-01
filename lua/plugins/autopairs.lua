return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  opts = {
    check_ts = true,
    disable_filetype = { "TelescopePrompt", "spectre_panel", "snacks_picker_input" },
  },
  config = function(_, opts)
    local autopairs = require("nvim-autopairs")
    autopairs.setup(opts)
  end,
}
