#!/bin/bash
set -euxo pipefail

mkdir -p voyager/data

cp artifacts/player-x86_64-unknown-linux-gnu/player voyager/Voyager-Linux-x86_64
cp artifacts/player-aarch64-unknown-linux-gnu/player voyager/Voyager-Linux-aarch64
cp artifacts/player-x86_64-pc-windows-msvc/player.exe voyager/Voyager-Windows.exe
cp artifacts/player-universal-apple-darwin/player voyager/Voyager-macOS
chmod a+x voyager/Voyager-{Linux-{x86_64,aarch64},macOS}

# shellcheck disable=SC2154
skopeo copy "docker://ghcr.io/lc-41/tapes@$tapes_digest" oci:tapes
manifest="$(jq -r '.manifests[].digest | split(":")[1]' tapes/index.json)"
blob="$(jq -r '.layers[0].digest | split(":")[1]' "tapes/blobs/sha256/$manifest")"
tar -C voyager/data -xvf "tapes/blobs/sha256/$blob"

echo "=== CHECKSUMS START ==="
(cd voyager; find . -type f | sort | sha256sum)
echo "=== CHECKSUMS END ==="

xorrisofs -J -V Voyager -o voyager.iso voyager
file voyager.iso
ls -l voyager.iso
sha256sum voyager.iso
