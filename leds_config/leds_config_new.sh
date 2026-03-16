#!/bin/sh 

echo usb-gadget >  /sys/class/leds/green:mail/trigger
echo phy0tx >  /sys/class/leds/green:wlan/trigger
echo rfkill-any >  /sys/class/leds/blue:status/trigger
