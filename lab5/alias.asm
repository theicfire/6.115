.org 00h
ljmp main

.org 0bh
	ljmp t0sr
.org 100h

;T0 Interrupt routing
t0sr: 
	push dph
	push dpl
	push acc
	mov th0, #0fch ; to get 1000 hz
	mov tl0, #067h
	lcall read_adc
	lcall write_dac
	pop acc
	pop dpl
	pop dph
	reti


main:
; =====
; Interrupt setup
mov tmod, #01h ; timer0 mode 2
setb tr0  ; start timer 0
; mov th0, #0h
mov r0, #1 ; interrupt keeping this as a multiplier to the 65ms; so it can wait 2 seconds
mov ie, #82h ; enable timer0 interrupt
; =====


mainloop:
; lcall read_adc
; mov p1, a


ljmp mainloop



read_adc:
	; Write to ADC
	mov a, #00h
	mov dptr, #0FE30h
	movx @dptr, a
	; Wait for ADC to compute
	lcall pause
	; Read ADC value
	mov dptr, #0FE30h
	movx a, @dptr
	ret

write_dac:
	mov dptr, #0FE10h
	movx @dptr, a
	ret

; pause 1/125th of a second == 8000 microseconds
pause:
	mov r2, #0
	mov r3, #31
	loop2:
	djnz r2, loop2
	djnz r3, loop2
	ret
