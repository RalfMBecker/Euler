####################################################################
# Common math functions
#
# Register convention: - %eax, %ecx, %edx can be modified
#                      - any other register used is pushed and popped
#####################################################################

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

# max(a, b)
# assumes integer values for a and b
# Calling and return convention
	.section .text
	.globl max
	.type max, @function
max:
	pushl %ebp
	movl %esp, %ebp

	movl 8(%ebp), %eax
	cmp %eax, 12(%ebp)
	jle lbl_maxe_
	movl 12(%esp), %eax
lbl_maxe_:

	movl %ebp, %esp
	popl %ebp
	ret
# end max(a, b)

# min(a, b)
# assumes integer values for a and b
# Calling and return convention
	.section .text
	.globl min
	.type min, @function
min:
	pushl %ebp
	movl %esp, %ebp

	movl 8(%ebp), %eax
	cmp %eax, 12(%ebp)
	jge lbl_maxe_
	movl 12(%esp), %eax
lbl_mine_:

	movl %ebp, %esp
	popl %ebp
	ret
# end min(a, b)

# gcd(a,b)
# Euclid's Algorithm:
# if (min(a,b) == 0) return max(a,b) (fine also both 0 as gcd(0,0) = 0)
# else return gcd(min(a,b), max(a,b) % min(a,b)
	.section .text
	.globl gcd
	.type gcd, @function
gcd:
	pushl %ebp
	movl %esp, %ebp
	subl $8, %esp 	# space for min(a,b) and max(a,b)

	pushl 12(%ebp)
	pushl 8(%ebp)
	call max
	addl $8, %esp
	movl %eax, -4(%ebp)  # holds max
	pushl 12(%ebp)
	pushl 8(%ebp)
	call min
	addl $8, %esp
	movl %eax, -8(%ebp)  # holds min
	
	# check for termination
	cmpl $0, -8(%ebp)
	jne lbl_gcdrec_
	movl -4(%ebp), %eax
	jmp lbl_gcdexit_

	#recurse
lbl_gcdrec_:
	pushl -8(%esp)	# modulo
	pushl -4(%esp)
	call modulo
	addl $8, %esp
	
	pushl %eax
	pushl -8(%esp)
	call gcd	# %eax of deepest recursion level handed
	addl $8, %esp   # on through the unrolling iterations
	
lbl_gcdexit_:	
	movl %ebp, %esp
	popl %ebp
	ret
# end gcd(a, b)
	
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
	jg lbl_fib_pos_
	xor %eax, %eax
	jmp exit
lbl_fib_pos_:
	cmpl $2, %edx
	jg lbl_fib_calc_
	movl $1, %eax
	jmp exit
lbl_fib_calc_:
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
lbl_fib_exit:
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
#       - n <= 500,000,000 (could be changed) - in assembly
#         compiling it with gcc: trouble. make n <= 50,000,000
# Returns: pointer to array of ints of prime numbers
#          (0 sentinel at end)
#
# Registers: %esi: sentinel value (n+1)
#            %edx: n
#            %ecx: counting variable (2 - n)
#            %ebx: pointer into array of primes
#                  (position next to be added)
#            %eax: inner pointer to A. tmp array
	.section .bss
	# total size of .bss seems to restricted somewhere < 2^30
	# to make it more memorable, restrict to a number memorable
	# in decimal that is n <= 2^30, say 500,000,000
#	.lcomm tmp_Arr, 2000000008  # 500,000,000 plus sentinel & padding
#	.comm prime_Arr, 500000008 # asymptotically, primes aren't dense
	.lcomm tmp_Arr, 200000008  # 50,000,000 plus sentinel & padding
	.comm prime_Arr, 50000008 # asymptotically, primes aren't dense

	.section .text
	.globl sieve
	.type sieve, @function
sieve:
	pushl %ebp
	movl %esp, %ebp
	movl 8(%ebp), %edx
	pushl %esi
	pushl %ebx
	
	# create Eratosthenes tmp array
	movl $0, %ecx
loop_sieve_Tmp_:	
	movl %ecx, tmp_Arr(, %ecx, 4)
	addl $1, %ecx
	cmp %ecx, %edx
	jge loop_sieve_Tmp_

	# initialize registers used in algorithm
	movl $2, %ecx   # outer loop counting var
	movl %ecx, %eax # inner loop counting var
	xor %ebx, %ebx  # pointer to prime array
	movl %edx, %esi
	incl %esi       # sentinel (or placeholder for 'not prime')
loop_sieve_Outer_:
	movl %ecx, prime_Arr(, %ebx, 4)  # record prime
	incl %ebx
loop_sieve_Inner_:
	addl %ecx, %eax
	movl %esi, tmp_Arr(, %eax, 4)
	cmp %eax, %edx
	jge loop_sieve_Inner_
find_Next_:	# find minimum in Erist. tmp array
	addl $1, %ecx
	cmp %ecx, %edx
	jl lbl_sieve_done_
	cmp tmp_Arr(, %ecx, 4), %esi
	je find_Next_

	movl %ecx, %eax
	jmp loop_sieve_Outer_
lbl_sieve_done_:
	movl $0, prime_Arr(, %ebx, 4)       # sentinel
	movl $prime_Arr, %eax

	popl %ebx
	popl %esi
	movl %ebp, %esp
	popl %ebp
	ret
# end sieve





	