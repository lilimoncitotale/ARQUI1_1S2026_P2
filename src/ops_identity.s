.global op_identity
.section .text

// op_identity
// x1 = base_result
// x2 = rows
// x3 = cols
// return x0 = 0 ok, x0 = 1 not square

op_identity:
    // validar que sea cuadrada
    cmp x2, x3
    b.ne op_id_not_square

    mov x4, #0     // i = 0

op_id_i:
    cmp x4, x2
    b.ge op_id_done

    mov x5, #0     // j = 0

op_id_j:
    cmp x5, x3
    b.ge op_id_next_i

    // adr = base + ((i*cols + j) * 4)
    mul x6, x4, x3
    add x6, x6, x5
    lsl x6, x6, #2
    add x7, x1, x6

    // si i == j -> 1000, sino -> 0
    cmp x4, x5
    b.eq op_id_set_one

    mov w8, #0
    str w8, [x7]
    b op_id_continue

op_id_set_one:
    mov w8, #1000
    str w8, [x7]

op_id_continue:
    add x5, x5, #1
    b op_id_j

op_id_next_i:
    add x4, x4, #1
    b op_id_i

op_id_done:
    mov x0, #0
    ret

op_id_not_square:
    mov x0, #1
    ret