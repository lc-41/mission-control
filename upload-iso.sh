#!/bin/bash
set -euxo pipefail

sftp -b - ci@titan.voyager.sibr.dev <<EOF
mkdir public_html/$GITHUB_RUN_NUMBER
cd public_html/$GITHUB_RUN_NUMBER
put voyager.iso
EOF

echo "https://titan.voyager.sibr.dev/~ci/$GITHUB_RUN_NUMBER/voyager.iso"
