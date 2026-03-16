#!/bin/sh -e

DEBIAN_FRONTEND=noninteractive
DEBCONF_NONINTERACTIVE_SEEN=true

echo 'tzdata tzdata/Areas select Etc' | debconf-set-selections
echo 'tzdata tzdata/Zones/Etc select UTC' | debconf-set-selections
echo "locales locales/default_environment_locale select en_US.UTF-8" | debconf-set-selections
echo "locales locales/locales_to_be_generated multiselect en_US.UTF-8 UTF-8" | debconf-set-selections
rm -f "/etc/locale.gen"

#stable - libconfig11;  bookworm libconfig9  libusbgx2

apt update -qqy
apt upgrade -qqy
apt autoremove -qqy

COMMON_PACKAGES="
    bridge-utils
    dnsmasq
    hostapd
    iptables
    libconfig9
    locales
    modemmanager
    netcat-traditional
    net-tools
    network-manager
    openssh-server
    qrtr-tools
    rmtfs
    sudo
    systemd-timesyncd
    tzdata
    wireguard-tools
    mc
    wpasupplicant
"

apt install -qqy --no-install-recommends $COMMON_PACKAGES

if [ "$RELEASE_TYPE" = "bookworm" ]; then
    apt install -qqy --no-install-recommends libusbgx2
fi

apt clean
rm -rf /var/lib/apt/lists/*

passwd -d root

echo user:1::::/home/user:/bin/bash | newusers
echo 'user ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/user
