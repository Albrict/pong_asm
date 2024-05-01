%include "raylib.inc"

; -- PROGRAM --
%define width           800
%define height          600
%define width_f         800.0
%define height_f        600.0
%define fps             60

global main	; the standard gcc entry point

section .rodata                   ; Game variables(window, fps and etc)
field_color  dd 0x759D33          ; Background color
title        db "Pong in ASM", 0 ; Window title

section .data                                 ; Game objects
left_racket     dd 0.0, 0.0, 20.0, 100.0      ; Left racket position 
right_racket    dd 780.0, 0.0, 20.0, 100.0    ; Right racket position
racket_velocity dd 0.0, 460.0                 ; Racket velocity
screen_borders  dd 800.0, 600.0               ; Screen borders
zero            dd 0.0, 0.0, 0.0, 0.0         ; Zero values to check for
object_color    dd 0xFFFFFFFF                 ; Color of rackets and ball

section .text                                         ; Code section
main:				                                  ; libc entry point
    init_window    width, height, title               ; Init raylib window
    set_target_fps fps                                ; Set fps
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
    draw_rectangle_rec left_racket,  [object_color]
    draw_rectangle_rec right_racket, [object_color]
    pop rbp
    ret

; Procces input function: check user input
proccess_input:                       
    push rbp
    get_frame_time                    ; Get delta time
    shufps xmm0, xmm0, 0              ; Get float from first index 
    is_key_down KEY_W                 ; Call IsKeyDown
    test al, al                       ; Is key down?
    je   .s_check                     ; Check other key 
    movq  xmm1, [left_racket]         ; Load the position into xmm1
    movq  xmm2, [racket_velocity]     ; Load racket velocity into xmm2
    mulps xmm2, xmm0                  ; Multiply velocity with delta time
    subps xmm1, xmm2                  ; Add new position to current one
    movq  [left_racket], xmm1         ; Set position
.s_check:
    is_key_down KEY_S                 ; Call IsKeyDown
    test al, al                       ; Is key down?
    je   .exit                        ; Key is not down - return
    movq  xmm1, [left_racket]         ; Load the position into xmm1
    movq  xmm2, [racket_velocity]     ; Load racket velocity into xmm2
    mulps xmm2, xmm0                  ; Multiply velocity with delta time
    addps xmm1, xmm2                  ; Add new position to current one
    movq  [left_racket], xmm1         ; Set position
.exit:                                ; Function exit
    pop rbp
    ret

; Check bounds rectangle: checks if rectangle is out of bounds
check_bounds_rect:
    push  rbp                          ; Save base stack pointer in stack
    mov   rbp, rsp 
    movss  xmm0, [first_arg + 4] 
    comiss xmm0, [screen_borders + 4] 
    je  end; Out of bounds - change position 
;    jmp .zero_check                   ; Check if rectangle is less than zero
.greater_than_height:                 ; Rect is greater than window height
     
;    mov  eax, height                  ; Copy current y
;    sub  eax, [first_arg + 12]        ; Sub height of rectangle from it's position           
;    mov  [first_arg + 4], eax         ; Copy new position into y
;    jmp  .exit
;.zero_check:
;    cmp   dword [first_arg + 4], 0  ; Compare with zero
;    jge   .exit                       ; Rectangle is in boundaries - return true
;.lesser_than_zero:
;    mov dword [first_arg + 4], 0      ; Copy into rectangle y
;.exit:                                ; Function exit
    mov rsp, rbp
    pop rbp
    ret

; Check collision: checks collision for all game objects
check_collision:
    push rbp 
    mov  rbp, rsp
    mov  first_arg, left_racket      ; Check collision of first rectangle
    call check_bounds_rect           ;  
    mov  first_arg, right_racket     ; Check collision of second rectangle
    call check_bounds_rect
    mov rsp, rbp
    pop rbp
    ret
 
