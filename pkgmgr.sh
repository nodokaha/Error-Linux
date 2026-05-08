#!/bin/bash
set -euo pipefail

DB_DIR="${PKGMGR_DB_DIR:-/var/lib/pkgmgr}"
ROOT_DIR="${PKGMGR_ROOT_DIR:-/}"

usage() {
  cat <<USAGE
Usage:
  $0 install <package.tar.zst>
  $0 remove <name>
  $0 list
  $0 info <name>
USAGE
}

safe_name() {
  local name="$1"
  [[ "$name" =~ ^[A-Za-z0-9._+-]+$ ]]
}

pkg_name_from_file() {
  local file="$1"
  local base
  base="$(basename "$file")"
  echo "$base" | sed -E 's/-[0-9][^-]*-[0-9]+-[A-Za-z0-9_]+\.tar\.zst$//'
}

install_pkg() {
  local package_file="$1"
  [[ -f "$package_file" ]] || { echo "package not found: $package_file"; exit 1; }

  local name
  name="$(pkg_name_from_file "$package_file")"
  safe_name "$name" || { echo "invalid package name: $name"; exit 1; }

  local pkg_db="$DB_DIR/$name"
  local manifest="$pkg_db/manifest.txt"

  mkdir -p "$pkg_db"

  local tmpdir
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' RETURN

  tar --zstd -xf "$package_file" -C "$tmpdir"

  (cd "$tmpdir" && find . -mindepth 1 -printf '%P\n' | sort > "$manifest")

  tar --zstd -xf "$package_file" -C "$ROOT_DIR"

  cp "$package_file" "$pkg_db/package.tar.zst"
  date -u +"%Y-%m-%dT%H:%M:%SZ" > "$pkg_db/installed_at"

  echo "installed: $name"
}

remove_pkg() {
  local name="$1"
  safe_name "$name" || { echo "invalid package name: $name"; exit 1; }

  local pkg_db="$DB_DIR/$name"
  local manifest="$pkg_db/manifest.txt"
  [[ -f "$manifest" ]] || { echo "package not installed: $name"; exit 1; }

  tac "$manifest" | while IFS= read -r rel; do
    local path="$ROOT_DIR/$rel"
    if [[ -f "$path" || -L "$path" ]]; then
      rm -f "$path"
    elif [[ -d "$path" ]]; then
      rmdir --ignore-fail-on-non-empty "$path" 2>/dev/null || true
    fi
  done

  rm -rf "$pkg_db"
  echo "removed: $name"
}

list_pkgs() {
  [[ -d "$DB_DIR" ]] || return 0
  find "$DB_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort
}

info_pkg() {
  local name="$1"
  local pkg_db="$DB_DIR/$name"
  [[ -d "$pkg_db" ]] || { echo "package not installed: $name"; exit 1; }
  echo "name: $name"
  [[ -f "$pkg_db/installed_at" ]] && echo "installed_at: $(cat "$pkg_db/installed_at")"
  [[ -f "$pkg_db/package.tar.zst" ]] && echo "archive: $pkg_db/package.tar.zst"
}

main() {
  mkdir -p "$DB_DIR"

  local cmd="${1:-}"
  case "$cmd" in
    install)
      [[ $# -eq 2 ]] || { usage; exit 1; }
      install_pkg "$2"
      ;;
    remove)
      [[ $# -eq 2 ]] || { usage; exit 1; }
      remove_pkg "$2"
      ;;
    list)
      [[ $# -eq 1 ]] || { usage; exit 1; }
      list_pkgs
      ;;
    info)
      [[ $# -eq 2 ]] || { usage; exit 1; }
      info_pkg "$2"
      ;;
    *)
      usage
      exit 1
      ;;
  esac
}

main "$@"
