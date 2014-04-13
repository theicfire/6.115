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

; ; clear display
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

; Write a character

lcall lcdprint
.db "6.115 Rules! Yeahhh", 0h

loop: sjmp loop


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
	mov r1, #10
	loop2:
	djnz r0, loop2
	djnz r1, loop2
	ret
