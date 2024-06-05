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
	
	# TODO: JAL, JALR, BEQ, BNE, BLT; BGE; BLTU; BGEU; LB; LH; LW; LBU; LHU; SB; SH; SW

	# test x0
	lui x0, 0x1248
	addi x3, x0, 0
