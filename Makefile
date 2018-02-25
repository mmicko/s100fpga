ifeq ($(OS),Windows_NT)
SILENT_OUT := >nul
EXE	:= .exe
else
SILENT_OUT := >/dev/null
EXE	:=
endif
.PHONY: all clean test_altair test_sdk80

all: build altair.bin

altair.bin: top/top_altair.v rtl/altair.v rtl/jmp_boot.v rtl/mc6850.v rtl/i8080.v rtl/rom_memory.v rtl/ram_memory.v rtl/simpleuart.v
	yosys -q -p "synth_ice40 -top top -blif build/altair.blif" $^
	arachne-pnr -d 5k -p board.pcf build/altair.blif -o build/altair.txt
	icepack build/altair.txt altair.bin

sdk80.bin: top/top_sdk80.v rtl/sdk80.v rtl/i8251.v rtl/i8080.v rtl/rom_memory.v rtl/ram_memory.v rtl/simpleuart.v
	yosys -q -p "synth_ice40 -top top -blif build/sdk80.blif" $^
	arachne-pnr -d 5k -p board.pcf build/sdk80.blif -o build/sdk80.txt
	icepack build/sdk80.txt sdk80.bin

build:
	@mkdir -p build

clean:
	$(RM) -rf build
	$(RM) -f *.bin
	$(RM) -f *.vcd
	$(RM) -f a.out

test_altair: tb/altair_tb.v rtl/altair.v rtl/jmp_boot.v rtl/mc6850.v rtl/i8080.v rtl/rom_memory.v rtl/ram_memory.v rtl/simpleuart.v
	iverilog -D DEBUG $^
	vvp a.out

test_sdk80: tb/sdk80_tb.v rtl/sdk80.v rtl/i8251.v rtl/i8080.v rtl/rom_memory.v rtl/ram_memory.v rtl/simpleuart.v
	iverilog -D DEBUG $^
	vvp a.out
