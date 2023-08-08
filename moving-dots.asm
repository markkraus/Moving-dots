.include "moving-dots_include.asm"

.eqv NUM_DOTS 3

.data
	dotX: .word 10, 30, 50
	dotY: .word 20, 30, 40
	curDot: .word 0
.text
.globl main
main:
	# when done at the beginning of the program, clears the display
	# because the display RAM is all 0s (black) right now.
	jal display_update_and_clear

	_loop:
		# code goes here!
		jal check_input
		jal wrap_dot_position
		jal draw_dots
		jal display_update_and_clear
		jal sleep
	j _loop

	li v0, 10
	syscall

#-----------------------------------------

# new functions go here!
draw_dots:
push ra
push s0
	#s0 = 0
	li s0, 0
	
	#for(){
	_loop:
		#t0 = s0 * 4
		mul t0, s0, 4
		
		#a0 = dotX(t0)
		lw a0, dotX(t0)
		
		#a1 = dotY(t0)
		lw a1, dotY(t0)
		
		#if(){
		_if:
			#t1 = curDot
			lw t1, curDot
			
			#s0 != curDot ->  _else
			bne s0, t1, _else
			
			#a2 = COLOR_ORANGE
			li a2, COLOR_ORANGE
			j _break
		#else(){
		_else:
			#a2 = COLOR_WHITE
			li a2, COLOR_WHITE	
		#}	
		
		_break:
		#}
		
		#display_set_pixel()
		jal display_set_pixel
	
		#s0++
		add s0, s0, 1
		#s0 < NUM_DOTS
		blt s0, NUM_DOTS, _loop
		
	#}
	
_return:
pop s0
pop ra
jr ra	

#-----------------------------------------
check_input:
push ra
	jal input_get_keys_held
	
	#if((v0 & KEY_Z) != 0) curDot = 0
	and t0, v0, KEY_Z
	beq t0, 0, _endif_z
		li t0, 0
		sw t0, curDot
	_endif_z:
	
	#if((v0 & KEY_X) !0) curDot = 1
	and t0, v0, KEY_X
	beq t0, 0, _endif_x
		li t0, 1
		sw t0, curDot
	_endif_x:
	
	#if((v0 & KEY_C) != 0) curDot = 2
	and t0, v0, KEY_C
	beq t0, 0, _endif_c
		li t0, 2
		sw t0, curDot	
	_endif_c:
	
	#t9 = curDot, t9 *= 4
	lw t9, curDot
	mul t9, t9, 4
	#DONT change T9 REGISTER!
	
	#if ((v0 & KEY_R) != 0) dotX[curDot++]
	and t0, v0, KEY_R
	beq t0, 0, _endif_r
		lw t1, dotX(t9)
		add t1, t1, 1
		sw t1, dotX(t9)
	_endif_r:
	
	#if((v0 & KEY_L) != 0) dotX[curDot--]
	and t0, v0, KEY_L
	beq t0, 0, _endif_l
		lw t1, dotX(t9)
		sub t1, t1, 1
		sw t1, dotX(t9)
	_endif_l:
	
	#if((v0 & KEY_D) != 0) dotY[curDot++]
	and t0, v0, KEY_D
	beq t0, 0, _endif_d
		lw t1, dotY(t9)
		add t1, t1, 1
		sw t1, dotY(t9)
	_endif_d:
	
	#if((v0 & KEY_U) != 0) dotY[curDot--]
	and t0, v0, KEY_U
	beq t0, 0, _endif_u
		lw t1, dotY(t9)
		sub t1, t1, 1
		sw t1, dotY(t9)
	_endif_u:
pop ra
jr ra
#-----------------------------------------
wrap_dot_position:
push ra
	#dotX[curDot] = dotX[curDot] & 63
	lw t0, dotX(t9)
	and t0, t0, 63
	sw t0, dotX(t9)
	
	#dotY[curDot] = dotY[curDot] & 63
	lw t0, dotY(t9)
	and t0, t0, 63
	sw t0, dotY(t9)
pop ra
jr ra
#-----------------------------------------
