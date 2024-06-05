# single-cycle-RISCV

## Preparation

- Download the content of file https://github.com/Digilent/Arty/blob/master/Projects/GPIO/src/hdl/UART_TX_CTRL.vhd @ revision ae49472.
- Save it as src/cpu/hdl/ioUart.vhd
- Apply the patch ioUart.patch to this file, for example via

```
# cd to project root dir

patch src/cpu/hdl/ioUart.vhd ioUart.patch
```

## Vivado

Example of setting up the project via Tcl:

```
source C:/_dev/fpga/single-cycle-riscv/funcs.tcl
cpu_new
```

## Compile and inspect test program

Example:

```
genImem.py cpu_test.S && C:\riscv64-unknown-elf-gcc-2018.07.0-x86_64-w64-mingw32\bin\riscv64-unknown-elf-objdump -d -Mno-aliases,numeric cpu_test.o
```

This works with assembly sources as well as with CPP sources.

Paste the contents that are printed onto stdout into the Vivado TCL console while the board is connected.
This procedure writes the system's program memory.
Afterwards, you should perform a CPU reset via the reset button on the FPGA.
The CPU will then start with the first instruction.