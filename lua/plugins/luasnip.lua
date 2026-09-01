return {
  {
    "L3MON4D3/LuaSnip",
    event = "InsertEnter",
    version = "v2.*",
    build = "make install_jsregexp",
    config = function()
      local ls = require("luasnip")
      local s, t, i = ls.snippet, ls.text_node, ls.insert_node

      ls.config.set_config({
        history = true,
        updateevents = "TextChanged,TextChangedI",
      })

      local function basics(main_signature)
        return {
          s("inc", { t("#include <"), i(1, "stdio.h"), t(">") }),
          s("if", { t("if ("), i(1, "condition"), t({ ") {", "\t" }), i(0), t({ "", "}" }) }),
          s("ife", { t("if ("), i(1, "condition"), t({ ") {", "\t" }), i(2), t({ "", "} else {", "\t" }), i(0), t({ "", "}" }) }),
          s("for", { t("for ("), i(1, "int i = 0"), t("; "), i(2, "i < count"), t("; "), i(3, "++i"), t({ ") {", "\t" }), i(0), t({ "", "}" }) }),
          s("while", { t("while ("), i(1, "condition"), t({ ") {", "\t" }), i(0), t({ "", "}" }) }),
          s("switch", { t({ "switch (" }), i(1, "value"), t({ ") {", "case " }), i(2, "value"), t({ ":", "\t" }), i(3), t({ "", "\tbreak;", "default:", "\tbreak;", "}" }) }),
          s("fn", { i(1, "void"), t(" "), i(2, "name"), t("("), i(3, "void"), t({ ") {", "\t" }), i(0), t({ "", "}" }) }),
          s("struct", { t({ "struct " }), i(1, "name"), t({ " {", "\t" }), i(0), t({ "", "};" }) }),
          s("enum", { t({ "enum " }), i(1, "name"), t({ " {", "\t" }), i(0), t({ "", "};" }) }),
          s("main", { t({ main_signature .. " {", "\t" }), i(1), t({ "", "\treturn 0;", "}" }) }),
        }
      end

      ls.add_snippets("c", basics("int main(void)"))
    end,
  },
}
