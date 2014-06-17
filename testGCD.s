####################################################################
# Test program for gcd(a,b) and lcm(a, b)
#
#####################################################################

	.section .rodata
fmt_Strgcd:
	.asciz "gcd(%d, %d) = %d\n"
fmt_Strlcm:
	.asciz "lcm(%d, %d) = %d\n"
defV_1:
	.int 12
defV_2:
	.int 27
	
	.section .text
	.globl _start
_start:
	pushl %ebp
	movl %esp, %ebp
	subl $8, %esp
	
	cmp $3, 4(%ebp)   # argc - how many args entered?
	jge has_Two
	movl defV_1, %eax
	movl %eax, -8(%ebp)
	movl defV_2, %eax
	movl %eax, -4(%ebp)
	jmp has_ltTwo
has_Two:
	pushl 16(%ebp)
	call atol
	addl $4, %esp
	movl %eax, -4(%ebp)
	pushl 12(%ebp)
	call atol
	addl $4, %esp
	movl %eax, -8(%ebp)
has_ltTwo:
	# gcd(a, b)
	pushl -8(%ebp)
	pushl -4(%ebp)
	call gcd
	addl $8, %esp
	
	pushl %eax
	pushl -4(%ebp)
	pushl -8(%ebp)
	pushl $fmt_Strgcd
	call printf
	addl $16, %esp

	# lcm(a, b)
	pushl -8(%ebp)
	pushl -4(%ebp)
	call lcm
	addl $8, %esp
	
	pushl %eax
	pushl -4(%ebp)
	pushl -8(%ebp)
	pushl $fmt_Strlcm
	call printf
	addl $16, %esp

	# epilogue
	movl %esp, %ebp
	movl $0, %ebx
	movl $1, %eax
	int $0x80
# end test program for gcd and lcm
