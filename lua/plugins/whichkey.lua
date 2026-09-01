return {
  "folke/which-key.nvim",
  event = "VeryLazy",

  opts = {
    delay = 500,
    preset = "classic",
    layout = { align = "center" },
    
    win = { border = "rounded" },

    spec = {
      { "<leader>b", group = "Buffers" },
      { "<leader>f", group = "Find" },
      { "<leader>l", group = "LSP", mode = "n" },
      { "<leader>s", group = "Splits" },
      { "<leader>c", desc = "Close Buffer" },
      { "<leader>w", desc = "Save File", mode = "n" },
      { "<leader>w", desc = "Surround Selection", mode = "x" },
      { "<leader>W", desc = "Save All Files" },
      { "<leader>q", desc = "Quit Window" },
      { "<leader>Q", desc = "Quit All" },
      { "<leader>i", desc = "Toggle Inlay Hints" },
    },

    icons = {
      mappings = true,
    },
  },

  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show()
      end,
      desc = "Show Keymaps",
    },
  },
}
