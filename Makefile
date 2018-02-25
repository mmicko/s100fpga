ifeq ($(OS),Windows_NT)
SILENT_OUT := >nul
EXE	:= .exe
else
SILENT_OUT := >/dev/null
EXE	:=
endif

ALTAIR_SRC=rtl/altair.v rtl/jmp_boot.v rtl/mc6850.v rtl/i8080.v rtl/rom_memory.v rtl/ram_memory.v rtl/simpleuart.v
ALTAIR_MEM=roms/altair/turnmon.bin.mem roms/altair/basic4k32.bin.mem roms/altair/tinybasic-1.0.bin.mem

SDK80_SRC=rtl/sdk80.v rtl/i8251.v rtl/i8080.v rtl/rom_memory.v rtl/ram_memory.v rtl/simpleuart.v
SDK80_MEM=roms/sdk80/mcs80.a14.mem

.PHONY: all clean test_altair test_sdk80

all: altair.bin

roms/%.mem: roms/%
	@echo "Converting $@ ..."
	@python roms/rom.py $< > $@

altair.bin: build top/top_altair.v $(ALTAIR_SRC) $(ALTAIR_MEM)
	yosys -q -p "synth_ice40 -top top -blif build/altair.blif" top/top_altair.v $(ALTAIR_SRC)
	arachne-pnr -d 5k -p board.pcf build/altair.blif -o build/altair.txt
	icepack build/altair.txt altair.bin

sdk80.bin: build top/top_sdk80.v $(SDK80_SRC) $(SDK80_MEM)
	yosys -q -p "synth_ice40 -top top -blif build/sdk80.blif" top/top_sdk80.v $(SDK80_SRC)
	arachne-pnr -d 5k -p board.pcf build/sdk80.blif -o build/sdk80.txt
	icepack build/sdk80.txt sdk80.bin

build:
	@mkdir -p build

clean:
	$(RM) -rf build
	$(RM) -f *.bin
	$(RM) -f *.vcd
	$(RM) -f a.out

test_altair: tb/altair_tb.v $(ALTAIR_SRC) $(ALTAIR_MEM)
	iverilog -D DEBUG tb/altair_tb.v $(ALTAIR_SRC)
	vvp a.out

test_sdk80: tb/sdk80_tb.v $(SDK80_SRC) $(SDK80_MEM)
	iverilog -D DEBUG tb/sdk80_tb.v $(SDK80_SRC)
	vvp a.out
