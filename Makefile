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

ISBC8010_SRC=rtl/isbc8010.v rtl/i8251.v rtl/i8080.v rtl/rom_memory.v rtl/ram_memory.v rtl/simpleuart.v
ISBC8010_MEM=roms/isbc8010/sbc80p.a23.mem roms/isbc8010/sbc80p.a24.mem roms/isbc8010/basic_blc_1.a24.mem roms/isbc8010/basic_blc_2.a25.mem roms/isbc8010/basic_blc_3.a26.mem roms/isbc8010/basic_blc_4.a27.mem

ZEXALL_SRC=rtl/zexall.v rtl/z80/tv80n.v rtl/z80/tv80_reg.v rtl/z80/tv80_mcode.v rtl/z80/tv80_core.v rtl/z80/tv80_alu.v  rtl/rom_memory.v rtl/ram_memory.v rtl/simpleuart.v
ZEXALL_MEM=roms/zexall/zexall-1.bin.mem roms/zexall/zexall-2.bin.mem

.PHONY: all clean test_altair test_sdk80 test_isbc8010 test_zexall

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

isbc8010.bin: build top/top_isbc8010.v $(ISBC8010_SRC) $(ISBC8010_MEM)
	yosys -q -p "synth_ice40 -top top -blif build/isbc8010.blif" top/top_isbc8010.v $(ISBC8010_SRC)
	arachne-pnr -d 5k -p board.pcf build/isbc8010.blif -o build/isbc8010.txt
	icepack build/isbc8010.txt isbc8010.bin

zexall.bin: build top/top_zexall.v $(ZEXALL_SRC) $(ZEXALL_MEM)
	yosys -q -p "synth_ice40 -top top -blif build/zexall.blif" top/top_zexall.v $(ZEXALL_SRC)
	arachne-pnr -d 5k -p board.pcf build/zexall.blif -o build/zexall.txt
	icepack build/zexall.txt zexall.bin

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

test_isbc8010: tb/isbc8010_tb.v $(ISBC8010_SRC) $(ISBC8010_MEM)
	iverilog -D DEBUG tb/isbc8010_tb.v $(ISBC8010_SRC)
	vvp a.out

test_zexall: tb/zexall_tb.v $(ZEXALL_SRC) $(ZEXALL_MEM)
	iverilog -D DEBUG tb/zexall_tb.v $(ZEXALL_SRC)
	vvp a.out
