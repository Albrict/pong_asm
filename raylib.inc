extern  InitWindow
extern  CloseWindow
extern  SetTargetFPS
extern  WindowShouldClose
extern  BeginDrawing
extern  EndDrawing
extern  ClearBackground
extern  DrawRectangle
extern  IsKeyDown 

%ifdef LINUX
    %define first_arg  rdi 
    %define second_arg rsi
    %define third_arg  rdx
    %define fouth_arg  rcx 
    %define fifth_arg  r8
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

; Draw rectangle macro. First argument is address of 16 byte memory
; filled with x, y, width and height. Second argument is rectangle color
%macro draw_rectangle 2
    push rbp
    mov  first_arg,  [%1]       ; x position 
    mov  second_arg, [%1 + 4]   ; y position 
    mov  third_arg,  [%1 + 8]   ; width
    mov  fouth_arg,  [%1 + 12]  ; height
    mov  fifth_arg,  %2         ; color
    call DrawRectangle
    pop  rbp
%endmacro

; Check if key pressed
%macro is_key_down 1
    push rbp          
    mov  first_arg, %1 ; Key code
    call IsKeyDown 
    pop  rbp
%endmacro
