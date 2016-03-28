# Convert an input file to an output file with all the letters converted to uppercase

# 1) Open the input file
# 2) Open the output file
# 4) While we're not at the end of the input file:
#    a) read part of file into our memory buffer
#    b) go through each byte of memory
#       if the byte is a lower-case letter,
#       convert it to uppercase
#    c) write the memory buffer to output file


.section .data

# Constants #
# syscall numbers
.equ SYS_OPEN, 2
.equ SYS_WRITE, 1
.equ SYS_READ, 0
.equ SYS_CLOSE, 3
.equ SYS_EXIT, 60

# options for open (look at /usr/include/asm/fcntl.h for values)
.equ O_RDONLY, 0
.equ O_CREATE_WRONLY_TRUNC, 03101

# standard file descriptors
.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2

# system call interrupt
.equ LINUX_SYSCALL, 0x80

.equ END_OF_FILE, 0   # This is the return value of read (end of file)

.equ NUMBER_ARGUMENTS, 2


.section .bss
# Buffer - this is where the data is loaded into from the data file and written from into the output file.  This
#          shouldn't exceed 16,000.
.equ BUFFER_SIZE, 500
.lcomm BUFFER_DATA, BUFFER_SIZE

.section .text
# stack positions
.equ ST_SIZE_RESERVE, 16
.equ ST_FD_IN, -8
.equ ST_FD_OUT, -16
.equ ST_ARGC, 0     # Number of arguments
.equ ST_ARGV_0, 8   # Name of the program
.equ ST_ARGV_1, 16  # Input file name
.equ ST_ARGV_2, 24  # output file name

.globl _start
_start:
# Initialize program #
# save the stack pointer
movq %rsp, %rbp

# allocate space for our file descriptors on the stack
subq $ST_SIZE_RESERVE, %rsp

open_files:
open_fd_in:
 # open input file #
 # open syscall
 movq $SYS_OPEN, %rax
 #input filename into %rbx
 movq ST_ARGV_1(%rbp), %rdi
 #read-only flag
 movq $O_RDONLY, %rsi
 # this doesn't matter for reading
 movq $0666, %rdx
 #call linux
 syscall

store_fd_in:
 # save the given file descriptor
 movq %rax, ST_FD_IN(%rbp)

open_fd_out:
 # open output file #
 movq $SYS_OPEN, %rax
 # output filename into %rbx
 movq ST_ARGV_2(%rbp), %rdi
 # flags for writing to the file
 movq $O_CREATE_WRONLY_TRUNC, %rsi
 #mode for new file (if it's created)
 movq $0666, %rdx
 #call
 syscall

store_fd_out:
 # store the file descriptor here
 movq %rax, ST_FD_OUT(%rbp)

# BEGIN MAIN LOOP #
read_loop_begin:
 # read in a block from the input file #
 movq $SYS_READ, %rax
 # get the input file descriptor
 movq ST_FD_IN(%rbp), %rdi
 #the location to read into
 movq $BUFFER_DATA, %rsi
 # the size of the buffer
 movq $BUFFER_SIZE, %rdx
 # size of buffer read is returned in %rax
 syscall

 # exit if we've reached the end
 # check for end of file marker
 cmpq $END_OF_FILE, %rax
 #if found or on error, go to end
 jle end_loop

continue_read_loop:
 # convert the block to upper case #
 pushq $BUFFER_DATA         # location of buffer
 pushq %rax                 # size of the buffer
 call convert_to_upper
 popq %rax                  # get the size back
 addq $8, %rsp              # restore %rsp


 # Write the block out to the output file
 # size of the buffer
 movq %rax, %rdx
 movq $SYS_WRITE, %rax
 # file to use
 #movq ST_FD_OUT(%rbp), %rdi        # write to file
 movq $STDOUT, %rdi                # write to stdout
 # location of buffer
 movq $BUFFER_DATA, %rsi
 syscall

 #Continue the loop
 jmp read_loop_begin


end_loop:
 # close the files
 # we don't need to do error checking on these because error conditions don't signify anything special here
 movq $SYS_CLOSE, %rax
 movq ST_FD_OUT(%rbp), %rdi
 syscall

 movq $SYS_CLOSE, %rax
 movq ST_FD_IN(%rbp), %rdi
 syscall

 # Exit
 movq $SYS_EXIT, %rax
 movq $57, %rbx
 syscall


# This function actually does the conversion to uppercase for a block
# INPUT: the first parameter is the location of the block of memory to convert, the second parameter is the length of the buffer
# OUTPUT: Overwrites the current buffer with the uppercase version
# VARIABLES:
#  %rax - beginning of buffer
#  %rbx - length of buffer
#  %rdi - current buffer offset
#  %cl - current byte being examed (first byte of %rcx

# constants #
# lower boundary of our search
.equ LOWERCASE_A, 'a'

# upper boundary of our search
.equ LOWERCASE_Z, 'z'

# conversion between upper and lower case
.equ UPPER_CONVERSION, 'A' - 'a'

# stack stuff #
.equ ST_BUFFER_LEN, 16 # length of buffer
.equ ST_BUFFER, 24    # actual buffer

convert_to_upper:
 pushq %rbp
 movq %rsp, %rbp

 # set up variables
 movq ST_BUFFER(%rbp), %rax
 movq ST_BUFFER_LEN(%rbp), %rbx
 movq $0, %rdi

 # if a buffer with zero length was given to us, just leave
 cmpq $0, %rbx
 je end_convert_loop

convert_loop:
 # get the current byte
 movb (%rax, %rdi,1), %cl

 # go to the next byte unless it is between 'a' and 'z'
 cmpb $LOWERCASE_A, %cl
 jl next_byte
 cmpb $LOWERCASE_Z, %cl
 jg next_byte

 # otherwise convert the byte to uppercase and store it back
 addb $UPPER_CONVERSION, %cl
 movb %cl, (%rax,%rdi,1)

next_byte:
 incq %rdi              # next byte
 cmpq %rdi, %rbx        # exit if we're at the end
 jne convert_loop

end_convert_loop:
 # no return value, just leave
 movq %rbp, %rsp
 popq %rbp
 ret

