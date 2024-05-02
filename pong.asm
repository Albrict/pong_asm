%include "raylib.inc"

; -- PROGRAM --
%define width      800
%define height     600
%define fps        60
%define left_dir   1 
%define right_dir  2

%macro check_collision 0
    check_ball_bounds            ; Check bounds of ball
    mov  first_arg, left_paddle; x and y of rect
    call check_bounds_rect       ; check bounds
    mov  first_arg, right_paddle; x and y of rect
    call check_bounds_rect       ; check bounds
    check_object_collision       ; check collisions for game objects
%endmacro

%macro check_object_collision 0 
_check_object_col:
    movss xmm0, [ball]
    check_collision_circle_rec ball, [ball + 8], left_paddle
    test al, al                       ; Is collided?
    je   .check_right_paddle          ; Not collided, check another
    change_ball_y_velocity left_paddle
    jmp  .invert_direction            ; change direction
.check_right_paddle:
    movss xmm0, [ball]
    check_collision_circle_rec ball, [ball + 8], right_paddle
    test al, al                       ; Is collided?
    je   .exit                        ; Not collided - exit 
    change_ball_y_velocity right_paddle 
.invert_direction:
    movss xmm0, [ball_direction]      ; Copy x value of ball direction
    mulss xmm0, [minus_one]           ; Invert direction 
    movss [ball_direction], xmm0      ; Set direction x to new value
.exit:
%endmacro

; Parameters: paddle address
%macro change_ball_y_velocity 1 
    movss xmm0, [ball + 4] ; y value of ball 
    movss xmm1, [%1 + 12]  ; rect height

    subss xmm0, [%1 + 4]   ; ball.y - paddle.y 
    divss xmm1, [two]      ; paddle.height / 2
    
    divss xmm0, xmm1       ; xmm0 = (ball.y - paddle.y) / (paddle.height / 2)
    mulss xmm0, [velocity] ; xmm0 * 300.0 
    movss [ball_velocity + 4], xmm0
%endmacro

%macro check_ball_bounds 0
_check_ball_x:
    movss  xmm0, [ball]                ; Copy x value of ball
    addss  xmm0, [ball + 8]            ; Current x position of ball

    movss  xmm1, [ball + 4]            ; Copy y value of ball
    addss  xmm1, [ball + 8]            ; Current y position of ball 

    movss  xmm2,  [screen_borders]       ; Copy address of screen borders

    comiss xmm2, xmm0                  ; Is on right side?
    jbe    .greater_than_width         ; In bounds - return, else change position 
    jmp    .zero_check                 ; Check if circle is less than zero
.greater_than_width:                   ; Rect is greater than window height
    inc dword [left_player_score]      ; Increment left player score
    jmp .set_to_center
    jmp .set_random_direction          ; Set random direction for ball
.zero_check:
    pxor   xmm3, xmm3                  ; Set xmm3 to zero(we don't need width anymore)
    comiss xmm3, xmm0                  ; Is ball out of bounds?
    jbe   .exit                        ; Rectangle is in boundaries - return
.lesser_than_zero:
    inc dword [right_player_score]     ; Increment left player score
.set_to_center:
    movss xmm0, [center_pos]           ; Copy center x
    movss xmm1, [center_pos + 4]       ; Copy center y
    movss [ball], xmm0                 ; Copy center x into ball position
    movss [ball + 4], xmm1             ; Copy center y into ball position
.set_random_direction:
    get_random_value left_dir, right_dir ; Get random value for ball direction
    cmp eax, left_dir                    ; Is left dir?
    je  set_to_left                      ; Then set direction to left
    movss xmm0, [positive_one]           ; Else set to right direction
    movq  [ball_direction], xmm0
    jmp .exit 
.set_to_left:
    movss xmm0, [minus_one] 
    movq  [ball_direction], xmm0
    jmp .exit
.exit:
_check_y_bounds:
    movss  xmm1, [ball + 4]            ; Copy y value of ball
    addss  xmm1, [ball + 8]            ; Current y position of ball 

    movss  xmm2,  [screen_borders + 4] ; Copy height of screen borders

    comiss  xmm1, xmm2                 ; Is higher?
    jbe    .zero_check                 ; In bounds - return, else change position 
    jmp    .invert                     ; invert y value
.zero_check:
    pxor   xmm3, xmm3                  ; Set xmm3 to zero(we don't need width anymore)
    movss  xmm1, [ball + 4]            ; check y value
    comiss xmm3, xmm1                  ; Is ball out of bounds?
    jbe   .exit                        ; Rectangle is in boundaries - return
.invert:                               ; Rect is greater than window height
    movss xmm0, [minus_one]            ; xmm0 = (ball.y - paddle.y) / (paddle.height / 2)
    mulss xmm0, [ball_velocity + 4]    ; xmm0 * 300.0 
    movss [ball_velocity + 4], xmm0
.exit:
%endmacro

%macro move_ball 0 
    get_frame_time                    ; Get delta time
    shufps xmm0, xmm0, 0              ; Get float from first index 
    movss xmm1, [ball]                ; ball x position
    movss xmm2, [ball_velocity]       ; Load ball velocity into xmm2
    mulss xmm2, xmm0                  ; Multiply velocity with delta time
    mulss xmm2, [ball_direction]      ; Multiply velocity width direction
    addss xmm1, xmm2                  ; add value to position
    movss [ball], xmm1                ; Update position

    movss xmm1, [ball + 4]            ; y value of ball
    movss xmm2, [ball_velocity + 4]   ; Copy y velocity
    mulss xmm2, xmm0                  ; Multiply with delta time
    addss xmm1, xmm2                  ; And value to position     
    movss [ball + 4], xmm1            ; Update position
%endmacro

%macro proccess_input 0 
    get_frame_time                    ; Get delta time
    shufps xmm0, xmm0, 0              ; Get float from first index 
    is_key_down KEY_W                 ; Call IsKeyDown
    test al, al                       ; Is key down?
    je   .s_check                     ; Check other key 
    movss xmm1, [left_paddle + 4]     ; Load the position into xmm1
    movss xmm2, [paddle_velocity]     ; Load paddle velocity into xmm2
    mulss xmm2, xmm0                  ; Multiply velocity with delta time
    subss xmm1, xmm2                  ; Add new position to current one
    movss [left_paddle + 4], xmm1     ; Set position
.s_check:
    is_key_down KEY_S                 ; Call IsKeyDown
    test al, al                       ; Is key down?
    je   .arrow_up_check              ; Key is not down - return
    movss xmm1, [left_paddle + 4]     ; Load the position into xmm1
    movss xmm2, [paddle_velocity]     ; Load paddle velocity into xmm2
    mulss xmm2, xmm0                  ; Multiply velocity with delta time
    addss xmm1, xmm2                  ; Add new position to current one
    movss [left_paddle + 4], xmm1     ; Set position
.arrow_up_check:
    is_key_down KEY_UP                ; Call IsKeyDown
    test al, al                       ; Is key down?
    je   .arrow_down_check            ; Check other key 
    movss xmm1, [right_paddle + 4]    ; Load the position into xmm1
    movss xmm2, [paddle_velocity]     ; Load paddle velocity into xmm2
    mulss xmm2, xmm0                  ; Multiply velocity with delta time
    subss xmm1, xmm2                  ; Add new position to current one
    movss [right_paddle + 4], xmm1    ; Set position
.arrow_down_check:
    is_key_down KEY_DOWN              ; Call IsKeyDown
    test al, al                       ; Is key down?
    je   .exit                        ; Key is not down - return
    movss xmm1, [right_paddle + 4]     ; Load the position into xmm1
    movss xmm2, [paddle_velocity]     ; Load paddle velocity into xmm2
    mulss xmm2, xmm0                  ; Multiply velocity with delta time
    addss xmm1, xmm2                  ; Add new position to current one
    movss [right_paddle + 4], xmm1     ; Set position
.exit:                                ; Macro exit 
%endmacro

%macro draw 0 
    clear_background   [field_color]                ; Clear background of window
    draw_rectangle_rec left_paddle ,  [object_color]
    draw_rectangle_rec right_paddle, [object_color]
    draw_circle_v      ball, [ball + 8], [object_color]

    format_num         format_str, [right_player_score]
    draw_text          rax, 700, 20, 28, [object_color]

    format_num         format_str, [left_player_score]
    draw_text          rax, 100, 20, 28, [object_color]
%endmacro

global main	; the standard gcc entry point

section .text                                 ; Code section
main:				                          ; libc entry point
    init_window    width, height, title       ; Init raylib window
    set_target_fps fps                        ; Set fps
    get_random_value left_dir, right_dir      ; Get random value for ball direction
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
        draw 
        proccess_input 
        move_ball
        check_collision
    end_drawing                                       ; End drawing
    window_should_close                               ; Is window closed
    test eax, eax 
    jz   game_cycle                                   ; Not closed - continue game cycle
end:
    close_window
	mov	rax,0		                                  ; normal, no error, return value
	ret			                                      ; return

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

section .rodata                                 ; Game variables(window, fps and etc)
field_color        dd 0x759D33                  ; Background color
title              db "Pong in ASM", 0          ; Window title
format_str         dd "%d"                      ; Used in text_format macro 
screen_borders     dd 800.0, 600.0              ; Screen borders
center_pos         dd 400.0, 300.0              ; Center position for ball
object_color       dd 0xFFFFFFFF                ; Color of paddles and ball
velocity           dd 300.0     
minus_one          dd -1.0                      ; Minus one to copy or compare
positive_one       dd 1.0                       ; Positiove one to copy or compare
two                dd 2.0                       ; For calculations 

section .data                                   ; Game objects
ball_velocity      dd 450.0, 0.0                ; Ball velocity
left_paddle        dd 0.0, 250.0, 20.0, 100.0   ; Left paddle position 
right_paddle       dd 780.0, 250.0, 20.0, 100.0 ; Right paddle position
paddle_velocity    dd 660.0                     ; paddle velocity
ball               dd 400.0, 300.0, 10.0        ; Ball position and radius
ball_direction     dd 0.0                       ; Ball current direction
garbage_var        dd 0                         ; 
left_player_score  dd 0                         ; Left player score counter
right_player_score dd 0                         ; Right player score counter
