
.section .text

.globl _start
_start:
 popq %rax
 popq %rbx
 popq %rcx

_exit:
 movq 1, %rax
 movq 0, %rbx
 int $0x80
