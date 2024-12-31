# Quick edit of the database Device Tree in boot.img.
You must first install: device-tree-compiler, simg2img, img2simg.

- edit test.dts
- run script
  ```shell
  cd boot_repack
  sudo ./build_boot.sh
  ```
- flash boot.bin
  ```shell
  fastboot flash boot boot.bin 
  ```
  
