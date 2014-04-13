.org 00h
ljmp main

.org 100h
main:
; ===========SETUP AND WRITE TO LCD===============
; Activate 8255 (all output)
mov a, #80h
mov dptr, #0fe23h ; 2b in page
movx @dptr, a

; ; set display for 8 bit communication, 5x7 char set
mov a, #00h
mov dptr, #0fe22h
movx @dptr, a

mov a, #38h
mov dptr, #0fe21h
movx @dptr, a

mov a, #04h
mov dptr, #0fe22h
movx @dptr, a

mov a, #00h
mov dptr, #0fe22h
movx @dptr, a

lcall pause ; WAIT after display clear
; turn display on; hide cursor
mov a, #0Fh
mov dptr, #0fe21h
movx @dptr, a

mov a, #04h
mov dptr, #0fe22h
movx @dptr, a

mov a, #00h
mov dptr, #0fe22h
movx @dptr, a

lcall pause ; WAIT after display clear
lcall cleardisplay



; Write a character

lcall lcdprint
.db "6.115 Rules! Yeahhh", 0h
ljmp mainloop


lcdprint:
   pop   dph              ; put return address in dptr
   pop   dpl
prtstr:
   clr  a                 ; set offset = 0
   movc a,  @a+dptr       ; get chr from code memory
   cjne a,  #0h, mchrok   ; if termination chr, then return
   sjmp prtdone
mchrok:
   lcall lcdwrite           ; send character
   inc   dptr             ; point at next character
   sjmp  prtstr           ; loop till end of string
prtdone:
   mov   a,  #1h          ; point to instruction after string
   jmp   @a+dptr          ; return

; r2 is the character to write
lcdwrite:
	push dph
	push dpl

	lcall pause ; WAIT for a bit....
	mov r2, a
	mov a, #01h
	mov dptr, #0fe22h
	movx @dptr, a

	mov a, r2
	mov dptr, #0fe21h
	movx @dptr, a

	mov a, #05h
	mov dptr, #0fe22h
	movx @dptr, a

	mov a, #01h
	mov dptr, #0fe22h
	movx @dptr, a
	pop dpl
	pop dph
	ret

pause:
	mov r0, #0
	mov r1, #20
	loop2:
	djnz r0, loop2
	djnz r1, loop2
	ret

; ===========END SETUP AND WRITE TO LCD===============







mainloop:

; Write to ADC
mov a, #00h
mov dptr, #0FE30h
movx @dptr, a
; Wait for ADC to compute
lcall pause
; Read ADC value
mov dptr, #0FE30h
movx a, @dptr

mov p1, a

; HARDCODE TODO REMOVE
; mov a, #135

; ; convert to 0-500v
; ; 500 IN BINARY: 1 1111 0100 (note the 2 bytes)
mov r1, #01h ; high byte of 500
mov r0, #0f4h ; low byte of 500
mov r2, a
; Multiply a by 500 (r0 and r1)
mov b, r0
mul ab
mov r3, a ; save lowest byte
push b 
mov a, r2
mov b, r1
mul ab
pop 7
add a, r7

mov r4, a ; save second lowest
clr a
addc a, b
mov r5, a ; save highest
; solution in r5, r4, r3 (in order).
; We can drop r3, because we are dividing by 256

; mov p1, r4 ; display middle byte

; WRITE to LCD
lcall cleardisplay
mov a, r5
mov r7, a
mov a, r4
; mov p1, a
lcall hundredsdottens
lcall pauselong

sjmp mainloop

pauselong:
	mov r0, #0
	mov r1, #0
	mov r2, #3
	; mov r2, #1
	loop3:
	djnz r0, loop3
	djnz r1, loop3
	djnz r2, loop3
	ret

; Given r7, the msb and a, the lsb, print the hundreds '.' tens place
; r7 should be 1 or 0, because the overall answer is 0-500
hundredsdottens:
	clr c 
	add a, #5 ; We are rounding to the nearest 10, so adding this and then dropping the lowest number does that
	jnc yeshighbit
	mov r7, #1 ; handle overflow to r7

	yeshighbit:
	djnz r7, nohighbit
	add a, #11 ; 11 is 5 + 6, where the 6 came from 256 from the high bit
	mov b, #10
	div ab
	mov b, #10
	add a, #25; 25 is for 256/10. This can now "fit" in the lower byte
	div ab
	mov r6, b
	add a, #48
	lcall lcdwrite
	mov a, #46
	lcall lcdwrite
	mov a, #48
	add a, r6
	lcall lcdwrite
	ret

	nohighbit:
	; mov p1, a
	mov b, #10
	div ab
	mov b, #10
	div ab
	mov r6, b
	add a, #48
	lcall lcdwrite
	mov a, #46
	lcall lcdwrite
	mov a, #48
	add a, r6
	lcall lcdwrite
	ret

cleardisplay:
	mov a, #01h
	mov dptr, #0fe21h
	movx @dptr, a

	mov a, #04h
	mov dptr, #0fe22h
	movx @dptr, a

	mov a, #00h
	mov dptr, #0fe22h
	movx @dptr, a

	lcall pause ; WAIT after display clear

	; ; set RAM to zero
	mov a, #00h
	mov dptr, #0fe22h
	movx @dptr, a

	mov a, #80h
	mov dptr, #0fe21h
	movx @dptr, a

	mov a, #04h
	mov dptr, #0fe22h
	movx @dptr, a

	mov a, #00h
	mov dptr, #0fe22h
	movx @dptr, a

	lcall pause ; WAIT after display clear
	ret
