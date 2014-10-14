include .knightos/variables.make

INIT=/bin/fileman

ALL_TARGETS:=$(BIN)count $(BIN)hello $(BIN)gfxdemo $(BIN)pixelmad

$(BIN)count: count/*.asm
	mkdir -p $(BIN)
	$(AS) $(ASFLAGS) --listing $(OUT)count.list count/main.asm $(BIN)count

$(BIN)hello: hello/*.asm
	mkdir -p $(BIN)
	$(AS) $(ASFLAGS) --listing $(OUT)hello.list hello/main.asm $(BIN)hello

$(BIN)gfxdemo: gfxdemo/*.asm
	mkdir -p $(BIN)
	$(AS) $(ASFLAGS) --listing $(OUT)gfxdemo.list gfxdemo/main.asm $(BIN)gfxdemo

$(BIN)pixelmad: pixelmad/*.asm
	mkdir -p $(BIN)
	$(AS) $(ASFLAGS) --listing $(OUT)pixelmad.list pixelmad/main.asm $(BIN)pixelmad

include .knightos/sdk.make
