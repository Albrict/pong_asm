%include "raylib.inc"

; -- PROGRAM --
%define width  800
%define height 600
%define fps    60

global main	; the standard gcc entry point

section .rodata                   ; Game variables(window, fps and etc)
field_color  dd 0x759D33          ; Background color
title        db "Pong in ASM", 0 ; Window title

section .data                        ; Game objects
object_color dd 0xFFFFFFFF           ; Color of rackets and ball
left_racket  dd 0, 0, 20, 100        ; Left racket rectangle 
right_racket dd 800 - 20, 0, 20, 100 ; Right racket rectangle

section .text                        ; Code section
main:				                                  ; libc entry point
    init_window    width, height, title           ; Init raylib window
    set_target_fps fps                              ; Set fps
game_cycle:                                           ; Main game cycle
    begin_drawing                                     ; Start drawing
        call  draw 
        call  proccess_input 
        call  check_collision
    end_drawing                                       ; End drawing
    window_should_close                               ; Is window closed
    test eax, eax 
    jz   game_cycle                                   ; Not closed - continue game cycle
end:
    close_window
	mov	rax,0		                                  ; normal, no error, return value
	ret			                                      ; return


; --- FUNCTIONS ---
; Draw function: draw background and game objects
draw:
    push rbp
    clear_background [field_color]                ; Clear background of window
    draw_rectangle   left_racket,  [object_color] ; Draw left racket
    draw_rectangle   right_racket, [object_color] ; Draw right racket
    pop rbp
    ret

; Procces input function: check user input
proccess_input:                       
    push rbp
    is_key_down KEY_W                 ; Call IsKeyDown
    test al, al                       ; Is key down?
    je   .s_check                     ; Check other key 
    sub  dword [left_racket + 4], 10  ; Key is down - change left_racket y value
.s_check:
    is_key_down KEY_S                 ; Call IsKeyDown
    test al, al                       ; Is key down?
    je   .exit                        ; Key is not down - return
    add  dword [left_racket + 4], 10  ; Key is down - change left_racket y value
.exit:                                ; Function exit
    pop rbp
    ret

; Check bounds rectangle: checks if rectangle is out of bounds
check_bounds_rect:
    push rbp                          ; Save base stack pointer in stack
    mov  rbp, rsp 
    mov  eax, [first_arg  + 4]        ; Copy y value into register
    add  eax, [first_arg  + 12]       ; Calculate position
    cmp  eax, height                  ; Check if current position is out of bounds 
    jg  .greater_than_height          ; Out of bounds - change position 
    jmp .zero_check                   ; Check if rectangle is less than zero
.greater_than_height:                  ; Rect is greater than window height
    mov  eax, height         ; Copy current y
    sub  eax, [first_arg + 12]        ; Sub height of rectangle from it's position           
    mov  [first_arg + 4], eax         ; Copy new position into y
    jmp  .exit
.zero_check:
    cmp   dword [left_racket + 4], 0  ; Compare with zero
    jge   .exit                       ; Rectangle is in boundaries - return true
.lesser_than_zero:
    mov dword [first_arg + 4], 0      ; Copy into rectangle y
.exit:                                ; Function exit
    mov rsp, rbp
    pop rbp
    ret

; Check collision: checks collision for all game objects
check_collision:
    push rbp 
    mov  rbp, rsp
    mov  first_arg, left_racket       ; Check collision of first rectangle
    call check_bounds_rect            
    mov  first_arg, right_racket     ; Check collision of second rectangle
    call check_bounds_rect
    mov rsp, rbp
    pop rbp
    ret
 
