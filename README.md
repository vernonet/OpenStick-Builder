# OpenStick Image Builder
Image builder for MSM8916 based 4G modem dongles

This builder uses the precompiled [kernel](https://pkgs.postmarketos.org/package/v24.06/postmarketos/aarch64/linux-postmarketos-qcom-msm8916) provided by [postmarketOS](https://postmarketos.org/) for Qualcomm MSM8916 devices.

> [!NOTE]
> This branch generates a `debian` image, use the [alpine branch](https://github.com/kinsamanka/OpenStick-Builder/tree/alpine) for an `alpine` image.

## Build Instructions
### Build locally
This has been tested to work on **Ubuntu 22.04**
- clone
  ```shell
  git clone --recurse-submodules https://github.com/kinsamanka/OpenStick-Builder.git
  cd OpenStick-Builder/
  ```
#### Quick
- build
  ```shell
  cd OpenStick-Builder/
  sudo ./build.sh
  ```
#### Detailed
- install dependencies
  ```shell
  sudo scripts/install_deps.sh
  ```
- build hyp and lk2nd

  these custom bootloader allows basic support for `extlinux.conf` file, similar to u-boot and depthcharge.
  ```shell
  sudo scripts/build_hyp_aboot.sh
  ```
- extract Qualcomm firmware

  extracts the bootloader and creates a new partition table that utilizes the full emmc space
  ```shell
  sudo scripts/extract_fw.sh
  ```
- create rootfs using debootstrap
  ```shell
  sudo scripts/debootstrap.sh
  ```

- build gadget-tools
  ```shell
  sudo scripts/build_gt.sh
  ```
- create images
  ```shell
  sudo scripts/build_images.sh
  ```

The generated firmware files will be stored under the `files` directory

### On the cloud using Github Actions
1. Fork this repo
2. Run the [Build workflow](../../actions/workflows/build.yml)
   - click and run ***Run workflow***
   - once the workflow is done, click on the workflow summary and then download the resulting artifact

## Customizations
Edit [`scripts/setup.sh`](scripts/setup.sh) to add/remove packages. Note that this script is running inside the `chroot` environment.

## Firmware Installation
> [!WARNING]  
> The following commands can potentially brick your device, making it unbootable. Proceed with caution and at your own risk!

> [!IMPORTANT]  
> Make sure to perform a backup of the original firmware using the command `edl rf orig_fw.bin`

### Prerequisites
- [EDL](https://github.com/bkerler/ed)
- Android fastboot tool
  ```
  sudo apt install fastboot
  ```

### Steps
- Enter Qualcom EDL mode using this [guide](https://wiki.postmarketos.org/wiki/Zhihe_series_LTE_dongles_(generic-zhihe)#How_to_enter_flash_mode)
- Backup required partitions

  The following files are required from the original firmware:
  
     - `fsc.bin`
     - `fsg.bin`
     - `modem.bin`
     - `modemst1.bin`
     - `modemst2.bin`
     - `persist.bin`
     - `sec.bin`

  Skip this step if these files are already present
  ```shell
  for n in fsc fsg modem modemst1 modemst2 persist sec; do
      edl r ${n} ${n}.bin
  done
  ```
- Install `aboot`
  ```shell
  edl w aboot aboot.mbn
  ```
- Reboot to fastboot
  ```shell
  edl e boot
  edl reset
  ```
- Flash firmware
  ```shell
  fastboot flash partition gpt_both0.bin
  fastboot flash aboot aboot.mbn
  fastboot flash hyp hyp.mbn
  fastboot flash rpm rpm.mbn
  fastboot flash sbl1 sbl1.mbn
  fastboot flash tz tz.mbn
  fastboot flash boot boot.bin
  fastboot flash rootfs rootfs.bin
  ```
- Restore original partitions
  ```shell
  for n in fsc fsg modem modemst1 modemst2 persist sec; do
      fastboot flash ${n} ${n}.bin
  done
  ```
- Reboot
  ```shell
  fastboot reboot
  ```

## Post-Install
- Network configuration
  
  | wlan0 | |
  | ----- | ---- |
  | ssid | Openstick |
  | password | openstick |
  | ip addr | 192.168.4.1 |

  | usb0 | |
  | ----- | ---- |
  | ip addr | 192.168.5.1 |

- Default user
  
  | | |
  | ----- | ---- |
  | username | user |
  | password | 1 |
 
- If your device is not based on **UZ801**, modify `/boot/extlinux/extlinux.conf` to use the correct devicetree
  ```shell
  sed -i 's/yiming-uz801v3/<BOARD>/' /boot/extlinux/extlinux.conf
  ```

  where `<BOARD>` is
     - `thwc-uf896` for **UF896** boards
     - `thwc-ufi001c` for **UFIxxx** boards
     - `jz01-45-v33` for **JZxxx** boards
     - `fy-mf800` for **MF800** boards

- To maximize the `rootfs` partition
  ```shell
  resize2fs /dev/disk/by-partlabel/rootfs
  ```

- To update the kernel of the `debian` image
  ```shell
  wget -O - http://mirror.postmarketos.org/postmarketos/<branch>/aarch64/linux-postmarketos-qcom-msm8916-<version>.apk \
          | tar xkzf - -C / --exclude=.PKGINFO --exclude=.SIGN* 2>/dev/null
  ```

  Specify the correct `<branch>` and `<version>` values.
  
---------------------------------------------------------------------------------------------------
  
# My personal experience:
Last <a href="https://mega.nz/file/0NhFWAwK#Rz4k5DNquBxdBnS3UWuoM0W1oAnrcMsfw7Lirts4VAQ" rel="nofollow">binary</a>, tested on fy-mf800 board, see instructions above. 
- To set the APN for your cellular network provider:
  ```shell
  sudo nmcli connection modify lte gsm.apn <your_apn>
  sudo nmcli connection up lte
  ```
- To enable RNDIS on **MF800** boards (this is already included in my fork):
  ```shell
  sudo apt update
  sudo apt install  libusbgx2
  sudo gt load --path /etc/gt/templates rndis-os-desc.scheme
  ```
- Controlling LED behavior,for example:
  ```shell
  echo usb-gadget >  /sys/class/leds/green:sms/trigger
  ```
- Adding LED configuration to startup(this is already included in my fork):

  create file leds_config.sh on /home/user 
  ```shell
  #!/bin/sh
  
  echo usb-gadget >  /sys/class/leds/green:sms/trigger
  echo phy0tx >  /sys/class/leds/green:wlan/trigger
  echo phy0radio >  /sys/class/leds/blue:wan_blue/trigger
  ```
  don't forget to make the script executable
  ```shell
  chmod +x leds_config.sh
  ```
  create file "leds_config.service" on /etc/systemmd/system
  ```shell
  [Unit]
  Description=Config Leds
  After=sys-kernel-config.mount

  [Service]
  Type=oneshot
  ExecStart=/home/user/leds_config.sh

  [Install]
  WantedBy=multi-user.target
  ```
  create service
  ```shell
  sudo systemctl enable leds_config
  sudo systemctl reboot 
  ```
- To disable wifi module:
  ```shell
  sudo nmcli radio wifi off  
  ```
- To enable wifi module:
  ```shell
  sudo nmcli radio wifi on  
  ```  
### Build locally
I tried to compile a project on WSL2 Ubuntu 22, errors occurred, you need to run a command:
 ```shell
  sudo update-binfmts --enable
  ```
