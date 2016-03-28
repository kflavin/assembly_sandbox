# Write out to a file x86_64, AT&T style
.section .data

# Our systems calls
.equ SYS_OPEN, 2
.equ SYS_WRITE, 1
.equ SYS_CLOSE, 3
.equ SYS_EXIT, 60
.equ O_CREATE_WRONLY_TRUNC, 03101
.equ FD, -8

# File to write out
filename:
  .ascii "myfile.txt\0"

message:
  .ascii "Hello, world!\n"

.equ LEN, 14

.section .text
.globl _start
_start:
  movq %rsp, %rbp

  # Open to file
  movq $SYS_OPEN, %rax     # Our system call
  movq $filename, %rdi      # Address of filename
  movq $O_CREATE_WRONLY_TRUNC, %rsi       # Intentions on file
  movq $0666, %rdx          # File mode
  syscall

  pushq %rax                # Save our file descriptor

  # Write to the file
  movq $SYS_WRITE, %rax
  movq FD(%rbp), %rdi
  movq $message, %rsi
  movq $LEN, %rdx
  syscall

  movq $SYS_EXIT, %rax
  movq $0, %rdi
  syscall

