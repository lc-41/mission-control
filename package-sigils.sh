#!/bin/bash
set -euxo pipefail

mkdir -p sigils
youtube-dl -o 'sigils/%(id)s.%(ext)s' -f 247 https://www.youtube.com/watch?v=0et7jJ1zV_w

pushd sigils
tar -czf ../sigils.tar.gz -- *
popd
skopeo copy --digestfile /dev/stdout tarball:sigils.tar.gz docker://ghcr.io/lc-41/sigils
