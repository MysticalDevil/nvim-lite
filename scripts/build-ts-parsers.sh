#!/usr/bin/env bash

# Build and install selected Tree-sitter parsers for Neovim.
# Usage: scripts/build-ts-parsers.sh [--update] [--install-dir DIR] <lang> [<lang> ...]
# Supported languages: c, cpp, go, rust, zig

set -euo pipefail

CACHE_DIR="${HOME}/.cache/tree-sitter-parsers"
INSTALL_DIR="${HOME}/.local/share/nvim/site/parser"
UPDATE_REPOS=0

usage() {
  printf '%s\n' \
    "Usage: $(basename "$0") [--update] [--install-dir DIR] <lang> [<lang> ...]" \
    "Supported languages: c, cpp, go, rust, zig"
}

fail() {
  printf 'error: %s\n' "$1" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "missing required command: $1"
}

repo_url_for() {
  case "$1" in
    c) printf '%s\n' 'https://github.com/tree-sitter/tree-sitter-c' ;;
    cpp) printf '%s\n' 'https://github.com/tree-sitter/tree-sitter-cpp' ;;
    go) printf '%s\n' 'https://github.com/tree-sitter/tree-sitter-go' ;;
    rust) printf '%s\n' 'https://github.com/tree-sitter/tree-sitter-rust' ;;
    zig) printf '%s\n' 'https://github.com/tree-sitter-grammars/tree-sitter-zig' ;;
    *) fail "unsupported language: $1" ;;
  esac
}

clone_or_update_repo() {
  local lang="$1"
  local repo_dir="$CACHE_DIR/$lang"
  local repo_url
  repo_url="$(repo_url_for "$lang")"

  if [ ! -d "$repo_dir/.git" ]; then
    printf '==> Cloning %s\n' "$lang" >&2
    git clone --depth=1 "$repo_url" "$repo_dir"
  elif [ "$UPDATE_REPOS" -eq 1 ]; then
    printf '==> Updating %s\n' "$lang" >&2
    git -C "$repo_dir" pull --ff-only
  fi

  printf '%s\n' "$repo_dir"
}

compile_shared() {
  local compiler="$1"
  local output="$2"
  shift 2
  "$compiler" -shared "$@" -o "$output"
}

build_one() {
  local lang="$1"
  local repo_dir src_dir build_dir output parser_obj scanner_c_obj scanner_cc_obj
  repo_dir="$(clone_or_update_repo "$lang")"
  src_dir="$repo_dir/src"
  build_dir="$repo_dir/.build"
  output="$INSTALL_DIR/$lang.so"
  parser_obj="$build_dir/parser.o"
  scanner_c_obj="$build_dir/scanner.o"
  scanner_cc_obj="$build_dir/scanner-cpp.o"

  [ -f "$src_dir/parser.c" ] || fail "$lang is missing $src_dir/parser.c"

  mkdir -p "$build_dir" "$INSTALL_DIR"
  rm -f "$parser_obj" "$scanner_c_obj" "$scanner_cc_obj"

  printf '==> Building %s\n' "$lang"
  cc -O2 -fPIC -I"$src_dir" -c "$src_dir/parser.c" -o "$parser_obj"

  case "$lang" in
    c|cpp|go|rust|zig)
      if [ -f "$src_dir/scanner.c" ]; then
        cc -O2 -fPIC -I"$src_dir" -c "$src_dir/scanner.c" -o "$scanner_c_obj"
        compile_shared cc "$output" "$parser_obj" "$scanner_c_obj"
      elif [ -f "$src_dir/scanner.cc" ]; then
        c++ -O2 -fPIC -I"$src_dir" -c "$src_dir/scanner.cc" -o "$scanner_cc_obj"
        compile_shared c++ "$output" "$parser_obj" "$scanner_cc_obj"
      else
        compile_shared cc "$output" "$parser_obj"
      fi
      ;;
    *)
      fail "unsupported language during build: $lang"
      ;;
  esac

  printf 'Installed %s\n' "$output"
}

main() {
  local langs=()

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --update)
        UPDATE_REPOS=1
        shift
        ;;
      --install-dir)
        [ "$#" -ge 2 ] || fail "--install-dir requires a value"
        INSTALL_DIR="$2"
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      --)
        shift
        break
        ;;
      -*)
        fail "unknown option: $1"
        ;;
      *)
        langs+=("$1")
        shift
        ;;
    esac
  done

  while [ "$#" -gt 0 ]; do
    langs+=("$1")
    shift
  done

  [ "${#langs[@]}" -gt 0 ] || {
    usage
    exit 1
  }

  require_cmd git
  require_cmd cc
  require_cmd c++

  mkdir -p "$CACHE_DIR" "$INSTALL_DIR"

  for lang in "${langs[@]}"; do
    build_one "$lang"
  done
}

main "$@"
