
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
.extern op_add
.extern op_sub
.extern op_hadamard
.extern op_matmul
.extern op_div


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

menu_op8: .ascii "7. Aritmetica\n"
.equ MENU_OP8_LEN, . - menu_op8

menu_op2: .ascii "8. Salir\n"
.equ MENU_OP2_LEN, . - menu_op2

menu_op9: .ascii "9. Cargar nueva matriz\n"
.equ MENU_OP9_LEN, . - menu_op9

menu_op10: .ascii "10. Toggle verbose (Gauss/Gauss-Jordan)\n"
.equ MENU_OP10_LEN, . - menu_op10

arith_welc: .ascii "\n--- Submenu Aritmetica ---\n"
.equ ARITH_WELC_LEN, . - arith_welc

arith_op1: .ascii "1. Suma (A + B)\n"
.equ ARITH_OP1_LEN, . - arith_op1

arith_op2: .ascii "2. Resta (A - B)\n"
.equ ARITH_OP2_LEN, . - arith_op2

arith_op3: .ascii "3. Multiplicacion punto (A .* B)\n"
.equ ARITH_OP3_LEN, . - arith_op3

arith_op4: .ascii "4. Multiplicacion cruz (A x B)\n"
.equ ARITH_OP4_LEN, . - arith_op4

arith_op5: .ascii "5. Division (A * inv(B))\n"
.equ ARITH_OP5_LEN, . - arith_op5

arith_op8: .ascii "8. Volver\n"
.equ ARITH_OP8_LEN, . - arith_op8

msg_det: .ascii "Determinante: "
.equ MSG_DET_LEN, . - msg_det

msg_inv_sing: .ascii "La matriz es singular (no invertible)\n"
.equ MSG_INV_SING_LEN, . - msg_inv_sing

msg_not_sq: .ascii "La matriz no es cuadrada\n"
.equ MSG_NOT_SQ_LEN, . - msg_not_sq

msg_op_err: .ascii "Opcion no valida\n"
.equ MSG_OP_ERR_LEN, . - msg_op_err

msg_mem_err: .ascii "Error: no se pudo reservar memoria dinamica\n"
.equ MSG_MEM_ERR_LEN, . - msg_mem_err

msg_arith_bad_dims: .ascii "Aritmetica: dimensiones incompatibles\n"
.equ MSG_ARITH_BAD_DIMS_LEN, . - msg_arith_bad_dims

msg_arith_sing: .ascii "Division: matriz B singular (no invertible)\n"
.equ MSG_ARITH_SING_LEN, . - msg_arith_sing

msg_tittle: .ascii "Test matriz MxN (row-major)\n"
.equ MSG_TITTLE_LEN, . - msg_tittle

msg_sel_id: .ascii "\n[Operacion] Matriz identidad\n"
.equ MSG_SEL_ID_LEN, . - msg_sel_id

msg_sel_tr: .ascii "\n[Operacion] Transpuesta\n"
.equ MSG_SEL_TR_LEN, . - msg_sel_tr

msg_sel_det: .ascii "\n[Operacion] Determinante\n"
.equ MSG_SEL_DET_LEN, . - msg_sel_det

msg_sel_gauss: .ascii "\n[Operacion] Gauss triangular superior\n"
.equ MSG_SEL_GAUSS_LEN, . - msg_sel_gauss

msg_sel_inv: .ascii "\n[Operacion] Inversa (Gauss-Jordan)\n"
.equ MSG_SEL_INV_LEN, . - msg_sel_inv

msg_sel_add: .ascii "\n[Aritmetica] Suma A+B\n"
.equ MSG_SEL_ADD_LEN, . - msg_sel_add

msg_sel_sub: .ascii "\n[Aritmetica] Resta A-B\n"
.equ MSG_SEL_SUB_LEN, . - msg_sel_sub

msg_sel_had: .ascii "\n[Aritmetica] Multiplicacion punto A.*B\n"
.equ MSG_SEL_HAD_LEN, . - msg_sel_had

msg_sel_mm: .ascii "\n[Aritmetica] Multiplicacion cruz A x B\n"
.equ MSG_SEL_MM_LEN, . - msg_sel_mm

msg_sel_div: .ascii "\n[Aritmetica] Division A * inv(B)\n"
.equ MSG_SEL_DIV_LEN, . - msg_sel_div

msg_b_loaded: .ascii "Matriz B cargada correctamente\n"
.equ MSG_B_LOADED_LEN, . - msg_b_loaded

msg_reload: .ascii "\nRecargando matriz...\n"
.equ MSG_RELOAD_LEN, . - msg_reload

menu_dbg_on: .ascii "[DEBUG] Verbose ON\n"
.equ MENU_DBG_ON_LEN, . - menu_dbg_on

menu_dbg_off: .ascii "[DEBUG] Verbose OFF\n"
.equ MENU_DBG_OFF_LEN, . - menu_dbg_off

msg_dbg_snapshot: .ascii "[DEBUG] Snapshot:\n"
.equ MSG_DBG_SNAPSHOT_LEN, . - msg_dbg_snapshot

prompt_r: .ascii "Ingrese filas (1..10)"
.equ PROMPT_R_LEN, . - prompt_r

prompt_c: .ascii "Ingrese columnas (1..10)"
.equ PROMPT_C_LEN, . - prompt_c

prompt_br: .ascii "ingrese filas de B (1..10)"
.equ PROMPT_BR_LEN, . - prompt_br

prompt_bc: .ascii "ingrese columnas de B (1..10)"
.equ PROMPT_BC_LEN, . - prompt_bc

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

msg_in_b: .ascii "Ingrese B["
.equ MSG_IN_B_LEN, . - msg_in_b

msg_out: .ascii "\nMatriz ingresada:\n"
.equ MSG_OUT_LEN, . - msg_out

minus: .ascii "-"
sp: .ascii " "
nl: .ascii "\n"

.section .bss

//MAX_ROWS=10, MAX_COLS=10 => 100 int32 => 400 bytes
matrix_res: .skip 400  //misma capacidad que matrix: 10x10 int32
matrix: .skip 400   //10*10*4 bytes (int32) por que es una matriz 10x10(prueba)
matrix_b: .skip 400 //segunda matriz para operaciones binarias (aritmética)
ptr_matrix: .skip 8   //puntero para manejo dinámico de matrices
ptr_matrix_b: .skip 8 //puntero para manejo dinámico de matrices 
ptr_matrix_res: .skip 8 //puntero para manejo dinámico de matrices 

sz_matrix: .skip 8 //para manejo dinámico de matrices (almacena rows y cols)
sz_matrix_b: .skip 8 //para manejo dinámico de matrices (almacena rows y cols)
sz_matrix_res: .skip 8 //para manejo dinámico de matrices (almacena rows y cols)

inbuf: .skip 64
outbuf: .skip 32

debug_verbose: .skip 4
    .global debug_verbose

.section .text
_start:

    //titulo
    ldr x0, = msg_tittle
    mov x1, #MSG_TITTLE_LEN
    bl print_str

    b input_matrix

input_matrix:
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

    //Reservar A dinamica
    mov x0, x23     //rows
    mov x1, x24     //cols
    bl alloc_matrix  //ret: x0 = ptr, x1 = size
    cbz x0, mem_error

    ldr x9, =ptr_matrix
    str x0, [x9]    //guardar ptr_matrix
    ldr x9, =sz_matrix
    str x1, [x9]    //guardar sz_matrix


    //Reservar R dinamica (inicial: rowsAxcolsA)
    mov x0, x23     //rows
    mov x1, x24     //cols
    bl alloc_matrix  //ret: x0 = ptr, x1 = size
    cbz x0, mem_error

    ldr x9, =ptr_matrix_res
    str x0, [x9]    //guardar ptr_matrix_res
    ldr x9, =sz_matrix_res
    str x1, [x9]    //guardar sz_matrix_res

    //base A para carga inicial
    ldr x9, =ptr_matrix
    ldr x20, [x9]    //base de A en x20
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

    ldr x0, = menu_op8
    mov x1, #MENU_OP8_LEN
    bl print_str

    ldr x0, = menu_op9
    mov x1, #MENU_OP9_LEN
    bl print_str

    ldr x0, = menu_op10
    mov x1, #MENU_OP10_LEN
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

    cmp x25, #7
    b.eq arith_menu

    cmp x25, #8
    b.eq menu_exit

    cmp x25, #9
    b.eq menu_reload_matrix

    cmp x25, #10
    b.eq menu_toggle_debug

    ldr x0, = msg_op_err
    mov x1, #MSG_OP_ERR_LEN
    bl print_str
    b menu_loop

menu_reload_matrix:
    bl free_and_reset_all
    ldr x0, =msg_reload
    mov x1, #MSG_RELOAD_LEN
    bl print_str
    ldr x0, =msg_tittle
    mov x1, #MSG_TITTLE_LEN
    bl print_str
    b input_matrix

menu_toggle_debug:
    ldr x9, =debug_verbose
    ldr w10, [x9]
    eor w10, w10, #1
    str w10, [x9]
    cbz w10, menu_toggle_dbg_off
    // dbg on
    ldr x0, =menu_dbg_on
    mov x1, #MENU_DBG_ON_LEN
    bl print_str
    b menu_loop

menu_toggle_dbg_off:
    ldr x0, =menu_dbg_off
    mov x1, #MENU_DBG_OFF_LEN
    bl print_str
    b menu_loop

menu_show:
    b print_matrix

//-----------------------------LLAMADAS A MODULOS-----------------------------
//----------------------------LLAMADA A GAUSS JORDAN-----------------------
call_op_inverse:
    ldr x0, =msg_sel_inv
    mov x1, #MSG_SEL_INV_LEN
    bl print_str

    ldr x9, =ptr_matrix
    ldr x1, [x9]
    ldr x9, =ptr_matrix_res
    ldr x2, [x9]
    mov x3, x23
    mov x4, x24
    bl op_inverse

    cmp x0, #1
    b.eq not_square

    cmp x0, #2
    b.eq inv_singular

    cmp x0, #3
    b.eq invalid_dims

    ldr x9, =ptr_matrix_res
    ldr x26, [x9]
    b print_identity_result

inv_singular:
    ldr x0, =msg_inv_sing
    mov x1, #MSG_INV_SING_LEN
    bl print_str
    b menu_loop
//------------------------------LLAMADA A GAUSS-----------------------------
call_op_gauss:
    ldr x0, =msg_sel_gauss
    mov x1, #MSG_SEL_GAUSS_LEN
    bl print_str

    ldr x9, =ptr_matrix
    ldr x1, [x9]
    ldr x9, =ptr_matrix_res
    ldr x2, [x9]
    mov x3, x23
    mov x4, x24
    bl op_gauss

    cmp x0, #1
    b.eq not_square

    cmp x0, #2
    b.eq gauss_pivot_zero

    ldr x9, =ptr_matrix_res
    ldr x26, [x9]
    b print_identity_result

gauss_pivot_zero:
    ldr x0, = msg_gauss_pivot
    mov x1, #MSG_GAUSS_PIVOT_LEN
    bl print_str
    b menu_loop
//------------------------------LLAMADA A DETERMINANTE-----------------------------
call_op_determinant:
    ldr x0, =msg_sel_det
    mov x1, #MSG_SEL_DET_LEN
    bl print_str

    ldr x9, =ptr_matrix
    ldr x1, [x9]
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
    ldr x0, =msg_sel_tr
    mov x1, #MSG_SEL_TR_LEN
    bl print_str

    ldr x9, =ptr_matrix
    ldr x1, [x9]
    ldr x9, =ptr_matrix_res
    ldr x2, [x9]
    mov x3, x23
    mov x4, x24
    bl op_transpose

    cmp x0, #0
    b.ne invalid_dims

    //si es válida, imprimir resultado
    ldr x9, =ptr_matrix_res
    ldr x26, [x9]
    b print_transpose_result

//-----------------------------LLAMADA A IDENTITY-----------------------------
call_op_identity:
    ldr x0, =msg_sel_id
    mov x1, #MSG_SEL_ID_LEN
    bl print_str

    ldr x9, =ptr_matrix_res
    ldr x1, [x9]
    mov x2, x23
    mov x3, x24
    bl op_identity

    cmp x0, #0
    b.ne not_square

    //si es cuadrada, imprimir resultado
    ldr x9, =ptr_matrix_res
    ldr x26, [x9]
    b print_identity_result

//-----------------------------submenu aritmética-----------------------------
arith_menu:
    ldr x0, = arith_welc
    mov x1, #ARITH_WELC_LEN
    bl print_str

    ldr x0, = arith_op1
    mov x1, #ARITH_OP1_LEN
    bl print_str

    ldr x0, = arith_op2
    mov x1, #ARITH_OP2_LEN
    bl print_str

    ldr x0, = arith_op3
    mov x1, #ARITH_OP3_LEN
    bl print_str

    ldr x0, = arith_op4
    mov x1, #ARITH_OP4_LEN
    bl print_str
    
    ldr x0, = arith_op5
    mov x1, #ARITH_OP5_LEN
    bl print_str

    ldr x0, = arith_op8
    mov x1, #ARITH_OP8_LEN
    bl print_str

    ldr x0, =inbuf
    mov x1, #64
    bl read_line

    ldr x0, = inbuf
    bl ascii_to_int
    mov x25, x0     //opción del submenú aritmética

    cmp x25, #8
    b.eq menu_loop

    // cargar matriz B
    bl load_matrix_b
    cmp x0, #0
    b.ne menu_loop  //load matrix_b ya imprime error 

    //x17 = rows de B, x18 = cols de B (los prepara load_matrix_b)
    //preparar args comunes

    ldr x9, =ptr_matrix
    ldr x1, [x9]
    ldr x9, =ptr_matrix_b
    ldr x2, [x9]
    ldr x9, =ptr_matrix_res
    ldr x3, [x9]
    mov x4, x23     //rows A
    mov x5, x24     //cols A
    mov x6, x17     //rows B
    mov x7, x18     //cols B

    cmp x25, #1
    b.eq arith_call_add

    cmp x25, #2
    b.eq arith_call_sub

    cmp x25, #3
    b.eq arith_call_had

    cmp x25, #4
    b.eq arith_call_matmul

    cmp x25, #5
    b.eq arith_call_div

    ldr x0, = msg_op_err
    mov x1, #MSG_OP_ERR_LEN
    bl print_str
    b arith_menu

arith_call_add:
    ldr x0, =msg_sel_add
    mov x1, #MSG_SEL_ADD_LEN
    bl print_str

    ldr x9, =ptr_matrix
    ldr x1, [x9]
    ldr x9, =ptr_matrix_b
    ldr x2, [x9]
    ldr x9, =ptr_matrix_res
    ldr x3, [x9]
    mov x4, x23
    mov x5, x24
    mov x6, x17
    mov x7, x18
    bl op_add
    cmp x0, #0
    b.ne arith_bad_dims
    ldr x9, =ptr_matrix_res
    ldr x26, [x9]
    mov x27, x23      //rowsRes
    mov x28, x24      //colsRes
    b print_result_dyn

arith_call_sub:
    ldr x0, =msg_sel_sub
    mov x1, #MSG_SEL_SUB_LEN
    bl print_str

    ldr x9, =ptr_matrix
    ldr x1, [x9]
    ldr x9, =ptr_matrix_b
    ldr x2, [x9]
    ldr x9, =ptr_matrix_res
    ldr x3, [x9]
    mov x4, x23
    mov x5, x24
    mov x6, x17
    mov x7, x18
    bl op_sub
    cmp x0, #0
    b.ne arith_bad_dims
    ldr x9, =ptr_matrix_res
    ldr x26, [x9]   
    mov x27, x23      //rowsRes
    mov x28, x24      //colsRes
    b print_result_dyn

arith_call_had:
ldr x0, =msg_sel_had
    mov x1, #MSG_SEL_HAD_LEN
    bl print_str

    ldr x9, =ptr_matrix
    ldr x1, [x9]
    ldr x9, =ptr_matrix_b
    ldr x2, [x9]
    ldr x9, =ptr_matrix_res
    ldr x3, [x9]
    mov x4, x23
    mov x5, x24
    mov x6, x17
    mov x7, x18
    bl op_hadamard
    cmp x0, #0
    b.ne arith_bad_dims
    ldr x9, =ptr_matrix_res
    ldr x26, [x9]
    mov x27, x23      //rowsRes
    mov x28, x24      //colsRes
    b print_result_dyn

arith_call_matmul:
    ldr x0, =msg_sel_mm
    mov x1, #MSG_SEL_MM_LEN
    bl print_str

    ldr x9, =ptr_matrix
    ldr x1, [x9]
    ldr x9, =ptr_matrix_b
    ldr x2, [x9]
    ldr x9, =ptr_matrix_res
    ldr x3, [x9]
    mov x4, x23
    mov x5, x24
    mov x6, x17
    mov x7, x18
    bl op_matmul
    cmp x0, #0
    b.ne arith_bad_dims
    ldr x9, =ptr_matrix_res
    ldr x26, [x9]
    mov x27, x23       //rowsRes = rowsA
    mov x28, x18        //colsRes = colsB
    b print_result_dyn


arith_call_div:
    ldr x0, =msg_sel_div
    mov x1, #MSG_SEL_DIV_LEN
    bl print_str

    ldr x9, =ptr_matrix
    ldr x1, [x9]
    ldr x9, =ptr_matrix_b
    ldr x2, [x9]
    ldr x9, =ptr_matrix_res
    ldr x3, [x9]
    mov x4, x23
    mov x5, x24
    mov x6, x17
    mov x7, x18
    bl op_div   //A * inv(B)
    cmp x0, #0
    b.eq arith_div_ok
    cmp x0, #2
    b.eq arith_div_sing
    b arith_bad_dims

arith_div_ok:
    ldr x9, =ptr_matrix_res
    ldr x26, [x9]
    mov x27, x23       // rowsRes = rowsA
    mov x28, x18       // colsRes = colsB
    b print_result_dyn

arith_div_sing:
    ldr x0, = msg_arith_sing
    mov x1, #MSG_ARITH_SING_LEN
    bl print_str
    b menu_loop

arith_bad_dims:
    ldr x0, = msg_arith_bad_dims
    mov x1, #MSG_ARITH_BAD_DIMS_LEN
    bl print_str
    b menu_loop


//----------------------------------carga de matrz B para operaciones binarias-------------------------------
//return x0=0 si carga exitosa, x0=1 si filas o columnas invalidas
//deja x17=rowsB, x18=colsB para facilitar llamadas posteriores

load_matrix_b:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    // pedir filas B
    ldr x0, = prompt_br
    mov x1, #PROMPT_BR_LEN
    bl print_str

    ldr x0, =inbuf
    mov x1, #64
    bl read_line

    ldr x0, =inbuf
    bl ascii_to_int
    mov x17,x0                     //rowsB

    //pedir columnas B
    ldr x0, = prompt_bc
    mov x1, #PROMPT_BC_LEN
    bl print_str

    ldr x0, =inbuf
    mov x1, #64
    bl read_line

    ldr x0, =inbuf
    bl ascii_to_int
    mov x18,x0                     //colsB


    //validar filas 1..10
    cmp x17, #1
    b.lt load_b_invalid
    cmp x17, #10
    b.gt load_b_invalid
    //validar columnas 1..10
    cmp x18, #1
    b.lt load_b_invalid
    cmp x18, #10
    b.gt load_b_invalid

    //liberar b previa si existia
    ldr x9, =ptr_matrix_b
    ldr x0, [x9]
    cbz x0, load_b_alloc_new

    ldr x11, =sz_matrix_b
    ldr x1, [x11]    //size de b previa
    bl free_matrix

    mov x12, #0
    str x12, [x9]    //ptr_matrix_b = 0
    str x12, [x11]   //sz_matrix_b = 0

load_b_alloc_new:
    mov x0, x17     //rowsB
    mov x1, x18     //colsB
    bl alloc_matrix  //ret: x0 = ptr, x1 = size
    cbz x0, mem_error_in_load_b

    ldr x9, =ptr_matrix_b
    str x0, [x9]    //guardar ptr_matrix_b
    ldr x9, =sz_matrix_b
    str x1, [x9]    //guardar sz_matrix_b

    ldr x9, =ptr_matrix_b
    ldr x19, [x9]   //base de B en x19

    mov x21, #0     //i = 0

load_b_i:
    cmp x21, x17
    b.ge load_b_ok

    mov x22,#0     //j = 0

load_b_j:
    cmp x22,x18
    b.ge load_b_next_i

    ldr x0, = msg_in_b
    mov x1, #MSG_IN_B_LEN
    bl print_str

    mov x0, x21
    ldr x1, =outbuf
    bl int_to_ascii
    mov x1, x0
    ldr x0, =outbuf
    bl print_str

    ldr x0, =msg_mid
    mov x1, #MSG_MID_LEN
    bl print_str

    mov x0, x22
    ldr x1, =outbuf
    bl int_to_ascii
    mov x1, x0
    ldr x0, =outbuf
    bl print_str

    ldr x0, =msg_end
    mov x1, #MSG_END_LEN
    bl print_str

    ldr x0, =inbuf
    mov x1, #64
    bl read_line

    ldr x0, = inbuf
    bl ascii_to_fixed      //x0 = valor leído

    //matrix_b[i][j] = valor leído

    mul x10, x21, x18    //i*colsB
    add x10, x10, x22    //i*colsB + j
    lsl x10, x10, #2     //idx*4 (int32
    add x12, x19, x10   //base + offset
    str w0, [x12]

    add x22, x22, #1    //j++
    b load_b_j

load_b_next_i:
    add x21, x21, #1    //i++
    b load_b_i

load_b_ok:
    ldr x0, =msg_b_loaded
    mov x1, #MSG_B_LOADED_LEN
    bl print_str
    mov x0, #0
    b load_b_end

mem_error_in_load_b:
    ldr x0, = msg_mem_err
    mov x1, #MSG_MEM_ERR_LEN
    bl print_str
    mov x0, #1
    b load_b_end

load_b_invalid:
    ldr x0, = msg_op_err
    mov x1, #MSG_OP_ERR_LEN
    bl print_str
    mov x0, #1
    b load_b_end

load_b_end:
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
//-----------------------------PRINT RESULTADO DINAMICO-----------------------
print_result_dyn:
    ldr x0, = msg_out
    mov x1, #MSG_OUT_LEN
    bl print_str

    mov x21, #0              // i

prd_i:
    cmp x21, x27
    b.ge done

    mov x22, #0              // j

prd_j:
    cmp x22, x28
    b.ge prd_end_row

    // addr = base + ((i*cols + j)*4)
    mul x10, x21, x28
    add x10, x10, x22
    lsl x10, x10, #2
    add x12, x26, x10

    ldrsw x14, [x12]

    cmp x14, #0
    b.ge prd_val_abs

    ldr x0, =minus
    mov x1, #1
    bl print_str
    neg x14, x14

prd_val_abs:
    mov x0, x14
    ldr x1, =outbuf
    bl fixed_to_ascii

    mov x1, x0
    ldr x0, =outbuf
    bl print_str

    add x11, x28, #-1
    cmp x22, x11
    b.eq prd_no_sp
    ldr x0, =sp
    mov x1, #1
    bl print_str

prd_no_sp:
    add x22, x22, #1
    b prd_j

prd_end_row:
    ldr x0, =nl
    mov x1, #1
    bl print_str

    add x21, x21, #1
    b prd_i


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

// x0 = rows, x1 = cols
//ret: XO =Ptr (0 si error), x1 = size reservada (0 si error)
alloc_matrix:
    mul x2, x0, x1     //rows*cols
    lsl x2, x2, #2     //rows*cols*4 (

    sub sp, sp, #16
    str x2, [sp]

    mov x8, #222             //syscall para mmap, retorna ptr en x0 o 0 si error/
    mov x0, #0
    mov x1, x2
    mov x2, #3             //PROT_READ | PROT_WRITE
    mov x3, #34           //MAP_ANONYMOUS | MAP_PRIVATE
    mov x4, #-1            //fd
    mov x5, #0             //offset
    svc #0

    //error si retorno negativo

    tbnz x0, #63, alloc_fail

    //exito devolver size en x1
    ldr x1, [sp]
    add sp, sp, #16
    ret

alloc_fail:
    add sp, sp, #16
    mov x0, #0
    mov x1, #0
    ret

//x0 = ptr, x1 = size
mem_error:
    ldr x0, =msg_mem_err
    mov x1, #MSG_MEM_ERR_LEN
    bl print_str
    b menu_exit

free_matrix:
    mov x8, #215             //syscall para munmap            
    svc #0
    ret
done:
    b menu_loop

// debug helper: imprime una matriz (ptr, rows, cols)
.global debug_print_matrix
debug_print_matrix:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    // save x19-x26 (callee-saved) used by this helper
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!

    // guardar args en registros callee-saved
    mov x19, x0    // base ptr
    mov x20, x1    // rows
    mov x21, x2    // cols

    // header
    ldr x0, =msg_dbg_snapshot
    mov x1, #MSG_DBG_SNAPSHOT_LEN
    bl print_str

    mov x22, #0    // i = 0

dbg_pr_i:
    cmp x22, x20
    b.ge dbg_pr_done

    mov x23, #0    // j = 0
dbg_pr_j:
    cmp x23, x21
    b.ge dbg_pr_endrow

    // addr = base + ((i*cols + j)*4)
    mul x24, x22, x21
    add x24, x24, x23
    lsl x24, x24, #2
    add x25, x19, x24
    ldrsw x26, [x25]

    cmp x26, #0
    b.ge dbg_pr_val_abs
    ldr x0, =minus
    mov x1, #1
    bl print_str
    neg x26, x26

dbg_pr_val_abs:
    mov x0, x26
    ldr x1, =outbuf
    bl fixed_to_ascii
    mov x1, x0
    ldr x0, =outbuf
    bl print_str

    add x11, x21, #-1
    cmp x23, x11
    b.eq dbg_pr_no_sp
    ldr x0, =sp
    mov x1, #1
    bl print_str

dbg_pr_no_sp:
    add x23, x23, #1
    b dbg_pr_j

dbg_pr_endrow:
    ldr x0, =nl
    mov x1, #1
    bl print_str
    add x22, x22, #1
    b dbg_pr_i

dbg_pr_done:
    // restore x25-x26, x23-x24, x21-x22, x19-x20
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

free_and_reset_all:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    bl cleanup_all

    mov x0, #0
    ldr x9, =ptr_matrix
    str x0, [x9]    //ptr_matrix = 0
    ldr x9, =ptr_matrix_b
    str x0, [x9]    //ptr_matrix_b = 0
    ldr x9, =ptr_matrix_res
    str x0, [x9]    //ptr_matrix_res = 0

    ldr x9, =sz_matrix
    str x0, [x9]    //sz_matrix = 0
    ldr x9, =sz_matrix_b
    str x0, [x9]    //sz_matrix_b = 0
    ldr x9, =sz_matrix_res
    str x0, [x9]    //sz_matrix_res = 0

    ldp x29, x30, [sp], #16
    ret

cleanup_all:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // free A
    ldr x9, =ptr_matrix
    ldr x0, [x9]
    cbz x0, cleanup_b
    ldr x10, =sz_matrix
    ldr x1, [x10]
    bl free_matrix

cleanup_b:
    ldr x9, =ptr_matrix_b
    ldr x0, [x9]
    cbz x0, cleanup_r
    ldr x10, =sz_matrix_b
    ldr x1, [x10]
    bl free_matrix

cleanup_r:
    ldr x9, =ptr_matrix_res
    ldr x0, [x9]
    cbz x0, cleanup_done
    ldr x10, =sz_matrix_res
    ldr x1, [x10]
    bl free_matrix

cleanup_done:
    ldp x29, x30, [sp], #16
    ret

menu_exit:
    bl cleanup_all
    mov x0, #0
    mov x8, #93
    svc #0







