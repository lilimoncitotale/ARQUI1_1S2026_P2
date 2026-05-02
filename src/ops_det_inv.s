.global op_inverse
.extern fixed_mul
.extern fixed_div
.extern fixed_abs
.extern debug_print_matrix
.extern debug_verbose

.section .text

//op_inverse
//x1 = base matriz A (int32 fixed x1000)
//x2 = base salida INV(A) (int32 fixed x1000)
//x3 = rows
//x4 = cols
//
//return:
//x0 = 0 -> ok
//x0 = 1 -> no cuadrada
//x0 = 2 -> matriz singular (no tiene inversa)
//x0 = 3 -> matriz no soportada (mayor a 10x10)

op_inverse:
    stp x29, x30, [sp, #-16]! //prologo
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    stp x27, x28, [sp, #-16]!

    mov x19, x1                 //A
    mov x20, x2                 //INV(A)
    mov x21, x3                 //rows = n
    mov x22, x4                 //cols = m

    //debe ser cuadrada
    cmp x21, x22
    b.ne inv_not_square

    //validar tamaño máximo 10x10
    cmp x21, #1
    b.lt inv_invalid_dims
    cmp x21, #10
    b.gt inv_invalid_dims

    //reserva local:
    //32 bytes de variables + matriz aumentada 10x20 int 32 = 800bytes
    //total = 832 bytes (alineado a 16)
    sub sp, sp, #832

    //locals
    // [sp +0]  = best_row (x)
    // [sp +8]  = pivot (x)
    // [sp +16] = factor (x)
    // [sp +24] = libre
    // [sp +32] = aug base

    add x23, sp, #32 //base matriz aumentada
    add x24, x21, x21          //x24 = 2n


    //construir aug = [A | I]
    //---------------------------------
    mov x26, #0         //i = 0

inv_build_i:
    cmp x26, x21
    b.ge inv_gj_start

    mov x27, #0    //j = 0

inv_build_j:
    cmp x27, x24
    b.ge inv_build_i_next

    //addr aug[i][j]
    mul x28, x26, x24    //i*2n
    add x8, x28, x27    //i*2n + j
    lsl x8, x8, #2      //offset = (i*2n + j)*4
    add x9, x23, x8     //addr aug[i][j]

    cmp x27, x21
    b.ge inv_build_right

    //izquierda A[I][J]
    mul x10, x26, x21
    add x10, x10, x27   //i*n + j
    lsl x10, x10, #2    //offset = (i*n + j)*4
    add x11, x19, x10   //addr A[i][j]
    ldr w15, [x11]
    str w15, [x9]

    b inv_build_j_next

inv_build_right:
    // derecha: I[i][j-n]
    sub x12, x27, x21   //col_id = j-n
    cmp x26, x12
    b.eq inv_id_one 
    mov w15, #0
    str w15, [x9]
    b inv_build_j_next

inv_id_one:
    mov w15, #1000
    str w15, [x9]

inv_build_j_next:
    add x27, x27, #1
    b inv_build_j

inv_build_i_next:
    add x26, x26, #1
    b inv_build_i


    //gaus jordan con pivoteo parcial
    //-----------------------------------------

inv_gj_start:
    mov x25, #0         //k = 0

    // debug snapshot inicial (augmented matrix)
    ldr x9, =debug_verbose
    ldr w9, [x9]
    cbz w9, .Linv_skip_dbg_init
    mov x0, x23    // aug base
    mov x1, x21    // rows (n)
    mov x2, x24    // cols (2n)
    bl debug_print_matrix
.Linv_skip_dbg_init:

inv_k_loop:
    cmp x25, x21
    b.ge inv_extract

    //best_row = k
    str x25, [sp, #0]

    //best_abs = abs(aug[k][k])
    mul x8, x25, x24     // k * 2n
    add x8, x8, x25      // k * 2n + k
    lsl x8, x8, #2      // offset = (k*2
    add x9, x23, x8     // addr aug[k][k]
    ldr w10, [x9]
    sxtw x10, w10
    mov x0, x10
    bl fixed_abs
    mov x28, x0          // best_abs

    //buscar i = k+1 a n-1
    add x26, x25, #1

inv_pivot_scan:
    cmp x26, x21
    b.ge inv_pivot_selected //no break, solo salto

    //abs(aug[i][k])
    mul x8, x26, x24     // i * 2n
    add x8, x8, x25      // i * 2n + k
    lsl x8, x8, #2      // offset = (i*2n + k)*4
    add x9, x23, x8     // addr aug
    ldr w10, [x9]
    sxtw x10, w10
    mov x0, x10
    bl fixed_abs

    cmp x0, x28
    ble inv_pivot_next
    mov x28, x0          // nuevo best abs
    str x26, [sp, #0]    // guardar mejor fila

inv_pivot_next:
    add x26, x26, #1
    b inv_pivot_scan

inv_pivot_selected:
    //si best abs es 0, matriz singular
    cmp x28, #0
    b.eq inv_singular_cleanup

    //swap filas k y best_row
    ldr x16, [sp, #0]    //best_row
    cmp x16, x25
    b.eq inv_no_swap

    mov x27, #0         //j = 0

inv_swap_j:
    cmp x27, x24
    b.ge inv_no_swap

    //addr1 = aug[k][j]
    mul x8, x25, x24     // k * 2n
    add x8, x8, x27      // k * 2n + j
    lsl x8, x8, #2      // offset = (k*2
    add x9, x23, x8     // addr aug[k][j]

    //addr2 = aug[best_row][j]
    mul x10, x16, x24   // best_row * 2n
    add x10, x10, x27   // best_row * 2n + j
    lsl x10, x10, #2    // offset = (best_row*2n + j)*4
    add x11, x23, x10   //

    ldr w12, [x9]       // temp = aug[k][j]
    ldr w13, [x11]      // temp2 = aug[best_row][j]
    str w13, [x9]       // aug[k][j] = aug[best_row][j]
    str w12, [x11]      // aug[best_row][j] = temp

    add x27, x27, #1
    b inv_swap_j

inv_no_swap:
    //pivot = aug[k][k]
    mul x8, x25, x24     // k * 2n
    add x8, x8, x25      // k * 2n + k
    lsl x8, x8, #2      // offset = (k*2
    add x9, x23, x8     // addr aug[k][k]
    ldr w10, [x9]
    sxtw x10, w10
    cmp x10, #0
    b.eq inv_singular_cleanup
    str x10, [sp, #8]   //guardar pivot

    //normalizar fila k dividiendo por pivot
    mov x27, #0         //j = 0

inv_norm_j:
    cmp x27, x24 //j >= 2n?
    b.ge inv_elim_rows

    //addr = aug[k][j]
    mul x8, x25, x24     // k * 2n
    add x8, x8, x27      // k * 2n + j
    lsl x8, x8, #2      // offset = (k*2
    add x9, x23, x8     // addr aug[k][j]
    ldr w10, [x9]       // temp = aug[k][j]
    sxtw x10, w10

    mov x0, x10         // temp
    ldr x1, [sp, #8]   // pivot
    bl fixed_div
    str w0, [x9]       // aug[k][j] = temp / pivot

    add x27, x27, #1
    b inv_norm_j

    //eliminar en otras filas

inv_elim_rows:
    mov x26, #0         //i = 0

inv_elim_i:
    cmp x26, x21
    b.ge inv_k_next

    cmp x26, x25
    b.eq inv_elim_i_next

    //factor = aug[i][k]
    mul x8, x26, x24     // i * 2n
    add x8, x8, x25      // i * 2n + k
    lsl x8, x8, #2      // offset = (i*2
    add x9, x23, x8     // addr aug[i][k]
    ldr w10, [x9]
    sxtw x10, w10
    str x10, [sp, #16]   //factor (persistente)

    cmp x10, #0
    b.eq inv_elim_i_next

    mov x27, #0         //j = 0

inv_elim_j:
    cmp x27, x24
    b.ge inv_elim_i_next

    //aij = aug[i][j]
    mul x8, x26, x24     // i * 2n
    add x8, x8, x27      // i * 2n + j
    lsl x8, x8, #2      // offset = (i*2
    add x9, x23, x8     // addr aug[i][j]
    ldr w12, [x9]       // aijq
    sxtw x12, w12

    //akj = aug[k][j]
    mul x10, x25, x24   // k * 2n
    add x10, x10, x27   // k * 2n + j
    lsl x10, x10, #2    // offset = (k*2
    add x11, x23, x10   // addr aug[k][j]
    ldr w13, [x11]      // akj
    sxtw x13, w13

    //term = fixed_mul(factor, akj)
    ldr x0, [sp, #16]   // factor
    mov x1, x13         // akj
    bl fixed_mul

    //aug[i][j] = aij - term
    sub x12, x12, x0
    str w12, [x9]

    add x27, x27, #1
    b inv_elim_j

inv_elim_i_next:
    add x26, x26, #1
    b inv_elim_i

inv_k_next:
    // debug snapshot al final de iteracion k
    ldr x9, =debug_verbose
    ldr w9, [x9]
    cbz w9, .Linv_skip_dbg_k
    mov x0, x23    // aug base
    mov x1, x21    // rows
    mov x2, x24    // cols
    bl debug_print_matrix
.Linv_skip_dbg_k:
    add x25, x25, #1
    b inv_k_loop

    //extraer INV(A) de la parte derecha de aug

inv_extract:
    mov x26, #0         //i = 0

inv_ext_i:
    cmp x26, x21
    b.ge inv_ok_cleanup

    mov x27, #0         //j = 0

inv_ext_j:
    cmp x27, x21
    b.ge inv_ext_i_next

    //src = aug[i][j+n]
    add x12, x21, x27   //col_id = j+n
    mul x8, x26, x24     // i * 2n
    add x8, x8, x12     // i * 2n + j
    lsl x8, x8, #2      // offset = (i*2n + j)*4
    add x9, x23, x8     // addr aug[i][j+n]
    ldr w14, [x9]

    //dst = INV(A)[i][j]
    mul x10, x26, x21   // i * n
    add x10, x10, x27   // i * n + j
    lsl x10, x10, #2    // offset = (i*n +
    add x11, x20, x10   // addr INV(A)[i][j]
    str w14, [x11]

    add x27, x27, #1
    b inv_ext_j

inv_ext_i_next:
    add x26, x26, #1
    b inv_ext_i

inv_ok_cleanup:
    mov x0, #0          //status = 0 (ok)
    add sp, sp, #832
    b inv_epilogue

inv_singular_cleanup:
    mov x0, #2          //status = 2 (singular)
    add sp, sp, #832
    b inv_epilogue

inv_not_square:
    mov x0, #1          //status = 1 (not square)
    b inv_epilogue

inv_invalid_dims:
    mov x0, #3          //status = 3 (invalid dims)
    b inv_epilogue

inv_epilogue:
    ldp x27, x28, [sp], #16
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret


