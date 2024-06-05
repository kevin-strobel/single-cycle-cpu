import os
import sys

COMPILER = R"C:\riscv64-unknown-elf-gcc-2018.07.0-x86_64-w64-mingw32\bin\riscv64-unknown-elf-g++"
OBJCOPY = R"C:\riscv64-unknown-elf-gcc-2018.07.0-x86_64-w64-mingw32\bin\riscv64-unknown-elf-objcopy"

if len(sys.argv) != 2:
    exit("First and only parameter needs to be the source file.")
sourceFile = sys.argv[1]
if not sourceFile.endswith(".S"):
    exit("You must provide an assembly file as source.")
objFile = sourceFile[:-1] + "o"
ihexFile = sourceFile[:-1] + "ihex"
hexFile = sourceFile[:-1] + "hex"

# Compile
os.system(f"{COMPILER} -c -nostdlib -nodefaultlibs -nostartfiles -fno-exceptions -march=rv32i -mabi=ilp32 -o {objFile} {sourceFile}")
# ihex
os.system(f"{OBJCOPY} -O ihex {objFile} {ihexFile}")
# hex
os.system(f"python __ihex2hex.py {ihexFile} {hexFile} 32")