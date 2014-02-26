#!/bin/bash

ROOTFS_PATH="/home/lonas/Kernel_Lonas/Nexus5/Hammerhead/ramdisk"

echo "Building Lonas Nexus 5..."

# Cleanup
./clean.sh

# Making .config
make ARCH=arm CROSS_COMPILE=$TOOLCHAIN lonas_defconfig

# Compiling
./build.sh $ROOTFS_PATH
