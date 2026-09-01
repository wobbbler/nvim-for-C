return {
  "stevearc/oil.nvim",
  lazy = false,

  opts = {
    default_file_explorer = true,
    columns = {},
    delete_to_trash = true,
    skip_confirm_for_simple_edits = false,
    prompt_save_on_select_new_entry = true,
    watch_for_changes = true,
    constrain_cursor = "editable",

    view_options = {
      show_hidden = false,
      natural_order = "fast",
      sort = {
        { "type", "asc" },
        { "name", "asc" },
      },
    },

    keymaps = {
      -- Navigation
      ["h"] = "actions.parent",
      ["l"] = "actions.select",
      ["<CR>"] = false,
      ["-"] = false,

      -- Return to project root ('H')
      ["H"] = "actions.open_cwd",

      -- Quick file preview ('p')
      ["p"] = "actions.preview",

      -- Copy full file path ('y')
      ["y"] = {
        callback = function()
          local oil = require("oil")
          local entry = oil.get_cursor_entry()
          local dir = oil.get_current_dir()
          if entry and dir then
            local name = entry.name
            if entry.type == "directory" then
              name = name .. "/"
            end
            local path = dir .. name
            vim.fn.setreg("+", path)
            vim.fn.setreg('"', path)
            vim.notify("Copied path: " .. path)
          end
        end,
        desc = "Copy full path",
      },

      -- Close
      ["q"] = "actions.close",
      ["<Esc>"] = "actions.close",

      -- Toggle hidden files
      ["."] = "actions.toggle_hidden",

      -- Refresh
      ["R"] = "actions.refresh",

      -- Create file or directory ('c')
      ["c"] = { "o", desc = "Create file/dir" },

      -- Rename file ('r' -> change file name)
      ["r"] = { "ciw", desc = "Rename file" },

      -- Disable unused default mappings
      ["i"] = false,
      ["g?"] = false,
      ["?"] = false,
      ["v"] = false,
      ["s"] = false,
      ["d"] = false,        
      ["t"] = false,
      ["K"] = false,
      ["P"] = false,
      ["_"] = false,
      ["`"] = false,
      ["gs"] = false,
      ["gx"] = false,
      ["<C-s>"] = false,
      ["<C-h>"] = false,
      ["<C-t>"] = false,
      ["<C-p>"] = false,
      ["<C-l>"] = false,
    },
  },
}
