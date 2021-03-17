.include "./cs47_proj_macro.asm"
.text
.globl au_normal
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_normal
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_normal:
	
	beq $a2, '+', add_normal
	beq $a2, '-', sub_normal
	beq $a2, '*', mul_normal
	beq $a2, '/', div_normal

add_normal:
	add $v0, $a0, $a1
	jr	$ra

sub_normal:
	sub $v0, $a0, $a1
	jr	$ra

mul_normal:
	mult $a0, $a1
	mflo $v0
	mfhi $v1
	jr	$ra

div_normal:
	div $a0, $a1 
	mflo $v0
	mfhi $v1
	jr	$ra
