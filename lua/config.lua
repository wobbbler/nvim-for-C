-- leader key (space) - must be declared before loading plugins
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- This setup is C-only: always treat .h files as C headers so clangd attaches.-- This setup is C-only: always treat .h files as C headers so clangd attaches.-- This setup is C-only: always treat .h files as C headers so clangd attaches.-- This setup is C-only: always treat .h files as C headers so clangd attaches.
vim.filetype.add({ extension = { h = "c" } })

-- appearance and interface
vim.opt.number = true         -- line numbers
vim.opt.relativenumber = true -- relative line numbers
vim.opt.mouse = ""  -- "a" if need
vim.opt.showmode = false  -- hide mode
vim.opt.laststatus = 3   -- show status line
vim.opt.cmdheight = 0     -- hide command line until it is needed
vim.opt.ruler = false     -- hide cursor position and file progress
vim.opt.showcmd = false   -- hide pending command text
vim.opt.termguicolors = true  -- 24-bit color
vim.opt.signcolumn = "yes"    -- sign column
vim.opt.cursorline = true     -- highlight current line
vim.opt.scrolloff = 8         -- scroll offset
vim.opt.sidescrolloff = 16
vim.opt.confirm = true         -- confirm instead of losing unsaved work
vim.opt.autoread = true        -- notice changes made by build tools or Git
vim.opt.wrap = false           -- never hide long C lines by wrapping them
vim.opt.breakindent = true
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.timeoutlen = 400

-- system clipboard
vim.opt.clipboard = "unnamedplus" -- use system clipboard

-- tabs and indentation
vim.opt.tabstop = 2        -- tab width
vim.opt.softtabstop = 2    -- soft tab width
vim.opt.shiftwidth = 2     -- indent size
vim.opt.expandtab = true   -- tabs to spaces
vim.opt.autoindent = true  -- auto indent
vim.opt.smartindent = true -- smart indent
vim.opt.backspace = "indent,eol,start"

-- search
vim.opt.ignorecase = true -- ignore case
vim.opt.smartcase = true  -- smart case
vim.opt.hlsearch = false  -- hide search highlight
vim.opt.inccommand = "split" -- preview substitutions and LSP renames in a split

-- window and file behavior
vim.opt.splitright = true -- split right
vim.opt.splitbelow = true -- split below
vim.opt.swapfile = false  -- no swap file
vim.opt.backup = false    -- no backup file
vim.opt.undofile = true   -- undo history
vim.opt.updatetime = 250  -- fast update

-- Reload a file changed outside Neovim when focus returns to the editor.
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})

-- Keep project-aware commands (Oil, Telescope, grep) rooted at the project.
-- Cache the root to avoid repeated searches
local project = require("config.project")
local project_root_cache = {}
local project_root_group = vim.api.nvim_create_augroup("ProjectRoot", { clear = true })
vim.api.nvim_create_autocmd("BufEnter", {
  group = project_root_group,
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" then
      return
    end

    local file = vim.api.nvim_buf_get_name(args.buf)
    local cached_root = project_root_cache[file]
    
    if cached_root and vim.fn.getcwd() == cached_root then
      return
    end

    local root = project.find_root(file)

    if root then
      project_root_cache[file] = root
      vim.cmd.cd(vim.fn.fnameescape(root))
    end
  end,
})

-- Keep manual indentation aligned with each C project's clang-format.
-- Without a project style, use the personal default of two spaces.
local clang_format_cache = {}
local c_family_indent_group = vim.api.nvim_create_augroup("CFamilyIndent", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = c_family_indent_group,
  pattern = "c",
  callback = function(args)
    local buffer = args.buf
    local fallback = 2
    vim.bo[buffer].shiftwidth = fallback
    vim.bo[buffer].softtabstop = fallback
    vim.bo[buffer].expandtab = true

    local file = vim.api.nvim_buf_get_name(buffer)
    if file == "" then
      return
    end

    local style_file = vim.fs.find({ ".clang-format", "_clang-format" }, {
      path = vim.fs.dirname(file),
      upward = true,
      type = "file",
    })[1]
    local clang_format = vim.fn.exepath("clang-format")
    if not style_file or clang_format == "" then
      return
    end

    local style = clang_format_cache[style_file]
    if not style then
      local result = vim.system({
        clang_format,
        "--style=file",
        "--assume-filename=" .. file,
        "--dump-config",
      }, { text = true }):wait()
      if result.code ~= 0 then
        return
      end

      style = {
        indent_width = tonumber(result.stdout:match("\nIndentWidth:%s*(%d+)")),
        tab_width = tonumber(result.stdout:match("\nTabWidth:%s*(%d+)")),
        use_tab = result.stdout:match("\nUseTab:%s*(%S+)"),
      }
      clang_format_cache[style_file] = style
    end

    local indent_width = style.indent_width
    if not indent_width or indent_width == 0 then
      indent_width = style.tab_width
    end
    if indent_width and indent_width > 0 then
      vim.bo[buffer].shiftwidth = indent_width
      vim.bo[buffer].softtabstop = indent_width
    end
    if style.tab_width and style.tab_width > 0 then
      vim.bo[buffer].tabstop = style.tab_width
    end
    vim.bo[buffer].expandtab = style.use_tab == nil or style.use_tab == "Never"
  end,
})


-- reset search highlighting on esc
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Replace the default stuck "No Name" buffer on startup with a hidden scratch buffer
local startup_group = vim.api.nvim_create_augroup("StartupBuffer", { clear = true })
vim.api.nvim_create_autocmd("VimEnter", {
  group = startup_group,
  callback = function()
    -- if files were provided on the command line, do nothing
    if vim.fn.argc() > 0 then
      return
    end

    local cur = vim.api.nvim_get_current_buf()
    if vim.api.nvim_buf_get_name(cur) ~= "" then
      return
    end

    -- create an unlisted scratch buffer and switch to it
    local scratch = vim.api.nvim_create_buf(false, true)
    pcall(vim.api.nvim_buf_set_option, scratch, "buftype", "nofile")
    pcall(vim.api.nvim_buf_set_option, scratch, "bufhidden", "wipe")
    pcall(vim.api.nvim_buf_set_option, scratch, "buflisted", false)
    vim.api.nvim_set_current_buf(scratch)

    -- delete the original empty buffer if it's still unnamed and unmodified
    if vim.api.nvim_buf_is_valid(cur) and vim.api.nvim_buf_get_name(cur) == "" and vim.fn.getbufvar(cur, "&modified") == 0 then
      pcall(vim.api.nvim_buf_delete, cur, { force = true })
    end
  end,
})
