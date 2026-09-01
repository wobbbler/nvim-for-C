return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },

  opts = {
    formatters_by_ft = {
      c = { "clang-format" },
    },

    default_format_opts = {
      lsp_format = "fallback",
    },

    format_on_save = {
      timeout_ms = 3000,
      lsp_format = "fallback",
    },

    notify_on_error = true,
  },

  config = function(_, opts)
    require("conform").setup(opts)
  end,

}
