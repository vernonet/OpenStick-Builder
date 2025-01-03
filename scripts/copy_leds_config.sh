#!/bin/sh -e


# copy leds config files
cp -a rootfs/home dist/home
cp leds_config/leds_config.sh dist/home/user
chmod +x dist/home/user/leds_config.sh
mkdir -p dist/etc/systemd
mkdir -p dist/etc/systemd/system
mkdir -p dist/etc/systemd/system/multi-user.target.wants
cp leds_config/leds_config.service dist/etc/systemd/system
#cp leds_config/multi-user.target.wants/leds_config.service ${CHROOT}/etc/systemd/system/multi-user.target.wants
ln -s /etc/systemd/system/leds_config.service  dist/etc/systemd/system/multi-user.target.wants/leds_config.service

