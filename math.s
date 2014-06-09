######################################################
# Common math functions
#
######################################################

# modulo
# assumes integer values handed on for a % b
# C calling convention: pushl b, then a
#                       RV in %eax
	.section .text
	.type modulo, @function
	.globl modulo
modulo:
	pushl %ebp
	movl %esp, %ebp

#	xor %edx, %edx     # would work only for unsigned integers
	movl 8(%ebp), %eax # dividend
	cdq                # sign-extend 32b value in %eax to %edx:%eax
	idivl 12(%ebp)
	movl %edx, %eax    # move remainder

	movl %ebp, %esp
	popl %ebp
	ret
# end modulo

# fibonacci
# C calling convention, with non-negative integer on top of stack
# Calculation: f(0) = 0
#              f(1) = 1
#              f(n) = f(n-2) + f(n-1), n >=2
# Registers: %edx: n for f(n)
#            %ebx: f(n-1)
#            %ecx: f(n-2)
# Rv: Fibonacci(n) for n >= 0 (in %eax)
# Errors: none. Assume a correct arg n is handed on.
	.section .text
	.globl fibonacci
	.type fibonacci, @function
fibonacci:
	pushl %ebp
	movl %esp, %ebp
	pushl %edx
	pushl %ecx
	pushl %ebx
	movl 8(%ebp), %edx

	# base cases
	cmpl $0, %edx
	jg positive
	xor %eax, %eax
	jmp exit
positive:
	cmpl $2, %edx
	jg calculate
	movl $1, %eax
	jmp exit
calculate:
	# fib(n-1)
	movl %edx, %ebx
	subl $1, %ebx
	pushl %ebx
	call fibonacci
	addl $4, %esp
	movl %eax, %ebx

	# fib(n-2)
	movl %edx, %ecx
	subl $2, %ecx
	pushl %ecx
	call fibonacci
	addl $4, %esp
	movl %eax, %ecx

	addl %ebx, %ecx
	movl %ecx, %eax
exit:
	popl %ebx
	popl %ecx
	popl %edx
	movl %ebp, %esp
	popl %ebp
	ret
# end fibonacci


