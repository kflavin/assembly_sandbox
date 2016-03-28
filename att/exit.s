.section .data
.section .blah

.section .text
.globl _start
_start:
movl $1, %eax
movl $3, %ebx
xor  %edx, %edx
idivl %ebx
movl %esp, %ebx

movl $1, %eax
movl $_start, %ebx

int $0x80
