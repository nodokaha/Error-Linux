#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR"
PACKAGES_DIR="$ROOT_DIR/packages"
PKGMGR_BIN="${PKGMGR_BIN:-$ROOT_DIR/pkgmgr.sh}"
PROFILE_FILE_DEFAULT="$ROOT_DIR/distribution/profiles/base.list"

usage() {
  cat <<USAGE
Usage:
  $0 build <package>
  $0 build-all [profile.list]
  $0 assemble [profile.list] [rootdir]
  $0 list [profile.list]

Examples:
  $0 build pkgmgr
  $0 build-all
  $0 assemble distribution/profiles/base.list /tmp/error-root
USAGE
}

require_file() {
  local path="$1"
  [[ -f "$path" ]] || { echo "file not found: $path"; exit 1; }
}

resolve_profile() {
  local p="${1:-$PROFILE_FILE_DEFAULT}"
  if [[ "$p" != /* ]]; then
    p="$ROOT_DIR/$p"
  fi
  echo "$p"
}

list_packages() {
  local profile="$1"
  require_file "$profile"
  sed -e 's/#.*//' -e '/^\s*$/d' "$profile"
}

build_package() {
  local name="$1"
  local pkg_dir="$PACKAGES_DIR/$name"
  local build_sh="$pkg_dir/build.sh"
  [[ -d "$pkg_dir" ]] || { echo "unknown package: $name"; exit 1; }
  require_file "$build_sh"

  echo "==> build: $name"
  (cd "$pkg_dir" && ./build.sh)
}

build_all() {
  local profile="$1"
  while IFS= read -r pkg; do
    build_package "$pkg"
  done < <(list_packages "$profile")
}

latest_archive() {
  local pkg="$1"
  local out_dir="$PACKAGES_DIR/$pkg/out"
  [[ -d "$out_dir" ]] || return 1
  ls -1t "$out_dir"/*.tar.zst 2>/dev/null | head -n 1
}

assemble_rootfs() {
  local profile="$1"
  local rootdir="$2"
  mkdir -p "$rootdir"

  while IFS= read -r pkg; do
    local archive
    archive="$(latest_archive "$pkg" || true)"
    if [[ -z "$archive" ]]; then
      echo "archive not found for $pkg. building package first..."
      build_package "$pkg"
      archive="$(latest_archive "$pkg")"
    fi

    echo "==> install: $archive"
    PKGMGR_DB_DIR="$rootdir/var/lib/pkgmgr" PKGMGR_ROOT_DIR="$rootdir" "$PKGMGR_BIN" install "$archive"
  done < <(list_packages "$profile")
}

main() {
  local cmd="${1:-}"
  case "$cmd" in
    build)
      [[ $# -eq 2 ]] || { usage; exit 1; }
      build_package "$2"
      ;;
    build-all)
      [[ $# -le 2 ]] || { usage; exit 1; }
      build_all "$(resolve_profile "${2:-}")"
      ;;
    assemble)
      [[ $# -ge 1 && $# -le 3 ]] || { usage; exit 1; }
      local profile rootdir
      profile="$(resolve_profile "${2:-}")"
      rootdir="${3:-$ROOT_DIR/distribution/rootfs}"
      if [[ "$rootdir" != /* ]]; then
        rootdir="$ROOT_DIR/$rootdir"
      fi
      assemble_rootfs "$profile" "$rootdir"
      ;;
    list)
      [[ $# -le 2 ]] || { usage; exit 1; }
      list_packages "$(resolve_profile "${2:-}")"
      ;;
    *)
      usage
      exit 1
      ;;
  esac
}

main "$@"
