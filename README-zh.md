# APM - Arch Linux Package Manager

[English Version](README.md)

> 像管理 NPM 软件包一样管理 Arch Linux 软件包
>
> Manage Arch Linux packages like NPM
>
> 纯 Shell 实现的 Arch Linux 软件包管理工具

## 项目简介

APM 是一个简单高效的 Arch Linux 软件包管理工具，它允许您：

- 通过配置文件声明式管理软件包
- 自动安装/卸载软件包
- 分组管理不同类型的软件包
- 自动配置系统和软件
- 提供可选的复杂软件包配置模块

APM 默认使用 `yay` 作为包管理器后端，支持 Pacman 和 AUR 软件包的安装。  
你可以通过配置切换到 `pacman` 或其它 AUR 助手（见「自定义配置」）。

## 项目结构

```
.
├── apm.d/             # 分组软件包配置目录
├── pre.d/             # 前置脚本目录（安装前执行: 源配置、密钥导入等）
├── post.d/            # 后置脚本目录（安装后执行）
├── modules/           # 可选模块目录
├── apm.conf           # 主软件包配置文件
├── apm                # 声明式软件包管理器（单文件 CLI）
└── installer.sh       # Arch Linux 系统全新安装脚本
```

## 配置文件

### apm.conf

主软件包配置文件，每行表示一个软件包。支持分节配置不同来源的软件包：

```conf
[Pacman]
# 官方仓库软件包
zsh
obsidian
vlc

[AUR]
# AUR 软件包
visual-studio-code-bin
wechat-universal-bwrap
```

### 注释语法

使用 `#` 或 `;` 添加注释，支持行注释和行内注释：

```conf
# UI 主题
capitaine-cursors
papirus-icon-theme # 图标主题
; motrix  # 已禁用的软件包
```

### @pkg / @pre / @post 指令

```conf
@pkg apm.d/base.conf     # 引入包组文件（.conf 递归解析）
@pkg apm.d/gnome.conf    # 可引入多个组文件
#@pkg apm.d/desktop.conf # 注释即停用
@pre pre.d/              # 前置脚本（安装前执行: 源配置、密钥导入等）
@post post.d/            # 后置脚本（安装后执行: 服务/用户态配置）

[Pacman]
*xorg        # 声明包组: 展开为成员参与对拍与安装
*fcitx5-im
```

- `@pkg <path>` — 引入包清单文件，只处理 `.conf`（递归解析），不处理脚本
- `@post <path>` — 登记后置脚本（安装后执行，如服务/用户态配置），任意扩展名/无后缀
- `@pre <path>` — 登记前置脚本（安装前执行，如源配置、密钥导入），任意扩展名/无后缀
- 三者均支持三种形式：
  - `@pkg apm.d/base.conf` — 单个文件
  - `@post post.d/` — 目录（取其下全部脚本，按文件名排序展开）
  - `@pkg apm.d/*.conf` — glob 通配

规则：按扩展名分流——`@pkg` 只取 `.conf`，`@pre`/`@post` 只取非 `.conf` 文件；**未经指令引用的文件一律不加载**；被引入的 `.conf` 不继承调用点的 section，需自带 `[Pacman]`/`[AUR]` 声明；前置脚本报错会中断调和流程，后置脚本失败仅告警继续。

**包组声明 `*<组名>`：** 不想在配置里列出组的全部成员时，用 `*xorg` 这种形式声明包组。apm 将其展开为成员参与对拍（缺失成员会补装，已装的不动），删除该行即期望移除该组。元包（如 `base`、`base-devel`）本身是普通包，直接写包名即可；普通行误写组名时会警告并引导使用 `*` 前缀。

### pre.d 目录

用于存放**安装前准备脚本**（如镜像源配置 `archlinuxcn.sh`、网络/代理准备等）。脚本需在 apm.conf 中经 `@pre` 声明启用，在 `apm apply` 执行包安装前优先运行。准备脚本返回非零值时会立即终止 `apply` 过程，防止环境未就绪时带病安装。

### apm.d 目录

用于分组管理软件包，包含多个 `.conf` 格式文件，每个文件可以包含一组相关的软件包。例如：

- `gnome.conf` - GNOME 桌面环境相关软件包
- `base.conf` - 基础软件包（内核、引导器、系统工具等）

**注意：** 组文件需在 apm.conf 中经 `@pkg` 显式引入才生效（`base.conf`、`gnome.conf` 当前已引入，注释即停用）。组文件内既可以用普通包名，也可以用 `*<组名>` 声明包组（如 `gnome.conf` 中的 `*xorg`）。

## 系统配置

### post.d 目录

包含配置脚本（`.sh` 或无后缀），用于系统配置和软件初始化。脚本需在 apm.conf 中经 `@post` 声明启用（当前为 `@post post.d/`，即全部启用），之后会在 `apm apply` 产生变更时自动运行（也可用 `apm run` 强制运行）。

已实现的配置包括：
- 输入法配置 (fcitx)
- 音频系统配置（禁用 wireplumber 闲置挂起）
- 临时目录挂载
- 交换文件配置
- NTP 时间同步
- SSH 服务配置
- 别名设置
- SSD 定期 TRIM (fstrim.timer)
- vim 基础配置
- 固定 IP / 网络唤醒（需 nmcli，可用 `APM_IFACE` 指定网卡，默认 eno1）
- 微信数据目录与 tmpfs 优化

**注意：** 所有配置脚本都设计为可重复执行，不会产生副作用。

### modules 目录

包含可选的复杂软件包配置模块，如：
- Docker 配置
- NVIDIA 驱动配置
- KVM 虚拟化配置
- Samba 文件共享配置
- ZFS 文件系统配置

这些模块需要手动执行，不会在执行 `apm apply` 时自动运行。

## 使用方法

### 安装软件包

首次使用时直接调和即可 — AUR 助手自动检测（需要安装 AUR 包且缺失时会自动引导）：

```bash
./apm apply
```

`apply` 会：
1. 执行 `@pre` 声明的前置脚本（如源配置、密钥导入）
2. 安装 apm.conf 和 apm.d 中定义的软件包（有安装需求时先升级系统）
3. **全量声明式调和**：提议移除清单之外的所有显式安装包，移除前打印真实递归闭包并需确认
4. 执行 `@post` 声明的后置脚本（post.d 目录；无变更时需 `--scripts` 强制执行）
5. 创建 `apm` 命令别名（由 post.d/alias.sh 完成）

### apm 命令

`apm` 别名由 post.d/alias.sh 写入 shell 配置文件，之后可以直接使用 `apm` 命令：

| 命令 / 别名 | 说明 |
|---|---|
| `apm ins`, `install` | 系统全新安装：触发交互式 Arch 系统安装引导 (`installer.sh`) |
| `apm a`, `apply [-y] [--scripts] [-c <path>]` | 调和：清单 → 系统（先打印 diff，再安装/移除） |
| `apm d`, `diff [-c <path>]` | 查看待执行变更 |
| `apm st`, `stat`, `status [-c <path>]` | 期望 vs 已装的摘要 |
| `apm s`, `sync [-y] [-c <path>]` | 导出：系统已装 → apm.conf（反向调和） |
| `apm new`, `gen [-f] [-c <path>]` | 生成 apm.conf 模板（已存在时拒绝覆盖） |
| `apm up`, `update`, `upgrade` | 全系统升级（repo + AUR） |
| `apm run`, `exec` | 强制执行 `@post` 声明的后置脚本 |
| `apm help`, `-h` | 显示帮助（默认命令） |

每次执行 `apm apply` 时，脚本会：
1. 将清单与当前系统状态对拍并打印 diff
2. 安装新增的软件包
3. 移除清单之外的显式安装包（打印递归闭包并需确认，`--yes` 跳过）
4. 执行后置脚本（无变更时需 `--scripts` 强制执行）

### 自定义配置

apm 会自动检测已安装的 AUR 助手（`yay`/`paru`），未找到时默认 `yay`。可以通过环境变量覆盖后端：

```bash
APM_BACKEND=pacman ./apm apply
# 创建别名后也可以这样使用：
APM_BACKEND=pacman apm
```

其它环境变量：

- `APM_IFACE`：post.d/ip.sh 与 modules/kvm 使用的有线网卡名（默认 `eno1`）

## 无重复副作用设计

所有配置脚本都设计为可重复执行，不会产生副作用。每个配置脚本在执行前都会检查是否已经配置，避免重复配置。

---

## Arch Linux 安装脚本 (installer.sh / apm ins)

`installer.sh`（也可通过 `apm ins` / `apm install` 触发）是一个用于自动化全新安装 Arch Linux 系统的脚本。阶段化设计，每阶段幂等，支持断点续跑（阶段标记存于 `/tmp/.install-steps`，续跑需保持 /mnt 挂载或用 `-D` 手动挂载）。

> **注意：** 脚本自动检测 UEFI 环境，未检测到时回退 Legacy BIOS 安装。

### 使用方法

```shell
# 通过 apm 或 installer.sh 直接调用
apm ins -h 主机名 -u 用户名 -p 密码 安装磁盘
./installer.sh -h 主机名 -u 用户名 -p 密码 安装磁盘

# 示例
./installer.sh -h myarch -u alex -p mypassword /dev/sda

# 手动挂载分区
./installer.sh -D -h 主机名 -u 用户名 -p 密码

# 从指定阶段续跑 / 只验证不执行
./installer.sh --from configure -h 主机名 -u 用户名 -p 密码
./installer.sh --dry-run -h 主机名 /dev/sda

# 参数说明
-h 主机名（仅限字母/数字/连字符；若不指定，交互输入或使用随机值）
-u 用户名 (若不指定，则不新建用户)
-p 密码 (若不指定，则自动生成随机密码并在结束时打印)
-D 不指定安装磁盘，手动挂载需要安装的分区到 /mnt 目录
--from <phase> 从指定阶段开始（prepare/disk/install/configure/user/bootloader/tuning）
--dry-run 只做前置验证，不执行任何操作
```

### 安装过程

脚本会自动执行以下步骤：
1. 分区和格式化磁盘 (EFI、根分区和家目录分区)
2. 安装基本系统（pacstrap，镜像源自动优化）
3. 配置系统 (fstab、时区、语言、主机名、root 密码)
4. 创建用户并配置 sudo
5. 安装引导程序（GRUB，UEFI/BIOS 自动选择）
6. 启用网络服务并创建动态大小 swapfile

## 贡献指南

欢迎提交 Issue 和 Pull Request 来改进这个项目。在提交代码前，请确保：

1. 所有脚本都可以重复执行而不产生副作用
2. 配置文件格式符合项目规范
3. 添加适当的注释和文档

## 许可证

本项目采用 MIT 许可证。
