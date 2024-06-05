.globl _start
_start:
	lui x1, 0x1234
	auipc x2, 0x800
	addi x4, x2, 8
	addi x5, x2, -8
	addi x6, x0, 4
	slti x7, x6, 4
	slti x8, x6, 5
	addi x9, x0, -1
	slti x10, x9, 1
	sltiu x11, x9, 1
	addi x12, x0, 5
	xori x13, x12, 12
	ori x14, x12, 12
	andi x15, x12, 12
	slli x16, x12, 4
	srli x17, x9, 4
	srai x18, x9, 4
	add x19, x2, x4
	sub x20, x6, x8
	sll x21, x5, x6
	slt x22, x2, x6
	slt x23, x9, x8
	sltu x24, x9, x8
	xor x27, x4, x12
	srl x28, x9, x6
	sra x29, x9, x6
	or x30, x4, x12
	and x31, x4, x12
	fence
	ecall
	ebreak

	# TODO: BEQ, BNE, BLT; BGE; BLTU; BGEU; LB; LH; LW; LBU; LHU; SB; SH; SW

	# test x0
	lui x0, 0x1248
	addi x3, x0, 0

	jal x1, tmpFunction
	ebreak

# never executed
	addi x1, x0, 0
	addi x2, x0, 0
	addi x3, x0, 0
	addi x4, x0, 0
	addi x5, x0, 0
	addi x6, x0, 0
	addi x7, x0, 0
	addi x8, x0, 0
	addi x9, x0, 0
	addi x10, x0, 0
	addi x11, x0, 0
	addi x12, x0, 0
	addi x13, x0, 0
	addi x14, x0, 0
	addi x15, x0, 0
	addi x16, x0, 0
	addi x17, x0, 0
	addi x18, x0, 0
	addi x19, x0, 0
	addi x20, x0, 0
	addi x21, x0, 0
	addi x22, x0, 0
	addi x23, x0, 0
	addi x24, x0, 0
	addi x25, x0, 0
	addi x26, x0, 0
	addi x27, x0, 0
	addi x28, x0, 0
	addi x29, x0, 0
	addi x30, x0, 0
	addi x31, x0, 0

tmpFunction:
	addi x25, x0, 12
	addi x26, x0, 24
	jalr x1, 0(x1)