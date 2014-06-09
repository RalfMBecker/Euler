##################################################
# Euler 1: sum up integers <= 1,000 divisible by
#          3 or 5
# Registers: %edi - n (1,000)
#            %esi - running index
##################################################
	
	.section .data
fmt_Str:
	.asciz "For n = %d, the result is %d.\n"
defaultV:
	.int 10
##############################
	.section .bss
	.comm totalV, 4
##############################

	.section .text
	.globl _start
_start:
	movl %esp, %ebp

	# handle command line argument (default = 10)
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
	movl $3, %esi
loop:	
	# mod 3
	movl $3, %ebx
	pushl %ebx
	pushl %esi
	call modulo
	addl $8, %esp
	cmpl $0, %eax
	jne not_by3
	addl %esi, totalV
	jmp incr
not_by3:	
	# mod 5
	movl $5, %ebx
	pushl %ebx
	pushl %esi
	call modulo
	addl $8, %esp
	cmpl $0, %eax
	jne incr
	addl %esi, totalV
incr:
	addl $1, %esi
	cmpl %esi, %edi
	jg loop

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
# end euler 1
