%include "raylib.inc"

; -- PROGRAM --
%define width           800
%define height          600
%define fps             60
%define left_dir        1 
%define right_dir       2

global main	; the standard gcc entry point

section .rodata                   ; Game variables(window, fps and etc)
field_color  dd 0x759D33          ; Background color
title        db "Pong in ASM", 0 ; Window title

section .data                                 ; Game objects
left_racket     dd 0.0, 0.0, 20.0, 100.0      ; Left racket position 
right_racket    dd 780.0, 0.0, 20.0, 100.0    ; Right racket position
racket_velocity dd 660.0                      ; Racket velocity
ball            dd 400.0, 300.0, 10.0         ; Ball position and radius
ball_velocity   dd 450.0                      ; Ball velocity
ball_direction  dd 0.0                        ; Ball current direction
minus_one       dd -1.0                       ; Minus one to copy or compare
positive_one    dd 1.0                        ; Positiove one to copy or compare
screen_borders  dd 800.0, 600.0               ; Screen borders
object_color    dd 0xFFFFFFFF                 ; Color of rackets and ball

section .text                                         ; Code section
main:				                                  ; libc entry point
    init_window    width, height, title               ; Init raylib window
    set_target_fps fps                                ; Set fps
    get_random_value left_dir, right_dir              ; Get random value for ball direction
    cmp eax, left_dir
    je  set_to_left
    movss xmm0, [positive_one] 
    movq  [ball_direction], xmm0
    jmp game_cycle
set_to_left:
    movss xmm0, [minus_one] 
    movq  [ball_direction], xmm0
game_cycle:                                           ; Main game cycle
    begin_drawing                                     ; Start drawing
        call  draw 
        call  proccess_input 
        call  move_ball
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
    draw_circle_v      ball, [ball + 8], [object_color]
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
    movss xmm1, [left_racket + 4]     ; Load the position into xmm1
    movss xmm2, [racket_velocity]     ; Load racket velocity into xmm2
    mulss xmm2, xmm0                  ; Multiply velocity with delta time
    subss xmm1, xmm2                  ; Add new position to current one
    movss [left_racket + 4], xmm1     ; Set position
.s_check:
    is_key_down KEY_S                 ; Call IsKeyDown
    test al, al                       ; Is key down?
    je   .exit                        ; Key is not down - return
    movss xmm1, [left_racket + 4]     ; Load the position into xmm1
    movss xmm2, [racket_velocity]     ; Load racket velocity into xmm2
    mulss xmm2, xmm0                  ; Multiply velocity with delta time
    addss xmm1, xmm2                  ; Add new position to current one
    movss [left_racket + 4], xmm1     ; Set position
.exit:                                ; Function exit
    pop rbp
    ret

move_ball:
    push rbp
    get_frame_time                    ; Get delta time
    shufps xmm0, xmm0, 0              ; Get float from first index 
    movss xmm1, [ball]                ; ball x position
    movss xmm2, [ball_velocity]       ; Load racket velocity into xmm2
    mulss xmm2, xmm0                  ; Multiply velocity with delta time
    mulss xmm2, [ball_direction]      ; Direction
    addss xmm1, xmm2
    movss [ball], xmm1
    pop rbp
    ret
; Check bounds rectangle: checks if rectangle is out of bounds
check_bounds_rect:
    push   rbp                          ; Save base stack pointer in stack
    mov    rbp, rsp 
    movss  xmm0, [first_arg + 4]       ; y value
    movss  xmm1, [screen_borders + 4]  ; Height
    addss  xmm0, [first_arg + 12]      ; Calculate position
    comiss xmm1, xmm0                  ; is out of bounds?
    jbe    .greater_than_height        ; In bounds - return, else change position 
    jmp    .zero_check                 ; Check if rectangle is less than zero
.greater_than_height:                  ; Rect is greater than window height
    movss  xmm0, [screen_borders + 4]  ; Copy height of the screen     
    subss  xmm0, [first_arg + 12]      ; Sub height of the rect from height
    movss  [first_arg + 4], xmm0      
.zero_check:
     pxor   xmm0, xmm0                 ; Set xmm0 to zero
     movss  xmm1, [first_arg + 4]      ; Copy y value into xmm1
     comiss xmm0, xmm1                 ; Is rectangle out of bound?
     jbe   .exit                       ; Rectangle is in boundaries - return
.lesser_than_zero:
     movss [first_arg + 4], xmm0       ; Copy zero into rectangle y
.exit:                                 ; Function exit
    mov rsp, rbp
    pop rbp
    ret

; Check collision: checks collision for all game objects
check_collision:
    push rbp 
    mov  rbp, rsp
    mov  first_arg, left_racket  ; x and y of rect
    call check_bounds_rect       ; check bounds
    mov  first_arg, right_racket ; x and y of rect
    call check_bounds_rect       ; check bounds
    mov rsp, rbp
    pop rbp
    ret
