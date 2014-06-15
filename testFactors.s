####################################################################
# Test program for getFactors(n)
#
#####################################################################

	.section .rodata
fmt_Str1:
	.asciz "The factors of %qd are:\n"
fmt_Str2:
	.asciz "%d (%d)\n"
fmt_Str3:
	.asciz "%qd is prime.\n"
defV_Str:
	.asciz "600851475143"

	.section .bss

	.lcomm factor_Arr, 1000
	.lcomm mult_Arr, 100
	
	.section .text
	.globl _start
_start:
	pushl %ebp
	movl %esp, %ebp
	subl $8, %esp	# store n
	pushl %ebx
	
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

	pushl $mult_Arr
	pushl $factor_Arr
	pushl -4(%ebp)
	pushl -8(%ebp)
	call getFactors
	addl $16, %esp

	# print if is prime
	movl (factor_Arr), %eax
	cmp $0, %eax
	jne lbl_hasf_

	pushl -4(%ebp)
	pushl -8(%ebp)
	pushl $fmt_Str3
	call printf
	addl $12, %esp
	jmp lbl_exit_
lbl_hasf_:	
	# print if n is composite
	pushl -4(%ebp)
	pushl -8(%ebp)
	pushl $fmt_Str1
	call printf
	addl $12, %esp

	# print factors
	xor %ebx, %ebx
lbl_pf_:
	pushl %ebx       # save for later retrieval
	pushl mult_Arr(, %ebx, 4)
	pushl factor_Arr(, %ebx, 4)
	pushl $fmt_Str2
	call printf
	addl $12, %esp
	popl %ebx
	incl %ebx
	movl factor_Arr(, %ebx, 4), %eax
	cmp $0, %eax
	jne lbl_pf_
#	pushl %ebx      # save for later retrieval
#	pushl factor_Arr(, %ebx, 4)
#	pushl $fmt_Str2
#	call printf
#	addl $8, %esp
#	popl %ebx
#	incl %ebx
#	cmp %ebx, %esi
#	jge lbl_pf_
	
lbl_exit_:	
	popl %ebx
	movl %ebp, %esp
	popl %ebp
	movl $0, %ebx
	movl $1, %eax
	int $0x80
# end test program for gcd and lcm
