return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",

  config = function()
    local ts = require("nvim-treesitter")
    ts.setup()

    pcall(ts.install, { "c", "lua" })

    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        if vim.bo[args.buf].buftype ~= "" then
          return
        end
        local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
        if lang and pcall(vim.treesitter.get_parser, args.buf, lang) then
          pcall(vim.treesitter.start, args.buf)
        end
      end,
    })
  end,
}
