//TEST DE CARGA POR TECLADO + GUARDARO ROW MAJOR EN MEMORIA Y REIMPRESION DE LA MATRIZ
//ESTE TEST NO ES PARTE DEL PROYECTO FINAL, SOLO UN EJERCICIO DE PRACTICA PARA COMPRENDER EL FUNCIONAMIENTO DE LA CARGA POR TECLADO Y EL GUARDADO EN MEMORIA EN FORMATO ROW MAJOR
//puede ser util para analisis por separado de cada parte del proyecto final, pero no es parte del proyecto final en si

.global _start
.extern print_str
.extern read_line
.extern ascii_to_int
.extern int_to_ascii

.section .data

msg_tittle: .ascii "Test matriz MxN (row-major)\n"
.equ MSG_TITTLE_LEN, . - msg_tittle

prompt_r: .ascii "Ingrese filas (1..10)"
.equ PROMPT_R_LEN, . - prompt_r

prompt_c: .ascii "Ingrese columnas (1..10)"
.equ PROMPT_C_LEN, . - prompt_c

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

sp: .ascii " "
nl: .ascii "\n"

.section .bss

//MAX_ROWS=10, MAX_COLS=10 => 100 int32 => 400 bytes

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
    bl ascii_to_int       //x0 = valor leído

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
    ldr w14, [x12]      //cargar valor
    uxtw x0, w14        //convertir a 64 bits para int_to_ascii
    ldr x1, =outbuf
    bl int_to_ascii     //convertir a ascii, x0 = cantidad dígitos

    mov x1, x0         //usar cantidad dígitos como longitud
    ldr x0, =outbuf
    bl print_str         //imprimir valor

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
    b exit_now

done:
    mov x0, #0
    
exit_now:
    mov x8, #93 //syscall:exit
    svc #0





