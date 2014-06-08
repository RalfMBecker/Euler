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
	


