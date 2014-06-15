####################################################################
# getFactors(long long n, int* pFactors, int* pMults)
#
# Registers: %ecx - pointer into array of primes
#
# Notes: (1) A composite number n has a prime factor <= square root(n)
#        (2) For each factor f found, we adjust n -> n/f. By (1), for
#            the next check we also adjust bound to sr(n/f).
#        (3) size of n up to ~ quad word. Not recommended for n >
#            9.99e15 (slow). At <= 9.99e13, fairly fast, 9.99e14 ok.
#
# Args: n - quad word in little-endian format
#       pFactors - pointer to array of integers to hold factors
#       pMults - pointer to array of integers to hold their multiplicity
#
###################################################################
	
	.section .data
num_LL:       # to do: REMOVE
	.int 0, 0
highestV:     # to do: CHANGE NAME
	.int 0
	
#	.section .bss
	
#	.lcomm factor_Arr, 1000
#	.lcomm mult_Arr, 1000
	
##############################

	.section .text
	.globl getFactors
	.type getFactors, @function
getFactors:
	pushl %ebp
	movl %esp, %ebp
	subl $16, %esp	# store args
	pushl %ebx
	pushl %edi
	pushl %esi

	movl 16(%ebp), %eax
	movl %eax, -12(%ebp)    # pointer to array of ints (factors)
	movl 20(%ebp), %eax
	movl %eax, -16(%ebp)    # pointer to array of ints (multiplicity)

	movl 12(%ebp), %eax     # higher order dword
	movl 8(%ebp), %edx      # lower order dword
	movl $1, %edi
	movl %eax, num_LL(, %edi, 4)
	movl %eax, -4(%ebp)
	movl %edx, num_LL
	movl %edx, -8(%ebp)

	# get a bound to which prime to check
	call getSrBound

	# generate relevant primes
	pushl highestV
	call sieve
	addl $4, %esp
	
	# initialize array element pointers
	movl $0, %ecx     # to prime array
#	movl $-1, %esi    # to factor array

	# handle 2 (just because - general case can handle 2 of course)
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
#	xor %esi, %esi
	movl -12(%ebp), %eax
	movl $2, (%eax)        # store factors
#	movl $2, factor_Arr(, %esi, 4)
	movl -16(%ebp), %eax
	addl $1, (%eax)        # increase its multiplicity         
#	addl $1, mult_Arr(, %esi, 4)
	call foundAll
	cmp $1, %eax
	je lbl_foundall_
	call getSrBound
	jmp loop_2_

	# all other cases
lbl_from3_:
	incl %ecx	
loop_A_:
	# check if we hit (updated) square root bound first
	# if yes, current value in num_LL is prime
	movl prime_Arr(, %ecx, 4), %edi
	cmp %edi, highestV
	jg lbl_ctue_
#	cmp $-1, %esi      # STILL OK?
#	jne lbl_esif_
#	xor %esi, %esi
#	jmp lbl_adjusted_
#lbl_esif_:	
	movl -12(%ebp), %eax
	movl (%eax), %eax
#	movl factor_Arr(, %esi, 4), %eax
	cmp %eax, num_LL
	je lbl_adjusted_
	addl $4, -12(%ebp)
	addl $4, -16(%ebp)
#	addl $1, %esi
lbl_adjusted_:
	movl -12(%ebp), %eax
	movl num_LL, %ebx
        movl %ebx, (%eax)
#	movl num_LL, %eax
#	movl %eax, factor_Arr(, %esi, 4)
	movl -16(%ebp), %eax
	addl $1, (%eax)
#	addl $1, mult_Arr(, %esi, 4)
	jmp lbl_foundall_
	
lbl_ctue_:	
	pushl prime_Arr(, %ecx, 4)
	call isFactor
	addl $4, %esp
	cmp $1, %eax
	jne lbl_lincr_

	movl prime_Arr(, %ecx, 4), %edi
	movl -12(%ebp), %eax
	movl (%eax), %eax
#	movl factor_Arr(, %esi, 4), %eax
	cmp %eax, %edi
	je lbl_adjusted2_      # ** TO DO: increases in first iteration
	addl $4, -12(%ebp)
	movl $4, -16(%ebp)
#	addl $1, %esi
lbl_adjusted2_:
	movl -12(%ebp), %eax
	movl %edi, (%eax)	# add next factor
#	movl %edi, factor_Arr(, %esi, 4)
	movl -16(%ebp), %eax
	addl $1, (%eax)		# and increase its multiplicity
#	addl $1, mult_Arr(, %esi, 4)
	call foundAll
	cmp $1, %eax
	je lbl_foundall_
	call getSrBound
	jmp loop_A_     # check for multiple factor
lbl_lincr_:
	incl %ecx
	jmp loop_A_

	# add a sentinel
	addl $4, -12(%ebp)
	addl $4, -16(%ebp)
	movl -12(%ebp), %eax
	movl $0, (%eax)
	movl -16(%ebp), %eax
	movl $0, (%eax)	
	
lbl_foundall_:
#	movl $factor_Arr, %eax
#	movl $mult_Arr, %edx
	
	popl %esi
	popl %edi
	popl %ebx
	movl %ebp, %esp
	popl %ebp
	ret
# end getFactors


	# get square root bound
	.globl getSrBound
	.type getSrBound, @function
getSrBound:	
	finit
	fildll num_LL
	fsqrt
	fistl highestV          # rounds integers (does NOT truncate)
	fisubl highestV	        # st(0): V - rd(V) -> if > 0, was rounded down
	fldz
	fcomip %st(1), %st(0)
	jl lbl_getSrBound_     # value is already ceiling(V)
	addl $1, highestV       # if not, make it
lbl_getSrBound_:	
	ret
# end getSrBound
	
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
