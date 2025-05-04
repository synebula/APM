# APM - Arch Linux Package Manager

[中文版](README-zh.md)

> Manage Arch Linux packages like NPM
>
> A pure Shell implementation of Arch Linux package management tool

## Project Introduction

APM is a simple and efficient Arch Linux package management tool that allows you to:

- Declaratively manage packages through configuration files
- Automatically install/uninstall packages
- Group management of different types of packages
- Automatically configure system and software
- Provide optional complex package configuration modules

APM uses `yay` as the default package manager backend, supporting installation of both Pacman and AUR packages.

## Project Structure

```
.
├── packages.d/        # Grouped package configuration directory
├── conf.d/            # System configuration scripts directory
├── modules/           # Optional modules directory
├── packages.ini       # Main package configuration file
├── setup.sh           # Main installation script
├── func.sh            # Utility function library
└── arch-installer.sh  # Arch Linux installation script
```

## Configuration Files

### packages.ini

Main package configuration file, each line represents a package. Supports sectioned configuration for packages from different sources:

```ini
[Pacman]
# Official repository packages
zsh
obsidian
vlc

[AUR]
# AUR packages
visual-studio-code-bin
wechat-universal-bwrap
```

### Comment Syntax

Use `#` or `;` to add comments, supporting line comments and inline comments:

```ini
# UI theme
capitaine-cursors
papirus-icon-theme # Icon theme
; motrix  # Disabled package
```

### packages.d Directory

Used for group management of packages, containing multiple `.ini` format files, each file can include a group of related packages. For example:

- `gnome.ini` - GNOME desktop environment related packages
- `dev.ini` - Development tools related packages

## System Configuration

### conf.d Directory

Contains configuration scripts in `.sh` format, used for system configuration and software initialization. These scripts will run automatically when executing `setup.sh`.

Implemented configurations include:
- Input method configuration (fcitx)
- Audio system configuration
- Temporary directory mounting
- Swap file configuration
- NTP time synchronization
- SSH service configuration
- Alias settings

**Note:** All configuration scripts are designed to be repeatable without side effects.

### modules Directory

Contains optional complex package configuration modules, such as:
- Docker configuration
- NVIDIA driver configuration
- KVM virtualization configuration
- Samba file sharing configuration
- ZFS file system configuration

These modules need to be executed manually and will not run automatically when executing `setup.sh`.

## Usage

### Installing Packages

For first-time use, execute the `setup.sh` script to install:

```bash
./setup.sh
```

The script will:
1. Check network connection
2. Configure software sources
3. Install AUR helper (yay)
4. Install all packages defined in packages.ini and packages.d
5. Execute all configuration scripts in the conf.d directory
6. Create the `apm` command alias

### apm Command

After executing `setup.sh` for the first time, an `apm` alias will be set in the shell configuration file, and you can directly use the `apm` command to update the system:

```bash
apm
```

Each time the `apm` command is executed, the script will:
1. Compare the current configuration with the differences from the last execution
2. Install newly added packages
3. Uninstall removed packages
4. Execute configuration scripts

### Custom Configuration

You can change the package manager used by modifying the `apm` variable at the beginning of the `setup.sh` file:

```bash
# Set the default package manager
apm="yay"  # Can be changed to "pacman" or other package managers
```

## No Repeated Side Effects Design

All configuration scripts are designed to be repeatable without side effects. Each configuration script checks if it has already been configured before execution to avoid repeated configuration.

---

## Arch Linux Installation Script

`arch-installer.sh` is a script for automating the installation of Arch Linux systems.

> **Note:** This script performs a UEFI installation. If your machine does not support this installation method, do not execute it or modify the script before execution.

### Usage

```shell
# Basic usage
arch-installer.sh -h hostname -u username -p password installation_disk

# Example
arch-installer.sh -h myarch -u alex -p mypassword /dev/sda

# Manually mount partitions
arch-installer.sh -D -h hostname -u username -p password

# Parameter description
-h hostname
-u username (if not specified, no new user will be created)
-p password (if not specified, the default password is 0000)
-D do not specify installation disk, manually mount the partitions to be installed to the /mnt directory
```

### Installation Process

The script will automatically perform the following steps:
1. Partition and format the disk (EFI, root partition, and home partition)
2. Mount file systems
3. Install the basic system
4. Configure the system (timezone, language, hostname, etc.)
5. Install the bootloader
6. Set up user and password

## Contribution Guidelines

Issues and Pull Requests are welcome to improve this project. Before submitting code, please ensure:

1. All scripts can be executed repeatedly without side effects
2. Configuration file formats comply with project specifications
3. Add appropriate comments and documentation

## License

This project is licensed under the MIT License.
