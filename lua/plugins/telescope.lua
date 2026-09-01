return {
  "nvim-telescope/telescope.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },

  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find Buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Search Help" },
    { "<leader>fo", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
    { "<leader>fr", "<cmd>Telescope resume<cr>", desc = "Resume Search" },
    { "<leader>fc", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Find in Buffer" },
    { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Find Diagnostics" },
  },

  opts = {
    defaults = {
      sorting_strategy = "ascending",
      layout_config = {
        horizontal = {
          prompt_position = "top",
          preview_width = 0.55,
        },
      },
      mappings = {
        i = {
          ["<C-j>"] = "move_selection_next",
          ["<C-k>"] = "move_selection_previous",
        },
      },
    },
  },

  config = function(_, opts)
    local telescope = require("telescope")
    telescope.setup(opts)
    telescope.load_extension("fzf")
  end,
}
