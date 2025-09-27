# V86 Buildroot Action

A GitHub Action to build v86-compatible buildroot images following the community-maintained configuration from [copy/v86#725](https://github.com/copy/v86/issues/725#issuecomment-2631238720).

This action builds a minimal Linux kernel and filesystem image that can be used with the [v86 x86 emulator](https://github.com/copy/v86) for running Linux in the browser.

## Features

- 🚀 **Automated builds**: Complete buildroot compilation process
- 🔧 **Customizable configuration**: Append your own buildroot settings  
- 📁 **File system overlay**: Copy files/directories into the resulting image
- 📦 **Artifact upload**: Automatically saves the built image as a GitHub artifact
- 🌐 **Network ready**: Includes networking support with dnsmasq for DHCP/DNS
- 🛠️ **Based on community config**: Uses the latest tested configuration from the v86 community

## Quick Start

### Basic Usage

```yaml
name: Build V86 Image
on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: arcanis/v86-buildroot-action@v1
```

### Advanced Usage

```yaml
name: Build Custom V86 Image
on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Build V86 Image with Custom Config
        uses: arcanis/v86-buildroot-action@v1
        with:
          buildroot-config: |
            BR2_PACKAGE_PYTHON3=y
            BR2_PACKAGE_NANO=y
            BR2_PACKAGE_HTOP=y
          copy-path: ./my-files
          artifact-name: my-custom-v86-image
          buildroot-version: '2024.05.2'
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `buildroot-config` | Additional buildroot configuration lines to append to the base config | No | `''` |
| `copy-path` | Path to copy into the resulting filesystem (copied to root of filesystem) | No | `''` |
| `buildroot-version` | Buildroot version to use | No | `'2024.05.2'` |
| `artifact-name` | Name for the output artifact | No | `'v86-buildroot-image'` |
| `working-directory` | Working directory for the build | No | `'./build'` |

## Outputs

| Output | Description |
|--------|-------------|
| `artifact-name` | Name of the uploaded artifact |
| `bzimage-path` | Full path to the built bzImage file |

## Configuration Examples

### Adding Packages

To add additional packages to your buildroot image, use the `buildroot-config` input:

```yaml
- uses: arcanis/v86-buildroot-action@v1
  with:
    buildroot-config: |
      # Add Python 3
      BR2_PACKAGE_PYTHON3=y
      BR2_PACKAGE_PYTHON3_PYEXPAT=y
      
      # Add common utilities
      BR2_PACKAGE_NANO=y
      BR2_PACKAGE_HTOP=y
      BR2_PACKAGE_CURL=y
      
      # Add development tools
      BR2_PACKAGE_GCC=y
      BR2_PACKAGE_MAKE=y
```

### Common Package Categories

**Text Editors:**
```
BR2_PACKAGE_NANO=y          # Nano text editor
BR2_PACKAGE_VIM=y           # Vim editor (larger)
```

**System Utilities:**
```
BR2_PACKAGE_HTOP=y          # Process monitor
BR2_PACKAGE_TREE=y          # Directory tree display
BR2_PACKAGE_FILE=y          # File type detection
BR2_PACKAGE_WHICH=y         # Which command
```

**Network Tools:**
```
BR2_PACKAGE_CURL=y          # HTTP client
BR2_PACKAGE_WGET=y          # Web downloader  
BR2_PACKAGE_OPENSSH=y       # SSH client/server
BR2_PACKAGE_DROPBEAR=y      # Lightweight SSH (alternative)
```

**Programming Languages:**
```
BR2_PACKAGE_PYTHON3=y       # Python 3
BR2_PACKAGE_NODEJS=y        # Node.js
BR2_PACKAGE_GO=y            # Go language
BR2_PACKAGE_LUA=y           # Lua language
```

**Development Tools:**
```
BR2_PACKAGE_GCC=y           # GCC compiler
BR2_PACKAGE_MAKE=y          # Make build tool
BR2_PACKAGE_GIT=y           # Git version control
BR2_PACKAGE_STRACE=y        # System call tracer
```

**Libraries:**
```
BR2_PACKAGE_ZLIB=y          # Compression library
BR2_PACKAGE_OPENSSL=y       # SSL/TLS library
BR2_PACKAGE_SQLITE=y        # SQLite database
BR2_PACKAGE_NCURSES=y       # Terminal library
```

### Adding Custom Files

You can copy files or directories into the filesystem using the `copy-path` input:

```yaml
- name: Prepare custom files
  run: |
    mkdir -p custom-files/etc
    echo "welcome to my custom v86 image" > custom-files/etc/motd
    echo '#!/bin/sh\necho "Hello from startup script"' > custom-files/startup.sh
    chmod +x custom-files/startup.sh

- uses: arcanis/v86-buildroot-action@v1
  with:
    copy-path: ./custom-files
```

## Base Configuration

This action is based on the community-maintained configuration from [chschnell's comment](https://github.com/copy/v86/issues/725#issuecomment-2648530139) which includes:

- **Buildroot 2024.05.2** - Stable and tested version
- **Networking support** - NE2000 PCI network driver, DHCP client (udhcpc)
- **DHCP/DNS server** - dnsmasq for inbrowser networking
- **Network testing tools** - iperf for performance testing
- **Basic utilities** - Essential tools and shell environment
- **Optimized kernel** - Minimal configuration suitable for v86 emulation

## Network Configuration

The built image includes networking capabilities:

- **Router IP**: 192.168.86.1 (when using `v86-inbrowser-router` script)
- **DHCP range**: 192.168.86.2 - 192.168.86.254
- **DNS domain**: v86.local
- **Network tools**: ping, wget, iperf for testing

### Starting the network in v86

Boot the image and run:
```bash
# Start as router (for first VM)
v86-inbrowser-router [hostname]

# Or get DHCP lease (for additional VMs)
udhcpc -F [hostname]
```

## Performance

Build times vary depending on the configuration and GitHub runner resources:
- **Basic build**: ~15-30 minutes
- **With additional packages**: ~20-45 minutes
- **Parallel compilation**: Uses all available CPU cores (`nproc`)

The resulting image is typically 5-15MB depending on included packages.

## Troubleshooting

### Build Fails with Missing Dependencies

The action installs common build dependencies automatically. If you encounter missing dependencies, they're likely related to specific packages you've added. Common additional dependencies:

```yaml
- name: Install additional dependencies
  run: |
    sudo apt-get update
    sudo apt-get install -y python3-dev libssl-dev

- uses: arcanis/v86-buildroot-action@v1
  with:
    buildroot-config: |
      BR2_PACKAGE_OPENSSL=y
      BR2_PACKAGE_PYTHON3=y
```

### Large Images

If your image becomes too large (>50MB), consider:
- Remove unnecessary packages from `buildroot-config`
- Use `BR2_TARGET_ROOTFS_*` options to configure filesystem compression:
  ```
  BR2_TARGET_ROOTFS_EXT2_SIZE="16M"
  BR2_TARGET_ROOTFS_EXT2_COMPRESS=y
  ```
- Consider using `BR2_TOOLCHAIN_EXTERNAL` for smaller toolchain footprint

### Network Issues in v86

Ensure your v86 setup:
- Uses the `inbrowser` network backend
- Has the NE2000 network device configured  
- Uses the correct bzImage (not just any Linux kernel)
- For networking between VMs, one must run `v86-inbrowser-router` first

### Build Timeouts

GitHub Actions has a 6-hour timeout limit. If builds consistently timeout:
- Remove large packages (compilers, development tools)
- Use external toolchain: `BR2_TOOLCHAIN_EXTERNAL=y`
- Consider using a cached intermediate build

### Configuration Validation

To validate your buildroot configuration before building:
```bash
# Download just the config files
curl -L -o config-buildroot.txt "https://gist.githubusercontent.com/chschnell/22345dcc8d3bce1c577f853edd2ff598/raw/config-buildroot_20250203.txt"

# Append your custom config
echo "BR2_PACKAGE_YOUR_PACKAGE=y" >> config-buildroot.txt

# Check for conflicts (requires local buildroot)
make oldconfig
```

## Development

To test this action locally:

```bash
# Clone this repository
git clone https://github.com/arcanis/v86-buildroot-action.git
cd v86-buildroot-action

# Set environment variables
export BUILDROOT_VERSION="2024.05.2"
export ARTIFACT_NAME="test-image"
export WORKING_DIR="./test-build"

# Run the build script
./entrypoint.sh
```

## Contributing

Contributions are welcome! Please:
1. Test your changes thoroughly
2. Update documentation if needed
3. Follow the existing code style
4. Submit a pull request with clear description

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [copy/v86](https://github.com/copy/v86) - The amazing x86 emulator that runs Linux in browsers
- [chschnell](https://github.com/chschnell) - For the detailed buildroot configuration and networking setup
- [SuperMaxusa](https://github.com/SuperMaxusa) - For configuration improvements and testing
- [Buildroot project](https://buildroot.org/) - For the excellent embedded Linux build system