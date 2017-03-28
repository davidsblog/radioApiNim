NIMC=nim c
NFLAGS=--os:linux
XFLAGS=--cpu:mipsel --os:linux -d:uClibc
TARGET=radioApi
PACK=upx
PFLAGS=--ultra-brute

$(TARGET):
	$(NIMC) $(NFLAGS) $(TARGET).nim

ht02: $(TARGET)
	docker run --rm -v ${PWD}:/src davidsblog/openwrt-build-ht-tm02-nim /bin/sh -c "cd /src;$(NIMC) $(XFLAGS) $(TARGET).nim"
	$(PACK) $(TARGET) $(PFLAGS)

.PHONY: clean

clean:
	rm -f $(TARGET)
