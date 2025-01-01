#!/bin/sh 

echo usb-gadget >  /sys/class/leds/green:sms/trigger
echo phy0tx >      /sys/class/leds/green:wlan/trigger
echo phy0radio >   /sys/class/leds/blue:wan_blue/trigger


 