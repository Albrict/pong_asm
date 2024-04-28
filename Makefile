pong: pong.o
	gcc -m64 -no-pie pong.o -lraylib -lm -o pong 
pong.o: pong.asm
	nasm -f elf64 -dLINUX -g pong.asm
