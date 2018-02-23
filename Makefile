ifeq ($(OS),Windows_NT)
SILENT_OUT := >nul
EXE	:= .exe
else
SILENT_OUT := >/dev/null
EXE	:=
endif
.PHONY: all test_cpu clean test

all: test.bin

test.bin:  top/top.v rtl/altair.v rtl/jmp_boot.v rtl/serial_io.v rtl/i8080.v rtl/prom_memory.v rtl/ram_memory.v rtl/simpleuart.v
	yosys -q -p "synth_ice40 -top top -blif test.blif" $^
	arachne-pnr -d 5k -p board.pcf test.blif -o test.txt
	icepack test.txt test.bin

clean:
	$(RM) -f test.bin
	$(RM) -f test.blif
	$(RM) -f test.txt
	$(RM) -f *.vcd
	$(RM) -f a.out

test: tb/top_tb.v rtl/altair.v rtl/jmp_boot.v rtl/serial_io.v rtl/i8080.v rtl/prom_memory.v rtl/ram_memory.v rtl/simpleuart.v
	iverilog $^
	vvp a.out
