.global op_gauss
.extern fixed_mul
.extern fixed_div
.extern fixed_abs


.section .text

// Gauss triangular superior en punto fijo x1000
// x1 = base_matriz (A)
// x2 = base resultado (R)
// x3 = rows
// x4 = cols
//
// return:
// x0 = 0 -> ok
// x0 = 1 -> no cuadrada
// x0 = 2 -> pivote nulo

op_gauss:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    stp x27, x28, [sp, #-16]!
    sub sp, sp, #16
    mov x11, #0
    str x11, [sp, #8]

    mov x19, x1          // src = A
    mov x20, x2          // dst = R
    mov x21, x3          // rows
    mov x22, x4          // cols
    

    // debe ser cuadrada
    cmp x21, x22
    b.ne ga_not_square

    // copiar A -> R
    mul x28, x21, x22    // total elementos = rows * cols
    mov x23, #0          // idx = 0

ga_copy_loop:
    cmp x23, x28
    b.ge ga_start

    lsl x8, x23, #2      // idx * 4
    add x9, x19, x8      // addr A[idx]
    add x10, x20, x8     // addr R[idx]
    ldr w11, [x9]
    str w11, [x10]

    add x23, x23, #1
    b ga_copy_loop

ga_start:
    mov x23, #0          // k = 0

ga_k_loop:
    sub x11, x21, #1
    cmp x23, x11
    b.ge ga_done

    //pivoteo parcial: Buscar fila con mayor valor abs
    //-----------------------------------------------
    mov x27,x23          // mejor fila
    
    //best abs = abs(R[K][K])
    mul x8, x23, x22     // k * cols
    add x8, x8, x23      // k * cols + k
    lsl x8, x8, #2
    add x9, x20, x8      // addr R[k][k]
    ldr w10, [x9]
    sxtw x10, w10
    mov x0, x10
    bl fixed_abs
    mov x28, x0          // best abs

    //i = k + 1
    add x24, x23, #1

ga_pivot_search:
    cmp x24, x21
    b.ge ga_pivot_selected

    //val = abs(R[i][k])
    mul x8, x24, x22     // i * cols
    add x8, x8, x23      // i * cols + k
    lsl x8, x8, #2
    add x9, x20, x8      // addr R[i][k]
    ldr w10, [x9]
    sxtw x10, w10
    mov x0, x10
    bl fixed_abs

    cmp x0, x28
    ble ga_pivot_next
    mov x28, x0          // nuevo best abs
    mov x27, x24         // nueva mejor fila

ga_pivot_next:
    add x24, x24, #1
    b ga_pivot_search

ga_pivot_selected:
    //si best_abs ==0, columna pivote nula -> matriz singular
    cmp x28, #0
    b.eq ga_pivot_zero

    //si best fila != k, intercambiar filas completas
    cmp x27, x23
    b.eq ga_after_swap

    mov x24, #0          // j = 0

ga_swap_loop:
    cmp x24, x22
    b.ge ga_after_swap 
    // addr R[k][j]

    mul x8, x23, x22
    add x8, x8, x24
    lsl x8, x8, #2
    add x9, x20, x8

    // addr R[best][j]
    mul x10, x27, x22
    add x10, x10, x24
    lsl x10, x10, #2
    add x11, x20, x10

    ldr w14, [x9]
    ldr w15, [x11]
    str w15, [x9]
    str w14, [x11]

    add x24, x24, #1
    b ga_swap_loop

ga_after_swap:
    //pivot = R[k][k] despues de posible intercambio
    mul x8, x23, x22
    add x8, x8, x23
    lsl x8, x8, #2
    add x9, x20, x8
    ldr w25, [x9]
    cmp x25, #0
    b.eq ga_pivot_zero
    sxtw x25, w25 //pivot en x25

    //-------------------------------------------------
    //eliminacion para filas i = k+1 a rows-1
    //------------------------------------------------
    add x24, x23, #1     // i = k + 1

    //contar swap
    cmp x27, x23
    b.eq ga_no_swap
    ldr x11, [sp, #8]
    add x11, x11, #1
    str x11, [sp, #8]

ga_no_swap:
    //pivot = R[k][k] despues de posible intercambio


ga_i_loop:
    cmp x24, x21
    b.ge ga_k_next

    // factor = fixed_div(R[i][k], pivot)
    mul x8, x24, x22     // i * cols
    add x8, x8, x23      // i * cols + k
    lsl x8, x8, #2
    add x9, x20, x8      // addr R[i][k]
    ldr w10, [x9]
    sxtw x10, w10

    mov x0, x10
    mov x1, x25
    bl fixed_div
    mov x26, x0          // factor

    mov x27, x23         // j = k

ga_j_loop:
    cmp x27, x22
    b.ge ga_i_next

    // R[i][j]
    mul x8, x24, x22
    add x8, x8, x27
    lsl x8, x8, #2
    add x9, x20, x8
    mov x28, x9
    ldr w14, [x9] //guardar valor original de R[i][j] para la resta posterior
    sxtw x14, w14

    // R[k][j]
    mul x8, x23, x22
    add x8, x8, x27
    lsl x8, x8, #2
    add x10, x20, x8
    ldr w15, [x10]
    sxtw x15, w15

    // term = fixed_mul(factor, R[k][j])
    mov x0, x26
    mov x1, x15
    bl fixed_mul

    // R[i][j] = R[i][j] - term
    sub x14, x14, x0
    str w14, [x28]

    add x27, x27, #1
    b ga_j_loop

ga_i_next:
    add x24, x24, #1
    b ga_i_loop

ga_k_next:
    add x23, x23, #1
    b ga_k_loop

ga_done:
    mov x0, #0
    ldr x2, [sp, #8]         // swap_count
    b ga_epilogue

ga_not_square:
    mov x0, #1
    ldr x2, [sp, #8]         // swap_count
    b ga_epilogue

ga_pivot_zero:
    mov x0, #2
    ldr x2, [sp, #8]         // swap_count
    b ga_epilogue

ga_epilogue:
    add sp, sp, #16
    ldp x27, x28, [sp], #16
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    
    ret