##################################################
# generate some prime numbers <= n/2
# Note: - n <= 200,000,000
#       - default value: 200,000,000
#       - n >= 2 assumed (no error check)
##################################################
	
	.section .data
fmt_Str:
	.asciz "For n = %d, the prime numbers <= n are:\n"
fmt_Str2:
	.asciz "%d\n"
defaultV:
	.int 1000000

	.section .text
	.globl _start
_start:
	movl %esp, %ebp

	# handle command line argument (default = 10,000)
	cmpl $1, (%esp) # argc
	je noargs
	pushl 8(%ebp)   #argv[1] (pointer to)
	call atoi
	movl %eax, %edi
	addl $4, %esp
	jmp argsdone
noargs:
	movl defaultV, %edi
argsdone:
	pushl %edi     # not used in sieve
	call sieve
	addl $4, %esp
test:
	pushl %edi
	pushl $fmt_Str
	call printf
	addl $4, %esp
	popl %edi
	
	xor %ecx, %ecx
loop_:
	pushl %edi
	pushl %ecx
	pushl prime_Arr(, %ecx, 4)
	pushl $fmt_Str2
	call printf
	addl $8, %esp
	popl %ecx
	popl %edi
	
	incl %ecx
	cmp $0, prime_Arr(, %ecx, 4)
	jne loop_
	
	movl %ebp, %esp
	movl $0, %ebx
	movl $1, %eax
	int $0x80
# end testSieve.s
