#!/bin/bash
set -euo pipefail

echo "📦 Installing dependencies..."

# V86 Buildroot Action Entrypoint
# This script builds a v86-compatible buildroot image following the community configuration
# from https://github.com/copy/v86/issues/725#issuecomment-2631238720

echo "🚀 Starting V86 Buildroot build process"

# Default values
BUILDROOT_VERSION="${1}"
BUILDROOT_CONFIG="${2}"
OVERLAY_SOURCE="${3}"
OUTPUT="${4}"

export FORCE_UNSAFE_CONFIGURE=1

echo "🔧 Buildroot version: $BUILDROOT_VERSION"

# Create config directory
mkdir -p config-v86

echo "⬇️ Downloading configuration files from GitHub Gists..."

# Download the latest v86 config files from GitHub Gists
# Using the most recent configs from chschnell's gists (referenced in the issue)
if ! curl -L --fail --output config-v86/config-buildroot.txt \
    "https://gist.githubusercontent.com/chschnell/22345dcc8d3bce1c577f853edd2ff598/raw/a15e3e089a320e5dac1f7a81c1a95ef34dc67607/config-buildroot_20250203.txt"; then
    echo "❌ Failed to download buildroot config"
    exit 1
fi

if ! curl -L --fail --output config-v86/config-linux.txt \
    "https://gist.githubusercontent.com/chschnell/7c0af26fe9156bb03436f55d1a0b2866/raw/cb44c8c34ac8e32499e7dab3f77f28fc9b4124c3/config-linux_20250203.txt"; then
    echo "❌ Failed to download linux config"
    exit 1
fi

if ! curl -L --fail --output config-v86/rootfs.patch \
    "https://gist.githubusercontent.com/chschnell/9ba411733237bb9daf09575bb066e6f6/raw/73df51d2e1eed24eea58f267b59e5376d22e1da2/rootfs_20250203.patch"; then
    echo "❌ Failed to download rootfs patch"
    exit 1
fi

echo "✅ Configuration files downloaded"

# Download and extract buildroot
echo "⬇️ Downloading Buildroot $BUILDROOT_VERSION..."
BUILDROOT_TAR="buildroot-${BUILDROOT_VERSION}.tar.gz"
if [[ ! -f "$BUILDROOT_TAR" ]]; then
    curl -LO "https://buildroot.org/downloads/${BUILDROOT_TAR}"
fi

echo "📦 Extracting Buildroot..."
tar xf "$BUILDROOT_TAR"
cd "buildroot-${BUILDROOT_VERSION}"

echo "🔧 Installing base configuration files..."
cp ../config-v86/config-buildroot.txt .config
cp ../config-v86/config-linux.txt linux-config

# Apply the rootfs patch
echo "🔧 Applying rootfs patch..."
patch -p1 < ../config-v86/rootfs.patch

# Apply user-provided buildroot configuration
if [[ -n "$BUILDROOT_CONFIG" ]]; then
    echo "🔧 Applying user-provided buildroot configuration..."
    echo "$BUILDROOT_CONFIG" >> .config
    echo "Applied configuration:"
    echo "$BUILDROOT_CONFIG"
fi

# Handle optional file copying
if [[ -n "$OVERLAY_SOURCE" && -d "$OVERLAY_SOURCE" ]]; then
    echo "📂 Copying user files from $OVERLAY_SOURCE..."

    # Copy directory contents; note the trailing dot to include all files and directories
    cp -r /github/workspace/"$OVERLAY_SOURCE"/. rootfs-overlay/
fi

# Apply configuration
echo "🔧 Applying configuration..."
make oldconfig

echo "🏗️ Building bzImage (this may take a while)..."
echo "Build started at: $(date)"

# Build with multiple cores for faster compilation
NPROC=$(nproc)
echo "Using $NPROC parallel jobs"

make -j$NPROC

echo "✅ Build completed at: $(date)"

# Copy bzImage to a standard location
BZIMAGE_PATH="$PWD/output/images/bzImage"

if [[ -f "$BZIMAGE_PATH" ]]; then
    cp "$BZIMAGE_PATH" /github/workspace/"$OUTPUT"
    echo "✅ bzImage copied to: $OUTPUT"

    # Get file size for reporting
    FILE_SIZE=$(ls -lh /github/workspace/"$OUTPUT" | awk '{print $5}')
    echo "📊 Image size: $FILE_SIZE"
else
    echo "❌ Error: bzImage not found at $BZIMAGE_PATH"
    exit 1
fi
