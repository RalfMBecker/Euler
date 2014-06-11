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

# Sieve of Eratosthenes
# Create list of prime numbers smaller than n
#
# Note: - no input error (range) check
#       - n <= 200,000,000 (could be changed)
# Returns: pointer to array of ints of prime numbers
#          (0 sentinel at end)
#
# Registers: %edx: n
#            %ecx: counting variable (2 - n)
#            %ebx: pointer into array of primes
#                  (position next to be added)
#            %eax: inner pointer to A. tmp array
#                  (we enter %edx as a placeholder for "is multiple")
	.section .bss
	.lcomm tmp_Arr, 800000000 # arbitrary size - could be changed

	.comm prime_Arr, 200000000

	.section .text
	.globl sieve
	.type sieve, @function
sieve:
	pushl %ebp
	movl %esp, %ebp
	movl 8(%ebp), %edx
	
	# create Eratosthenes tmp array
	movl $0, %ecx
loop_Tmp_:	
	movl %ecx, tmp_Arr(, %ecx, 4)
	addl $1, %ecx
	cmp %ecx, %edx
	jge loop_Tmp_

	# initialize registers used in algorithm
	movl $2, %ecx   # outer loop counting var
	movl %ecx, %eax # inner loop counting var
	xor %ebx, %ebx  # pointer to prime array
loop_Outer_:
	movl %ecx, prime_Arr(, %ebx, 4)  # record prime
	incl %ebx
loop_Inner_:
	addl %ecx, %eax
	movl %edx, tmp_Arr(, %eax, 4)
	cmp %eax, %edx
	jg loop_Inner_
find_Next_:	# find minimum in A. tmp array
	addl $1, %ecx
	cmp %ecx, %edx
	jl done_
	cmp tmp_Arr(, %ecx, 4), %edx
	je find_Next_

	movl %ecx, %eax
	jmp loop_Outer_
done_:
	movl $0, prime_Arr(, %ebx, 4)       # sentinel
	movl $prime_Arr, %eax

	movl %ebp, %esp
	popl %ebp
	ret
# end sieve





	