extern  InitWindow
extern  CloseWindow
extern  SetTargetFPS
extern  WindowShouldClose
extern  BeginDrawing
extern  EndDrawing
extern  ClearBackground
extern  DrawRectangle
extern  IsKeyDown 
extern  DrawRectangleRec
extern  GetFrameTime
extern  DrawCircleV
extern  GetRandomValue
extern  CheckCollisionCircleRec
extern  TextFormat
extern  DrawText
extern  TextFormat

%ifdef LINUX
    %define first_arg  rdi 
    %define second_arg rsi
    %define third_arg  rdx
    %define fouth_arg  rcx 
    %define fifth_arg  r8
    %define vector_arg rax

    %define first_float_arg  xmm0
    %define second_float_arg xmm1
    %define third_float_arg  xmm2
    %define fouth_float_arg  xmm3
%elifdef WINDOWS 

%else
%error Please define OS
%endif

%define KEY_W    87
%define KEY_S    83
%define KEY_UP   265
%define KEY_DOWN 264

%macro init_window 3
    push rbp
    mov  first_arg,  %1 ; Window width
    mov  second_arg, %2 ; Window height
    mov  third_arg,  %3 ; Window title
    call InitWindow
    pop  rbp 
%endmacro

%macro close_window 0
    push rbp
    call CloseWindow 
    pop  rbp 
%endmacro

%macro get_frame_time 0
    push rbp
    call GetFrameTime
    pop  rbp
%endmacro

%macro set_target_fps 1
    push rbp  
    mov  first_arg, %1 ; FPS 
    call SetTargetFPS 
    pop  rbp   
%endmacro

%macro begin_drawing 0
    push rbp    
    call BeginDrawing 
    pop  rbp     
%endmacro

%macro end_drawing 0
    push rbp      
    call EndDrawing
    pop  rbp       
%endmacro

%macro window_should_close 0
    push rbp        
    call WindowShouldClose 
    pop  rbp        
%endmacro

%macro clear_background 1
    push rbp             ; Set up stack frame
    mov  first_arg, %1   ; Set color
    call ClearBackground 
    pop  rbp             ; Restore stack
%endmacro


%macro draw_rectangle_rec 2
    push rbp
    movq first_float_arg, [%1]     ; Rectangle x and y
    movq second_float_arg, [%1 + 8] ; Rectangle width and height
    mov  first_arg, %2  ; Color of rectangle
    call DrawRectangleRec
    pop  rbp
%endmacro

%macro draw_circle_v 3
    push rbp
    movq  first_float_arg,  [%1]; Circle x and y
    movss second_float_arg, %2  ; Radius
    mov   first_arg, %3         ; Color of circle
    call DrawCircleV 
    pop  rbp
%endmacro

%macro get_random_value 2
    push rbp
    mov  first_arg,  %1 ; Minimal value
    mov  second_arg, %2 ; Max value
    call GetRandomValue
    pop  rbp
%endmacro

%macro check_collision_circle_rec 3
    push rbp 
    movq  first_float_arg,  [%1]     ; Circle x and y
    movss second_float_arg,  %2      ; Radius of circle
    movq  third_float_arg,  [%3]     ; Rectangle x and y 
    movq  fouth_float_arg,  [%3 + 8] ; Rectangle width and height
    call  CheckCollisionCircleRec
    pop  rbp
%endmacro

%macro draw_text 5
    push rbp
    mov first_arg, %1  ; Text
    mov second_arg, %2 ; x position
    mov third_arg, %3  ; y position
    mov fouth_arg, %4  ; font size
    mov fifth_arg, %5  ; color
    call DrawText
    pop rbp
%endmacro

%macro format_num 2 
    push rbp
    mov first_arg,  %1 ; Text
    mov second_arg, %2 ; Number 
    mov vector_arg,  0 ; vector args
    call TextFormat
    pop rbp
%endmacro

; Check if key pressed
%macro is_key_down 1
    push rbp          
    mov  first_arg, %1 ; Key code
    call IsKeyDown 
    pop  rbp
%endmacro
