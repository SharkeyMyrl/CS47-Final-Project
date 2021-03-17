.include "./cs47_proj_macro.asm"
.text
.globl au_logical
#####################################################################
# Implement au_logicalogical
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_logical:
	store_enviroment()

	beq $a2, '+', as_logical
	beq $a2, '-', as_logical
	beq $a2, '*', mul_logical
	beq $a2, '/', div_logical

add_logical:
	store_enviroment()
	
	add $t0, $zero, $zero #I = 0
	add $t8, $zero, $zero #S = 0
	j loop
	
sub_logical:
	store_enviroment()
	
	add $t0, $zero, $zero #I = 0
	add $t8, $zero, $zero #S = 0
	addi $a3, $zero, 1 #SnA = 1
	not $a1, $a1 #Invert Reg B
	j loop

as_logical: #add_logical + sub_logical
	store_enviroment()
	
	add $t0, $zero, $zero #I = 0
	add $t8, $zero, $zero #S = 0
	
	beq $a2, '+', loop
	beq $a2, '*', loop #Use Adder
	addi $a3, $zero, 1 #SnA = 1
	not $a1, $a1 #Invert Reg B
loop:	
	extract_nth_bit($t2, $a0, $t0) #A = A[I]
	extract_nth_bit($t3, $a1, $t0) #B = B[I]
	
	#Full Adder
	#Y=C XOR (A XOR B)
	xor $t4, $t2, $t3 #A XOR B
	xor $t9, $a3, $t4 #C XOR (A XOR B)
	
	#Overflow
	#C=C(A XOR B) + AB
	and $t6, $t2, $t3 #AB
	and $t7, $a3, $t4 #C(A XOR B)
	or $a3, $t7, $t6  #C(A XOR B) + AB
	
	insert_to_nth_bit($t8, $t0, $t9, $t5) #S[I] = Y
	addi $t0, $t0, 1 #I = I + 1	
	bgt $t0, 31, exit				
	j loop
exit:
	move $v0, $t8	#sum
	move $v1, $a3	#carry
	restore_enviroment()
	jr $ra

twos_complement: #Return in $v0 twos complement of negative numbers
	store_enviroment()
	not $a0, $a0 #Invert Values of $a0
	addi $a1, $zero, 1 #Add 1
	jal add_logical
	restore_enviroment()
	jr $ra
	
twos_complement_if_neg: #Check if negative
	store_enviroment()	
	move $v0, $a0
	bge $a0, $zero, else
	jal twos_complement
else:	restore_enviroment()
	jr $ra

twos_complement_64bit:
	store_enviroment()
	
	not $a0, $a0 #Invert
	not $a1, $a1
	mthi $a1
	addi $a1, $zero, 1 #Add 1
	jal as_logical
	mtlo $v0 
	mfhi $a0
	add $a1, $zero, $v1 #Add 1
	jal as_logical
	add $v1, $zero, $v0
	mflo $v0
	
	restore_enviroment()	
	jr $ra

bit_replicator:
	store_enviroment()
	srl $v0, $v0, 31 #bit shift 0
	beq $a0, $zero, bit #If $a0 == 0, restore	
	not $v0, $v0 #Invert $v0
bit:	restore_enviroment()
	jr $ra
	
mul_unsigned:
	store_enviroment()
	add $t0, $zero, $zero #I = 0
	add $t1, $zero, $zero #H = 0
	add $t2, $zero, $a1 #L = 0
	add $t3, $zero, $a0 #M = 0
begin:	
	extract_nth_bit($a0, $t2, $zero) #L[0]
	jal bit_replicator #R = {32{L[0]}}
	and $t6, $t3, $v0 #X = M & R
	
	add $a0, $zero, $t1
	add $a1, $zero, $t6
	
	jal as_logical #H = H + X
	add $t1, $zero, $v0
	
	addi $t4, $zero, 1
	addi $t5, $zero, 31	
	
	srl $t2, $t2, 1 #L = L >> 1
	
	#L[31] = H[0]
	extract_nth_bit($t8, $t1, $zero)   	# $t8 = H[0]
	insert_to_nth_bit($t2, $t5, $t8, $t9)   # L[31] = H[0]
	
	srl $t1, $t1, 1 #H = H >> 1
	addi $t0, $t0, 1 #I = I + 1
	
	bne $t0, 32, begin #Loop if not 32
	add $v0, $zero, $t2
	add $v1, $zero, $t1
	
	restore_enviroment()
	jr $ra

	
mul_logical:  
	store_enviroment()
	add $t6, $a0, $zero #Save input
	add $t7, $a1, $zero
	
	jal twos_complement_if_neg
	add $t8, $v0, $zero
	
	add $a0, $zero, $a1 #Move value prior to 2's complement
	jal twos_complement_if_neg #Flip Hi value
	add $t9, $v0, $zero
	
	add $a0, $t8, $zero 
	add $a1, $t9, $zero
	
	jal mul_unsigned #Sets $v0 and $v1
	
	addi $t1, $zero, 31
	extract_nth_bit($t4, $t6, $t1) #a0[31]
	extract_nth_bit($t5, $t7, $t1) #a1[31]
	add $a0, $v0, $zero 
	add $a1, $v1, $zero
	
	xor $t3, $t4, $t5 #Check if Negative output
	
	beq $t3, $zero, return
	jal twos_complement_64bit
return:	restore_enviroment()
	jr $ra

div_logical:
	store_enviroment()	
	add $t6, $a0, $zero #DVND
	add $t7, $a1, $zero #DVSR
	
	jal twos_complement_if_neg
	add $t8, $v0, $zero
	
	add $a0, $zero, $a1 #Move value prior to 2's complement
	jal twos_complement_if_neg #Flip Hi value
	add $t9, $v0, $zero
	
	add $a0, $t8, $zero #DVND
	add $a1, $t9, $zero #DVSR
	
	jal div_unsigned
	
	addi $t1, $zero, 31
	extract_nth_bit($t4, $t6, $t1) #a0[31]
	extract_nth_bit($t5, $t7, $t1) #a1[31]
	add $t1, $v0, $zero #QTNT
	add $t2, $v1, $zero #RMND
	
	xor $t3, $t4, $t5 #Check if Negative output
	
	beq $t3, $zero, next
	add $a0, $t1, $zero
	jal twos_complement
	add $t1, $v0, $zero
	
next:	beq $t4, $zero, rtrn
	add $a0, $t2, $zero
	jal twos_complement
	add $t2, $v0, $zero
	
rtrn:	
	add $v0, $t1, $zero #QTNT
	add $v1, $t2, $zero #RMND
	restore_enviroment()
	jr $ra

div_unsigned:
	store_enviroment()
	add $t0, $zero, $zero #I = 0
	add $t1, $zero, $zero #R = 0
	add $t2, $zero, $a1 #D = a1
	add $t3, $zero, $a0 #Q = a0
	
div:
	sll $t1, $t1, 1 #R = R << 1
	
	# R[0] = Q[31]
	addi $t9, $zero, 31
	extract_nth_bit($t4, $t3, $t9) #a0[31]
	insert_to_nth_bit($t1, $zero, $t4, $t8)   # R[0] = Q[31]
	
	sll $t3, $t3, 1 #Q = Q << 1
	
	#S = R - D
	add $a0, $t1, $zero
	add $a1, $t2, $zero
	jal as_logical
	
	#S<0
	blt $v0, $zero, iterate
	
	add $t1, $v0, $zero #R=S
	addi $t9, $zero, 1
	insert_to_nth_bit($t3, $zero, $t9, $t8)   # Q[0] = 1
	
iterate:addi $t0, $t0, 1 #I = I + 1	
	
	bne $t0, 32, div #Loop if not 32
	add $v0, $zero, $t3
	add $v1, $zero, $t1
	
	restore_enviroment()
	jr $ra