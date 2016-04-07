.include "linux.s"
.include "record-def.s"

.section .data

record1:
 .ascii "Tim\0"
 .rept 36
 .byte 0
 .endr

 .ascii "Tommerson\0"
 .rept 30
 .byte 0
 .endr

 .ascii "54145 whereever st.\naustin, tx 54321\0"
 .rept 203
 .byte 0
 .endr

 .long 22

filename:
 .ascii "test2.data\0"

 # Index to location of local vars on the stack
 .equ ST_FILE_DESCRIPTOR, -8
 .equ COUNT, -16
 .globl _start

.section .text

_start:
 movq %rsp , %rbp
 sub $16, %rsp

 # Open the file
 movq $SYS_OPEN, %rax
 movq $filename, %rdi
 movq $0101, %rsi
 movq $0666, %rdx
 syscall

 # Save the returned value on the stack
 movq %rax, ST_FILE_DESCRIPTOR(%rbp)
 # Initialize the first value of the loop
 movq $0, %rdx

begin_loop:
 # If we've written 30 records, exit
 cmp $2, %rdx
 jge end_loop
 movq %rdx, COUNT(%rbp)

 # Write the record to file
 pushq ST_FILE_DESCRIPTOR(%rbp)
 pushq $record1
 call write_record
 addq $16, %rsp

 # Increment the count, and save it on the stack
 movq COUNT(%rbp), %rdx
 incq %rdx
 #movq %rdx, COUNT(%rbp)
 jmp begin_loop

end_loop:
 # Close file
 movq $SYS_CLOSE, %rax
 movq ST_FILE_DESCRIPTOR(%rbp), %rdi
 syscall

 # Exit
 movq $SYS_EXIT, %rax
 movq $0, %rdi
 syscall
