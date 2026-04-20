/*TEST USADO PARA COMPRENDER EL FUNCIONAMIENTO DE ROW MAJOR EN ARM 
NO ES PARTE DEL PROYECTO FINAL, SOLO UN EJERCICIO DE PRACTICA
*/

.global _start
.extern print_str
.extern int_to_ascii

.section .data
msg1: .ascii "Matriz 2x3 guardada por (i, j), memoria lineal: "
.equ MSG1_LEN, .- msg1
sp: .ascii " "
nl: .ascii "\n"

.section .bss
matrix: .skip 36    //3*3*4 bytes (int32)
outbuf: .skip 32

.section .text
_start:
    //cols = 3, base = &matrix
    //cols representa el total de columnas de la matriz, no el valor ingresado por el usuario, ya que estamos trabajando con una matriz 2x3 fija.
    mov x19, #3         //cols = 3 por que estamos trabajando con una matriz 2x3
    ldr x20, =matrix

    //llenar matriz con 1..6 usando (i,j) y formula row-major
    mov x21, #0             //i = 0
    mov x23, #1         //valor a almacenar = 1

fill_i:
    cmp x21, #2         //comparar i con 2 (filas)
    b.ge print_phase

    mov x22, #0         //j = 0

fill_j:
    cmp x22, #3         //comparar j con 3 (columnas)
    b.ge next_i

    //idx = i*cols + j
    mul x10, x21, x19
    add x10, x10, x22

    //offset = idx * 4 (int32)
    lsl x10, x10, #2

    //adr = base + offset
    add x12, x20, x10

    //A[i][j] = valor
    str w23, [x12]

    add x23, x23, #1    //valor a almacenar++
    add x22, x22, #1    //j++
    b fill_j

next_i:
    add x21,x21, #1     //i++
    b fill_i

print_phase:
    //imprimir mensaje
    ldr x0, =msg1
    mov x1, #MSG1_LEN
    bl print_str

    //imprimir bloque lineal de memoria de la matriz: idx 0...5
    mov x24, #0         //idx = 0

print_loop:
    cmp x24, #6         //comparar idx con 6 (total elementos)
    b.ge done

    //adr = base + idx*4
    lsl x10, x24, #2
    add x12, x20, x10

    //leer valor int32
    ldr w14, [x12]

    //convertir numero leido a texto e imprimir
    uxtw x0, w14
    ldr x1, =outbuf
    bl int_to_ascii

    mov x1, x0
    ldr x0, =outbuf
    bl print_str

    //imprimir espacio menos el ultimo elemento
    cmp x24, #5
    b.eq no_space
    ldr x0, =sp
    mov x1, #1
    bl print_str

no_space:
    add x24, x24, #1    //idx++
    b print_loop

done:
    ldr x0, =nl
    mov x1, #1
    bl print_str

    mov x0, #0
    mov x8, #93 //syscall:exit
    svc #0

