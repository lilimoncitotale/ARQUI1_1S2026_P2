.global op_add
.global op_sub
.global op_hadamard
.global op_matmul
.global op_div

.extern fixed_mul
.extern op_inverse

.section .text

// =====================================================
// Convención común (todas):
// x1 = A base
// x2 = B base
// x3 = R base
// x4 = rowsA
// x5 = colsA
// x6 = rowsB
// x7 = colsB
//
// return x0:
// 0 = ok
// 1 = dimensiones incompatibles
// 2 = singular (solo op_div)
// =====================================================

// -----------------------------------------------------
// R = A + B
// requiere: rowsA==rowsB && colsA==colsB
// -----------------------------------------------------
op_add:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!

    cmp x4, x6
    b.ne add_bad_dims
    cmp x5, x7
    b.ne add_bad_dims

    mov x19, x1          // A
    mov x20, x2          // B
    mov x21, x3          // R
    mov x22, x4          // rows
    mov x23, x5          // cols

    mul x24, x22, x23    // total
    mov x25, #0          // idx

add_loop:
    cmp x25, x24
    b.ge add_ok

    lsl x8, x25, #2
    add x9,  x19, x8
    add x10, x20, x8
    add x11, x21, x8

    ldr w12, [x9]
    ldr w13, [x10]
    sxtw x12, w12
    sxtw x13, w13
    add x14, x12, x13
    str w14, [x11]

    add x25, x25, #1
    b add_loop

add_ok:
    mov x0, #0
    b add_end

add_bad_dims:
    mov x0, #1

add_end:
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// -----------------------------------------------------
// R = A - B
// requiere: rowsA==rowsB && colsA==colsB
// -----------------------------------------------------
op_sub:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!

    cmp x4, x6
    b.ne sub_bad_dims
    cmp x5, x7
    b.ne sub_bad_dims

    mov x19, x1
    mov x20, x2
    mov x21, x3
    mov x22, x4
    mov x23, x5

    mul x24, x22, x23
    mov x25, #0

sub_loop:
    cmp x25, x24
    b.ge sub_ok

    lsl x8, x25, #2
    add x9,  x19, x8
    add x10, x20, x8
    add x11, x21, x8

    ldr w12, [x9]
    ldr w13, [x10]
    sxtw x12, w12
    sxtw x13, w13
    sub x14, x12, x13
    str w14, [x11]

    add x25, x25, #1
    b sub_loop

sub_ok:
    mov x0, #0
    b sub_end

sub_bad_dims:
    mov x0, #1

sub_end:
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// -----------------------------------------------------
// R = A .* B  (Hadamard)
// requiere: rowsA==rowsB && colsA==colsB
// usa fixed_mul
// -----------------------------------------------------
op_hadamard:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!

    cmp x4, x6
    b.ne had_bad_dims
    cmp x5, x7
    b.ne had_bad_dims

    mov x19, x1
    mov x20, x2
    mov x21, x3
    mov x22, x4
    mov x23, x5

    mul x24, x22, x23
    mov x25, #0

had_loop:
    cmp x25, x24
    b.ge had_ok

    lsl x8, x25, #2
    add x9,  x19, x8
    add x10, x20, x8
    add x11, x21, x8

    ldr w12, [x9]
    ldr w13, [x10]
    sxtw x12, w12
    sxtw x13, w13

    mov x0, x12
    mov x1, x13
    bl fixed_mul
    str w0, [x11]

    add x25, x25, #1
    b had_loop

had_ok:
    mov x0, #0
    b had_end

had_bad_dims:
    mov x0, #1

had_end:
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// -----------------------------------------------------
// R = A x B (multiplicación matricial)
// requiere: colsA == rowsB
// resultado: rowsA x colsB en R
// -----------------------------------------------------
op_matmul:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    stp x27, x28, [sp, #-16]!

    cmp x5, x6
    b.ne mm_bad_dims

    mov x19, x1      // A
    mov x20, x2      // B
    mov x21, x3      // R
    mov x22, x4      // rowsA
    mov x23, x5      // colsA (= rowsB)
    mov x24, x7      // colsB

    mov x25, #0      // i
mm_i_loop:
    cmp x25, x22
    b.ge mm_ok

    mov x26, #0      // j
mm_j_loop:
    cmp x26, x24
    b.ge mm_next_i

    mov x27, #0      // k
    mov x28, #0      // sum
mm_k_loop:
    cmp x27, x23
    b.ge mm_store

    // A[i][k]
    mul x8, x25, x23
    add x8, x8, x27
    lsl x8, x8, #2
    add x9, x19, x8
    ldr w10, [x9]
    sxtw x10, w10

    // B[k][j]
    mul x11, x27, x24
    add x11, x11, x26
    lsl x11, x11, #2
    add x12, x20, x11
    ldr w13, [x12]
    sxtw x13, w13

    mov x0, x10
    mov x1, x13
    bl fixed_mul

    add x28, x28, x0

    add x27, x27, #1
    b mm_k_loop

mm_store:
    // R[i][j] = sum
    mul x8, x25, x24
    add x8, x8, x26
    lsl x8, x8, #2
    add x9, x21, x8
    str w28, [x9]

    add x26, x26, #1
    b mm_j_loop

mm_next_i:
    add x25, x25, #1
    b mm_i_loop

mm_ok:
    mov x0, #0
    b mm_end

mm_bad_dims:
    mov x0, #1

mm_end:
    ldp x27, x28, [sp], #16
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// -----------------------------------------------------
// R = A / B  definido como A * inv(B)
// requiere:
// 1) B cuadrada
// 2) B invertible
// 3) colsA == rowsB
//
// return:
// 0 = ok
// 1 = dimensiones incompatibles
// 2 = B singular
// -----------------------------------------------------
op_div:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!

    // Guardar params
    mov x19, x1      // A
    mov x20, x2      // B
    mov x21, x3      // R
    mov x22, x4      // rowsA
    mov x23, x5      // colsA
    mov x24, x6      // rowsB
    mov x25, x7      // colsB

    // B debe ser cuadrada
    cmp x24, x25
    b.ne div_bad_dims
    // compatibilidad A * inv(B): colsA == rowsB
    cmp x23, x24
    b.ne div_bad_dims

    // temp inv(B) 10x10 int32 = 400 bytes (alineado)
    sub sp, sp, #416
    mov x26, sp      // base invB temporal

    // invB = inverse(B)
    mov x1, x20      // B
    mov x2, x26      // invB temp
    mov x3, x24      // rowsB
    mov x4, x25      // colsB
    bl op_inverse

    cmp x0, #0
    b.eq div_mul
    cmp x0, #2
    b.eq div_singular
    b div_bad_dims_cleanup

div_mul:
    // R = A * invB
    mov x1, x19      // A
    mov x2, x26      // invB
    mov x3, x21      // R
    mov x4, x22      // rowsA
    mov x5, x23      // colsA
    mov x6, x24      // rowsB
    mov x7, x25      // colsB
    bl op_matmul

    // x0 ya trae status (0/1)
    add sp, sp, #416
    b div_end

div_singular:
    mov x0, #2
    add sp, sp, #416
    b div_end

div_bad_dims_cleanup:
    mov x0, #1
    add sp, sp, #416
    b div_end

div_bad_dims:
    mov x0, #1

div_end:
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
    