.section .data

# No data

.section .text

.globl _start
.globl factorial

_start:
 pushq $4
 call factorial
 addq $8, %rsp
 #movq %rax, %rbx
 #movq $1, %rax         # this is the old way to exit (interrupt)
 #int $0x80
 movq %rax, %rdi
 movq $60, %rax         # this is the new way (syscall)
 syscall

.type factorial, @function
factorial:
 pushq %rbp
 movq %rsp, %rbp
 movq 16(%rbp), %rax
 cmpq $1, %rax
 je end_factorial
 decq %rax
 pushq %rax
 call factorial
 movq 16(%rbp), %rbx
 imulq %rbx, %rax

end_factorial:
 movq %rbp, %rsp
 popq %rbp
 ret


