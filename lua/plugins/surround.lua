return {
  "kylechui/nvim-surround",
  version = "*",
  event = "VeryLazy",
  config = function()
    require("nvim-surround").setup({})

    vim.keymap.set("x", "<leader>w", function()
      vim.api.nvim_echo({
        { "Surround with: ", "Title" },
        { "( ), ", "Special" },
        { "[ ], ", "Special" },
        { "{ }, ", "Special" },
        { '" ", ', "Special" },
        { "' ', ", "Special" },
        { "` `, ", "Special" },
        { "f - f()", "Directory" },
      }, false, {})
      local feed = vim.api.nvim_replace_termcodes("<Plug>(nvim-surround-visual)", true, true, true)
      vim.api.nvim_feedkeys(feed, "m", false)
    end, { desc = "Surround visual selection" })
  end,
}
