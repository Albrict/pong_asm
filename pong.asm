extern	printf		; the C function, to be called
extern  InitWindow
global main		    ; the standard gcc entry point

section .data		        ; Data section, initialized variables
width  dd 800
height dd 600
title  db "Hello from NASM"

section .text           ; Code section.
main:				    ; the program label for the entry point
    push    rbp		    ; set up stack frame, must be alligned
	
	mov	rdi, [width]
	mov	rsi, [height]
    mov rdx, title
	mov	rax, 0		    ; or can be  xor  rax,rax
    call    InitWindow  ; Call C function

	pop	rbp		        ; restore stack

	mov	rax,0		    ; normal, no error, return value
	ret			        ; return
