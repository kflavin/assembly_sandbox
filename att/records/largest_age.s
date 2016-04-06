# Find the record with the largest age

.include "linux.s"
.include "record-def.s"

.section .data
input_file_name:
 .ascii "test.dat\0"

.equ INPUT_FD, -8
.equ MAX_AGE, -16

.section .bss
 .lcomm record_buffer, RECORD_SIZE

.section .text
.globl _start
_start:
 movq %rsp, %rbp
 subq $16, %rsp

 # Open the file
 movq $SYS_OPEN, %rax
 movq $input_file_name, %rdi
 movq $0, %rsi
 movq $0664, %rdx
 syscall

 # Save the file descriptor
 movq %rax, INPUT_FD(%rbp)


begin_loop:
 # read the record
 pushq INPUT_FD(%rbp)
 pushq $record_buffer
 call read_record
 addq $16, %rsp

 # %rax returns the number of bytes read.
 #cmpq $RECORD_SIZE, %rax
 #jne end_loop

 pushq $RECORD_AGE + record_buffer
 call count_chars
 addq $8, %rsp

end_loop:

 movq %rax, %rdi
 movq $SYS_EXIT, %rax
 syscall
