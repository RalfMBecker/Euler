##################################################
# Euler 2: sum up even Fibonacci Numbers whose
#          value is < 4,000,000
# Registers: %edi - f(n) (4,000,000)
#            %esi - running index
# Note: this is certainly not optimized for speed:
#       - saving a table of old fib(n) values faster
#       - helpful feedback output
#       - some duplication/redundant register
#         safety storage between calls
##################################################
	
	.section .data
fmt_Str:
	.asciz "For n = %d, the result is %d.\n"
fmt_Str2:
	.asciz "f(%d) = %d\n"
msg_Str:
	.asciz "***added to sum***\n"
defaultV:
	.int 4000000
##############################
	.section .bss
	.comm totalV, 4
##############################

	.section .text
	.globl _start
_start:
	movl %esp, %ebp

	# handle command line argument (default = 4,000,000)
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
	movl $0, %esi
loop:	
	pushl %esi
	call fibonacci
	addl $4, %esp

	pushl %eax    # to protect it through printf calls
	pushl %eax
	pushl %esi
	pushl $fmt_Str2
	call printf
	addl $8, %esp
	popl %eax    # retrieving result
	movl %eax, %ebx
	andl $0x1, %ebx  # odd?
	cmp $0, %ebx
	jne incr

	addl %eax, totalV
	pushl %eax     # we still need this round's result
	pushl $msg_Str
	call printf
	addl $4, %esp
	popl %eax
incr:	
	addl $1, %esi
	cmpl %eax, %edi
	jge loop

	# print out
	pushl totalV
	pushl %edi
	pushl $fmt_Str
	call printf
	addl $12, %esp
	
	movl %ebp, %esp
	movl $0, %ebx
	movl $1, %eax
	int $0x80
# end euler 2
