#!/usr/bin/env bash

# Define command exec sucess checker.
check_success(){
  if [ $? -ne 0 ]; then
    echo "Error occurred, exiting..."
    exit 1
  fi
}


# 0.1 Read args

hostname=""
password=""
user=""

while getopts ":h:p:u:" opt
do
  case $opt in
    h)
      hostname=$OPTARG
      ;;
    p)
      password=$OPTARG
      ;;
    p)
      user=$OPTARG
      ;;
  esac 
done
shift $(($OPTIND - 1)) # Remove option args, only leave /dev/**

disk=$1

# 0.2 Read disk to install
if [ -z "$disk" ] ; then
    echo "Please specify a disk to install! usage: $0 -h hostname -u user -p password /dev/sda"
    exit 0
fi

echo -ne "\033[31mThis script will erase the disk you provide $disk !!! Please confirm to continue.\033[0m [y/N]"
read -r input

case $input in
  [yY][eE][sS]|[yY])
    # echo "Read for hostname..."
    ;;
  *)
    echo "Exiting..."
    exit 0
    ;;
esac


if [ -z "$hostname" ] ; then
  read -r -p "You dont specify hostname by arg -h, will use random hostname. Please confirm to continue or input hostname. [y/N/hostname] " input

  case $input in
    [yY][eE][sS]|[yY])
      hostname="archlinux"
      echo "Continue..."
      ;;
    [nN][oO]|[nN])
      echo "Exiting..."
      exit 0
      ;;
    *)
      hostname=$input
      ;;
  esac
fi

# 0.3. Determine if the hard drive is NVMe, and set the suffix for the partition.
disk_suffix=""
is_nvme=false
if [[ "$disk" =~ ^\/dev\/nvme.* ]]; then
  disk_suffix="p"
  is_nvme=true
  echo 'nvme disk'
fi

echo "1. Update the system clock"
timedatectl
check_success


echo "2. Partition the disks"
wipefs -af $disk 
check_success
parted $disk -- mklabel gpt
check_success

# boot and EFI partition
parted $disk -- mkpart ESP fat32 1MiB 1025MiB
check_success
parted $disk -- set 1 esp on
check_success

# home partition
parted $disk -- mkpart primary ext4 1025MiB 50%
check_success

# root partition

if [ is_nvme ]; then
  parted $disk -- mkpart primary ext4 50% 95%
else
  parted $disk -- mkpart primary ext4 50% 100%
fi
check_success

root=${disk}${disk_suffix}3
home=${disk}${disk_suffix}2
boot=${disk}${disk_suffix}1

wipefs -af $boot 
mkfs.fat -F32 $boot
check_success
wipefs -af $root 
mkfs.ext4 $root
check_success
wipefs -af $home 
mkfs.ext4 $home
check_success


echo "3. Mount the file systems"
mount $root /mnt
check_success
mount --mkdir $boot /mnt/boot
check_success
mount --mkdir $home /mnt/home
check_success

echo "4.Installation base system"
# sed -i '1 i Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist #插入到第一行
sed -i '0,/Server = .*/i\Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist # 插入到第一个匹配行前
# awk '/Server = .*/ && !done { print "Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch"; done=1 } 1' /etc/pacman.d/mirrorlist
pacstrap -K /mnt base linux linux-firmware base-devel grub efibootmgr sudo git networkmanager archlinux-keyring



echo "5. Configure the system"
genfstab -U /mnt >> /mnt/etc/fstab


# shell can not continue after chroot, make a new script to continue.
cat >> /mnt/configure.sh << EFO
#!/usr/bin/env bash

echo "5.1 Chroot in the system and configure"
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc
locale-gen
echo $hostname > /etc/hostname
echo "5.2 Install bootloader"
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id='Arch Linux'
grub-mkconfig -o /boot/grub/grub.cfg
mkinitcpio -P

echo "5.3 Set root password"
if [ -z "$password" ] ; then 
  # default password 0000
  password="0000"
fi
echo "root:$password" | chpasswd

echo "5.4 Add user $user, and confiure sudo"
if [ -n "$user" ] ; then
  useradd -mN -g users -s /bin/bash -p $password $user
  echo "$user ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/$user
fi
exit 0
EFO

chmod +x /mnt/configure.sh
arch-chroot /mnt /bin/bash -c "./configure.sh"
rm /mnt/configure.sh
umount -a

echo "Install finished. Your user [root] and [$user] password is $password ."

