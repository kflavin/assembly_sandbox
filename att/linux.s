# System call numbers (x86_64)
.equ SYS_OPEN, 2
.equ SYS_WRITE, 1
.equ SYS_READ, 0
.equ SYS_CLOSE, 3
.equ SYS_BREAK, 12
.equ SYS_EXIT, 60

# Standard File Descriptors
.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2

# Common Status Codes
.equ END_OF_FILE, 0
