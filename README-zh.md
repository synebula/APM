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
├── packages.d/        # 分组软件包配置目录
├── conf.d/            # 系统配置脚本目录
├── modules/           # 可选模块目录
├── packages.ini       # 主软件包配置文件
├── setup.sh           # 主安装脚本
├── func.sh            # 工具函数库
└── arch-installer.sh  # Arch Linux 安装脚本
```

## 配置文件

### packages.ini

主软件包配置文件，每行表示一个软件包。支持分节配置不同来源的软件包：

```ini
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

```ini
# UI 主题
capitaine-cursors
papirus-icon-theme # 图标主题
; motrix  # 已禁用的软件包
```

### packages.d 目录

用于分组管理软件包，包含多个 `.ini` 格式文件，每个文件可以包含一组相关的软件包。例如：

- `gnome.ini` - GNOME 桌面环境相关软件包
- `dev.ini` - 开发工具相关软件包

## 系统配置

### conf.d 目录

包含 `.sh` 格式的配置脚本，用于系统配置和软件初始化。这些脚本会在执行 `setup.sh` 时自动运行。

已实现的配置包括：
- 输入法配置 (fcitx)
- 音频系统配置
- 临时目录挂载
- 交换文件配置
- NTP 时间同步
- SSH 服务配置
- 别名设置

**注意：** 所有配置脚本都设计为可重复执行，不会产生副作用。

### modules 目录

包含可选的复杂软件包配置模块，如：
- Docker 配置
- NVIDIA 驱动配置
- KVM 虚拟化配置
- Samba 文件共享配置
- ZFS 文件系统配置

这些模块需要手动执行，不会在执行 `setup.sh` 时自动运行。

## 使用方法

### 安装软件包

首次使用时，执行 `setup.sh` 脚本进行安装：

```bash
./setup.sh
```

脚本会：
1. 检查网络连接
2. 配置软件源
3. 安装 AUR 助手 (yay)
4. 安装 packages.ini 和 packages.d 中定义的所有软件包
5. 执行 conf.d 目录中的所有配置脚本
6. 创建 `apm` 命令别名

### apm 命令

首次执行 `setup.sh` 后，会在 shell 配置文件中设置 `apm` 别名，之后可以直接使用 `apm` 命令更新系统：

```bash
apm
```

每次执行 `apm` 命令时，脚本会：
1. 比较当前配置与上次执行的差异
2. 安装新增的软件包
3. 卸载已移除的软件包
4. 执行配置脚本

### 自定义配置

可以通过两种方式更改使用的包管理器后端：

```bash
# 1. 修改 setup.sh 文件开头的默认后端
apm="yay"  # 可以改为 "pacman" 或其它 AUR 助手

# 2. 通过环境变量在运行时覆盖
APM_BACKEND=pacman ./setup.sh
# 在创建好 apm 别名后，也可以这样使用：
APM_BACKEND=pacman apm
```

## 无重复副作用设计

所有配置脚本都设计为可重复执行，不会产生副作用。每个配置脚本在执行前都会检查是否已经配置，避免重复配置。

---

## Arch Linux 安装脚本

`arch-installer.sh` 是一个用于自动化安装 Arch Linux 系统的脚本。

> **注意：** 该脚本执行 UEFI 安装，若机器不支持该安装方式，请勿执行或修改脚本后执行。

### 使用方法

```shell
# 基本用法
arch-installer.sh -h 主机名 -u 用户名 -p 密码 安装磁盘

# 示例
arch-installer.sh -h myarch -u alex -p mypassword /dev/sda

# 手动挂载分区
arch-installer.sh -D -h 主机名 -u 用户名 -p 密码

# 参数说明
-h 主机名
-u 用户名 (若不指定，则不新建用户)
-p 密码 (若不指定，则默认密码为 0000)
-D 不指定安装磁盘，手动挂载需要安装的分区到 /mnt 目录
```

### 安装过程

脚本会自动执行以下步骤：
1. 分区和格式化磁盘 (EFI、根分区和家目录分区)
2. 挂载文件系统
3. 安装基本系统
4. 配置系统 (时区、语言、主机名等)
5. 安装引导程序
6. 设置用户和密码

## 贡献指南

欢迎提交 Issue 和 Pull Request 来改进这个项目。在提交代码前，请确保：

1. 所有脚本都可以重复执行而不产生副作用
2. 配置文件格式符合项目规范
3. 添加适当的注释和文档

## 许可证

本项目采用 MIT 许可证。
