.global op_transpose
.section .text

//op transpose
//x1 = base_origen (A)
//x2 = base_resultado (T)
//x3 = rows
//x4 = cols
//return x0 = 0 ok

op_transpose:
    mov x5, #0     //i = 0

op_t_i:
    cmp x5,x3
    b.ge op_t_done

    mov x6, #0      //j = 0

op_t_j:
    cmp x6,x4
    b.ge op_t_next_i

    //idxA = icols + j
    mul x7, x5, x4    //i*cols
    add x7, x7, x6    //i*cols + j
    lsl x7, x7, #2     //idx*4 (int32
    add x8, x1, x7   //baseA + offset

    //leer A[i][j]
    ldr w9, [x8]

    //idxT = j*rows + i
    mul x7, x6, x3    //j*rows
    add x7, x7, x5    //j*rows + i
    lsl x7, x7, #2     //idx*4 (int32
    add x8, x2, x7   //baseT + offset

    //escribir T[j][i] = A[i][j]
    str w9,[x8]

    add x6, x6, #1    //j++
    b op_t_j

op_t_next_i:
    add x5, x5, #1    //i++
    b op_t_i

op_t_done:
    mov x0, #0     //ok
    ret
