.section .text

.globl _start
_start:
 movq 8(%rsp), %rcx
 nop
 popq %rsi
 movq %rbx, %rdi
 movq $1, %rax
 movq $1, %rbx
