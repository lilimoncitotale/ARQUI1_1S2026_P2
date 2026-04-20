
.global _start
.extern print_str
.extern read_line
.extern ascii_to_int
.extern int_to_ascii
.extern ascii_to_fixed
.extern fixed_to_ascii
.extern op_identity
.extern op_transpose
.extern op_determinant
.extern op_gauss
.extern op_inverse


.section .data
menu_welc: .ascii "---------Bienvenido al programa de matrices---------\n"
.equ MENU_WELC_LEN, . - menu_welc

menu_op1: .ascii "1. Mostrar matriz\n"
.equ MENU_OP1_LEN, . - menu_op1

menu_op3: .ascii "2. Matriz identidad\n"
.equ MENU_OP3_LEN, . - menu_op3

menu_op4: .ascii "3. Transpuesta\n"
.equ MENU_OP4_LEN, . - menu_op4

menu_op5: .ascii "4. Determinante (nxn)\n"
.equ MENU_OP5_LEN, . - menu_op5

menu_op6: .ascii "5. Gauss (triangular superior)\n"
.equ MENU_OP6_LEN, . - menu_op6

menu_op7: .ascii "6. Inversa (Gauss-Jordan)\n"
.equ MENU_OP7_LEN, . - menu_op7

menu_op2: .ascii "8. Salir\n"
.equ MENU_OP2_LEN, . - menu_op2

msg_det: .ascii "Determinante: "
.equ MSG_DET_LEN, . - msg_det

msg_inv_sing: .ascii "La matriz es singular (no invertible)\n"
.equ MSG_INV_SING_LEN, . - msg_inv_sing

msg_not_sq: .ascii "La matriz no es cuadrada\n"
.equ MSG_NOT_SQ_LEN, . - msg_not_sq

msg_op_err: .ascii "Opcion no valida\n"
.equ MSG_OP_ERR_LEN, . - msg_op_err

msg_tittle: .ascii "Test matriz MxN (row-major)\n"
.equ MSG_TITTLE_LEN, . - msg_tittle

prompt_r: .ascii "Ingrese filas (1..10)"
.equ PROMPT_R_LEN, . - prompt_r

prompt_c: .ascii "Ingrese columnas (1..10)"
.equ PROMPT_C_LEN, . - prompt_c

msg_gauss_pivot: .ascii "Pivote nulo encontrado en Gauss\n"
.equ MSG_GAUSS_PIVOT_LEN, . - msg_gauss_pivot

msg_err: .ascii "Error: dimensiones invalidas\n"
.equ MSG_ERR_LEN, . - msg_err

msg_in: .ascii "Ingrese A["
.equ MSG_IN_LEN, . - msg_in

msg_mid: .ascii "]["
.equ MSG_MID_LEN, . - msg_mid

msg_end: .ascii "]: "
.equ MSG_END_LEN, . - msg_end

msg_out: .ascii "\nMatriz ingresada:\n"
.equ MSG_OUT_LEN, . - msg_out

minus: .ascii "-"
sp: .ascii " "
nl: .ascii "\n"

.section .bss

//MAX_ROWS=10, MAX_COLS=10 => 100 int32 => 400 bytes
matrix_res: .skip 400  //misma capacidad que matrix: 10x10 int32
matrix: .skip 400   //10*10*4 bytes (int32) por que es una matriz 10x10(prueba)
inbuf: .skip 64
outbuf: .skip 32

.section .text
_start:

    //titulo
    ldr x0, = msg_tittle
    mov x1, #MSG_TITTLE_LEN
    bl print_str

    //pedir filas
    ldr x0, =prompt_r
    mov x1, #PROMPT_R_LEN
    bl print_str

    ldr x0, =inbuf
    mov x1, #64
    bl read_line

    ldr x0, =inbuf
    bl ascii_to_int
    mov x23,x0                     //rows

    //pedir columnas
    ldr x0, = prompt_c
    mov x1, #PROMPT_C_LEN
    bl print_str

    ldr x0, =inbuf
    mov x1, #64
    bl read_line

    ldr x0, =inbuf
    bl ascii_to_int
    mov x24,x0                     //cols
 
    //calidar filas 1..10

    cmp x23, #1
    b.lt invalid_dims

    cmp x23, #10
    b.gt invalid_dims


    //validar columnas 1..10
    cmp x24, #1
    b.lt invalid_dims
    cmp x24, #10
    b.gt invalid_dims

    //base matriz
    ldr x20, =matrix
    mov x21, #0     //i = 0

  

    //=---------carga de la matriz por teclado---------
   

load_i:
    cmp x21, x23
    b.ge print_matrix

    mov x22,#0     //j = 0

load_j:
    cmp x22,x24
    b.ge next_i

    //PRINT "ingrese A["
    ldr x0, = msg_in
    mov x1, #MSG_IN_LEN
    bl print_str

    //PRINT i
    mov x0, x21
    ldr x1, =outbuf
    bl int_to_ascii
    mov x1, x0
    ldr x0, =outbuf
    bl print_str

    //print "]["
    ldr x0, = msg_mid
    mov x1, #MSG_MID_LEN
    bl print_str

    //PRINT j
    mov x0, x22
    ldr x1, =outbuf
    bl int_to_ascii
    mov x1, x0
    ldr x0, =outbuf
    bl print_str

    //print "]: "
    ldr x0, = msg_end
    mov x1, #MSG_END_LEN
    bl print_str

    //leer valor
    ldr x0, =inbuf
    mov x1, #64
    bl read_line

    ldr x0, = inbuf
    bl ascii_to_fixed      //x0 = valor leído

    //addr = base + ((i*cols +j)*4)
    mul x10, x21, x24    //i*cols
    add x10, x10, x22    //i*cols + j
    lsl x10, x10, #2     //idx*4 (int32
    add x12, x20, x10   //base + offset

    //guardar el valor en int32
    str w0, [x12]

    add x22, x22, #1    //j++
    b load_j

next_i:
    add x21, x21, #1    //i++
    b load_i

    //impresion

menu_loop:
    ldr x0, = menu_welc
    mov x1, #MENU_WELC_LEN
    bl print_str

    ldr x0, = menu_op1
    mov x1, #MENU_OP1_LEN
    bl print_str

    ldr x0, = menu_op3
    mov x1, #MENU_OP3_LEN
    bl print_str

    ldr x0, = menu_op4
    mov x1, #MENU_OP4_LEN
    bl print_str

    ldr x0, = menu_op5
    mov x1, #MENU_OP5_LEN
    bl print_str

    ldr x0, = menu_op6
    mov x1, #MENU_OP6_LEN
    bl print_str

    ldr x0, = menu_op7
    mov x1, #MENU_OP7_LEN
    bl print_str

    ldr x0, = menu_op2
    mov x1, #MENU_OP2_LEN
    bl print_str

    ldr x0, =inbuf
    mov x1, #64
    bl read_line

    ldr x0, = inbuf
    bl ascii_to_int
    mov x25, x0     //opción del menú

    cmp x25, #1
    b.eq menu_show

    cmp x25, #2
    b.eq call_op_identity

    cmp x25, #3
    b.eq call_op_transpose

    cmp x25, #4
    b.eq call_op_determinant

    cmp x25, #5
    b.eq call_op_gauss

    cmp x25, #6
    b.eq call_op_inverse

    cmp x25, #8
    b.eq menu_exit

    ldr x0, = msg_op_err
    mov x1, #MSG_OP_ERR_LEN
    bl print_str
    b menu_loop

menu_show:
    b print_matrix

//-----------------------------LLAMADAS A MODULOS-----------------------------
//----------------------------LLAMADA A GAUSS JORDAN-----------------------
call_op_inverse:
    ldr x1, =matrix
    ldr x2, =matrix_res
    mov x3, x23
    mov x4, x24
    bl op_inverse

    cmp x0, #1
    b.eq not_square

    cmp x0, #2
    b.eq inv_singular

    cmp x0, #3
    b.eq invalid_dims

    ldr x26, =matrix_res
    b print_identity_result

inv_singular:
    ldr x0, =msg_inv_sing
    mov x1, #MSG_INV_SING_LEN
    bl print_str
    b menu_loop
//------------------------------LLAMADA A GAUSS-----------------------------
call_op_gauss:
    ldr x1, =matrix
    ldr x2, = matrix_res
    mov x3, x23
    mov x4, x24
    bl op_gauss

    cmp x0, #1
    b.eq not_square

    cmp x0, #2
    b.eq gauss_pivot_zero

    ldr x26, =matrix_res
    b print_identity_result

gauss_pivot_zero:
    ldr x0, = msg_gauss_pivot
    mov x1, #MSG_GAUSS_PIVOT_LEN
    bl print_str
    b menu_loop
//------------------------------LLAMADA A DETERMINANTE-----------------------------
call_op_determinant:
    ldr x1, =matrix
    mov x2, x23
    mov x3, x24
    bl op_determinant

    mov x27, x1 //guardar resultado del determinante (si x0=0)

    cmp x0, #1
    b.eq not_square

    //status = 0 -> resultado válido
    ldr x0, = msg_det
    mov x1, #MSG_DET_LEN
    bl print_str

    //manejar resultado negativo
    cmp x27, #0
    b.ge det_print_abs

    ldr x0, =minus
    mov x1, #1
    bl print_str
    neg x27, x27
    b det_print_abs
//-----------------------------LLAMADA A TRANSPOSE-----------------------------
call_op_transpose:
    ldr x1, =matrix
    ldr x2, =matrix_res
    mov x3, x23
    mov x4, x24
    bl op_transpose

    cmp x0, #0
    b.ne invalid_dims

    //si es válida, imprimir resultado
    ldr x26, =matrix_res
    b print_transpose_result

//-----------------------------LLAMADA A IDENTITY-----------------------------
call_op_identity:
    ldr x1, =matrix_res
    mov x2, x23
    mov x3, x24
    bl op_identity

    cmp x0, #0
    b.ne not_square

    //si es cuadrada, imprimir resultado
    ldr x26, =matrix_res
    b print_identity_result

not_square:
    ldr x0, = msg_not_sq
    mov x1, #MSG_NOT_SQ_LEN
    bl print_str
    b menu_loop

//--------------------------------PRINT RESULTS------------------------------
//-----------------------------DETERMINANTE-------------------------------
det_print_abs:
    mov x0, x27
    ldr x1, =outbuf
    bl fixed_to_ascii
    mov x1, x0
    ldr x0, =outbuf
    bl print_str

    ldr x0, =nl
    mov x1, #1
    bl print_str

    b menu_loop

//----------------------------------TRANSPUESTA-------------------------------
print_transpose_result:
    ldr x0, = msg_out
    mov x1, #MSG_OUT_LEN
    bl print_str

    mov x21, #0     //i_t = 0 filas de T = cols de A

pt_i:
    cmp x21,x24
    b.ge done

    mov x22, #0     //j_t = 0 columnas de T = filas de A

pt_j:
    cmp x22,x23
    b.ge pt_end_row

    //addr = base_res + ((i_t*rows_T + j_t)*4)
    mul x10, x21, x23    //i_t*rows_T (cols
    add x10, x10, x22    //i_t*rows_T + j_t
    lsl x10, x10, #2     //idx*4 (int32
    add x12, x26, x10   //base_res + offset

    //leer y mostrar

    ldrsw x14, [x12]      // valor con signo

    cmp x14, #0
    b.ge pt_val_abs

    ldr x0, =minus
    mov x1, #1
    bl print_str
    neg x14, x14

pt_val_abs:
    mov x0, x14
    ldr x1, =outbuf
    bl fixed_to_ascii

    mov x1, x0
    ldr x0, =outbuf
    bl print_str

    //espacio entre columnas (evitar espacio al final de cada fila)
    add x11, x23, #-1
    cmp x22, x11
    b.eq pt_no_sp
    ldr x0, =sp
    mov x1, #1
    bl print_str

pt_no_sp:
    add x22, x22, #1    //j_t++
    b pt_j

pt_end_row:
    ldr x0, =nl
    mov x1, #1
    bl print_str         //imprimir salto de línea al final de cada fila

    add x21, x21, #1    //i_t++
    b pt_i

print_identity_result:
    ldr x0, = msg_out
    mov x1, #MSG_OUT_LEN
    bl print_str

    mov x21, #0     //i = 0

print_id_i:
    cmp x21,x23
    b.ge done

    mov x22,#0

print_id_j:
    cmp x22,x24
    b.ge id_end_row

    //adr = base + ((i*cols +j)*4)
    mul x10, x21, x24    //i*cols
    add x10, x10, x22    //i*cols + j
    lsl x10, x10, #2     //idx*4 (int32
    add x12, x26, x10   //base + offset

    //leer valor con signo  y mostrar
    ldrsw x14, [x12]      // valor con signo

    cmp x14, #0
    b.ge id_val_abs

    ldr x0, =minus
    mov x1, #1
    bl print_str
    neg x14, x14

id_val_abs:
    mov x0, x14
    ldr x1, =outbuf
    bl fixed_to_ascii

    mov x1, x0
    ldr x0, =outbuf
    bl print_str


    //espacio entre columnas
    add x11, x24, #-1
    cmp x22, x11
    b.eq id_no_sp
    ldr x0, =sp
    mov x1, #1
    bl print_str

id_no_sp:
    add x22, x22, #1    //j++
    b print_id_j

id_end_row:
    ldr x0, =nl
    mov x1, #1
    bl print_str         //imprimir salto de línea al final de cada fila

    add x21, x21, #1    //i++
    b print_id_i

print_matrix:
    ldr x0, = msg_out
    mov x1, #MSG_OUT_LEN
    bl print_str

    mov x21, #0     //i = 0

print_i:
    cmp x21, x23
    b.ge done

    mov x22, #0     //j = 0

print_j:
    cmp x22, x24
    b.ge end_row

    //adr = base + ((i*cols +j)*4)
    mul x10, x21, x24    //i*cols
    add x10, x10, x22    //i*cols + j
    lsl x10, x10, #2     //idx*4 (int32
    add x12, x20, x10   //base + offset

    //leer valor int32 y mostrar
    //leer valor con signo  y mostrar
    ldrsw x14, [x12]      // valor con signo

    cmp x14, #0
    b.ge mx_val_abs

    ldr x0, =minus
    mov x1, #1
    bl print_str
    neg x14, x14

mx_val_abs:
    mov x0, x14
    ldr x1, =outbuf
    bl fixed_to_ascii

    mov x1, x0
    ldr x0, =outbuf
    bl print_str

    //espacio entre columnas
    add x11, x24, #-1
    cmp x22, x11
    b.eq no_sp
    ldr x0, =sp
    mov x1, #1
    bl print_str

no_sp:
    add x22, x22, #1    //j++
    b print_j

end_row:
    ldr x0, =nl
    mov x1, #1
    bl print_str         //imprimir salto de línea al final de cada fila

    add x21, x21, #1    //i++
    b print_i

invalid_dims:
    ldr x0, = msg_err
    mov x1, #MSG_ERR_LEN
    bl print_str
    mov x0, #1
    b menu_exit
done:
    b menu_loop

menu_exit:
    mov x0, #0
    mov x8, #93
    svc #0





