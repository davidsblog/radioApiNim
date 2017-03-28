# radioApi (Nim)
A web API and front-end for radio streaming with madplay on Linux. The code is written in Nim.
It's a port of the version I wrote in C some time ago (with some improvements).

# VERY MUCH WORK IN PROGRESS :-)

I am using this on OpenWrt and running it on a tiny embedded router (like the HooToo HT-TM02) with a USB sound adapter.
I simply plug it into a speaker and then control it from my nearest web browser.

## Building
At the moment I'm just using a **Makefile** to build the code.

On a local Linux box you can just use `make` to build the executable.

To cross-compile for the HooToo HT-TM02 running OpenWrt, you can use  `make ht02` ... but *note* this uses a docker image
as a cross compile toolchain which means a big docker image will be downloaded the first time.

## Dependencies

Before running on OpenWrt, some packages are needed.

Add the realtime extensions library:
`opkg install librt`

Install USB audio support:
`opkg install kmod-usb-audio`

Then, add the Alsa Utils as well:
`opkg install alsa-utils`

Finally, install Madplay:
`opkg install madplay`

Then, reboot the device.
