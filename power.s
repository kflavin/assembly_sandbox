# Illustrate how fucntions work.  Compute teh value of 2^3 + 5^2

# Everything in the main program is stored in registers, so data section
# doesn't have anything.
.section .data

.section .text

.globl _start
_start:
  pushq $3
  pushq $2
  call power        # call power function
  #addq $8, %rsp     # move the stack pointer back (erase parameters we pushed)
  #pushq %rax        # save the first answer before calling the next function (return value)
  #pushq $2
  #pushq $5
  #call power
  #addq $8, %rsp
  #popq %rbx         # the first answer is saved on the stack, pop it into %rbx.  the second answer is in %rax
  #addq %rax, %rbx   # add them together.  result is stored in %rbx
  movq %rax, %rdi     # return value, %rdi is returned in x86_64 instead of $ebx :P
  movq $60, %rax
  syscall
  #movq $1, %rax     # exit (%rbx is returned)
  #int $0x80

# power function
# first arg - base number
# second arg - the power to raise it to
# output - return value
# variables - %rbx: holds the base number, %rcx: holds the power, -8(%rbp) - holds the current result
# %rax is used for temporary storage

.type power, @function
power:
  pushq %rbp        # save the old base pointer
  movq %rsp, %rbp   # make stack pointer the base pointer
  subq $8, %rsp     # get room for our local storage

  movq 16(%rbp), %rbx # put first parameter in %rbx
  movq 24(%rbp), %rcx # put the second parameter in %rcx

  movq %rbx, -8(%rbp) # store current result

power_loop_start:
  cmpq $1, %rcx   # if the power is 1, we are done
  je end_power
  movq -8(%rbp), %rax     # move the current result into %rax
  imulq %rbx, %rax        # multiply the current result by the base number
  movq %rax, -8(%rbp)
  decq %rcx               # decrease power
  jmp power_loop_start

end_power:
  movq -8(%rbp), %rax     # save answer
  movq %rbp, %rsp
  popq %rbp
  ret

