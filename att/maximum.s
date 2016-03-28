
.section .data
.globl data_items
data_items:
 .long 3,1,67,34,222,45,75,54,24,44,33,22,11,66,0,4294967295
 .ascii "Hello World\0"

more_data:
 .ascii "here we come!\0"

.section .text

.globl _start
_start:
 #movl $14, %edi
 #movl data_items(,%edi,4), %ecx # Get our stopping point (when using an ending address)
 movl $0, %edi                  # set index to 0
 movl data_items(,%edi,4), %eax # get data from first item into eax
 movl %eax, %ebx                # largest item found so far, so save it in ebx

start_loop:
 cmpl $0, %eax                  # check to see if we're at the end
 je loop_exit
 incl %edi                      # load next value
 movl data_items(,%edi,4), %eax
 cmpl %ebx, %eax                # compare values
 jle start_loop                 # jump if it isn't a larger value
 movl %eax, %ebx                # move ebx to eax if it's the largest
 jmp start_loop

loop_exit:
 # %ebx is the status code of the system call, and it holds the max #
 movl $1, %eax                  # 1 is the exit() syscall
 subl $1, %edi
 #movl data_items, %ebx         # testing different types of addressing
 movl $0, %edi
 #movl data_items(,%edi,4), %ebx # Get our stopping point (when using an ending address)
 movl %esp, %ebx # Get our stopping point (when using an ending address)
 int $0x80


