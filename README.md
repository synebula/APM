# APM - Arch Linux Package Manager

Arch Linux 软件包管理

> Manage Arch linux packages like NPM
>
> 像管理 NPM 软件包一样管理 Arch linux 软件
> 纯 shell 实现

## packages.ini

主软件包文件, 每行识别为一个软件包。

```ini
obsidian
neofetch
code
```

### 注释

字符`#`和`;`后的内容为注释内容。 注释可以为行注释，也可以为行内注释，如：

```ini
# ui theme
capitaine-cursors
papirus-icon-theme # icon theme
catppuccin-fcitx5-git
; motrix
```

## packages.d

文件夹包含`.ini`格式文件， 可以把一系列的软件包单独分成一个`.ini`文件放到文件夹下。

## conf.d

文件夹包含`.sh`格式文件，`.sh`脚本文件可以是系统的配置，同时也可以在其中安装和初始化软件包。

_需要避免脚本重复执行副作用_

## modules

该文件夹下放置包含了**可选的**复杂设置的软件包，如：`systemd`启动、设置环境变量、增加配置文件等。使用文件夹内脚本可以直接实现软件包的安装和初始化设置。

_该文件夹下脚本不会在执行`./install.sh`或`apm`时执行，需要手动执行需要的脚本。_

## 安装命令

第一次需要使用`./install.sh`脚本安装，后续可以直接执行`apm`命令。

脚本会对比文件的修改，安装新增软件包并卸载移除软件包。

_可在 install.sh 脚本开头修改 apm 参数来修改脚本使用的包管理程序_

### apm 命令

第一次执行`./install.sh`后会在`~/.bashrc`中设置 alias，后续执行`apm`即可。

### setup.sh

在调用`install.sh`时会先执行`setup.sh`脚本前进行一些系统设置，目前实现了以下内容的设置：

1. 国内软件源的增加
2. `AUR Helper`的安装（`yay`）
3. 默认文件夹挂载等
4. 写入`apm`命令的 alias

## 无重复副作用

软件的设置、文件的新增等都需要添加验证方法，以防止内容多次添加等重复副作用。

---

## Arch installer

`arch-installer.sh` 是用来 `Arch Linux` 系统安装的脚本。

> 该脚本执行 UEFI 安装，若机器不支持该安装方式，请勿执行或修改脚本后执行。

用法：

```shell
# arch-installer.sh -h 主机名 -u 用户名 -p 密码 安装磁盘
# arch-installer.sh -D -h 主机名 -u 用户名 -p 密码

arch-installer.sh -h hostname -u user -p password /dev/sda

-h 主机名
-u 若不指定，则不新建用户
-p 若不指定，则默认密码 0000
-D 不指定安装磁盘，手动挂载需要安装的分区到 /mnt 目录
```
