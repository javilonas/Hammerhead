#!/bin/bash

cp arch/arm/configs/lonas_defconfig .config;

echo "#################### Preparando Entorno ####################"
export KERNELDIR=`readlink -f .`
export RAMFS_SOURCE=`readlink -f $KERNELDIR/ramdisk`
export USE_SEC_FIPS_MODE=true

echo "kerneldir = $KERNELDIR"
echo "ramfs_source = $RAMFS_SOURCE"

if [ "${1}" != "" ];then
  export KERNELDIR=`readlink -f ${1}`
fi

# Set Default Path
TOP_DIR=$PWD
KERNEL_PATH="/home/lonas/Kernel_Lonas/Nexus5/Hammerhead"

# Set toolchain and root filesystem path
TOOLCHAIN="/home/lonas/Kernel_Lonas/toolchains/android-ndk-r9c/toolchains/arm-linux-androideabi-4.8/prebuilt/linux-x86/bin/arm-linux-androideabi-"
RAMFS_TMP="/home/lonas/Kernel_Lonas/tmp/ramfs-source-nexus5"

ROOTFS_PATH=$1

# Exports
export KERNEL_VERSION="Lonas-KL-0.1"
export KERNELDIR=$KERNEL_PATH

# Permisos
chmod 644 $ROOTFS_PATH/*.rc
chmod 750 $ROOTFS_PATH/init*
chmod 640 $ROOTFS_PATH/fstab*
chmod 644 $ROOTFS_PATH/default.prop
chmod 771 $ROOTFS_PATH/data
chmod 755 $ROOTFS_PATH/dev
chmod 755 $ROOTFS_PATH/proc
chmod 750 $ROOTFS_PATH/sbin
chmod 750 $ROOTFS_PATH/sbin/*
chmod 755 $ROOTFS_PATH/sys
chmod 755 $ROOTFS_PATH/system

find . -type f -name '*.h' -exec chmod 644 {} \;
find . -type f -name '*.c' -exec chmod 644 {} \;
find . -type f -name '*.py' -exec chmod 755 {} \;
find . -type f -name '*.sh' -exec chmod 755 {} \;
find . -type f -name '*.pl' -exec chmod 755 {} \;

# Compile
make -j`grep 'processor' /proc/cpuinfo | wc -l` ARCH=arm CROSS_COMPILE=$TOOLCHAIN >> compile.log 2>&1 || exit -1

# Recompile to make modules working
make -j`grep 'processor' /proc/cpuinfo | wc -l` ARCH=arm CROSS_COMPILE=$TOOLCHAIN || exit -1

echo "#################### Update Ramdisk ####################"
# Copy Kernel Image
rm -f $KERNEL_PATH/releasetools/tar/$KERNEL_VERSION.tar
rm -f $KERNEL_PATH/releasetools/zip/$KERNEL_VERSION.zip
cp -f $KERNEL_PATH/arch/arm/boot/zImage-dtb .

rm -rf $RAMFS_TMP
rm -rf $RAMFS_TMP.cpio
rm -rf $RAMFS_TMP.cpio.gz
rm -rf $KERNELDIR/*.cpio
rm -rf $KERNELDIR/*.cpio.gz
cd $ROOTFS_PATH
cp -ax $ROOTFS_PATH $RAMFS_TMP
find $RAMFS_TMP -name .git -exec rm -rf {} \;
find $RAMFS_TMP -name EMPTY_DIRECTORY -exec rm -rf {} \;
find $RAMFS_TMP -name .EMPTY_DIRECTORY -exec rm -rf {} \;
rm -rf $RAMFS_TMP/tmp/*
rm -rf $RAMFS_TMP/.hg

echo "#################### Build Ramdisk ####################"
cd $RAMFS_TMP
find . | fakeroot cpio -o -H newc > $RAMFS_TMP.cpio 2>/dev/null
ls -lh $RAMFS_TMP.cpio
gzip -9 -f $RAMFS_TMP.cpio

echo "#################### Compilar Kernel ####################"
cd $KERNELDIR

nice -n 10 make -j6 ARCH=arm CROSS_COMPILE=$TOOLCHAIN zImage-dtb || exit 1

echo "#################### Generar boot.img ####################"
# Make boot.img
./mkbootimg --base 0 --pagesize 2048 --kernel_offset 0x00008000 --ramdisk_offset 0x02900000 --second_offset 0x00f00000 --tags_offset 0x02700000 --cmdline 'console=ttyHSL0,115200,n8 androidboot.hardware=hammerhead user_debug=31 msm_watchdog_v2.enable=1' --kernel zImage-dtb --ramdisk $RAMFS_TMP.cpio.gz -o boot.img

echo "#################### Preparando flasheables ####################"
# Copy boot.img
cp boot.img $KERNEL_PATH/releasetools/zip
cp boot.img $KERNEL_PATH/releasetools

# Creating flashable zip and renaming boot.img
cd $KERNEL_PATH/releasetools/zip
zip -0 -r $KERNEL_VERSION.zip *
cd ..
mv boot.img $KERNEL_VERSION.img

# Cleanup
rm $KERNEL_PATH/releasetools/zip/boot.img
rm $KERNEL_PATH/zImage-dtb
rm -rf /home/lonas/Kernel_Lonas/tmp/ramfs-source-nexus5
rm /home/lonas/Kernel_Lonas/tmp/ramfs-source-nexus5.cpio.gz
echo "#################### Terminado ####################"
