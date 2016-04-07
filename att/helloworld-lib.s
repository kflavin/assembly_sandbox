# This program uses a library to write "hello world" and exits
#
# Compile and link as follows using gas and linker:
# $ as -g helloworld-lib.s -o helloworld-lib.o
# $ ld -dynamic-linker /lib64/ld-linux-x86-64.so.2 /usr/lib/x86_64-linux-gnu/crt1.o /usr/lib/x86_64-linux-gnu/crti.o -lc -o helloworld-lib helloworld-lib.o /usr/lib/x86_64-linux-gnu/crtn.o
#
# ...or using gcc
# $ gcc helloworld-lib.s -o helloworld-lib

.section .data

helloworld:
 .ascii "Hello world!\n\0"

.section .text
#.globl _start
#_start:
.globl main
main:
 #pushq $helloworld
 push %rbx
 movq $helloworld, %rdi
 call printf
 pop %rbx
 ret

