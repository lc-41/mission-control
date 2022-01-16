#!/bin/bash
set -euxo pipefail

mkdir artifacts
mkdir ~/vendor-cargo-home
CARGO_HOME=$(realpath ~/vendor-cargo-home)
export CARGO_HOME

mkdir -p .cargo
cargo vendor > .cargo/config.toml
# clamp vendor mtimes at Cargo.lock's mtime
find vendor -newer Cargo.lock -print0 | xargs -0r touch --no-dereference --reference=Cargo.lock

pushd vendor/before
# do build.rs's asset generation
npm ci
cargo check --no-default-features
cargo clean
find static -newer Cargo.lock -print0 | xargs -0r touch --no-dereference --reference=Cargo.lock
# zip it up
zip -9qr static.zip static
rm -rf static/*
echo "see static.zip elsewhere on the Voyager disc" > static/README
popd
mv vendor/before/static.zip artifacts/

echo "see zstd-dictionaries elsewhere on the Voyager disc" > zstd-dictionaries/README
unset POSIXLY_CORRECT # this should be the case but do it just in case
shopt -s dotglob
tar --sort=name --owner=0 --group=0 --numeric-owner \
    --exclude=.git --exclude=artifacts --exclude="zstd-dictionaries/*.dict" \
    -cf artifacts/source.tar -- *
shopt -u dotglob
zstd -q -19 artifacts/source.tar
