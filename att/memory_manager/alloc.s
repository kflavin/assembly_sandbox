# PURPOSE: program to manage memory usage - allocates and deallocates as requested

# The programs using these routines will ask for a certain amount of memory.  We actually use more
# for that size, but we put it at the beginning, before the pointer we hand back.  We add a size field
# and an AVAILABLE/UNAVAILABLE marker.  So, the memory looks like this
#
#############################################################
# # Available Marker#Size of Memory#Actual memory locations #
#############################################################
#                                   ^ Returned pointer
# The pointer we return only points to the actual locations requested to make it easier for the calling
# program.

.section .data
# GLOBALS #

# This points to the beginning of the memory we are managing
heap_begin:
 .long 0

# This points to one location past the memory we are managing
current_break:
 .long 0

# STRUCTURE INFORMATION #
# size of space for memory region header
.equ HEADER_SIZE, 8
# Location of the "available" flag in the header
.equ HDR_AVAIL_OFFSET, 0
#Location of the size field of the header
.equ HDR_SIZE_OFFSET, 4

# CONSTANTS #
.equ UNAVAILABLE, 0     # This is the number we will use to mark space that has been given out.
.equ AVAILABLE, 1       # This is the number we will use to mark space that has been returned and is available for giving.
.equ SYS_BRK, 12        # syscall for break

.section .text

# FUNCTIONS #
# allocate_init #
# PURPOSE: call this function to initialize the functions (specifically, this sets heap_begin and current_break).  This has
# no parameters and no return value.
.globl allocate_init
.type allocate_init,@function
allocate_init:
 pushq %rbp
 movq %rsp, %rbp

 # If the brk system call is called with 0 in %rdi, it returns the last valid usable address
 movq $SYS_BRK, %rax        # Find where the break is
 movq $0, %rdi
 syscall
 incq %rax                  # %rax now has the last valid address, and we want the memory location after that.
 movq %rax, current_break   # store the current break
 movq %rax, heap_begin      # store the current break as our first address.  This will cause the allocate function
                            #   to get more memory from Linux the first time it is run.
 movq %rbp, %rsp
 popq %rbp
 ret
 # END OF FUNCTION #

 # allocate #
 # PURPOSE: This function is used to grab a section of memory.  It checks to see if there are any free blocks, and, if not,
 #  it asks Linux for a new one.
 # PARAMETERS: This function has one parameter - the size of the memory block we want to allocate
 # RETURN VALUE: This function returns the address of the allocated memory in %rax.  If there is no memory available, it will
 #  return 0 in %rax.
 # PROCESSING#
 # variables used
 # %rcx - hold the size of the requested memory
 # %rax - current memory region being examined
 # %rbx - current break position
 # %rdx - size of the current memory region
 #
 # We scan through each memory region starting with heap_begin.  We look at the size of each one, and if it has been allocated.
 #  If it's big enough for the requested size, and its available, it grabs that one.  If it does not find a region large enough,
 #  it asks Linux for more memory.  In that case, it moves current_break up.
 .globl allocate
 .type allocate,@function
 .equ ST_MEM_SIZE, 16        # stack position of the memory size to allocate

 allocate:
  pushq %rbp
  movq %rsp, %rbp
  movq ST_MEM_SIZE(%rbp), %rcx  # size we're looking for
  movq heap_begin, %rax         # current search location
  movq current_break, %rbx      # current break

alloc_loop_begin:               # Iterate over each memory region
 cmpq %rbx, %rax               # Need more memory if these are equal
 je move_break

 # grab the size of this memory
 movq HDR_SIZE_OFFSET(%rax), %rdx
 cmpq $UNAVAILABLE, HDR_AVAIL_OFFSET(%rax)      # If unavailable, go to the next one
 je next_location

 cmpq %rdx, %rcx                               # If the space is available, compare the size to the needed size.
 jle allocate_here

next_location:
 addq $HEADER_SIZE, %rax    # The total size of the memory region is the sum of the size requested plus the header.
 addq %rdx, %rax
 jmp alloc_loop_begin

allocate_here:      # If we made it here, that means the %rax has the region to allocate
 # mark space as unavailable
 movq $UNAVAILABLE, HDR_AVAIL_OFFSET(%rax)
 movq $HEADER_SIZE, %rax                    # move %rax past the header (that's what we'll return)
 movq %rbp, %rsp
 popq %rbp
 ret

move_break:         # If we made it here, we exhausted all addressable memory and need to request more
                    #   %rbx holds the current endpoint of the data, and %rcx holds its size.  We need to increase
                    #   %rbx to where we want memory to end, so we add space for the headers and the requested data.
 addq $HEADER_SIZE, %rbx
 addq %rcx, %rbx
 pushq %rax         # Save needed registers
 pushq %rcx
 pushq %rbx
 movq $SYS_BRK, %rax    # reset the break (%rbx has the requested break points)
 syscall                # This should return the new break in %rax, or 0 if it fails.
 cmpq $0, %rax          # Check for error conditions
 je error

 popq %rbx              # restore saved registers
 popq %rcx
 popq %rax

 # set this memory as unavailable, since we're handing it out
 movq $UNAVAILABLE, HDR_AVAIL_OFFSET(%rax)
 # set the size of the memory
 movq %rcx, HDR_SIZE_OFFSET(%rax)

 # move %rax to the actual start of usable memory
 # %rax now holds the return value
 addq $HEADER_SIZE, %rax
 movq %rbx, current_break   # save the new break
 movq %rbp, %rsp            # return the function
 movq %rbp, %rsp
 popq %rbp
 ret

error:
 movq $0, %rax
 movq %rbp, %rsp
 popq %rbp
 ret

# End of function#

# deallocate #
# PURPOSE: The purpose of this function is to give back a region of memory to the pool after we're done using it
# PARAMETERS: The only parameter is the address of the memory we want to return to the pool
# RETURN VALUE: There is no return value
# PROCESSING:
#  Flip header available field
.globl deallocate
.type deallocate,@function
# Stack position of the memory region to free
.equ ST_MEMORY_SEG, 8
deallocate:
 # Get the address of the memory to free (normally this would be in 16(%rbp), but since we didn't push %rbp or move %rsp
 # to %rbp, we can just do 8(%rbp)
 movq ST_MEMORY_SEG(%rsp), %rax

 # get the pointer to the real beginning of the memory
 subq $HEADER_SIZE, %rax

 # mark it as available
 movq $AVAILABLE, HDR_AVAIL_OFFSET(%rax)

 # return
 ret
 # end of function #
