return {
  "neovim/nvim-lspconfig",
  -- LSP configuration must exist before filetype detection.  Loading it on
  -- BufReadPre can miss the first buffer's FileType event on Neovim 0.12.
  lazy = false,
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    -- diagnostic appearance
    vim.diagnostic.config({
      float = { border = "rounded" },
      virtual_text = { prefix = "●" },
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    })

    -- global window border
    vim.o.winborder = "rounded"

    -- lsp keymaps on attach
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local function map(mode, lhs, rhs, desc, opts)
          local options = vim.tbl_extend("force", { buffer = bufnr, silent = true, desc = desc }, opts or {})
          vim.keymap.set(mode, lhs, rhs, options)
        end

        local function diagnostic_jump(count)
          if vim.diagnostic.jump then
            vim.diagnostic.jump({ count = count, float = true })
          elseif count > 0 then
            vim.diagnostic.goto_next({ float = true })
          else
            vim.diagnostic.goto_prev({ float = true })
          end
        end

        -- navigation
        map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
        map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
        map("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
        map("n", "gr", vim.lsp.buf.references, "Find References")
        map("n", "gy", vim.lsp.buf.type_definition, "Go to Type Definition")

        -- clangd implements the LSP call hierarchy, so no separate plugin is
        -- needed to discover callers and callees.
        if client and client:supports_method("textDocument/prepareCallHierarchy") then
          map("n", "<leader>lI", vim.lsp.buf.incoming_calls, "Show Callers")
          map("n", "<leader>lO", vim.lsp.buf.outgoing_calls, "Show Callees")
        end

        -- actions and symbols
        map("n", "<leader>la", vim.lsp.buf.code_action, "Code Action")
        map("n", "<leader>lr", function()
          local ok = pcall(require, "inc_rename")
          if ok and vim.fn.exists(":IncRename") == 2 then
            return ":IncRename " .. vim.fn.expand("<cword>")
          else
            vim.schedule(vim.lsp.buf.rename)
            return "<Nop>"
          end
        end, "Rename Symbol (Preview)", { expr = true, silent = false })

        -- diagnostics
        map("n", "]d", function()
          diagnostic_jump(1)
        end, "Next Diagnostic")
        map("n", "[d", function()
          diagnostic_jump(-1)
        end, "Previous Diagnostic")

        -- `K` shows the most immediately useful information: a diagnostic on
        -- the current line, otherwise the LSP documentation for the symbol.
        map("n", "K", function()
          local line = vim.api.nvim_win_get_cursor(0)[1] - 1
          if #vim.diagnostic.get(bufnr, { lnum = line }) > 0 then
            vim.diagnostic.open_float(bufnr, { scope = "line", border = "rounded" })
          else
            vim.lsp.buf.hover({ border = "rounded" })
          end
        end, "Show Diagnostic or Hover")

        if vim.lsp.inlay_hint then
          -- Enable inlay hints by default for this buffer (safe call in case API differs)
          pcall(function()
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          end)

          map("n", "<leader>i", function()
            local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
            vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
          end, "Toggle Inlay Hints")
        end

      end,
    })

    -- clangd remains the primary diagnostics source.  cppcheck is available
    -- on demand as an additional static-analysis pass and writes only its own
    -- diagnostics namespace.
    local cppcheck_namespace = vim.api.nvim_create_namespace("cppcheck")
    local cppcheck_running = {}

    local function cppcheck_path()
      local path = vim.fn.exepath("cppcheck")
      return path ~= "" and path or nil
    end

    local function cppcheck_database(file)
      local database = vim.fs.find("compile_commands.json", {
        path = vim.fs.dirname(file),
        upward = true,
        type = "file",
      })[1]
      if database then
        return database
      end

    end

    local function parse_cppcheck(output, bufnr)
      local diagnostics = {}
      local current_file = vim.uv.fs_realpath(vim.api.nvim_buf_get_name(bufnr))

      for line in output:gmatch("[^\r\n]+") do
        local file, row, col, severity, message, code =
          line:match("^(.-):(%d+):(%d+):%s*(%w+):%s*(.-)%s*%[([^%]]+)%]$")
        local resolved = file and (vim.uv.fs_realpath(file) or vim.fs.normalize(file))

        if resolved and resolved == current_file then
          diagnostics[#diagnostics + 1] = {
            lnum = math.max(tonumber(row) - 1, 0),
            col = math.max(tonumber(col) - 1, 0),
            severity = severity == "error" and vim.diagnostic.severity.ERROR or vim.diagnostic.severity.WARN,
            source = "cppcheck",
            message = message,
            code = code,
          }
        end
      end
      return diagnostics
    end

    local function run_cppcheck(bufnr, opts)
      opts = opts or {}
      bufnr = bufnr or vim.api.nvim_get_current_buf()
      local file = vim.api.nvim_buf_get_name(bufnr)
      if file == "" or cppcheck_running[bufnr] then
        return
      end

      local executable = cppcheck_path()
      if not executable then
        vim.notify("cppcheck is not installed or not in PATH", vim.log.levels.WARN)
        return
      end

      local args = {
        "--enable=warning,style,performance,portability",
        "--inline-suppr",
        "--quiet",
        "--template={file}:{line}:{column}: {severity}: {message} [{id}]",
      }
      local database = cppcheck_database(file)
      if database then
        table.insert(args, "--project=" .. database)
        table.insert(args, "--file-filter=" .. file)
      else
        table.insert(args, file)
      end

      cppcheck_running[bufnr] = true
      if not opts.silent then
        vim.notify("Cppcheck: analysing " .. vim.fn.fnamemodify(file, ":t"))
      end
      vim.system(vim.list_extend({ executable }, args), { text = true }, function(result)
        cppcheck_running[bufnr] = nil
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(bufnr) then
            vim.diagnostic.set(cppcheck_namespace, bufnr, parse_cppcheck((result.stdout or "") .. (result.stderr or ""), bufnr), {})
            if not opts.silent then
              vim.notify("Cppcheck: finished", result.code == 0 and vim.log.levels.INFO or vim.log.levels.WARN)
            end
          end
        end)
      end)
    end

    vim.api.nvim_create_user_command("Cppcheck", function()
      run_cppcheck(0)
    end, { desc = "Run cppcheck for the current C file" })

    -- Auto-run cppcheck on save
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = { "*.c", "*.h" },
      callback = function(args)
        run_cppcheck(args.buf, { silent = true })
      end,
    })
  end,
}
