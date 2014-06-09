##################################################
# Euler 3: prime-factorize 600851475143
# Registers: %edi - f(n) (4,000,000)
#            %esi - running index
# Note: Set up for positive integer in the interval
#       (2^31 -1, 2^63 -1]
##################################################
	
	.section .data
fmt_Str:
	.asciz "For n = %qd, the prime factors are:\n"
defV_Str:
	.asciz "600851475143"
num_LL:
	.int 0, 0
##############################
	.section .bss
	.lcomm null_Ptr, 4
##############################

	.section .text
	.globl _start
_start:
	movl %esp, %ebp

	# handle command line argument (default = 600,851,475,143)
	cmpl $1, (%esp) # argc
	je noargs_
	pushl 8(%ebp)   #argv[1] (pointer to)
	jmp convert_
noargs_:
	pushl $defV_Str
convert_:	
	call atoll
	movl $1, %edi
	movl %eax, num_LL	# store lower order dword first
	movl %edx, num_LL(, %edi, 4)
	addl $4, %esp


	# print out
	movl $1, %edi
	pushl num_LL(, %edi, 4)  #push higher order dword first
	pushl num_LL	
	pushl $fmt_Str
	call printf
	addl $16, %esp
	
	movl %ebp, %esp
	movl $0, %ebx
	movl $1, %eax
	int $0x80
# end euler 1
