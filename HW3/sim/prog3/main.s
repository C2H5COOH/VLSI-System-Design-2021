.section .text
.align 2
.globl main
main:
    # t0    array0  // array1 -> array0 + sizei * sizek
    # t1    test
    # t2    sizei
    # t3    sizej
    # t4    sizek
    # t5    sizei * sizek
    # t6    index i
    # a0    index j
    # a1    index k
    # a2    index i*j
    # a3    index i*k
    # a4    index k*j
    # a5    tmp0
    # a6    tmp1
    # a7    tmp2
    # s2    tmp3
    addi    sp, sp, -4
    sw      s2, 0(sp)
    la      t0, array_addr
    la      t1, _test_start
    lw      t2, array_size_i
    lw      t3, array_size_j
    lw      t4, array_size_k
    li      t5, 0
    mv      a5, t2
    mv      a6, t4

    # a5 tmpi
    # a6 tmpk
    # a7 tmpi & 1
mul_loop:
    andi    a7, a5, 1
    beq     a7, zero, no_add
    add     t5, a6, t5
no_add:
    srli    a5, a5, 1
    slli    a6, a6, 1
    bne     a5, zero, mul_loop

    # Init i index
    li      t6, 0
    li      a2, 0
    li      a3, 0
i_loop:

    # Init j index
    li      a0, 0
j_loop:

    # Init tmp
    li      a5, 0
    # Init k index
    li      a1, 0
    li      a4, 0
k_loop:
    
    # mult0 index
    add     a6, a1, a3
    slli    a6, a6, 1
    add     a6, a6, t0
    lh      a6, 0(a6)
    # mult1 index
    add     a7, a4, a0
    add     a7, a7, t5
    slli    a7, a7, 1
    add     a7, a7, t0
    lh      a7, 0(a7)
    # a6 multiplier
    # a7 multiplicand
    # s2 multiplier & 1
mul_loop_half:
    andi    s2, a6, 1
    beq     s2, zero, no_add_half0
    add     a5, a7, a5
no_add_half0:
    srli    a6, a6, 1
    slli    a7, a7, 1
    beq     a6, zero, end_mult_loop_half

    andi    s2, a6, 1
    beq     s2, zero, no_add_half1
    add     a5, a7, a5
no_add_half1:
    srli    a6, a6, 1
    slli    a7, a7, 1
    beq     a6, zero, end_mult_loop_half

    andi    s2, a6, 1
    beq     s2, zero, no_add_half2
    add     a5, a7, a5
no_add_half2:
    srli    a6, a6, 1
    slli    a7, a7, 1
    beq     a6, zero, end_mult_loop_half

    andi    s2, a6, 1
    beq     s2, zero, no_add_half3
    add     a5, a7, a5
no_add_half3:
    srli    a6, a6, 1
    slli    a7, a7, 1
    bne     a6, zero, mul_loop_half
end_mult_loop_half:

    # Post k loop
    addi    a1, a1, 1
    add     a4, a4, t3
    blt     a1, t4, k_loop

    # Store product
    add     a6, a0, a2
    slli    a6, a6, 2
    add     a6, t1, a6
    sw      a5, 0(a6)
    # Post j loop
    addi    a0, a0, 1
    blt     a0, t3, j_loop

    # Post i loop
    add     a2, a2, t3
    add     a3, a3, t4
    addi    t6, t6, 1
    blt     t6, t2, i_loop

    lw      s2, 0(sp)
    addi    sp, sp, 4
    ret

