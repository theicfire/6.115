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
	djnz r0, done
	; cpl p1.0
	mov r0, #30 ; reset to 30 * 65ms = 2 seconds ish
	mov a, #0h
	cpl p3.2

	; jnb p3.2, writedac
	; mov a, #0ffh ; oscillate between 0 and 2.5 v from dac
	; ; write DAC 
	; writedac:
	; mov dptr, #0FE10h
	; movx @dptr, a
	done:
	mov th0, #0 ; timer 0 255 away
	mov tl0, #0 ; timer 0 255 away ; TODODODODODDO tl0??
	pop acc
	pop dpl
	pop dph
	reti


main:
; =====
; Interrupt setup
mov tmod, #01h ; timer0 mode 2
mov th0, #0 ; timer 0 255 away
mov tl0, #0 ; timer 0 255 away
setb tr0  ; start timer 0
mov r0, #1 ; interrupt keeping this as a multiplier to the 65ms; so it can wait 2 seconds
mov ie, #82h ; enable timer0 interrupt
; =====


mainloop:
lcall read_adc
mov p1, a


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

; pause 1/125th of a second == 8000 microseconds
pause:
	mov r2, #0
	mov r3, #31
	loop2:
	djnz r2, loop2
	djnz r3, loop2
	ret
