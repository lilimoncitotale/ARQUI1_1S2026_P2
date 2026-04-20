.global op_determinant
.extern op_gauss
.extern fixed_mul
.section .text

//op_determinant
//x1 = base_matriz
//x2 = rows
//x3 = cols
//
//return:
//x0 = status
// 0 -> ok
// 1 -> not square
//x1 = determinante en fixed x1000 (si status = 0)

op_determinant:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!

    mov x19, x1 //base matriz original
    mov x21,x2 //rows
    mov x22,x3 //cols

    //debe ser cuadrada
    cmp x2,x3
    b.ne det_not_square

    //buffer temporal para gauss: 10x10 int = 100 elementos = 400 bytes
    //reservamos espacio en el stack para esta matriz temporal
    sub sp,sp, #416
    mov x20, sp //base temporal

    //triangulizar en temporal: op_gauss (A, temp, rows, cols)
    mov x1, x19
    mov x2, x20
    mov x3, x21
    mov x4, x22

    bl op_gauss
    mov x23, x2 //swap_count de gauss

    //seguridad no cuadrada
    cmp x0, #1
    b.eq det_cleanup_not_square

    //pivote nulo -> determinante 0
    cmp x0, #2
    b.eq det_zero

    //det = 1. 000 en fixed
    mov x1, #1000
    mov x5, #0          //i = 0


det_diag_loop:
    cmp x5, x21
    b.ge det_ok

    //diag  = temp[i][i]
    mul x6, x5, x22     //i*cols
    add x6, x6, x5      //i*cols + i
    lsl x6, x6, #2      //offset = (i*cols
    add x7, x20, x6     //addr temp[i][i]
    ldr w8, [x7]        //diag = temp[i][i]
    sxtw x8, w8          //sign extend diag
    //det *= diag

    //det = fixed_mult(det, diag)
    mov x0, x1          //det
    mov x1, x8          //diag
    bl fixed_mul
    mov x1, x0          //actualizar det

    add x5, x5, #1
    b det_diag_loop

det_ok:
    //si swap count es impaar, det = -det
    tst x23, #1   //test bit 0 es impar?
    b.eq det_final  //si es par salta

    //det = -det (en punto fijo: det *= 1000/1000 = *(-1))
    mov x0, x1      //det
    mov x1, #-1000  //-1 en punto fijo
    bl fixed_mul
    mov x1, x0      //actualizar det


det_final:
    mov x0, #0      //status = 0 (ok)
    add sp,sp, #416
    b det_epilogue


det_zero:
    mov x0, #0        //det = 0
    mov x1, #0
    add sp,sp, #416
    b det_epilogue

det_cleanup_not_square:
    mov x0, #1        //status = 1 (not square)
    add sp,sp, #416
    b det_epilogue

det_not_square:
    mov x0, #1        //status = 1 (not square)
    b det_epilogue

det_epilogue:
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret