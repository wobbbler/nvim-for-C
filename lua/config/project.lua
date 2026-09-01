local uv = vim.uv

local M = {}

local function is_file(path)
  local stat = uv.fs_stat(path)
  return stat and stat.type == "file"
end

-- A directory named .git is not necessarily a Git repository (the home
-- directory in this setup has one without Git metadata).  Accept worktrees
-- (.git is a file) and normal repositories (.git/config exists) only.
local function is_git_root(path)
  local git = path .. "/.git"
  local stat = uv.fs_stat(git)
  return stat and (stat.type == "file" or (stat.type == "directory" and is_file(git .. "/config")))
end

function M.find_root(file)
  local start = vim.fs.dirname(vim.fs.normalize(file))
  local function is_root(directory)
    if is_file(directory .. "/compile_commands.json")
      or is_file(directory .. "/compile_flags.txt")
      or is_file(directory .. "/meson.build")
      or is_file(directory .. "/Makefile")
      or is_file(directory .. "/.clangd")
      or is_git_root(directory)
    then
      return directory
    end
  end
  -- vim.fs.parents() starts with the parent, so test the source directory
  -- itself before walking upward.
  local root = is_root(start)
  if root then
    return root
  end
  for directory in vim.fs.parents(start) do
    root = is_root(directory)
    if root then
      return root
    end
  end
end

function M.lsp_root(file_or_bufnr, on_dir)
  local file = file_or_bufnr
  if type(file_or_bufnr) == "number" then
    file = vim.api.nvim_buf_get_name(file_or_bufnr)
  end
  local root = M.find_root(file) or vim.fs.dirname(vim.fs.normalize(file))
  -- Neovim 0.12 passes a continuation as the second argument. Keeping the
  -- return value as well makes the function usable by older APIs and health
  -- checks.
  if on_dir then
    on_dir(root)
  end
  return root
end

return M
