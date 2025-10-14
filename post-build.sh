#!/bin/bash
set -euo pipefail

BUILDROOT_TREE=$(pwd)
TARGET_FILESYSTEM="$1"

cd $TARGET_FILESYSTEM

chmod +x etc/init.sh

if [[ -e "$BUILDROOT_TREE/post-build-user.sh" ]]; then
    "$BUILDROOT_TREE/post-build-user.sh"
fi
