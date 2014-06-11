####################################################################
# Euler 3: prime-factorize 600851475143
# Registers: %ecx - pointer into array of primes
#            %esi - pointer into factor array
# Notes: (1) Largest prime to check is sqr(n). To ensure that its
#            factors fit as an int, assume n <= 2^62 ~ 1 ~ 4.611e18
#        (2) atoll returns a long long in (%edx, %eax)
#
#	Set up for positive integer in the interval
#       (2^31 -1, 2^63 -1]
#
###################################################################
	
	.section .rodata
prime_Str:
	.asciz "prime factors retrieved...\n"
res_Str1:
	.asciz "The prime factors of %qd are:\n"
res_Str2:
	.asciz "%d\n"
res_Str3:
	.asciz "%qd is prime\n"
defV_Str:
	.asciz "600851475143"
	
	.section .data
num_LL:
	.int 0, 0
highestV:
	.int 0
	
	.section .bss
	.lcomm factor_Arr, 1000
	
##############################

	.section .text
	.globl _start
_start:
	movl %esp, %ebp
	subl $8, %esp	# store n for later printing
	
	# handle command line argument (default = 600,851,475,143)
	cmpl $1, (%ebp) # argc
	je noargs_
	pushl 8(%ebp)   #argv[1] (pointer to)
	jmp convert_
noargs_:
	pushl $defV_Str
convert_:	
	call atoll
	addl $4, %esp
	movl $1, %edi
	movl %eax, num_LL	# store lower order dword first
	movl %eax, -8(%ebp)
	movl %edx, num_LL(, %edi, 4)
	movl %edx, -4(%ebp)

test:	
	# get a bound to which prime to check (somewhat ad hoc)
	cmp $0, %edx
	je lbl_small_
	movl $0x0fffffff, highestV   # long long related bound
# better bound incoming
	jmp lbl_sieve_
lbl_small_:	
	xor %edx, %edx
	movl $2, %edi
	divl %edi
	incl %eax
	movl %eax, highestV
	# get square root bound
#	finit
#	fildll num_LL
#	fsqrt
#	frndint
#	fistp highestV
#	addl $1, highestV    # given size of n, won't overflow

lbl_sieve_:	
	# generate relevant primes
	pushl highestV
	call sieve
	pushl $prime_Str
	call printf
	addl $8, %esp
	
	# initialize array element pointers
	movl $0, %ecx     # to prime array
	movl $-1, %esi     # to factor array

	# handle 2
loop_2_:
	movl num_LL, %eax
	andl $0x1, %eax
	cmp $0, %eax
	jne lbl_from3_
	shrl num_LL
	shrl num_LL+4
	jnc lbl_done2_
	orl $0x80000000, num_LL  # transferred carry from higher to lower
lbl_done2_:
	incl %esi
	movl $2, factor_Arr(, %esi, 4)
	call foundAll
	cmp $1, %eax
	je lbl_foundall_
	jmp loop_2_

	# all other cases
lbl_from3_:
	incl %ecx	
loop_A_:
	movl prime_Arr(, %ecx, 4), %edi
	cmp $0, %edi
	je lbl_foundall_
	
	pushl prime_Arr(, %ecx, 4)
	call isFactor
	addl $4, %esp
	cmp $1, %eax
	jne lbl_lincr_

# missing: multiple factors for case p > 2
	
	incl %esi
	movl prime_Arr(, %ecx, 4), %eax
	movl %eax, factor_Arr(, %esi, 4)
	call foundAll
	cmp $1, %eax
	je lbl_foundall_
lbl_lincr_:
	incl %ecx
	jmp loop_A_

#lbl_ncheck_:
#	incl %ecx
#	movl prime_Arr(, %ecx, 4), %edi
#	cmp $0, %edi
#	movl prime_Arr(, %ecx, 4), %edi
#	cmp %edi, highestV      # if this is true, the variable is prime
#	jne loop_A_
	
lbl_foundall_:
	# print if is prime
	cmp $-1, %esi
	jne lbl_hasf_

	pushl -4(%ebp)
	pushl -8(%ebp)
	pushl $res_Str3
	call printf
	addl $12, %esp
	jmp lbl_exit_
lbl_hasf_:	
	# print factors if is not prime\
	pushl -4(%ebp)
	pushl -8(%ebp)
	pushl $res_Str1
	call printf
	addl $12, %esp

	xor %ebx, %ebx
lbl_pf_:
	pushl %ebx      # save for later retrieval
	pushl factor_Arr(, %ebx, 4)
	pushl $res_Str2
	call printf
	addl $8, %esp
	popl %ebx
	incl %ebx
	cmp %ebx, %esi
	jge lbl_pf_
	
lbl_exit_:	
	movl %ebp, %esp
	popl %esp
	movl $0, %ebx
	movl $1, %eax
	int $0x80
# end euler 3


# Is arg_1 a factor of (num_LL, num_LL+4) ?
	.globl isFactor
	.type isFactor, @function
isFactor:
	pushl %ebp
	movl %esp, %ebp

	finit
	fildll num_LL
	fild 8(%ebp)
	fdivr %st(1)         # divide st(1) by st(0), and store in st(0)  
	frndint              # st(0) - floor(quotient),  st(1) - num_LL
	fild 8(%esp)
	fmul %st(1), %st(0)  # st(0) - f(q) * f, st(1) - f(q), st(2) - num_LL
	fcomip %st(2), %st(0)
	jne lbl_isf_not_
	# found a factor
	movl $1, %eax
	fistpll num_LL       # actual value we want (f(q) == q if we get here)
	jmp lbl_isf_out_
lbl_isf_not_:
	xor %eax, %eax
	
lbl_isf_out_:	
	movl %ebp, %esp
	popl %ebp
	ret
# end isFactor
	
	.globl foundAll
	.type foundAll, @function
foundAll:
	pushl %ebp
	movl %esp, %ebp

	cmp $1, num_LL
	jne lbl_fa_not_
	cmp $0, num_LL + 4
	jne lbl_fa_not_
	movl $1, %eax
	jmp lbl_fa_out_
lbl_fa_not_:
	xor %eax, %eax
lbl_fa_out_:	
	movl %ebp, %esp
	popl %ebp
	ret
# end foundAll
