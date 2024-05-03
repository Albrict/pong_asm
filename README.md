# Pong in ASM
Pong game in assembly. Written using NASM, GCC(for linking) and [raylib](https://github.com/raysan5/raylib)

Most of the code is macros. Although perhaps some part of macros should have been turned into functions. Also, this code is written for x86-64 CPU, because call convention of functions is much more convenient on it, and I wanted to study it for a long time, because I knew only x86 instructions. There are many places for optimizations here: use packed instructions, branchless programming, etc.

Currenly code works only on Linux

## How to compile
### Linux
To compile this project on Linux, you will need NASM assembler and GCC for linking and also Raylib, then:

`git clone https://github.com/Albrict/pong_asm.git`

Then
`cd pong_asm && make`

## Game demonstration:

https://github.com/Albrict/pong_asm/assets/65279613/82e5e052-05c6-48d5-b9d6-8ae198956e33

