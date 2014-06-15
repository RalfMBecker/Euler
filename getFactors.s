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
c_getF_numLL:
	.int 0, 0
c_getF_highestV:
	.int 0
	
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
	movl %eax, c_getF_numLL(, %edi, 4)
	movl %eax, -4(%ebp)
	movl %edx, c_getF_numLL
	movl %edx, -8(%ebp)

	# get a bound to which prime to check
	call getSrBound

	# generate relevant primes
	pushl c_getF_highestV
	call sieve
	addl $4, %esp
	
	# initialize array element pointers
	movl $0, %ecx     # to prime array

	# handle 2 (just because - general case can handle 2 of course)
0:
	movl c_getF_numLL, %eax
	andl $0x1, %eax
	cmp $0, %eax
	jne lbl_from3_
	shrl c_getF_numLL
	shrl c_getF_numLL+4
	jnc 1
	orl $0x80000000, c_getF_numLL  # transferred carry from higher to lower
1:
	movl -12(%ebp), %eax
	movl $2, (%eax)        # store factors
	movl -16(%ebp), %eax
	addl $1, (%eax)        # increase its multiplicity         
	call foundAll
	cmp $1, %eax
	je lbl_foundall_
	call getSrBound
	jmp 0b

	# all other cases
lbl_from3_:
	incl %ecx	
loop_A_:
	# check if we hit (updated) square root bound first
	# if yes, current value in c_getF_numLL is prime
	movl prime_Arr(, %ecx, 4), %edi
	cmp %edi, c_getF_highestV
	jg lbl_ctue_
	movl -12(%ebp), %eax
	movl (%eax), %eax
	cmp %eax, c_getF_numLL
	je lbl_adjusted_
	addl $4, -12(%ebp)
	addl $4, -16(%ebp)
lbl_adjusted_:
	movl -12(%ebp), %eax
	movl c_getF_numLL, %ebx
        movl %ebx, (%eax)
	movl -16(%ebp), %eax
	addl $1, (%eax)
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
	cmp %eax, %edi
	je lbl_notNew_   # not a new factor
	cmp $0, %eax
	je lbl_notNew_   # not the first factor found
	addl $4, -12(%ebp)
	addl $4, -16(%ebp)
#	addl $1, %esi
lbl_notNew_:
	movl -12(%ebp), %eax
	movl %edi, (%eax)	# add next factor
	movl -16(%ebp), %eax
	addl $1, (%eax)		# and increase its multiplicity
	call foundAll
	cmp $1, %edi
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
	fildll c_getF_numLL
	fsqrt
	fistl c_getF_highestV   # rounds integers (does NOT truncate)
	fisubl c_getF_highestV	# st(0): V - rd(V) -> if > 0, was rounded down
	fldz
	fcomip %st(1), %st(0)
	jl lbl_getSrBound_     # value is already ceiling(V)
	addl $1, c_getF_highestV       # if not, make it
lbl_getSrBound_:	
	ret
# end getSrBound
	
	# Is arg_1 a factor of (c_getF_numLL, c_getF_numLL+4) ?
	.globl isFactor
	.type isFactor, @function
isFactor:
	pushl %ebp
	movl %esp, %ebp

	finit
	fildll c_getF_numLL
	fild 8(%ebp)
	fdivr %st(1)         # divide st(1) by st(0), and store in st(0)  
	frndint              # st(0) - floor(quotient),  st(1) - c_getF_numLL
	fild 8(%esp)
	fmul %st(1), %st(0)  # st(0): f(q) * f, st(1): f(q), st(2): c_getF_numLL
	fcomip %st(2), %st(0)
	jne lbl_isf_not_
	# found a factor
	movl $1, %eax
	fistpll c_getF_numLL  # actual value we want (f(q) == q if we get here)
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

	cmp $1, c_getF_numLL
	jne lbl_fa_not_
	cmp $0, c_getF_numLL + 4
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
