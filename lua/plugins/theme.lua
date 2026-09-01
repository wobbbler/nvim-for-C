return {
  "ficcdaf/ashen.nvim",
  tag = "*",
  lazy = false,
  priority = 1000,
  config = function()
    require("ashen").setup({
      style_presets = {
        bold_functions = true,
        italic_comments = true,
      },
    })
    vim.cmd("colorscheme ashen")
  end,
}
