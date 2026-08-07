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
├── pre.d/             # Pre-install scripts directory (mirrors, keyrings, etc.)
├── post.d/            # Post-install scripts directory
├── modules/           # Optional modules directory
├── apm.conf           # Main package configuration file
├── apm                # Declarative package manager (single-file CLI)
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

### @pkg / @pre / @post Directives

```conf
@pkg apm.d/base.conf     # include a package group file (.conf, parsed recursively)
@pkg apm.d/gnome.conf    # multiple group files are allowed
#@pkg apm.d/desktop.conf # commented out = disabled
@pre pre.d/              # prepare scripts (executed BEFORE system upgrade & install)
@post post.d/            # post scripts (executed AFTER install: services/user config)

[Pacman]
*xorg        # declare a package group: expanded to members for reconcile and install
*fcitx5-im
```

- `@pkg <path>` — include package manifests: only `.conf` files (parsed recursively), scripts are ignored
- `@post <path>` — register post-install scripts (any extension or none)
- `@pre <path>` — register pre-install scripts (any extension or none)
- All three support three forms:
  - `@pkg apm.d/base.conf` — a single file
  - `@post post.d/` — directory (all scripts inside, sorted by name)
  - `@pkg apm.d/*.conf` — glob pattern

Rules: dispatch by extension — `@pkg` takes only `.conf`, `@pre`/`@post` take only non-`.conf` files; **files never referenced by directives are not loaded at all**; an included `.conf` does not inherit the caller's section and must declare its own `[Pacman]`/`[AUR]`; a failing `@pre` script aborts the reconciliation, a failing `@post` script only warns and continues.

**Package Group Declarations `*<group>`:** To declare a package group without listing all members in the config, use `*xorg`. APM expands it to members for reconciliation.

### pre.d Directory

Used for **pre-installation prepare scripts** (e.g., mirror config `archlinuxcn.sh`, network/proxy preparation). Scripts must be enabled via `@pre` in apm.conf and run before package installation during `apm apply`. Returning a non-zero exit code will immediately abort the `apply` process.

### apm.d Directory

Used for group management of packages, containing multiple `.conf` format files, each file can include a group of related packages. For example:

- `gnome.conf` - GNOME desktop environment packages
- `base.conf` - Base system packages

**Note:** Group files only take effect when explicitly included via `@pkg` in apm.conf (`base.conf` and `gnome.conf` are currently included; comment the line to disable). Group files may contain plain package names as well as `*<group>` declarations (e.g. `*xorg` in `gnome.conf`).

## System Configuration

### post.d Directory

Contains configuration scripts (`.sh` or extensionless), used for system configuration and software initialization. Scripts must be enabled via `@post` in apm.conf (currently `@post post.d/`, i.e. all enabled); they then run automatically when changes are applied via `apm apply` (or can be forced with `apm run`).

Implemented configurations include:
- archlinuxcn mirror and keyring configuration (pre.d/archlinuxcn.sh)
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

For first-time use, just reconcile — the AUR helper is auto-detected (or auto-installed when an AUR package needs it):

```bash
./apm apply
```

`apply` will:
1. Run `@pre` prepare scripts (mirrors, keyring import, etc.)
2. Install packages defined in apm.conf and apm.d (upgrades the system first when installs are needed)
3. **Fully declarative reconciliation**: propose removal of every explicitly installed package outside the manifest; prints the real recursive closure and asks for confirmation before removal
4. Run `@post` scripts from post.d (use `--scripts` to force even when no changes)
5. Create the `apm` command alias (via post.d/alias.sh)

### apm Command

The `apm` alias is set in the shell configuration file by post.d/alias.sh; you can then use the `apm` command directly:

| Command / Alias | Description |
|---|---|
| `apm ins`, `install` | fresh system install: trigger Arch Linux interactive installer (`installer.sh`) |
| `apm a`, `apply [-y] [--scripts] [-c <path>]` | reconcile manifest → system (prints diff first, then install/remove) |
| `apm d`, `diff [-c <path>]` | show pending changes |
| `apm st`, `stat`, `status [-c <path>]` | summary of desired vs installed |
| `apm s`, `sync [-y] [-c <path>]` | export installed packages → apm.conf (system → manifest) |
| `apm new`, `gen [-f] [-c <path>]` | generate a apm.conf template (refuses to overwrite existing file) |
| `apm up`, `update`, `upgrade` | full system upgrade (repo + AUR) |
| `apm run`, `exec` | force-run `@post` scripts |
| `apm help`, `-h` | show help (default command) |

Each time `apm apply` is executed, the script will:
1. Compare the manifest with the current system state and print a diff
2. Install newly added packages
3. Remove explicitly installed packages outside the manifest (prints the recursive closure and asks for confirmation, `--yes` to skip)
4. Run post scripts (use `--scripts` to force even when no changes)

### Custom Configuration

apm auto-detects an installed AUR helper (`yay`/`paru`) and falls back to `yay`. Override the backend via environment variable:

```bash
APM_BACKEND=pacman ./apm apply
# After the alias is created, you can also run:
APM_BACKEND=pacman apm
```

Other environment variables:

- `APM_IFACE`: wired NIC name used by post.d/ip.sh and modules/kvm (default `eno1`)

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
