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

%ifdef LINUX
    %define first_arg  rdi 
    %define second_arg rsi
    %define third_arg  rdx
    %define fouth_arg  rcx 
    %define fifth_arg  r8

    %define first_float_arg  xmm0
    %define second_float_arg xmm1
%elifdef WINDOWS 

%else
%error Please define OS
%endif

%define KEY_W 87
%define KEY_S 83

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

; Check if key pressed
%macro is_key_down 1
    push rbp          
    mov  first_arg, %1 ; Key code
    call IsKeyDown 
    pop  rbp
%endmacro
