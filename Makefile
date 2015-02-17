include .knightos/variables.make

INIT=/bin/fileman

ALL_TARGETS:=$(BIN)count $(BIN)hello $(BIN)gfxdemo $(BIN)pixelmad \
	$(APPS)count.app $(APPS)hello.app $(APPS)gfxdemo.app $(APPS)pixelmad.app \
	$(SHARE)icons/demos.img

$(BIN)count: count/*.asm
	mkdir -p $(BIN)
	$(AS) $(ASFLAGS) --listing $(OUT)count.list count/main.asm $(BIN)count

$(APPS)count.app: config/count.app
	mkdir -p $(APPS)
	cp config/count.app $(APPS)

$(BIN)hello: hello/*.asm
	mkdir -p $(BIN)
	$(AS) $(ASFLAGS) --listing $(OUT)hello.list hello/main.asm $(BIN)hello

$(APPS)hello.app: config/hello.app
	mkdir -p $(APPS)
	cp config/hello.app $(APPS)

$(BIN)gfxdemo: gfxdemo/*.asm
	mkdir -p $(BIN)
	$(AS) $(ASFLAGS) --listing $(OUT)gfxdemo.list gfxdemo/main.asm $(BIN)gfxdemo

$(APPS)gfxdemo.app: config/gfxdemo.app
	mkdir -p $(APPS)
	cp config/gfxdemo.app $(APPS)

$(BIN)pixelmad: pixelmad/*.asm
	mkdir -p $(BIN)
	$(AS) $(ASFLAGS) --listing $(OUT)pixelmad.list pixelmad/main.asm $(BIN)pixelmad

$(APPS)pixelmad.app: config/pixelmad.app
	mkdir -p $(APPS)
	cp config/pixelmad.app $(APPS)

$(SHARE)icons/demos.img: config/demos.png
	mkdir -p $(SHARE)icons
	kimg -c config/demos.png $(SHARE)icons/demo.img

include .knightos/sdk.make
