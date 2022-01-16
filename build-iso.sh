#!/bin/bash
set -euxo pipefail

dl_ghcr() {
    dir="$(mktemp -d)"
    skopeo copy "docker://ghcr.io/lc-41/$1" oci:"$dir"
    manifest="$(jq -r '.manifests[].digest | split(":")[1]' "$dir/index.json")"
    blob="$(jq -r '.layers[0].digest | split(":")[1]' "$dir/blobs/sha256/$manifest")"
    tar -C "$2" -xvf "$dir/blobs/sha256/$blob"
}

mkdir -p voyager/data/static

cp scripts/Vcr.toml voyager/

cp artifacts/player-x86_64-unknown-linux-gnu/player voyager/Voyager-Linux-x86_64
cp artifacts/player-aarch64-unknown-linux-gnu/player voyager/Voyager-Linux-aarch64
cp artifacts/player-x86_64-pc-windows-msvc/player.exe voyager/Voyager-Windows.exe
cp artifacts/player-universal-apple-darwin/player voyager/Voyager-macOS
chmod a+x voyager/Voyager-{Linux-{x86_64,aarch64},macOS}

cp artifacts/static-and-source/static.zip voyager/data/
cp artifacts/static-and-source/source.tar.xz voyager/data/

dl_ghcr "tapes@$TAPES_DIGEST" voyager/data
dl_ghcr "sigils@$SIGILS_DIGEST" voyager/data/static

echo "=== CHECKSUMS START ==="
(cd voyager; find . -type f | sort | xargs sha256sum)
echo "=== CHECKSUMS END ==="

xorrisofs -J -V Voyager -o voyager.iso voyager
file voyager.iso
ls -l voyager.iso
sha256sum voyager.iso
