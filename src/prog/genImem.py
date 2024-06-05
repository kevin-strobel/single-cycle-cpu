import os
import sys

COMPILER = R"C:\riscv64-unknown-elf-gcc-2018.07.0-x86_64-w64-mingw32\bin\riscv64-unknown-elf-g++"
OBJCOPY = R"C:\riscv64-unknown-elf-gcc-2018.07.0-x86_64-w64-mingw32\bin\riscv64-unknown-elf-objcopy"
allowedInput = [".S", ".cpp"]

if len(sys.argv) != 2:
    exit("First and only parameter needs to be the source file.")
sourceFile = sys.argv[1]
if not sourceFile.endswith(".S") and not sourceFile.endswith(".cpp"):
    exit("You must provide a source file as first parameter.")
rawName = sourceFile[:sourceFile.rindex(".")]
objFile = rawName + ".o"
binFile = rawName + ".bin"
hexFile = rawName + ".hex"

# Compile
if os.system(f"{COMPILER} -std=c++17 -nostdlib -nodefaultlibs -nostartfiles -fno-exceptions -march=rv32i -mabi=ilp32 -T linkerscript.ld -o {objFile} bootstrap.S {sourceFile}") != 0:
    exit(-1)
# bin
if os.system(f"{OBJCOPY} -O binary {objFile} {binFile}") != 0:
    exit(-1)
# hex
if os.system(f"python __bin2hex.py {binFile} {hexFile}") != 0:
    exit(-1)
# JTAG2AXI
if os.system(f"python __jtag2axi.py {hexFile}") != 0:
    exit(-1)