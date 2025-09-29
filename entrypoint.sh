#!/bin/bash
set -euo pipefail

cd /root

echo "🚀 Starting V86 Buildroot build process"

# Default values
BUILDROOT_VERSION="${1}"
BUILDROOT_CONFIG="${2}"
OVERLAY_SOURCE="${3}"
OUTPUT="${4}"
SCRIPT="${5}"

export FORCE_UNSAFE_CONFIGURE=1

echo "🔧 Buildroot version: $BUILDROOT_VERSION"

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

cp ../config-buildroot.txt .config
cp ../config-linux.txt linux-config
cp ../post-build.sh post-build.sh
cp -r ../rootfs-overlay .

chmod +x post-build.sh

# Apply optional build script
if [[ -n "$SCRIPT" ]]; then
    echo "🔧 Applying build script..."
    echo "$SCRIPT" > post-build-user.sh

    chmod +x post-build-user.sh
fi

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
