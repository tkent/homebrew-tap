#!/usr/bin/env bash
# Render Formula/cairn.rb from tools/cairn.rb.tmpl and a goreleaser checksums.txt.
#
# Usage: tools/bump-formula.sh <version> <checksums.txt>
#   version: X.Y.Z with no leading "v", matching goreleaser's {{.Version}}.
#
# Only renders and syntax-checks; the caller (cairn's release workflow) commits and
# pushes. Refuses pre-release versions (anything with "-"): dev tags never reach the tap.
set -euo pipefail

usage() { echo "usage: $0 <version> <checksums.txt>" >&2; exit 2; }
[ $# -eq 2 ] || usage
version=$1
sums=$2
here=$(cd "$(dirname "$0")" && pwd)
tmpl="$here/cairn.rb.tmpl"
out="$here/../Formula/cairn.rb"

[[ $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || {
  echo "refusing version '$version': need stable X.Y.Z (no leading v, no pre-release)" >&2; exit 1; }
[ -f "$sums" ] || { echo "no such checksums file: $sums" >&2; exit 1; }

sha_for() {
  local name="cairn_${version}_$1.tar.gz" sha
  sha=$(awk -v n="$name" '$2 == n || $2 == "*"n { print $1 }' "$sums")
  [[ $sha =~ ^[0-9a-f]{64}$ ]] || { echo "missing or bad sha256 for $name in $sums" >&2; exit 1; }
  echo "$sha"
}

da=$(sha_for darwin_arm64)
di=$(sha_for darwin_amd64)
la=$(sha_for linux_arm64)
li=$(sha_for linux_amd64)

tmp=$(mktemp)
sed -e "s/@VERSION@/$version/g" \
    -e "s/@SHA_DARWIN_ARM64@/$da/" -e "s/@SHA_DARWIN_AMD64@/$di/" \
    -e "s/@SHA_LINUX_ARM64@/$la/"  -e "s/@SHA_LINUX_AMD64@/$li/" \
    "$tmpl" > "$tmp"

if grep -q '@[A-Z_0-9]*@' "$tmp"; then
  echo "unfilled placeholder left in rendered formula" >&2; rm -f "$tmp"; exit 1
fi
ruby -c "$tmp" >/dev/null
mkdir -p "$(dirname "$out")"
mv "$tmp" "$out"
chmod 0644 "$out"
echo "rendered Formula/cairn.rb for $version"
