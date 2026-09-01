return {
  "numToStr/Comment.nvim",
  event = { "BufReadPost", "BufNewFile" },
  opts = {},
  keys = {
    {
      "<leader>/",
      function()
        require("Comment.api").toggle.linewise.current()
      end,
      desc = "Toggle Comment",
      mode = "n",
    },
    {
      "<leader>/",
      "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
      desc = "Toggle Comment",
      mode = "v",
    },
  },
  config = function(_, opts)
    require("Comment").setup(opts)
  end,
}
