# John Nover
# jnover@ucsc.edu
# Assignment: Lab 3

#======= Main Program =======#
.data	
	welcome_msg: 	.asciiz "Welcome to Conversion.\n"
	input_msg:	.asciiz "Input Number: "
	output_msg:	.asciiz "\nOutput Number: "
	one:		.asciiz "1"
	zero:		.asciiz "0"
	neg:		.word	45
.text
	move	$s0, $a1	# This is to save the value of the registry a1,
	la 	$a0, welcome_msg
	li	$v0, 4 		# syscall for Printing a string
	syscall
	la	$a0, input_msg	# load welcome message into the parameter
	syscall
	lw	$a0, ($s0)	
	li	$v0, 4 		# syscall for Printing a Char
	syscall
	lw	$s0, ($s0)	# dereference the $a1 pointer again
	lb	$t1, 0($s0)	
	lb	$t2, neg	# Load negative symbol '-' into t2, so we can do a byte comparison
	beq 	$t1, $t2, setNeg# Byte comparison between '-' and the first byte of the input string
	li	$t3, 0		# This is my offset. Since the number is read as positive, we do NOT have to skip the '-', and so offset begins at first byte
	b setNeg_return
setNeg:	li	$t3, 1		# Set offset to 1 because we want to skip the '-' of the negative number string
setNeg_return:
	li	$v0, 4 		# syscall for Printing a String
	la	$a0, output_msg
	syscall
		# Set offset of our input to skip the first byte
	li	$s6, 0		# Register for the storage of the user's input.
	move	$s3, $a1
	lw	$s3, ($s3)
	add	$s3, $s3, $t3	# Move offset right by one
while_readInput:
	lb 	$t2, ($s3)	# Load the Nth byte of our input string
	beqz	$t2, return_readInput	# Break if we have reached the end of the string
	addi	$t2, $t2, -48
	addi	$s3, $s3, 1	# Move offset right by one
	sll	$t4, $s6, 3	# As Prof. Long suggested in Piazza post 373, It is faster for the computer to shift by 3, shift by 1, then add the two numbers
	sll	$t5, $s6, 1	# So I decided to use that method instead of using the mult instruction.
	addu	$s6, $t4, $t5 	# addition of the two shifts
	addu	$s6, $s6, $t2	# Adding the number we just read into the stored input
	b while_readInput
return_readInput:	# To convert a number to binary, we must make 32 bit masks
			# We start at the leftmost bit, and right shift
	beq 	$t3, 1, invert
invert_return:
	li 	$t1, 32		# Counter, so we can output 32 characters (4 bytes worth of bits)
	li 	$t0, 2147483648 # This is 2 ^ 31, which is basically a 10000...0000 (32 bits long)
	b	while_OutputLoop
returnOutput:	
	li	$v0, 10 	# syscall for Exiting the program
	syscall

invert: not	$s6, $s6	# Two's complement: Invert number, then add 1.
	addu 	$s6, $s6, 1	# adding 1 (without overflow)
	b 	invert_return	# Branching back to our main code

while_OutputLoop:
	beqz	$t1, returnOutput
	and	$s2, $t0, $s6	# AND the two numbers, our Mask, and our Input.
	beqz	$s2, printZero	# If our AND result is 0, we print 0
	b	printOne	# Else, we print 1
returnPrint:
	srl	$t0, $t0, 1
	addi 	$t1, $t1, -1
	b 	while_OutputLoop
printZero:	la 	$a0, zero	# Print 0
		syscall
		b 	returnPrint
printOne: 	la 	$a0, one	# Print 1
		syscall
		b 	returnPrint
