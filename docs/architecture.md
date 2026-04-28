# 架构说明

本文档描述 nvim-lite 的内部结构、模块边界和关键设计决策。

## 启动流程

```text
init.lua
  └─ devil.core.utils: bootstrap lazy.nvim
  └─ devil.core          (core/init.lua)
       ├─ devil.core.options    — 基础选项
       ├─ devil.core.autocmds   — 自动命令
       └─ devil.core.diag       — 诊断行为
  └─ devil.plugins        (plugins/init.lua)
       ├─ devil.plugins.specs.* — 插件声明（按领域分组）
       └─ devil.plugins.configs.* — 插件配置实现
  └─ devil.core.keymaps   — 全局编辑器映射
  └─ devil.core.commands  — 用户命令
  └─ devil.core.colorscheme — 颜色方案
```

## 目录职责

| 路径 | 职责 |
|------|------|
| `init.lua` | bootstrap 入口；依次加载 core 和 plugins |
| `lua/devil/core/` | 编辑器基础行为：选项、自动命令、命令、映射、诊断、颜色 |
| `lua/devil/plugins/specs/` | 插件声明，按领域分文件（core / prog / telescope / ui） |
| `lua/devil/plugins/configs/` | 各插件的具体配置实现 |

## core / plugins/specs / plugins/configs 边界

- **core**：不依赖任何插件的基础配置；处理 Neovim 原生能力
- **specs**：声明插件依赖、`opts`、`config` 函数和插件触发 keymap，**不做具体 setup**
- **configs**：具体的 `setup()` 调用和选项拼装；按功能域进一步拆分
  （如 lsp / fmt / lint / dap / neotest）

## 插件分组规则

| spec 文件 | 覆盖范围 |
|-----------|----------|
| `specs/core.lua` | lazy.nvim、mini.icons、treesitter、mason、LSP 基础、snacks、trouble、noice、nvim-surround |
| `specs/prog.lua` | blink.cmp、conform.nvim、nvim-lint、neotest、nvim-dap、rustaceanvim、lazydev |
| `specs/telescope.lua` | telescope.nvim、smart-open.nvim 及各 telescope 扩展 |
| `specs/ui.lua` | neo-tree、heirline、cokeline、dropbar、gitsigns、which-key、todo-comments、ts-comments |

## keymaps 和 commands 组织

- `lua/devil/core/keymaps.lua`：全局编辑器映射，启动后直接加载
- `lua/devil/core/commands.lua`：用户命令定义
- 各插件的 keymap 在对应 `specs/*.lua` 的 `keys` 字段中声明
- LSP keymap 在 `utils.on_attach()` 中按 buffer 注册
- gitsigns keymap 在 `configs/others.lua` 的 `on_attach` 中按 buffer 注册
- 不维护集中式 keymap 模板或转换层

## 职责去重策略

配置维护中遵循"不重复造轮子"原则，已执行的清理包括：

| 保留 | 移除/禁用 | 原因 |
|------|-----------|------|
| gitsigns.nvim `blame_line` | snacks.git `blame_line` | 同一功能保留 gitsigns |
| noice.nvim（通知路由） | snacks.notifier | noice 已覆盖消息路由 |
| LSP documentHighlight | snacks.words | 语义级高亮优先于文本匹配 |
| neo-tree.nvim | telescope-file-browser.nvim | 常驻侧边栏覆盖临时文件浏览 |
| conform.nvim `<leader>bf` | `vim.lsp.buf.format` | 统一走 conform 格式化入口 |
| dropbar.nvim（独立 winbar） | heirline 的 winbar | dropbar 自己管理 breadcrumb |
| rustaceanvim.neotest | neotest-rust | rustaceanvim 自带更准确的 adapter |

## Treesitter 策略

**当前实现细节**，后续可能变化：

- `romus204/tree-sitter-manager.nvim` 负责 parser 安装、删除和管理 UI
- `specs/core.lua` 只显式设置 `ensure_installed`，不重写插件默认选项
- 默认安装 c、c_sharp、cpp、css、dockerfile、go、html、javascript、json、just、
  lua、make、markdown、rust、sql、toml、tsx、typescript、zig parsers
- `ensure_installed` 只在存在 UI 时传给插件，避免 headless 检查触发 parser 安装
- 高亮由 Neovim core `vim.treesitter.start()` 启用（Neovim 0.12+ 内置 API）
- `nvim-ts-autotag` 使用自己的 `setup` 方式，不再挂载到旧
  `nvim-treesitter.configs`
- `ts-inject.nvim` 仅依赖 Neovim 内置 `vim.treesitter` API，不依赖
  `nvim-treesitter` 插件

**不保留旧兼容层**：上游重构接口后，直接迁移，不维护旧
`nvim-treesitter.configs.setup` 兼容路径。

## LSP / DAP / Formatting / Lint 组织

| 功能 | 配置位置 | 备注 |
|------|----------|------|
| LSP 服务器管理 | `configs/lsp.lua` + `configs/mason.lua` | rust_analyzer 由 rustaceanvim 接管；mason-lspconfig 不自动 enable，统一由本配置显式 `vim.lsp.config()` / `vim.lsp.enable()` |
| LSP 按需启用 | `configs/lsp.lua` 循环内检查 `vim.fn.executable` | 未安装的服务器自动跳过，减少 checkhealth 噪音 |
| 补全 | `configs/cmp.lua`（blink.cmp） | |
| 格式化 | `configs/fmt.lua`（conform.nvim） | `<leader>f` 和 `<leader>bf` 统一走 conform，LSP fallback 使用 `lsp_format = "fallback"` |
| Lint | `configs/lint.lua`（nvim-lint） | |
| 测试 | `configs/neotest.lua` | Rust 测试使用 `rustaceanvim.neotest` adapter |
| 调试 | `configs/dap.lua` | |

## 稳定约定 vs 当前实现细节

| 稳定约定 | 当前实现细节（可能变化） |
|----------|--------------------------|
| core/specs/configs 三层职责划分 | treesitter 具体 API 调用方式 |
| specs 按领域分文件 | mason/toolchain 具体配置 |
| keymaps 就近声明：全局归 core，插件归 specs，buffer-local 归 attach 回调 | 各插件具体 keybinding |
| 不保留旧兼容层原则 | tree-sitter-manager 配置方式 |
| 职责去重、不重复造轮子 | 具体保留哪家插件 |

维护者应优先保证稳定约定不被破坏，实现细节可按上游变化调整。
