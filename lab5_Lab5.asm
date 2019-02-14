# John Nover
# jnover@ucsc.edu
# Assignment: Lab 5
# Section: 1B, M/W 11-12pm
# Due: Monday, 11/26/17 @ 11:59pm
#======= Main Program =======#

.data	
	key_INmsg: 	.asciiz "The given key is: "
	text_INmsg:	.asciiz "\nThe given text is: "
	output1:	.asciiz "\nThe encrypted text is: "
	output2:	.asciiz "\nThe decrypted text is: "
	
.text	

	la	$s0, ($a0)	# Save Program Argument 1
	la	$s1, ($a1)	# Save Program Argument 2 (only ever 2)
	li	$v0, 4
	la 	$a0, key_INmsg	# Print 
	syscall	
	lw	$a0, 0($s1)
	syscall
	la	$a0, text_INmsg
	syscall
	lw	$a0, 4($s1)
	syscall
	
	li	$a0, 104	# Number of bytes to get allocated memory for 
	li	$v0, 9
	syscall
	move	$s4, $v0	

	li	$a0, 104	# Number of bytes to get allocated memory for 
	li	$v0, 9
	syscall
	move	$s5, $v0
	
	la	$a0, 0($s1)	# Argument 1: Address of Key
	la	$a1, 4($s1)	# Argument 2: Address of Cleartext
	la	$a2, ($s4)	# Argument 3: Address of Ciphertext
	jal	Encode		
	li	$v0, 4
	la	$a0, output1
	syscall
	move	$a0, $s4	# Argument 1: String index 0
	jal	print
	
	la	$a0, 0($s1)	# Argument 1: Address of Key
	move	$a1, $s4	# Argument 2: Address of Ciphertext
	move	$a2, $s5	# Argument 3: Address of Cleartext
	jal 	Decode
	li	$v0, 4
	la	$a0, output2
	syscall
	move	$a0, $s5	# Argument 1: Address of String's index 0
	jal	print
	li	$v0, 10
	syscall			# End program
		
# Function Encode START #
Encode:	move	$t0, $a0	# Address of Key
	move	$t1, $a1	# Address of Cleartext
	move	$t6, $a2	# Address of Ciphertext
	lw	$t0, ($t0)
	lw	$t1, ($t1)
	move	$t7, $t0	# Save index 0 of Key
encodeLoop:	
	lb	$t2, ($t0)	# Load next byte of Cleartext
	bnez	$t2, skipReset
	move	$t0, $t7
	j 	encodeLoop
skipReset:
	lb	$t3, ($t1)	# Load next byte of Cleartext
	beqz	$t3, done	# Encoding done if we reach null terminator of Cleartext
	add	$t2, $t2, $t3	# Shift by Key byte ASCII value
	divu	$t2, $t2, 128
	mfhi	$t2
	sb	$t2, ($t6)
	addiu	$t6, $t6, 1	# Offset index of saved address by 1 byte.
	addiu	$t0, $t0, 1	# 0ffset index of Key address by 1 byte.
	addiu	$t1, $t1, 1	# Offset index of Cleartext address by 1 byte.
	beqz	$t3, done	# Encoding done if we reach null terminator of Cleartext
	b	encodeLoop
done:	
	#move	$v0, $t4	# Return length of Ciphertext. I added this so I could make it easier for printing
	jr	$ra
# Function Encode END #
	
# Function Decode START #
Decode:	move	$t0, $a0	# Address of Key
	move	$t1, $a1	# Address of Ciphertext
	move	$t2, $a2	# Address of Cleartext
	lw	$t0, ($t0)
	la	$t6, ($t0)
decodeLoop:
	lb	$t4, ($t0)	# Load byte of Key
	bnez	$t4, skip	# If key reached Null terminator, reset index to 0
	move	$t0, $t6	# Set index of Key back to 0.
	j	decodeLoop
skip:
	lb	$t5, ($t1)	# Load byte of Ciphertext
	beqz	$t5, finish	# Finish if we reached Null Terminator
	sub	$t3, $t5, $t4	# Subtract Key to Cipher
	divu	$t3, $t3, 128
	mfhi	$t3
	sb	$t3, ($t2)	# Store byte into memory
	addiu	$t0, $t0, 1	# Increment Key index by 1
	addiu	$t1, $t1, 1	# Increment Ciphertext index by 1
	addiu	$t2, $t2, 1	# Increment Cleartext index by 1
	j	decodeLoop
finish:
	jr	$ra
# Function Decode END #
	
# Function Print START #
print:
	move	$t0, $a0	# Address of index 0 of string to print
	li	$v0, 11
printLoop:	
	lb	$t2, ($t0)	# Load byte of string
	beqz	$t2, end	
	addi	$t0, $t0, 1	# Increment index by 1
	move	$a0, $t2
	syscall
	j printLoop
end:	jr	$ra
# Function Print END #