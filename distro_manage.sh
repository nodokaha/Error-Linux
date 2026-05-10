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

Profile entry formats:
  pkg:<name>       build/install package from packages/<name>
  script:<path>    execute script relative to repository root
  <name>           shorthand of pkg:<name>
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

list_profile_entries() {
  local profile="$1"
  require_file "$profile"
  sed -e 's/#.*//' -e '/^\s*$/d' "$profile"
}

entry_kind() {
  local entry="$1"
  if [[ "$entry" == script:* ]]; then
    echo script
  else
    echo pkg
  fi
}

entry_value() {
  local entry="$1"
  if [[ "$entry" == script:* ]]; then
    echo "${entry#script:}"
  elif [[ "$entry" == pkg:* ]]; then
    echo "${entry#pkg:}"
  else
    echo "$entry"
  fi
}

build_package() {
  local name="$1"
  local pkg_dir="$PACKAGES_DIR/$name"
  local build_sh="$pkg_dir/build.sh"
  [[ -d "$pkg_dir" ]] || { echo "unknown package: $name"; exit 1; }
  require_file "$build_sh"

  echo "==> build package: $name"
  (cd "$pkg_dir" && ./build.sh)
}

run_script_entry() {
  local script_rel="$1"
  local script_path="$ROOT_DIR/$script_rel"
  require_file "$script_path"
  echo "==> run script: $script_rel"
  (cd "$ROOT_DIR" && bash "$script_path")
}

build_all() {
  local profile="$1"
  while IFS= read -r entry; do
    local kind value
    kind="$(entry_kind "$entry")"
    value="$(entry_value "$entry")"

    case "$kind" in
      pkg) build_package "$value" ;;
      script) run_script_entry "$value" ;;
    esac
  done < <(list_profile_entries "$profile")
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

  while IFS= read -r entry; do
    local kind value
    kind="$(entry_kind "$entry")"
    value="$(entry_value "$entry")"

    if [[ "$kind" == script ]]; then
      echo "skip script entry in assemble: $value"
      continue
    fi

    local archive
    archive="$(latest_archive "$value" || true)"
    if [[ -z "$archive" ]]; then
      echo "archive not found for $value. building package first..."
      build_package "$value"
      archive="$(latest_archive "$value")"
    fi

    echo "==> install package: $archive"
    PKGMGR_DB_DIR="$rootdir/var/lib/pkgmgr" PKGMGR_ROOT_DIR="$rootdir" "$PKGMGR_BIN" install "$archive"
  done < <(list_profile_entries "$profile")
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
      list_profile_entries "$(resolve_profile "${2:-}")"
      ;;
    *)
      usage
      exit 1
      ;;
  esac
}

main "$@"
