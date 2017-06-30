# radioApi (Nim)
A web API and front-end for radio streaming with madplay on Linux. The code is written in Nim.
It's a port of the version I wrote [in C some time ago](https://github.com/davidsblog/radioApi) -
but with some improvements.

# WORK IN PROGRESS :-)

I am using this on LEDE (embedded linux) and running it on a tiny router (like the HooToo HT-TM02) with a USB sound adapter.
I simply plug it into a speaker and then control it from my nearest web browser (probably my phone).

## Building
At the moment I'm just using a **Makefile** to build the code.

On a local Linux box you can just use `make` to build the executable, although if you don't have nim
installed you can also do `make docker` instead (which will use a docker container as a compiler).

To cross-compile for the HooToo HT-TM02 running LEDE, you can use `make ht02` ... but *note* this uses a
larger docker image as a cross compiler which means a reasonable download the first time you do it.
After compilation, it will strip and pack the executable. The executable should come out under 70 Kb
which is not bad.

## Running
When running the code, you must be in a directory *containing* the `/public` subdirectory. I normally have
this structure:

```
  /usr/bin/radio
  |
  +-- radioApi
  |
  +-- /public
      |
      + ... (files)
```

...so if you're in `/usr/bin/radio` when you run `radioApi` then all will be fine.

## Deploying to a HooToo HT-TM02
The makefile can also help with deployment, you can use `make ip=192.168.x.x deploy` which will copy
the files to `/usr/bin/radio/` on the target device, you just need to give it the IP address.
**NOTE:** this will _not_ start radioApi when the device boots.

## Dependencies
Before running on LEDE or OpenWrt, some packages are needed.

Do an update first:
`opkg update`

Add the realtime extensions library:
`opkg install librt`

Install USB audio support:
`opkg install kmod-usb-audio`

Then, add the Alsa Utils as well:
`opkg install alsa-utils`

Finally, install Madplay:
`opkg install madplay`

Then, reboot the device before proceeding.
