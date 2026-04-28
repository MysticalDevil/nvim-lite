# 日常维护与排错

本文档描述日常使用中的维护流程和常见问题处理。

## 首次启动

1. 确保满足[运行环境要求](../README.md#运行环境要求)
2. 将仓库内容放到 `~/.config/nvim` 或软链接过去
3. 运行 `nvim`，`lazy.nvim` 会自动 bootstrap
4. 首次启动会通过 `tree-sitter-manager.nvim` 安装默认 parser 列表
5. 运行 `:Mason` 手动安装 LSP / formatter / debugger 工具链

## 日常更新

### 插件同步

```vim
:Lazy sync
```

更新后优先执行此命令，确保插件版本与 lock 文件一致。

### Treesitter Parser 更新

```vim
:TSManager
```

在 `:Lazy sync` 后打开 parser 管理界面。把光标移到对应 parser 上，
按 `u` 更新，按 `i` 安装，按 `x` 移除。

### Mason 工具链更新

```vim
:Mason
```

打开 Mason UI 管理 LSP 服务器、formatter、debugger。也可运行 `:MasonUpdate` 更新所有工具。

## 本地检查

### Lua 静态检查

```bash
stylua --check .
selene lua init.lua
```

### 文档格式检查

```bash
rumdl fmt README.md README.en.md docs/*.md
rumdl check README.md README.en.md docs/*.md
```

## 常用命令

| 命令 | 作用 |
|------|------|
| `:Format` | 通过 conform.nvim 格式化当前 buffer |
| `:ConfigHealth` | 运行配置级健康检查 |
| `:Lazy sync` | 同步插件版本 |
| `:Lazy` | 打开 lazy.nvim 管理界面 |
| `:Mason` | 管理 LSP / formatter / debugger 工具链 |
| `:MasonUpdate` | 更新 Mason 已安装的工具 |
| `:TSManager` | 管理 treesitter parsers |
| `:Neotree` | 切换文件树 |

## 常见故障

### 缺 parser

症状：文件类型正确但无高亮。

处理：

1. 确认 parser 在 `specs/core.lua` 的 `ensure_installed` 列表中
2. 运行 `:TSManager` 安装或更新对应 parser
3. 检查 `tree-sitter` CLI 是否可用：`tree-sitter --version`

### 缺外部命令

症状：LSP 连接成功但功能不全；格式化/lint 不工作。

处理：

1. 运行 `:Mason` 检查工具链是否安装
2. 确认外部依赖存在（如 `rustfmt`、`black`、`shellcheck` 等）
3. 查看 `:checkhealth` 输出

### LSP 工具链未装

症状：LSP 服务器启动但报错 "tool not found"。

处理：

1. 运行 `:Mason` 安装对应语言服务器
2. 或运行 `:MasonInstall <server>` 安装特定服务器

### checkhealth 中大量 "not executable" 警告

症状：`:checkhealth vim.lsp` 出现大量 `WARNING 'xxx' is not executable`。

处理：

这是正常现象。配置已启用"按需启用"策略——未安装的可执行文件
对应的服务器会自动跳过，不会实际启动。这些警告只是提示哪些服务器
尚未安装。`mason-lspconfig` 不自动 enable 服务器，最终启用由
`configs/lsp.lua` 显式控制。

如需消除，运行 `:Mason` 安装对应工具，或从 `configs/lsp.lua` 的 `servers` 表中移除不需要的服务器。

### Lazy sync 后插件不工作

处理顺序：

1. `:Lazy sync` 确认无报错
2. `:Lazy` 检查插件状态
3. 重启 nvim
4. 如仍有问题，检查 lazy-lock.json 是否有异常变动

## 文档维护

- README.md 是主文档和事实来源
- 英文 README.en.md 是 companion doc，保留项目定位和入口，不做完整镜像
- 架构细节下沉到 docs/architecture.md
- 维护流程和排错下沉到 docs/workflows.md
- 文档修改后运行 `rumdl fmt` 和 `rumdl check`
