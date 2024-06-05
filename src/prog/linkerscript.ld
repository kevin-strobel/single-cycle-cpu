OUTPUT_ARCH( "riscv" )
ENTRY( _start )

MEMORY
{
/* Hardvard architecture */
   rom : ORIGIN = 0x0, LENGTH = 0x2000
   ram : ORIGIN = 0x0, LENGTH = 0x2000
}

SECTIONS
{
	.text :
	{
		*(.text);
	} > rom

	.data :
	{
		*(.data);
	} > ram
}
