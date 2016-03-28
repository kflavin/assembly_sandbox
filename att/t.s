.section .data
.equ SYS_OPEN, 2

.section .text
.globl _start
_start:
 movq SYS_OPEN, %rax
