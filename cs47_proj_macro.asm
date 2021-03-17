# Add you macro definition here - do not touch cs47_common_macro.asm"
#<------------------ MACRO DEFINITIONS ---------------------->#

.macro extract_nth_bit($regD, $regS, $regT)
	addi    $regD, $zero, 1 	
	sllv    $regD, $regD, $regT
	and 	$regD, $regD, $regS
	srlv    $regD, $regD, $regT
.end_macro 

 	
.macro insert_to_nth_bit ($regD, $regS, $regT, $maskReg)
	add $maskReg, $zero, 1
	sllv $maskReg, $maskReg, $regS
	not $maskReg, $maskReg 
	and $regD, $regD, $maskReg
	sllv $regT, $regT, $regS
	or $regD, $regT, $regD
.end_macro


.macro store_enviroment()
	addi	$sp, $sp, -68
	sw	$a0, 68($sp)
	sw	$a1, 64($sp)
	sw	$a2, 60($sp)
	sw	$a3, 56($sp)
	sw	$t0, 52($sp)
	sw	$t1, 48($sp)
	sw	$t2, 44($sp)
	sw	$t3, 40($sp)
	sw	$t4, 36($sp)
	sw	$t5, 32($sp)
	sw	$t6, 28($sp)
	sw	$t7, 24($sp)
	sw	$t8, 20($sp)
	sw	$t9, 16($sp)
	sw	$fp, 12($sp)
	sw 	$ra, 8($sp)
	addi	$fp, $sp, 68
.end_macro

.macro restore_enviroment()
	lw	$a0, 68($sp)
	lw	$a1, 64($sp)
	lw	$a2, 60($sp)
	lw	$a3, 56($sp)
	lw	$t0, 52($sp)
	lw	$t1, 48($sp)
	lw	$t2, 44($sp)
	lw	$t3, 40($sp)
	lw	$t4, 36($sp)
	lw	$t5, 32($sp)
	lw	$t6, 28($sp)
	lw	$t7, 24($sp)
	lw	$t8, 20($sp)
	lw	$t9, 16($sp)
	lw	$fp, 12($sp)
	lw 	$ra, 8($sp)
	addi	$sp, $sp, 68
.end_macro
