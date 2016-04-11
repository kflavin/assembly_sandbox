# To compile as a shaerd library
# $ ld -shared write-record.o read-record.o -o librecord.so

.include "record-def.s"
.include "linux.s"

# Read a record from the file
# INPUT: The file descriptor and buffer
# OUTPUT: This function writes data to the buffer and returns a status code

# STACK LOCAL VARS
.equ ST_READ_BUFFER, 16
.equ ST_FILEDES, 24
.section .text
.globl read_record
.type read_record, @function
read_record:
 pushq %rbp
 movq %rsp, %rbp

 pushq %rbx
 movq ST_FILEDES(%rbp), %rdi
 movq ST_READ_BUFFER(%rbp), %rsi
 movq $RECORD_SIZE, %rdx
 movq $SYS_READ, %rax
 syscall

 # %rax has the return value which we will pass back to calling program
 popq %rbx
 movq %rbp, %rsp
 popq %rbp
 ret

