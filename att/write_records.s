.include "linux.s"
.include "record-def.s"

.section .data

# constant data of the records we want to write.  Each data item is padded
# to the proper length with null bytes.

# .rept is used to pad each item.  .rept tells the assembler to repeat the
# section between .rept and .endr the number of times specified.
# This is used to add extra null characters at the end of each field.

record1:
 .ascii "Fredrick\0"
 .rept 31 #Padding to 40 bytes
 .byte 0
 .endr

 .ascii "Bartlett\0"
 .rept 31 #Padding to 40 bytes
 .byte 0
 .endr

 .ascii "4242 suth prairie\nsomewhereville, OK 55555\0"
 .rept 209 # Padding to 240 bytes
 .byte 0
 .endr

 .long 45


record2:
 .ascii "Marilyn\0"
 .rept 32
 .byte 0
 .endr

 .ascii "Taylor\0"
 .rept 33
 .byte 0
 .endr

 .ascii "2222 S johannan st\nnowheresville, IL 12345\0"
 .rept 203
 .byte 0
 .endr

 .long 29

# The name of the file we will write to
file_name:
 .ascii "test.dat\0"

 .equ ST_FILE_DESCRIPTOR, -8
 .globl _start
_start:
 # Copy the stack pointer to %rbp, and save space for 2 parameters on the stack
 movq %rsp, %rbp
 subq $16, %rsp

 # Open the file
 movq $SYS_OPEN, %rax
 movq $file_name, %rdi
 movq $0101, %rsi   # create if it doesn't exist and open for writing
 movq $0666, %rdx
 syscall

 # Store the file descriptor away
 movq %rax, ST_FILE_DESCRIPTOR(%rbp)

 # Write the first record (push our parameters onto the stack, then call write_record)
 pushq ST_FILE_DESCRIPTOR(%rbp)
 pushq $record1
 call write_record
 addq $16, %rsp

 # Write the second record
 pushq ST_FILE_DESCRIPTOR(%rbp)
 pushq $record2
 addq $16, %rsp

 # Close the file descriptor
 movq $SYS_CLOSE, %rax
 movq ST_FILE_DESCRIPTOR(%rbp), %rdi
 syscall

 # Exit
 movq $SYS_EXIT, %rax
 movq $0, %rdi
 syscall
