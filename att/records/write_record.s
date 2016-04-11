# To compile as a shared library
# $ ld -shared write-record.o read-record.o -o librecord.so

.include "linux.s"
.include "record-def.s"

# writes a record to the given file descriptor
# INPUT: the file descriptor and buffer
# OUTPUT: the status code

#STACK
 .equ ST_WRITE_BUFFER, 16
 .equ ST_FILEDES, 24
 .section .text
 .globl write_record
 .type write_record, @function
write_record:
 pushq %rbp
 movq %rsp, %rbp

 pushq %rbx
 movq $SYS_WRITE, %rax
 movq ST_FILEDES(%rbp), %rdi
 movq ST_WRITE_BUFFER(%rbp), %rsi
 movq $RECORD_SIZE, %rdx
 syscall

 # %rax as the return value which we will give back to the caller
 popq %rbx

 movq %rbp, %rsp
 popq %rbp
 ret
