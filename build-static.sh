#!/bin/bash
set -euxo pipefail

mkdir artifacts
if [[ -n ${GITHUB_ACTIONS+x} ]]; then
    mkdir ~/vendor-cargo-home
    CARGO_HOME=$(realpath ~/vendor-cargo-home)
    export CARGO_HOME
fi
export NODE_ENV=production

# use GNU tar and coreutils on macOS if they're installed with brew
# (this is for local testing)
if hash brew 2>/dev/null; then
    PATH="$(brew --prefix)/opt/gnu-tar/libexec/gnubin:$(brew --prefix)/opt/coreutils/libexec/gnubin:$PATH"
    export PATH
fi

mkdir -p .cargo
cargo vendor > .cargo/config.toml
# clamp vendor mtimes at Cargo.lock's mtime
find vendor -newer Cargo.lock -print0 | xargs -0r touch --no-dereference --reference=Cargo.lock
# do build.rs's asset generation
pushd vendor/before
npm ci --production=false
popd
cargo check -p player --features bundle_before
cargo clean

pushd vendor/before
find static -newer Cargo.lock -print0 | xargs -0r touch --no-dereference --reference=Cargo.lock
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
zstd -9e artifacts/source.tar
