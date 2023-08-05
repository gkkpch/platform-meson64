#


Note:

```
ln -s /lib/udev/rules.d/80-net-setup-link.rules /etc/udev/rules.d/80-net-setup-link.rules
```
Create a new rule ```/etc/udev/rules.d/70-persistent-net.rules```
```
SUBSYSTEM =="net", ACTION=="add", DRIVERS=="?*", KERNEL=="usb*", NAME="eth%n"
```

Build a service from the following and place it before volumio starting up

```
#!/bin/sh -e

# go to configfs directory for USB gadgets
modprobe libcomposite
mkdir /sys/kernel/config/usb_gadget/radxa
cd /sys/kernel/config/usb_gadget/radxa

echo 0x1d6b > idVendor
echo 0x104 > idProduct

# USB strings, optional
mkdir -p strings/0x409 
echo "Radxa" > strings/0x409/manufacturer
echo "ECM" > strings/0x409/product

# create the (only) configuration
mkdir -p configs/r.1 

# create the (only) function
mkdir -p functions/ecm.usb0

# assign function to configuration
ln -s functions/ecm.usb0/ configs/r.1/

# bind!
echo ff400000.usb > UDC

exit 0
```

