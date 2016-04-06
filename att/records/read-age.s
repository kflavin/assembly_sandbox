.include "linux.s"
.include "record-def.s"

.section .data
file_name:
 .ascii "test.dat\0"

.section .bss
.lcomm record_buffer, RECORD_SIZE

.section .text
.globl _start
_start:
 # These are the locations on the stack where we will store input/output descriptors
 .equ ST_INPUT_DESCRIPTOR, -8
 .equ ST_OUTPUT_DESCRIPTOR, -16

 # Copy the stack pointer to %rbp
 movq %rsp, %rbp
 # Allocate stack space to hold the file descriptors
 subq $16, %rsp

 # Open the file
 movq $SYS_OPEN, %rax
 movq $file_name, %rdi
 movq $0, %rsi      # This says to open read only
 movq $0666, %rdx
 syscall

 # Save the file descriptor we get back
 movq %rax, ST_INPUT_DESCRIPTOR(%rbp)

 # Even though STDOUT is a constant, we're saving it in case we want to change it to something else later
 movq $STDOUT, ST_OUTPUT_DESCRIPTOR(%rbp)

record_read_loop:
 movq $5, %rdx
 movq ST_OUTPUT_DESCRIPTOR(%rbp), %rdi
 movq $SYS_WRITE, %rax
 #movq $RECORD_AGE + record_buffer, %rsi
 movq $99, %rsi
 syscall

 pushq ST_OUTPUT_DESCRIPTOR(%rbp)
 call write_newline
 addq $8, %rsp

 #jmp record_read_loop

finished_reading:
 movq $SYS_EXIT, %rax
 movq $0, %rdi
 syscall


