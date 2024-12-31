Quick edit of the database in boot.img:
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
  