return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",

  opts = {
    options = {
      theme = "auto",
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
      globalstatus = true,
    },

    sections = {
      lualine_a = {
        {
          function()
            local mode_map = {
              n = "N", i = "I", v = "V", V = "L", [""] = "B",
              c = "C", R = "R", r = "R", t = "T",
            }
            return mode_map[vim.fn.mode()] or "?"
          end,
          padding = { left = 1, right = 1 },
        },
      },
      lualine_b = {
        {
          "filename",
          path = 1,
          symbols = { modified = " [+]", readonly = " 🔒" },
        },
      },
      lualine_c = {},
      lualine_x = {
        {
          function()
            local recording = vim.fn.reg_recording()
            return recording ~= "" and ("REC @" .. recording) or ""
          end,
          color = { fg = "#ff5555", gui = "bold" },
        },
      },
      lualine_y = {
        {
          "diagnostics",
          symbols = { error = "E:", warn = "W:", info = "I:", hint = "H:" },
          colored = true,
        },
      },
      lualine_z = {},
    },
  },
}
