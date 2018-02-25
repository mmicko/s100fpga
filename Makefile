ifeq ($(OS),Windows_NT)
SILENT_OUT := >nul
EXE	:= .exe
else
SILENT_OUT := >/dev/null
EXE	:=
endif
.PHONY: all test_altair clean

all: altair.bin

altair.bin:  top/top_altair.v rtl/altair.v rtl/jmp_boot.v rtl/serial_io.v rtl/i8080.v rtl/prom_memory.v rtl/ram_memory.v rtl/simpleuart.v
	yosys -q -p "synth_ice40 -top top -blif altair.blif" $^
	arachne-pnr -d 5k -p board.pcf altair.blif -o altair.txt
	icepack altair.txt altair.bin

clean:
	$(RM) -f altair.bin
	$(RM) -f altair.blif
	$(RM) -f altair.txt
	$(RM) -f *.vcd
	$(RM) -f a.out

test_altair: tb/altair_tb.v rtl/altair.v rtl/jmp_boot.v rtl/serial_io.v rtl/i8080.v rtl/prom_memory.v rtl/ram_memory.v rtl/simpleuart.v
	iverilog $^
	vvp a.out
