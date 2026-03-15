.PHONY: all clean run

all: server

server: server.asm
	nasm -f elf64 -o server.o server.asm
	ld -o server server.o

clean:
	rm -f server server.o

run: server
	./server
