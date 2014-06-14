####################################################################
# Test program for getFactors(n)
#
#	**** TO DO: make getFactors(n, int f[], int m[]), 0-terminated
#	
#####################################################################

	.section .rodata
fmt_Str1:
	.asciz "The factors of %qd are:\n"
fmt_Str2:
	.asciz "%d\n"
defV_Str:
	.asciz "600851475143"

	.section .text
	.globl _start
_start:
	pushl %ebp
	movl %esp, %ebp
	subl $8, %esp	# store n for later printing

	# handle command line argument (default = 600,851,475,143)
	cmpl $1, 4(%ebp) # argc
	je lbl_noargs_
	pushl 12(%ebp)   #argv[1] (pointer to)
	jmp lbl_convert_
lbl_noargs_:
	pushl $defV_Str
lbl_convert_:	
	call atoll
	addl $4, %esp
	movl %eax, -8(%ebp)    # store lower order dword
	movl %edx, -4(%ebp)    # higher order

	pushl -4(%ebp)
	pushl -8(%ebp)
	call getFactors
	addl $8, %esp

	# print factors
	pushl -4(%ebp)
	pushl -8(%ebp)
	pushl $fmt_Str1
	call printf
	addl $12, %esp

lbl_pf_:
#	pushl %ebx      # save for later retrieval
	pushl (%eax)
#	pushl factor_Arr(, %ebx, 4)
	pushl $fmt_Str2
	call printf
	addl $8, %esp
#	popl %ebx
#	incl %ebx
#	cmp %ebx, %esi
#	jge lbl_pf_
	
lbl_exit_:	
	movl %ebp, %esp
	popl %ebp
	movl $0, %ebx
	movl $1, %eax
	int $0x80
# end test program for gcd and lcm
