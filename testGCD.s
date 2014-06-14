####################################################################
# Test program for gcd(a,b) and lcm(a_1, ..., a_n)
#
#####################################################################

	.section .rodata
fmt_Strgcd:
	.asciz "gcd(%d, %d) = %d\n"

	.section .text
	.globl _start
_start:
	pushl %ebp
	movl %esp, %ebp
	




	movl %esp, %ebp
	movl $0, %ebx
	movl $1, %eax
	int $0x80
# end test program for gcd and lcm
