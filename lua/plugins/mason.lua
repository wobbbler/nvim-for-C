return {
  {
    "williamboman/mason.nvim",
    lazy = false,
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
    opts = {
      ui = { border = "rounded" },
    },
    config = function(_, opts)
      require("mason").setup(opts)
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
    },
    -- Configure and enable the C server before the first
    -- buffer is opened.
    lazy = false,
    opts = {
      ensure_installed = {
        "clangd",
      },
      automatic_enable = false,
    },
    config = function(_, opts)
      require("mason-lspconfig").setup(opts)

      local project = require("config.project")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local clangd_args = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
      }

      vim.lsp.config("clangd", {
        capabilities = capabilities,
        filetypes = { "c" },
        cmd = clangd_args,
        root_dir = project.lsp_root,
      })

      vim.lsp.enable("clangd")
    end,
  },
}
