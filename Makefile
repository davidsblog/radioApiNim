NIMC=nim c -d:release
NFLAGS=--os:linux
XFLAGS=--cpu:mipsel --os:linux -d:uClibc
TARGET=radioApi
PACK=upx
PFLAGS=--ultra-brute

# regular local compile
$(TARGET):
	$(NIMC) $(NFLAGS) $(TARGET).nim

# portable (when there's no nim installed locally)
docker:
	docker run --rm -v ${PWD}:/src nimlang/nim /bin/sh -c "cd /src;$(NIMC) $(NFLAGS) $(TARGET).nim"

# cross-compile for the HooToo HT-TM02 with docker
ht02:
	docker run --rm -v ${PWD}:/src davidsblog/openwrt-build-ht-tm02-nim /bin/sh -c "cd /src;$(NIMC) $(XFLAGS) $(TARGET).nim"
	$(PACK) $(TARGET) $(PFLAGS)

# deploy to HooToo - provide the ip address on the command line, eg: make ip=192.168.1.10 deploy
deploy:  ht02
	cp -rf public radio/public
	cp -rf $(TARGET) radio/
	scp -prC radio root@$(ip):/usr/bin/

.PHONY: clean

clean:
	rm -f $(TARGET)
