# Neovim для C

## Зависимости

```bash
git make build-essential clangd clang-format cppcheck curl unzip \
python3 ripgrep fd-find tree-sitter-cli luarocks fuse
```

## Установка Neovim

Следуйте инструкции: [neovim.io/doc/install/](https://neovim.io/doc/install/)

## Настройка

Конфиг должен быть в `~/.config/nvim`

## LSP

Для работы LSP нужен `compile_commands.json`. В make-проектах создаётся через:

```bash
compiledb make
```
