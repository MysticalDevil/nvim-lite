# nvim-lite

[中文](README.md) | English

A Neovim configuration for daily development, designed with maintainer
priorities: clear architecture, explicit module boundaries, and native
upstream APIs.

This is the **companion English entry point**. The [Chinese README](README.md)
is the authoritative source with full details. Deep dives are in [docs/](docs/):

- [Architecture](docs/architecture.md) — startup flow, module responsibilities,
  plugin organization, treesitter strategy
- [Workflows](docs/workflows.md) — installation, daily updates, health checks,
  troubleshooting

## What This Repo Is

- Not minimal in plugin count; focused on clean layering and complete toolchains
- Full LSP / completion / formatting / lint / testing / debugging workflows
- Prefers upstream-native APIs; no long-lived compatibility layers
- Migrates directly on breaking changes instead of stacking fallbacks

## Design Principles

- `lazy.nvim` handles bootstrap, version locking, and plugin loading
- `core` for editor basics; `plugins/specs` for declarations;
  `plugins/configs` for implementation
- Use built-in Neovim features where they are already good enough
- Converge on upstream breaking changes; do not preserve old interfaces

## Quick Start

```bash
git clone https://github.com/yourname/nvim-lite.git ~/.config/nvim
nvim  # bootstraps lazy.nvim on first run
```

Requirements: Neovim `0.12+`, `git`, `curl`, `tar`, `make`, a C compiler,
`tree-sitter` CLI, `ripgrep`.

## Layout

```text
init.lua                      # bootstrap entry
lua/devil/core/               # options, autocmds, commands, keymaps
lua/devil/plugins/specs/     # plugin specs by domain
lua/devil/plugins/configs/   # plugin-specific setup
lazy-lock.json
```

See [docs/architecture.md](docs/architecture.md) for full structure
and responsibilities.

## Key Conventions

- **core / specs / configs** three-layer split is stable
- Treesitter parsers listed in `specs/core.lua`; no `configs.setup`
  compatibility layer
- Keymaps are local to their owner: global editor mappings live in
  `core/keymaps.lua`, plugin trigger keys live in plugin specs, and
  buffer-local keys are attached by LSP/gitsigns callbacks
- Plugin groups: `core`, `prog`, `telescope`, `ui` (see
  [docs/architecture.md](docs/architecture.md))
- No legacy compatibility paths; upstream changes are migrated directly

## Common Commands

| Command | Purpose |
|---------|---------|
| `:Format` | conform.nvim formatter entry |
| `:ConfigHealth` | config-level health check |
| `:Lazy sync` | sync plugin versions |
| `:Mason` | manage LSP / formatter / debugger toolchains |
| `:TSUpdate` | update treesitter parsers |

## Local Checks

```bash
selene lua init.lua
rumdl fmt README.md README.en.md docs/*.md
rumdl check README.md README.en.md docs/*.md
```
