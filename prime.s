# prime.s

.equ    maxnb, 0x100000

.section .text
.globl  main                 # run in C environment

main:
    addi    sp, sp, -8       # store ra (return address) on stack
    sd      ra, 0(sp)

    la      a0, prompt       # printf the prompt string
    call    printf

    la      a0, scanfmt      # scanf from stdin (console)
    la      a1, input        # into buffer input
    call    scanf            # with format scanfmt

    blez    a0, .Lerr        # input error   

    la      a1, input        # check if input number n fits 
    lw      a1, 0(a1)
    li      t0, maxnb
    bge     a1, t0, .Lerr

    la      a0, input        # process input with sieve
    call    sieve

    bnez    a0, .Lp1
.Lp0:
    la      a0, outno 
    j       .Lpp
.Lp1:
    la      a0, outyes       # print result 
    j       .Lpp
.Lerr: 
    la      a0, error    
.Lpp:
    call    printf

    li      a0, 0

    ld      ra, 0(sp)        # restore ra
    addi    sp, sp, 8
    ret                      # return to caller


# ----------------------
# sieve of Eratosthenes
# ----------------------
# input:  a0 points to number n
# output: a0 = 1 if prime, else 0
sieve:
    lw      t1, 0(a0)        # n to check
    li      t2, 2            # counter starts with 2
    la      t3, array        # pointer to array

.Ls0:
    sw      t2, 8(t3)        # store value at index (offset by 2)
    addi    t3, t3, 4        # increment by word size
    addi    t2, t2, 1        # counter++
    ble     t2, t1, .Ls0     # until counter == n

    # cancel out non-primes
    li      t2, 2            # start with 2, t2 = index i
    la      t3, array

.Ls1:
    lw      t4, 8(t3)        # load current array item
    beqz    t4, .Ls3         # skip if zero (not prime)

    mul     t4, t2, t2       # j = i * i

.Ls2:
    slli    t5, t4, 2        # t5 = j * 4 (word offset)
    add     t5, t3, t5       # t5 = base + offset
    sw      x0, 0(t5)        # mark as non-prime
    add     t4, t4, t2       # j += i
    ble     t4, t1, .Ls2     # continue marking

.Ls3:
    addi    t2, t2, 1        # i++
    mul     t0, t2, t2       # i*i
    ble     t0, t1, .Ls1     # continue while i*i <= n

    slli    t0, t1, 2        # offset for n
    add     t0, t3, t0
    lw      t0, 0(t0)        # load array[n]
    snez    a0, t0           # a0 = 1 if nonzero (prime)

    ret


.section .rodata
prompt:     .asciz "Enter number (<1048576): "
scanfmt:    .asciz "%u" 
outyes:     .asciz "is a prime number.\n" 
outno:      .asciz "is not a prime number.\n" 
error:      .asciz "wrong input.\n"

.section .bss
input:      .word 0
array:      .zero 4*maxnb
