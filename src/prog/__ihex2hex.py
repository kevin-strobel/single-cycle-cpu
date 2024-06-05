import sys

file_in = sys.argv[1]
file_out = sys.argv[2]
# Should be multiple of 4
BITS_PER_LINE = int(sys.argv[3])

ADDRESS_LEN = 4 # IHEX format uses 4 nibbles for addresses
DATA_LEN = 32 # GCC generates 32 nibbles (16 bytes) per line
STRIPPED_LINE_LEN = ADDRESS_LEN + DATA_LEN
CHECKSUM_LEN = 2 # IHEX format uses 2 nibbles for checksums


in_content = None
out_content = []
nibbles_per_line = BITS_PER_LINE // 4

with open(file_in, "r") as f:
	in_content = f.readlines()

# discard EOF record
in_content = in_content[:-1]
# strip lines (drop start code, byte count, record type, checksum)
for i in range(len(in_content)):
	line = in_content[i].strip()
	in_content[i] = line[3:7] + line[9:-2]
# zero-pad shorter lines (except last line)
for i in range(len(in_content)):
	line = in_content[i]
	if len(line) != STRIPPED_LINE_LEN and i != len(in_content)-1:
		in_content[i] = line + (STRIPPED_LINE_LEN-len(line)) * "0"

# create and fill map
data_map = {}
max_address = int(in_content[-1][:4], 16)
for line in in_content:
	address = int(line[:4], 16)
	data = line[4:]
	data_map[address] = data;

out_content = ""
for i in range(0, max_address+16, 16):
	if i in data_map.keys():
		out_content += data_map[i]
	else:
		out_content += "0" * DATA_LEN

with open(file_out, "w") as f:
	f.write("(")
	for i in range(0, len(out_content), nibbles_per_line):
		if i != 0:
			f.write(", ")
		f.write("x\"" + out_content[i:i+nibbles_per_line] + "\"")
	f.write(")")