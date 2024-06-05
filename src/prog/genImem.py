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
os.system(f"{COMPILER} -nostdlib -nodefaultlibs -nostartfiles -fno-exceptions -march=rv32i -mabi=ilp32 -T linkerscript.ld -o {objFile} bootstrap.S {sourceFile}")
# bin
os.system(f"{OBJCOPY} -O binary {objFile} {binFile}")
# hex
os.system(f"python __bin2hex.py {binFile} {hexFile}")