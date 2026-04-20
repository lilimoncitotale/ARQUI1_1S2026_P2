.global _start
.extern print_str
.extern read_line
.extern ascii_to_int
.extern int_to_ascii


.section .data

prompt_f: .ascii "Ingrese filas: "
.equ PROMPT_F_LEN, . -prompt_f

prompt_c: .ascii "Ingrese columnas: "
.equ PROMPT_C_LEN, . -prompt_c

msg_leido: .ascii "Filas: "
.equ MSG_LEIDO_LEN, . - msg_leido

msg_leido2: .ascii ", Columnas: "
.equ MSG_LEIDO2_LEN, . - msg_leido2

msg_ok: .ascii "\nEntrada valida\n"
.equ MSG_OK_LEN, . - msg_ok

msg_err: .ascii "Error: filas y columnas deben ser mayores a 0\n"
.equ MSG_ERR_LEN, . - msg_err


.section .bss
inbuf: .skip 64
outbuf: .skip 64


.section .text
_start:
    //pedir filas
    ldr x0, =prompt_f
    mov x1, #PROMPT_F_LEN
    bl print_str

    ldr x0, =inbuf
    mov x1, #64
    bl read_line

    ldr x0, =inbuf
    bl ascii_to_int
    mov x20,x0 //x20 = filas

    //pedir columnas
    ldr x0, =prompt_c
    mov x1, #PROMPT_C_LEN
    bl print_str

    ldr x0, = inbuf
    mov x1, #64
    bl read_line

    ldr x0, = inbuf
    bl ascii_to_int
    mov x21,x0 //x21 = columnas

    //mostrar lo leido
    ldr x0, = msg_leido
    mov x1, #MSG_LEIDO_LEN
    bl print_str

    mov x0, x20
    ldr x1, = outbuf
    bl int_to_ascii

    mov x1, x0                             //usar el retorno anterior como longitud
    ldr x0, = outbuf
    bl print_str

    ldr x0, = msg_leido2
    mov x1, #MSG_LEIDO2_LEN
    bl print_str

    mov x0, x21
    ldr x1, = outbuf
    bl int_to_ascii

    mov x1, x0
    ldr x0, = outbuf
    bl print_str

    //validar >0
    cmp x20, #1
    b.lt invalid

    cmp x21, #1
    b.lt invalid

valid:
    ldr x0, = msg_ok
    mov x1, #MSG_OK_LEN
    bl print_str
    mov x0, #0
    b exit_now

invalid:
    ldr x0, = msg_err
    mov x1, #MSG_ERR_LEN
    bl print_str
    mov x0, #1

exit_now:
    mov x8, #93 //syscall:exit
    svc #0

