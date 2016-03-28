.include "record-def.s"
.include "linux.s"

# This functions reads a record from the file descriptor
# INPUT: File descriptor
# OUTPUT: Writes the data to the buffer and returns a status code

# STACK
 .equ ST_READ_BUFFER, 16
 .equ ST_FILEDES, 12
 .section .text
 .globl read_record
 .type read_record, @function
read_record:
 # standard save base pointer / update to stack pointer
 pushq %rbp
 movq %rsp, %rbp

 pushq %rbx
 movq ST_FILEDES(%rbp), %rdi
 movq ST_READ_BUFFER(%rbp), %rsi
 movq $RECORD_SIZE, %rdx
 movq $SYS_READ, %rax
 syscall

 # %rax has the return value, which we'll pass back to the caller
 popq %rbx

 movq %rbp, %rsp
 popq %rbp
 ret
