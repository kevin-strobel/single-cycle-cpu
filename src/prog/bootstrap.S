.globl _start
_start:
	li sp, 0x3f0

	jal main # call main

	j _exit

_exit:
	# Exit loop prevents bare-metal programs from executing uninitialized memory
	j _exit
