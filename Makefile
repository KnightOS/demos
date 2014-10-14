include .knightos/variables.make

INIT=/bin/fileman

ALL_TARGETS:=$(BIN)count $(BIN)hello $(BIN)gfxdemo $(BIN)pixelmad \
	$(APPS)count.app $(APPS)hello.app $(APPS)gfxdemo.app $(APPS)pixelmad.app

$(BIN)count: count/*.asm
	mkdir -p $(BIN)
	$(AS) $(ASFLAGS) --listing $(OUT)count.list count/main.asm $(BIN)count

$(APPS)count.app: count/count.app
	mkdir -p $(APPS)
	cp count/count.app $(APPS)

$(BIN)hello: hello/*.asm
	mkdir -p $(BIN)
	$(AS) $(ASFLAGS) --listing $(OUT)hello.list hello/main.asm $(BIN)hello

$(APPS)hello.app: hello/hello.app
	mkdir -p $(APPS)
	cp hello/hello.app $(APPS)

$(BIN)gfxdemo: gfxdemo/*.asm
	mkdir -p $(BIN)
	$(AS) $(ASFLAGS) --listing $(OUT)gfxdemo.list gfxdemo/main.asm $(BIN)gfxdemo

$(APPS)gfxdemo.app: gfxdemo/gfxdemo.app
	mkdir -p $(APPS)
	cp gfxdemo/gfxdemo.app $(APPS)

$(BIN)pixelmad: pixelmad/*.asm
	mkdir -p $(BIN)
	$(AS) $(ASFLAGS) --listing $(OUT)pixelmad.list pixelmad/main.asm $(BIN)pixelmad

$(APPS)pixelmad.app: pixelmad/pixelmad.app
	mkdir -p $(APPS)
	cp pixelmad/pixelmad.app $(APPS)

include .knightos/sdk.make
