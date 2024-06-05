OUTPUT_ARCH( "riscv" )
ENTRY( _start )

MEMORY
{
/* Hardvard architecture */
   rom : ORIGIN = 0x0, LENGTH = 0x1000
   ram : ORIGIN = 0x1000, LENGTH = 0x1000
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
