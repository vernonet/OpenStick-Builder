#!/bin/sh -e

dtc test.dts -o msm8916-fy-mf800_new.dtb

simg2img boot_orig.bin boot.raw

mkdir -p mnt
mount boot.raw mnt
cp msm8916-fy-mf800_new.dtb mnt/dtbs/qcom/msm8916-fy-mf800.dtb
umount mnt

# create sparse android images 
img2simg boot.raw boot.bin

# copy boot.bin to host
cp boot.bin /mnt/e/4G_LTE/boot.bin


