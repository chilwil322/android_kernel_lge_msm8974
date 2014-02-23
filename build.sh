#!/bin/bash

#### EXPORT VARIABLES ####
build=/home/chilwil322/android/android_kernel_lge_msm8974
version="3.4.82"
rom="cm"
variant="vs980"
toolchain=~/android/toolchain/bin/arm-eabi-
ccache=$build/scripts/ccache

#### BUILD ZIMAGE ####
echo "Starting build..."
export ARCH=arm
export CCACHE_DIR="/home/chilwil322/.kernelccache"
export CROSS_COMPILE="$ccache $toolchain"
make clean
make vs980_defconfig
script -q ~/Compile.log -c " time make -j4 "

#### BUILD BOOT.IMG ####
echo "Checking for build..."
if [ -f arch/arm/boot/zImage ]; then
	cp arch/arm/boot/zImage output
	find . -name "*.ko" -exec cp {} out/system/lib/modules \;
else
	echo "No zimage found, you have to build first..."
	exit 0
fi
echo "Making boot image..."
./scripts/mkbootimg --kernel output/zImage --ramdisk output/ramdisk.gz --cmdline "console=ttyHSL0,115200,n8 androidboot.hardware=g2 user_debug=31 msm_rtb.filter=0x0" --base 0x00000000 --pagesize 2048 --ramdisk_offset 0x05000000 --tags_offset 0x04800000 --dt output/boot.img-dt -o out/boot.img
echo "Boot.img has been created..."

#### BUILD FLASHABLE ZIP ####
echo "Zipping..."
cd out
zip -r ../burkKernel-"$version"_"$rom"-"$variant".zip .
cd ..
echo "Cleaning up..."
rm -rf output/zImage
rm -rf out/boot.img
echo "Done..."
