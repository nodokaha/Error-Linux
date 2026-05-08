#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/package.conf"

WORKDIR="${WORKDIR:-$PWD/work}"
OUTDIR="${OUTDIR:-$PWD/out}"
PKG_ROOT="${WORKDIR}/pkgroot"

mkdir -p "$WORKDIR" "$OUTDIR"
rm -rf "$PKG_ROOT"
mkdir -p "$PKG_ROOT/usr/bin"

install -m755 "$SCRIPT_DIR/../../pkgmgr.sh" "$PKG_ROOT/usr/bin/pkgmgr"

PACKAGE_FILE="${OUTDIR}/${NAME}-${VERSION}-${RELEASE}-${ARCH}.tar.zst"
tar --zstd -cf "$PACKAGE_FILE" -C "$PKG_ROOT" .

echo "Package created: $PACKAGE_FILE"
