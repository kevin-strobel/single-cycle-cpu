import sys

lines = None

if len(sys.argv) != 2:
    print("Please provide a hex file!")
    exit(-1)

with open(sys.argv[1], "r") as f:
	lines = f.readlines()
	lines = [l.strip() for l in lines]

print("set_msg_config -id {[Labtoolstcl 44-481]} -limit 999999999")

address = 0
for list_item in lines:
	for i in range(0, len(list_item), 8):
		data = list_item[i:i+8]

		addr_str = "{0:0{1}x}".format(address, 16)
		print("create_hw_axi_txn -force wr_txn [get_hw_axis hw_axi_1] -address " + addr_str + " -data " + data + " -type write; run_hw_axi wr_txn")

		address += 4
