#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Arch Linux Installer — 单脚本模块化版本
# =============================================================================
# 用法: 见 usage() 或运行 --help
# 理念: 函数即阶段，每阶段幂等，先验证后执行，支持断点续跑
# =============================================================================

# ---------------------------------------------------------------------------
# 阶段标记目录 — 记录每个阶段是否已完成（用于幂等 + 断点续跑）
# ---------------------------------------------------------------------------
readonly STATE_DIR="/tmp/.install-steps"

# =============================================================================
# 辅助函数
# =============================================================================

log_info()  { printf "\033[32m[INFO]\033[0m  %s\n" "$*"; }
log_step()  { printf "\033[34m[STEP]\033[0m  %s\n" "$*"; }
log_warn()  { printf "\033[33m[WARN]\033[0m  %s\n" "$*" >&2; }
log_error() { printf "\033[31m[ERROR]\033[0m %s\n" "$*" >&2; }

# 确认提示
confirm() {
  local prompt="$1" input
  printf "\033[33m%s\033[0m [y/N] " "$prompt"
  read -r input
  case "$input" in
    [yY][eE][sS] | [yY]) return 0 ;;
    *) return 1 ;;
  esac
}

# 幂等标记：检查阶段是否已完成
state_done()   { [ -f "$STATE_DIR/$1" ]; }
state_mark()   { mkdir -p "$STATE_DIR" && touch "$STATE_DIR/$1"; }
state_clear()  { rm -rf "$STATE_DIR"; }

# 运行阶段：只有未完成时才执行，失败时自动退出
run_phase() {
  local name="$1" label="$2"; shift 2

  if state_done "$name"; then
    log_info "[$name] 已完成，跳过"
    return 0
  fi

  log_step "=== $label ==="
  "$@"
  state_mark "$name"
  log_info "[$name] ✓ 完成"
}

# 在 chroot 中执行命令
chroot_run() {
  arch-chroot /mnt /bin/bash -e -c "$*"
}

# 获取分区后缀（NVMe/MMC 需要 p 前缀）
disk_part_suffix() {
  if [[ "$1" =~ [0-9]$ ]]; then echo "p"; else echo ""; fi
}

# =============================================================================
# 阶段 1: 环境准备
# =============================================================================

phase_prepare() {
  log_info "同步系统时钟"
  timedatectl set-ntp true 2>/dev/null || true
}

# =============================================================================
# 阶段 2: 磁盘分区与格式化
# =============================================================================

phase_disk() {
  local disk="$1"
  local suffix

  # 重做磁盘分区，所有历史阶段标记失效
  state_clear

  suffix=$(disk_part_suffix "$disk")

  log_info "清理磁盘 $disk"
  wipefs -af "$disk"
  parted -s "$disk" -- mklabel gpt

  log_info "创建分区"
  parted -s "$disk" -- mkpart ESP fat32 1MiB 1025MiB
  parted -s "$disk" -- set 1 esp on
  parted -s "$disk" -- mkpart root ext4 1025MiB 50%
  parted -s "$disk" -- mkpart home ext4 50% 100%

  udevadm settle 2>/dev/null || { sleep 2; udevadm settle 2>/dev/null || true; }

  local boot="${disk}${suffix}1"
  local root="${disk}${suffix}2"
  local home="${disk}${suffix}3"

  log_info "格式化分区"
  wipefs -af "$boot" "$root" "$home"
  mkfs.fat -F32 "$boot"
  mkfs.ext4 -F "$root"
  mkfs.ext4 -F "$home"

  log_info "挂载分区"
  mount "$root" /mnt
  mount --mkdir "$boot" /mnt/boot
  mount --mkdir "$home" /mnt/home
}

# =============================================================================
# 阶段 3: 安装基础系统
# =============================================================================

phase_install() {
  log_info "优化镜像源"
  if command -v reflector >/dev/null 2>&1; then
    reflector --country CN --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
  elif curl -sSL 'https://archlinux.org/mirrorlist/?country=CN&protocol=https' -o /etc/pacman.d/mirrorlist 2>/dev/null; then
    sed -i 's/#Server/Server/' /etc/pacman.d/mirrorlist
  fi

  log_info "执行 pacstrap（这可能需要几分钟）"
  # 与 apm.d/base.conf 的 [Pacman] 段保持一致
  pacstrap -K /mnt base linux linux-firmware linux-headers base-devel \
    grub efibootmgr sudo vim git networkmanager openssh archlinux-keyring
}

# =============================================================================
# 阶段 4: 基础系统配置
# =============================================================================

phase_configure() {
  local hostname="$1" password="$2"

  log_info "生成 fstab"
  genfstab -U /mnt >/mnt/etc/fstab

  log_info "配置时区与语言"
  chroot_run "ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime"
  chroot_run "hwclock --systohc"
  chroot_run "sed -i 's/#\?en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen"
  chroot_run "locale-gen"
  chroot_run "echo 'LANG=en_US.UTF-8' > /etc/locale.conf"

  log_info "配置主机名"
  chroot_run "echo '$hostname' > /etc/hostname"
  # 引号定界符 HOSTS: 内层 shell 不对内容做二次展开（hostname 已经 validate 白名单校验）
  chroot_run "cat > /etc/hosts <<'HOSTS'
127.0.0.1   localhost
::1         localhost
127.0.1.1   $hostname.localdomain $hostname
HOSTS"

  log_info "设置 root 密码"
  # 经 stdin 传递, 避免密码拼进 shell 字符串（特殊字符断裂/cmdline 暴露）
  printf 'root:%s\n' "$password" | arch-chroot /mnt chpasswd
}

# =============================================================================
# 阶段 5: 用户创建
# =============================================================================

phase_user() {
  local user="$1" password="$2"

  [ -z "$user" ] && { log_info "未指定用户，跳过"; return 0; }

  log_info "创建用户 $user"
  chroot_run "id -u '$user' >/dev/null 2>&1 || useradd -m -G wheel -s /bin/bash '$user'"
  printf '%s:%s\n' "$user" "$password" | arch-chroot /mnt chpasswd

  chroot_run "echo '$user ALL=(ALL:ALL) NOPASSWD:ALL' > /etc/sudoers.d/$user"
  chroot_run "chmod 0440 /etc/sudoers.d/$user"
  # 校验失败即回滚: 损坏的 sudoers 会导致所有 sudo 调用失败
  if ! chroot_run "visudo -cf /etc/sudoers.d/$user" >/dev/null; then
    log_error "sudoers 校验失败，已回滚 /etc/sudoers.d/$user"
    chroot_run "rm -f /etc/sudoers.d/$user"
    return 1
  fi
}

# =============================================================================
# 阶段 6: 引导安装
# =============================================================================

phase_bootloader() {
  local disk="$1"

  if [ -d /sys/firmware/efi/efivars ]; then
    log_info "安装 GRUB (UEFI 模式)"
    chroot_run "grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id='Arch Linux' --removable"
  else
    log_info "未检测到 UEFI 环境，安装 GRUB (Legacy BIOS 模式)"
    if [ -n "$disk" ]; then
      chroot_run "grub-install --target=i386-pc '$disk'"
    else
      log_warn "BIOS 模式下未指定磁盘设备，跳过 grub-install"
    fi
  fi

  log_info "重新生成 initramfs"
  chroot_run "mkinitcpio -P"

  log_info "生成 GRUB 配置"
  chroot_run "grub-mkconfig -o /boot/grub/grub.cfg"
}

# =============================================================================
# 阶段 7: 服务与调优
# =============================================================================

phase_tuning() {
  log_info "启用 NetworkManager"
  chroot_run "systemctl enable NetworkManager"

  log_info "创建 swapfile（动态大小）"
  chroot_run '
    if [ ! -f /swapfile ]; then
      available=$(df / --output=avail | tail -1)
      swap_mib=$((available * 10 / 1024 / 100))
      if [ $swap_mib -gt 4096 ]; then swap_mib=4096; fi
      if [ $swap_mib -lt 512 ]; then swap_mib=512; fi
      fallocate -l "${swap_mib}M" /swapfile 2>/dev/null ||
        dd if=/dev/zero of=/swapfile bs=1M count=$swap_mib status=progress
      chmod 600 /swapfile
      mkswap /swapfile
    fi
    grep -q "/swapfile" /etc/fstab || echo "/swapfile none swap defaults 0 0" >> /etc/fstab
  '
}

# =============================================================================
# 验证
# =============================================================================

validate() {
  local disk="$1" manually_mount="$2" hostname="$3" user="$4" password="$5"
  local errors=0

  log_step "=== 前置验证 ==="

  if [ "$EUID" -ne 0 ]; then
    log_error "必须以 root 运行"
    errors=$((errors + 1))
  fi

  if [ "$manually_mount" = false ]; then
    if [ -z "$disk" ]; then
      log_error "未指定磁盘设备（使用 -D 可跳过）"
      errors=$((errors + 1))
    elif [ ! -b "$disk" ]; then
      log_error "磁盘设备不存在: $disk"
      errors=$((errors + 1))
    fi
  else
    mountpoint -q /mnt || { log_error "手动挂载模式但 /mnt 未挂载"; errors=$((errors + 1)); }
  fi

  if [ -z "$hostname" ]; then
    log_warn "未指定主机名，将使用随机值"
  elif ! [[ "$hostname" =~ ^[a-zA-Z0-9-]+$ ]]; then
    log_error "主机名只能包含字母、数字和连字符: $hostname"
    errors=$((errors + 1))
  fi

  if [ -n "$user" ] && ! [[ "$user" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    log_error "用户名不合法（小写字母开头, 仅含小写字母/数字/下划线/连字符）: $user"
    errors=$((errors + 1))
  fi

  if [ -z "$password" ]; then
    log_info "未指定密码，将自动生成随机密码"
  fi

  # 检查必要命令
  local cmds=(wipefs parted mkfs.fat mkfs.ext4 pacstrap arch-chroot)
  for cmd in "${cmds[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      log_error "命令未找到: $cmd（确认是否在 archiso 环境中运行）"
      errors=$((errors + 1))
    fi
  done

  if [ "$errors" -gt 0 ]; then
    log_error "验证失败，共 $errors 个错误"
    exit 1
  fi

  log_info "验证通过"
}

# =============================================================================
# 使用说明
# =============================================================================

usage() {
  cat <<EOF
用法: $0 [选项] [磁盘设备]

选项:
  -h <hostname>    设置主机名
  -u <username>    创建普通用户
  -p <password>    设置密码（未指定则自动生成）
  -D               手动挂载模式（跳过分区和格式化）
  --from <phase>   从指定阶段开始（prepare/disk/install/configure/user/bootloader/tuning）
  --dry-run        只验证不执行
  --help           显示此帮助

示例:
  $0 -h mybox -u arch -p secret /dev/sda
  $0 -D -h mybox -u arch -p secret
  $0 --from disk -h mybox /dev/sda
EOF
  exit 0
}

# =============================================================================
# 入口
# =============================================================================

main() {
  # ---- 默认配置 ----
  local disk=""
  local hostname=""
  local password=""
  local user=""
  local manually_mount=false
  local from_phase=""
  local dry_run=false

  # ---- 解析参数 ----
  # 需要取值的选项统一检查 $2, 避免 set -u 下缺值报"未绑定变量"
  while [ $# -gt 0 ]; do
    case "$1" in
      -h | -u | -p | --from)
        if [ $# -lt 2 ]; then
          log_error "选项 $1 需要一个参数（--help 查看用法）"
          exit 1
        fi
        case "$1" in
          -h) hostname="$2" ;;
          -u) user="$2" ;;
          -p) password="$2" ;;
          --from) from_phase="$2" ;;
        esac
        shift 2
        ;;
      -D) manually_mount=true; shift ;;
      --dry-run) dry_run=true; shift ;;
      --help) usage ;;
      -*)
        echo "Error: Unknown option $1" >&2
        echo "Try '$0 --help' for more information." >&2
        exit 1
        ;;
      *)  disk="$1"; shift ;;
    esac
  done

  # --from 白名单校验: 非法阶段名会跳过所有阶段却谎报成功
  if [ -n "$from_phase" ]; then
    case "$from_phase" in
      prepare | disk | install | configure | user | bootloader | tuning) ;;
      *)
        log_error "非法阶段名: $from_phase（可选: prepare/disk/install/configure/user/bootloader/tuning）"
        exit 1
        ;;
    esac
    # install 及之后的阶段都写入 /mnt, 跳过 disk 阶段时必须已挂载
    case "$from_phase" in
      prepare | disk) ;;
      *)
        mountpoint -q /mnt || {
          log_error "--from $from_phase 需要 /mnt 已挂载（先手动挂载分区, 或改用 -D 模式）"
          exit 1
        }
        ;;
    esac
  fi

  # 密码自动生成
  [ -z "$password" ] && password="$(cat /proc/sys/kernel/random/uuid)" && password="${password%%-*}"

  # ---- 交互式补全 ----
  if [ "$manually_mount" = false ] && [ -z "$disk" ]; then
    usage
  fi

  if [ -z "$hostname" ]; then
    printf "未指定主机名，输入主机名或回车使用随机值: "
    read -r input || input=""
    if [ -z "$input" ]; then
      uid=$(cat /proc/sys/kernel/random/uuid)
      hostname="arch-${uid%%-*}"
    else
      hostname="$input"
    fi
    log_info "主机名: $hostname"
  fi

  # ---- 确认 ----
  # 仅当 disk 阶段真正会执行时才询问清盘（--from 跳过 disk 时不碰磁盘）
  local disk_will_run=true
  [ "$manually_mount" = true ] && disk_will_run=false
  if [ -n "$from_phase" ] && [ "$from_phase" != prepare ] && [ "$from_phase" != disk ]; then
    disk_will_run=false
  fi
  if [ "$disk_will_run" = true ]; then
    confirm "磁盘 $disk 上的所有数据将被清空，确认继续？" || {
      log_info "已取消"
      exit 0
    }
  fi

  # ---- 验证 ----
  validate "$disk" "$manually_mount" "$hostname" "$user" "$password"

  # ---- 干跑模式 ----
  if [ "$dry_run" = true ]; then
    log_info "干跑模式，验证通过，未执行任何操作"
    exit 0
  fi

  # ---- 阶段调度 ----
  local skip=true
  local phases=(
    "prepare:环境准备"
    "disk:磁盘分区"
    "install:基础系统安装"
    "configure:系统配置"
    "user:用户创建"
    "bootloader:引导安装"
    "tuning:服务与调优"
  )

  for entry in "${phases[@]}"; do
    local name="${entry%%:*}"
    local label="${entry#*:}"

    # --from 支持：匹配到指定阶段后开始执行
    if [ -n "$from_phase" ]; then
      if [ "$skip" = true ] && [ "$name" != "$from_phase" ]; then
        log_info "[$name] 跳过（--from $from_phase）"
        continue
      fi
      skip=false
    fi

    case "$name" in
      prepare)    run_phase "$name" "$label" phase_prepare ;;
      disk)       [ "$manually_mount" = false ] && run_phase "$name" "$label" phase_disk "$disk"
                  [ "$manually_mount" = true ] && log_info "[$name] 手动挂载模式，跳过" ;;
      install)    run_phase "$name" "$label" phase_install ;;
      configure)  run_phase "$name" "$label" phase_configure "$hostname" "$password" ;;
      user)       run_phase "$name" "$label" phase_user "$user" "$password" ;;
      bootloader) run_phase "$name" "$label" phase_bootloader "$disk" ;;
      tuning)     run_phase "$name" "$label" phase_tuning ;;
    esac
  done

  # ---- 收尾 ----
  state_clear
  echo ""
  log_info "安装完成！"
  log_info "Root 密码: $password"
  [ -n "$user" ] && log_info "用户 $user 密码: $password"
  log_info "重启后移除安装介质并进入新系统。"
}

main "$@"
