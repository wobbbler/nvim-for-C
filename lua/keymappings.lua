-- switch buffers
vim.keymap.set("n", "<Tab>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "<S-Tab>", "<cmd>bprevious<cr>", { desc = "Previous Buffer" })

-- fast file and session management
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save File" })
vim.keymap.set("n", "<leader>W", "<cmd>wa<cr>", { desc = "Save All Files" })
vim.keymap.set("n", "<leader>q", "<cmd>confirm q<cr>", { desc = "Quit Window" })
vim.keymap.set("n", "<leader>Q", "<cmd>confirm qa<cr>", { desc = "Quit All" })

-- move between splits
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Focus Left Split" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Focus Lower Split" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Focus Upper Split" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Focus Right Split" })

-- resize splits with arrows
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- split window management
vim.keymap.set("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Split Vertically" })
vim.keymap.set("n", "<leader>sh", "<cmd>split<cr>", { desc = "Split Horizontally" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make Splits Equal" })
vim.keymap.set("n", "<leader>so", "<cmd>only<cr>", { desc = "Close Other Splits (Only)" })

-- move lines
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { silent = true, desc = "Move Lines Down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { silent = true, desc = "Move Lines Up" })

-- indent
vim.keymap.set("v", "<", "<gv", { desc = "Indent Left" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent Right" })

-- preserve register on visual paste (paste without losing copied text)
vim.keymap.set("x", "p", [["_dP]], { desc = "Paste Without Overwriting Register" })

-- center screen on scroll and search
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll Down and Center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll Up and Center" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next Search Result" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous Search Result" })

-- select all
vim.keymap.set("n", "<C-a>", "ggVG", { desc = "Select All" })

-- editor: file explorer
vim.keymap.set("n", "<leader>e", function()
  require("oil").toggle_float()
end, { desc = "Toggle File Explorer" })
