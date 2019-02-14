# John Nover
# jnover@ucsc.edu
# Assignment: Lab 4

#======= Main Program =======#
.data	
	in_msg:	.asciiz "Please enter an unsigned int larger than 2: "
	newline:.asciiz "\n"
	delim:	.asciiz ", " # User friendly output deliminator
.text
	la	$a0, in_msg	# Prompt user 
	li	$v0, 4
	syscall
	li	$v0, 5		# Prompt user for input
	syscall
	move	$s0, $v0	# Save our user input
	bgtu	$s0, 1, checkPrimes
	li	$v0, 10
	syscall

checkPrimes:
	li 	$v0, 9		# Syscall for Dynamic Memory Allocation
	la	$a0, ($s0)	
	syscall
	la	$s1, ($v0) 	# Save memory allocation address to s1
	li	$v0, 9		# Syscall for Dynamic Memory Allocation 
	li	$t0, 1		# Initial value for counting (Ex. counting from 2 to sqrt(n)
	li	$t1, 2		# Initial value for our list of primes.
	move	$t2, $s1
	addu	$t2, $t2, $t0	# Start at index [1]
	li	$t6, 1
	
elimNonPrimes:
	addi	$t0, $t0, 1	# Increment Counter
	mulu	$t4, $t0, $t0	# Square our Counter 
	bgt	$t4, $s0, outputPrimes	# Limit has been reached, move to output
	addu	$t2, $t2, $t0	# Increment Address array index pointer
	la	$t5, ($t2)
	la	$t5, ($t5)
	beqz	$t5, elimNonPrimes
	la	$t3, ($t0)
	move	$t2, $s1	# Start address at 0
primeLoop:
	addu	$t3, $t3, $t0	# Increment counter by multiples of $t0
	addu	$t2, $s1, $t3	# Increment address
	sb	$t6, ($t2)	# Mark number in array as false (1 is false here)
	bgt	$t3, $s0, elimNonPrimes
	beqz	$zero, primeLoop
	
outputPrimes:
	li	$t0, 1
	addi	$s1, $s1, 1
print:
	addi	$t0, $t0, 1	# Counter starting at 1 + 1 (2)
	addi	$s1, $s1, 1	# Address pointer starting at 1 + 1 (2)
	lb	$t1, ($s1)	# Load byte at address of s1
	bltu	$s0, $t0, exit	# End program if $t1 is greater than $s0
	bnez	$t1, print	# Branch if our number is NOT prime (skip it)
	bltu	$t0, 3, printnum	# Dumb check I have to make so I don't have a trailing
	la	$a0, delim		# comma at the end. Only way I could think of
	li	$v0, 4
	syscall	
printnum:
	move	$a0, $t0	# Print out the counter variable (which is our prime number)
	li	$v0, 1
	syscall
	j	print
exit: 	li	$v0, 10		# Exit program
	syscall
