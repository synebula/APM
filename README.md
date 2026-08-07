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

APM uses `yay` as the default package manager backend by default, supporting installation of both Pacman and AUR packages.  
You can switch to `pacman` or other helpers through configuration (see **Custom Configuration**).

## Project Structure

```
.
├── apm.d/             # Grouped package configuration directory
├── pre.d/             # Pre-installation prepare scripts directory (mirrors, keyrings, etc.)
├── conf.d/            # Post-installation configuration script directory
├── modules/           # Optional modules directory
├── apm.conf           # Main package configuration file
├── apm                # Declarative package manager (replaces setup.sh)
├── func.sh            # Utility function library
└── installer.sh       # Arch Linux installation script
```

## Configuration Files

### apm.conf

Main package configuration file, each line represents a package. Supports sectioned configuration for packages from different sources:

```conf
[Pacman]
# Official repo packages
zsh
obsidian
vlc

[AUR]
# AUR packages
visual-studio-code-bin
wechat-universal-bwrap
```

### Comment Syntax

Use `#` or `;` to add comments, supporting both line comments and inline comments:

```conf
# UI themes
capitaine-cursors
papirus-icon-theme # icon theme
; motrix  # disabled package
```

### @include and @prepare Directives

```conf
@prepare pre.d/               # include prepare scripts (executed BEFORE system upgrade & install)
@include apm.d/base.conf   # include a package group file (.conf, parsed recursively)
@include conf.d/                 # include post-install configuration scripts
;@include apm.d/gnome.conf   # commented out = disabled

[Pacman]
*xorg        # declare a package group: expanded to members for reconcile and install
*fcitx5-im
```

- `@prepare <path>` — only processes `.sh` files, executed BEFORE system upgrade & package installation (e.g. mirrors, network setup). If a prepare script fails, reconciliation is aborted.
- `@include <path>` — supports three forms:
  - `@include apm.d/base.conf` — a single file
  - `@include conf.d/` — directory
  - `@include apm.d/*.conf` — glob pattern

Rules: `.conf` files are parsed recursively as package manifests, `.sh` files are registered as configuration scripts; **files never referenced by directives are not loaded at all**; an included `.conf` does not inherit the caller's section and must declare its own `[Pacman]`/`[AUR]`.

**Package Group Declarations `*<group>`:** To declare a package group without listing all members in the config, use `*xorg`. APM expands it to members for reconciliation.

### pre.d Directory

Used for **pre-installation prepare scripts** (e.g., mirror config `archlinuxcn.sh`, network/proxy preparation). Scripts must be enabled via `@prepare` in apm.conf and run before package installation during `apm apply`. Returning a non-zero exit code will immediately abort the `apply` process.

### apm.d Directory

Used for group management of packages, containing multiple `.conf` format files, each file can include a group of related packages. For example:

- `gnome.conf` - GNOME desktop environment packages
- `base.conf` - Base system packages

**Note:** Group files only take effect when explicitly included via `@include` in apm.conf (`base.conf` is included by default, `gnome.conf` is commented out by default). Group files may contain plain package names as well as `*<group>` declarations (e.g. `*xorg` in `gnome.conf`).

## System Configuration

### conf.d Directory

Contains configuration scripts in `.sh` format, used for system configuration and software initialization. Scripts must be enabled via `@include` in apm.conf (currently `@include conf.d/`, i.e. all enabled); they then run automatically when changes are applied via `apm apply` (or can be forced with `apm conf`).

Implemented configurations include:
- archlinuxcn mirror and keyring configuration (conf.d/archlinuxcn.sh)
- Input method configuration (fcitx)
- Audio system configuration (disable wireplumber idle suspend)
- Temporary directory mounting
- Swap file configuration
- NTP time synchronization
- SSH service configuration
- Alias settings
- Periodic SSD TRIM (fstrim.timer)
- Basic vim configuration
- Static IP / Wake-on-LAN (requires nmcli, NIC selectable via `APM_IFACE`, default eno1)
- WeChat data directory and tmpfs optimization

**Note:** All configuration scripts are designed to be repeatable without side effects.

### modules Directory

Contains optional complex package configuration modules, such as:
- Docker configuration
- NVIDIA driver configuration
- KVM virtualization configuration
- Samba file sharing configuration
- ZFS file system configuration

These modules need to be executed manually and will not run automatically when executing `apm apply`.

## Usage

### Installing Packages

For first-time use, bootstrap the package manager, then reconcile:

```bash
./apm init
./apm apply
```

`init` will:
1. Check network connection
2. Verify and autodetect/install AUR helper (yay)
3. Run initial system upgrade

`apply` will:
1. Install packages defined in apm.conf and apm.d (upgrades the system first when installs are needed)
2. **Fully declarative reconciliation**: propose removal of every explicitly installed package outside the manifest; prints the real recursive closure and asks for confirmation before removal
3. Execute configuration scripts in conf.d (only when changes were applied)
4. Create the `apm` command alias (via conf.d/alias.sh)

### apm Command

The `apm` alias is set in the shell configuration file by conf.d/alias.sh; you can then use the `apm` command directly:

| Command / Alias | Description |
|---|---|
| `apm ins`, `install` | fresh system install: trigger Arch Linux interactive installer (`installer.sh`) |
| `apm a`, `apply [--yes] [--conf]` | reconcile manifest → system (prints diff first, then install/remove) |
| `apm d`, `diff` | show pending changes |
| `apm st`, `status` | summary of desired vs installed (default) |
| `apm s`, `sync [--yes]` | export installed packages → apm.conf (system → manifest) |
| `apm new`, `gen [--force]` | generate a apm.conf template (refuses to overwrite existing file) |
| `apm up`, `update`, `upgrade` | full system upgrade (repo + AUR) |
| `apm i`, `init`, `bootstrap` | first-time setup: network check + AUR helper + initial upgrade |
| `apm run`, `conf` | force-run conf.d scripts |
| `apm log`, `logs [n]` | tail audit log (default 30 lines) |

Each time `apm apply` is executed, the script will:
1. Compare the manifest with the current system state and print a diff
2. Install newly added packages
3. Remove explicitly installed packages outside the manifest (prints the recursive closure and asks for confirmation, `--yes` to skip)
4. Execute configuration scripts

### Custom Configuration

apm auto-detects an installed AUR helper (`yay`/`paru`) and falls back to `yay`. Override the backend via environment variable:

```bash
APM_BACKEND=pacman ./apm apply
# After the alias is created, you can also run:
APM_BACKEND=pacman apm
```

Other environment variables:

- `APM_IFACE`: wired NIC name used by conf.d/ip.sh and modules/kvm (default `eno1`)

## No Repeated Side Effects Design

All configuration scripts are designed to be repeatable without side effects. Each configuration script checks if it has already been configured before execution to avoid repeated configuration.

---

## Arch Linux Installation Script (installer.sh / apm ins)

`installer.sh` (can also be invoked via `apm ins` / `apm install`) is a script for automating fresh Arch Linux system installations. Phase-based design: each phase is idempotent and resumable (progress markers live in `/tmp/.install-steps`; resume requires /mnt still mounted, or use `-D` to mount manually).

> **Note:** The script auto-detects UEFI and falls back to Legacy BIOS installation when UEFI is not available.

### Usage

```shell
# Via apm or direct installer.sh execution
apm ins -h hostname -u username -p password installation_disk
./installer.sh -h hostname -u username -p password installation_disk

# Example
./installer.sh -h myarch -u alex -p mypassword /dev/sda

# Manually mount partitions
./installer.sh -D -h hostname -u username -p password

# Resume from a phase / validate only
./installer.sh --from configure -h hostname -u username -p password
./installer.sh --dry-run -h hostname /dev/sda

# Parameter description
-h hostname (letters/digits/hyphens only; prompted or randomized if not specified)
-u username (if not specified, no new user will be created)
-p password (if not specified, a random password is generated and printed at the end)
-D do not specify installation disk, manually mount the partitions to be installed to the /mnt directory
--from <phase> start from a phase (prepare/disk/install/configure/user/bootloader/tuning)
--dry-run run pre-flight validation only, without any changes
```

### Installation Process

The script will automatically perform the following steps:
1. Partition and format the disk (EFI, root partition, and home partition)
2. Install the basic system (pacstrap with optimized mirrorlist)
3. Configure the system (fstab, timezone, locale, hostname, root password)
4. Create user and configure sudo
5. Install the bootloader (GRUB, UEFI/BIOS auto-selected)
6. Enable network services and create a dynamically sized swapfile

## Contribution Guidelines

Issues and Pull Requests are welcome to improve this project. Before submitting code, please ensure:

1. All scripts can be executed repeatedly without side effects
2. Configuration file formats comply with project specifications
3. Add appropriate comments and documentation

## License

This project is licensed under the MIT License.
