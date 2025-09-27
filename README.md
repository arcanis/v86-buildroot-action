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

The action installs common build dependencies automatically. If you encounter missing dependencies, they're likely related to specific packages you've added.

### Large Images

If your image becomes too large:
- Remove unnecessary packages from `buildroot-config`
- Use `BR2_TARGET_ROOTFS_*` options to configure filesystem compression
- Consider using `BR2_TOOLCHAIN_EXTERNAL` for smaller toolchain footprint

### Network Issues in v86

Ensure your v86 setup:
- Uses the `inbrowser` network backend
- Has the NE2000 network device configured
- Uses the correct bzImage (not just any Linux kernel)

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