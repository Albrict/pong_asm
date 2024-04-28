%include "raylib.inc"

global main	; the standard gcc entry point

section .rodata
; Game variables(window, fps and etc)
width        dd 800               ; Window width
height       dd 600               ; Window height
fps          dd 60                ; FPS
field_color  dd 0x759D33          ; Background color
title        db "Hello from NASM", 0 ; Window title

; Game objects
object_color dd 0xFFFFFFFF      ; Color of rackets and ball
left_racket  dd 0, 0, 20, 100 ; Left racket rectangle 
right_racket dd width - 20, 0, 20, 100
section .text ; Code section.
main:				                                  ; libc entry point
    init_window    [width], [height], title           ; Init raylib window
    set_target_fps [fps]                              ; Set fps
game_cycle:                                           ; Main game cycle
    begin_drawing                                     ; Start drawing
        clear_background [field_color]                ; Clear background of window
        draw_rectangle   left_racket,  [object_color] ; Draw left racket
        draw_rectangle   right_racket, [object_color]
    end_drawing                                       ; End drawing
    window_should_close                               ; Is window closed
    test eax, eax 
    jz   game_cycle                                   ; Not closed - continue game cycle
end:
	mov	rax,0		                                  ; normal, no error, return value
	ret			                                      ; return
