#!/bin/bash
set -euxo pipefail

mkdir -p sigils
youtube-dl -o 'sigils/%(id)s.%(ext)s' -f 247 https://www.youtube.com/watch?v=0et7jJ1zV_w

tar czf sigils.tar.gz sigils
skopeo copy tarball:sigils.tar.gz docker://ghcr.io/lc-41/sigils
