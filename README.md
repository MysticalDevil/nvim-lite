# nvim-lite

[中文](README.md) | [English](README.en.md)

nvim-lite 是一套面向日常开发的 Neovim 配置，面向维护者设计，以架构清晰和可维护性为首要目标。

## 项目定位

- 不追求最少插件，而是追求配置分层清楚、链路完整
- LSP、补全、格式化、lint、测试、调试都有完整链路
- 尽量回到上游原生接口，不长期维护兼容层
- 插件升级时优先直接迁移，不叠旧版 fallback

## 设计原则

- 用 `lazy.nvim` 负责 bootstrap、锁版本和插件装载
- `core` 放编辑器基础行为，`plugins/specs` 放插件声明，`plugins/configs` 放插件细节
- 能用 Neovim 内建能力解决的地方，尽量不额外包一层
- 对上游 breaking change 采取直接收敛，不保留历史接口兼容

## 仓库结构

```text
.
├── init.lua                      # bootstrap 入口
├── lua/devil/
│   ├── core/                    # 基础行为（选项、自动命令、命令、映射）
│   │   ├── init.lua
│   │   ├── options.lua
│   │   ├── autocmds.lua
│   │   ├── commands.lua
│   │   ├── mappings.lua
│   │   ├── colorscheme.lua
│   │   ├── diag.lua
│   │   └── utils.lua
│   └── plugins/
│       ├── init.lua             # 插件加载入口
│       ├── specs/               # 插件声明
│       │   ├── core.lua         # treesitter、mason、LSP 基础
│       │   ├── coding.lua       # blink.cmp、conform、lint、neotest、dap
│       │   ├── telescope.lua    # telescope 及扩展
│       │   └── ui.lua           # neo-tree、heirline、cokeline、dropbar 等
│       └── configs/             # 各插件具体配置实现
│           ├── lsp.lua
│           ├── mason.lua
│           ├── cmp.lua
│           ├── fmt.lua
│           ├── lint.lua
│           ├── neotest.lua
│           ├── dap.lua
│           ├── telescope.lua
│           ├── neo-tree.lua
│           ├── heirline.lua
│           ├── cokeline.lua
│           ├── snacks.lua
│           ├── lazy.lua
│           └── others.lua
├── lazy-lock.json
└── neovim.yml                   # selene 配置
```

## 启动链路

```text
init.lua
  └─ bootstrap lazy.nvim
  └─ require("devil.core")       # 基础选项、自动命令、诊断
  └─ require("devil.plugins")   # 插件声明与加载
  └─ load_mappings()
  └─ require("devil.core.commands")
  └─ require("devil.core.colorscheme")
```

## 关键实现约定

### 职责边界

- **core**：不依赖插件的基础配置，处理 Neovim 原生能力
- **specs**：声明插件依赖、`opts`、`config` 函数，不做具体 setup
- **configs**：具体的 `setup()` 调用和选项拼装

### Treesitter 策略

- `nvim-treesitter` 本体不 lazy-load
- parser 列表在 `specs/core.lua` 的 `opts.install_languages`
- 高由 `vim.treesitter.start()` 启用，缩进只在语言存在 `indents` query 时设置
- `nvim-ts-autotag` 使用自己的 setup 方式
- **不保留旧 `configs.setup` 兼容层**

### 插件分组

| spec 文件 | 覆盖范围 |
|-----------|----------|
| core | lazy.nvim、mini.icons、treesitter、mason、LSP 基础、snacks、trouble、noice、nvim-surround |
| coding | blink.cmp、conform.nvim、nvim-lint、neotest、nvim-dap、rustaceanvim、lazydev |
| telescope | telescope.nvim、smart-open.nvim 及各扩展 |
| ui | neo-tree、heirline、cokeline、dropbar、outline、gitsigns、which-key、todo-comments、ts-comments |

## 运行环境要求

- Neovim `0.11+`
- `git`、`curl`、`tar`、`make`、可用的 C 编译器
- `tree-sitter` CLI、`ripgrep`

可选：SQLite 运行时支持（smart-open.nvim）、`fd`、`ast-grep`

## 安装

```bash
# 方式一：直接使用
git clone https://github.com/yourname/nvim-lite.git ~/.config/nvim

# 方式二：保留目录名并软链接
git clone https://github.com/yourname/nvim-lite.git ~/projects/nvim-lite
ln -s ~/projects/nvim-lite ~/.config/nvim
```

首次启动 `nvim` 时自动 bootstrap `lazy.nvim`。

## 继续阅读

- [架构详解](docs/architecture.md) — 启动流程、模块边界、插件组织规则、treesitter 策略
- [日常维护与排错](docs/workflows.md) — 首次启动、日常更新、健康检查、常见故障处理

## 常用命令

| 命令 | 作用 |
|------|------|
| `:Format` | conform.nvim 格式化入口 |
| `:ConfigHealth` | 配置级健康检查 |
| `:Lazy sync` | 同步插件版本 |
| `:Mason` | 管理 LSP / formatter / debugger 工具链 |
| `:TSUpdate` | 更新 treesitter parsers |
| `:Neotree` | 切换文件树 |

## 本地检查

```bash
# Lua 静态检查
selene lua/devil

# 文档格式检查
rumdl fmt README.md README.en.md docs/*.md
rumdl check README.md README.en.md docs/*.md
```
