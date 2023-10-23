# APM - Arch Linux Package Manager

Arch Linux 软件包管理

> Manage Arch linux packages like NPM
>
> 像管理 NPM 软件包一样管理 Arch linux 软件

## packages.pkg

主软件包文件, 每行识别为一个软件包。

```shell
obsidian
neofetch
code
```

## packages.d

脚本会查找该文件夹下的`.pkg`文件识别为软件包进行包安装， 可以把一系列的软件包单独分成一个`.pkg`文件放到文件夹下。

## modules

该文件夹下放置包含了复杂设置的软件包，如：`systemd`启动、设置环境变量、增加配置文件等。使用文件夹内脚本可以直接实现软件包的安装和初始化设置。

## 注释

字符`#`后的内容为注释内容。 注释可以为行注释，也可以为行内注释，如：

```shell
# ui theme
capitaine-cursors
papirus-icon-theme # icon theme
catppuccin-fcitx5-git
```

## 安装命令

使用`install.sh`脚本安装。

脚本会对比文件的修改，安装新增软件包并卸载移除软件包。

### setup.sh

会在调用`install.sh`前进行一些系统设置，目前实现了以下内容的设置：

1. 国内软件源的增加
2. `AUR Helper`的安装（`yay`）
3. 默认文件夹挂载等

## 无重复副作用

软件的设置、文件的新增等都需要添加验证方法，以防止内容多次添加等重复副作用。

---

## Arch installer

`arch-installer.sh` 是用来 `Arch Linux` 系统安装的脚本。

用法：

```shell
# arch-installer.sh -h 主机名 -u 用户名 -p 密码 安装磁盘

arch-installer.sh -h hostname -u user -p password /dev/sda

-u 若不指定，则不新建用户
-p 若不指定，则默认密码 0000
```
