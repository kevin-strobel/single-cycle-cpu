import sys

if len(sys.argv) != 3:
    print("Define input (binary) and output (txt) file.")
    exit(-1)

inputFile = sys.argv[1]
outputFile = sys.argv[2]

with open(inputFile, "rb") as f:
    hexdata = f.read().hex()

assert len(hexdata) != 0
# full 32-bit instructions
assert len(hexdata) % 8 == 0

with open(outputFile, 'w') as f:
    for i in range(0, len(hexdata), 8):
        if i != 0:
            f.write("\n")
        f.write(hexdata[i:i+8])
