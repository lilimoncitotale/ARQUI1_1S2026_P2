.global print_str
.global read_line
.global ascii_to_int
.global int_to_ascii
.global ascii_to_fixed
.global fixed_to_ascii

.section .text
//------------------------------------------------------------
// print_str(x0=addr, x1=len)
// Entrada: x0 direccion del texto, x1 longitud del tecto
print_str:
    mov x2, x1              //x2 = len
    mov x1, x0              //x1 = buf
    mov x0, #1              //x0 = fd stdout
    mov x8, #64            //syscall:write
    svc #0
    ret

//------------------------------------------------------------
// read_line(x0=addr, x1=maxlen) -> x0=bytes leidos
read_line:
    mov x2, x1             //count = maxlen
    mov x1,x0             //buf = addr
    mov x0, #0             //fd = stdin
    mov x8,#63           //syscall:read
    svc #0
    ret


//ascii to fixed (x0 = buffer) -> x0 = valor en fixed point x1000
//admite
//12
//-12
//12.3
//-12.345
//la parte decimal se rellena con ceros hasta 3 digitos

ascii_to_fixed:
    mov x1,#0           //parte entera
    mov x5, #0          //parte decimal acumulada
    mov x6, #0          //cantidad de digitos fraccionarios
    mov x7, #0        //bandera: 0= entero 1 = fraccion
    mov x4, #0         //bandera signo 0 = possitivo, 1 = negativo

    //leer el primer caaracter
    ldrb w2, [x0], #1
    cmp w2, #'-'
    b.eq atf_negative
    cmp w2, #'+'
    b.eq atf_loop
    sub x0,x0, #1     //retroceder el puntero si no es signo
    b atf_loop

atf_negative:
    mov x4, #1         //signo negativo

atf_loop:
    ldrb w2, [x0], #1    //cargar byte y
    cmp w2, #10          //comparar con '\n'
    b.eq atf_finish
    cmp w2, #13          //comparar con '\r'
    b.eq atf_finish

    cmp w2, #'.'         //comparar con '-'
    b.eq atf_dot

    cmp w2, #'0'
    b.lt atf_finish
    cmp w2, #'9'
    b.gt atf_finish

    sub w2, w2, #'0'     //convertir char a valor numérico

    cmp x7, #0
    b.ne atf_frac_digit

    //parte entera
    mov x9, #10
    mul x1, x1, x9       //entero *= 10
    add x1, x1, x2       //entero += dígito
    b atf_loop

atf_frac_digit:
    //solo guardar hasta 3 digitos
    cmp x6, #3
    b.ge atf_loop

    mov x9, #10
    mul x5, x5, x9       //decimal *= 10
    add x5, x5, x2       //decimal += dígito
    add x6, x6, #1       //incrementar contador de dígitos
    b atf_loop

atf_dot:
    mov x7, #1         //cambiar a modo fraccionario
    b atf_loop

atf_finish:
    //rellenar decimales faltantes con ceros 
    mov x9, #3
    sub x9, x9, x6     //3 - cantidad de dígitos fraccionarios

atf_pad_loop:
    cmp x9, #0
    b.le atf_combine
    mov x10, #10
    mul x5, x5, x10     //decimal *= 10
    sub x9, x9, #1
    b atf_pad_loop

atf_combine:
    mov x10, #1000
    mul x1, x1, x10     //entero *= 1000
    add x1, x1, x5     //resultado = entero + decimal

    cmp x4, #0
    b.eq atf_done
    neg x1, x1          //si es negativo, negar el resultado

atf_done:
    mov x0, x1
    ret

//fixed ro ascii x0 = valor escalado x1000, x1 = buffer -> x0 = cantidad de caracteres escritos
//imprime siempre 3 dígitos fraccionarios, aunque sean ceros

fixed_to_ascii:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    mov x2, x1         //buffer actual
    mov x5, #0         //logitud total

    //signo
    cmp x0, #0
    b.ge fta_abs
    mov w3, #'-'
    strb w3, [x2], #1
    add x5, x5, #1
    neg x0, x0

fta_abs:
    //parte entera y decimal
    mov x6, #1000
    udiv x7, x0, x6       //entero = valor/1000
    msub x8, x7, x6, x0    //decimal = valor

    //imprimir parte entera usando int_to_ascii
    sub sp, sp, #32
    str x2, [sp, #0]
    str x5, [sp, #8]
    str x8, [sp, #16]
    mov x1,x2
    mov x0,x7
    bl int_to_ascii

    ldr x2, [sp, #0]
    ldr x5, [sp, #8]
    ldr x8, [sp, #16]
    add sp, sp, #32

    //logitud de la parte entera
    mov x9,x0
    add x5, x5, x9
    add x2, x2, x9       //mover el puntero del buffer

    //punto decimal
    mov w3, #'.'
    strb w3, [x2], #1
    add x5, x5, #1

     //centenas
    mov x6, #100
    udiv x10, x8, x6          //digit_h = frac/100
    mov x12, x10              //guardar valor numerico
    add w10, w10, #'0'        //convertir a ASCII
    strb w10, [x2], #1
    add x5, x5, #1
    msub x11, x12, x6, x8     //resto = frac - digit_h*100

    //decenas
    mov x8, x11
    mov x6, #10
    udiv x10, x8, x6          //digit_t = resto/10
    mov x12, x10              //guardar valor numerico
    add w10, w10, #'0'        //convertir a ASCII
    strb w10, [x2], #1
    add x5, x5, #1
    msub x11, x12, x6, x8     //resto = resto - digit_t*10

    //unidades
    add w11, w11, #'0'
    strb w11, [x2], #1
    add x5, x5, #1

    mov x0, x5
    ldp x29, x30, [sp], #16
    ret
    

//ascii to int (x0 = buffer) ->=valor entero no negativo
//lee hasta '\n', '\r' o primer no-digito.
ascii_to_int:
    mov x1, #0            //acumulador resultado
    mov x4, #0            //bandera negativo

    //verificar primer caracter para signo
    ldrb w2, [x0], #1        //cargar primer byte
    cmp w2, #'-'         //comparar con '-'
    b.ne atoi_first_digit

    //es negativo, setear bandera y avanzar puntero
    mov x4, #1            //bandera negativo
    b atoi_loop

atoi_first_digit:
    //el primer caracter no es '-', retrocede el puntero 
    //si no es digito terminar en 0
    cmp w2, #'0'         //comparar con '0'
    b.lt atoi_apply_sign
    cmp w2, #'9'         //comparar con '9'
    b.gt atoi_apply_sign

    //procesar primer digito yua leido
    sub w2,w2, #'0'        //convertir char a valor numérico
    mov x3, #10
    mul x1,x1, x3        //resultado *= 10
    add x1, x1, x2        //resultado += dígito
    

atoi_loop:
    ldrb w2, [x0], #1     //cargar byte y avanzar puntero
    cmp w2, #10           //comparar con '\n'
    b.eq atoi_apply_sign
    cmp w2, #13           //comparar con '\r'
    b.eq atoi_apply_sign

    cmp w2, #'0'         //comparar con '0'
    b.lt atoi_apply_sign
    cmp w2, #'9'        //comparar con '9'
    b.gt atoi_apply_sign

    sub w2,w2, #'0'        //convertir char a valor numérico
    mov x3, #10
    mul x1,x1, x3        //resultado *= 10
    add x1, x1, x2        //resultado += dígito
    b atoi_loop

atoi_apply_sign:
    //si x4 == 1, negar el resultado
    cmp x4, #1
    b.ne atoi_done
    neg x1, x1  //resultado = -resultado

atoi_done:
    mov x0, x1
    ret

//int_to_ascii(x0 = numero, x1 = buffer) -> x0 = cantidad_digitos
//convierte un numero en su representacion ASCII
//ejemplo: 305 -> buffer contiene 305
int_to_ascii:
    mov x2,x1               //x2 = puntero al buffer
    mov x3, #10             //divisor
    mov x4,#0              //contador de dígitos
    mov x5, x1             //guardar inicio del buffer

    //caso especial si es 0
    cmp x0, #0
    b.ne ita_loop
    
    mov w6, #'0'
    strb w6, [x2], #1
    mov x0, #1
    ret

ita_loop:
    //si no quedan digitos, termina
    cmp x0, #0
    b.eq ita_reverse

    //extrae el digito mas a la derecha
    udiv x7, x0, x3           //cociente = num/10
    msub x8, x7, x3, x0        //resto = num - cociente*10  residuo = num - (cociente*10)

    //convierte digito a ASCII
    add w8, w8, #'0'
    strb w8, [x2], #1
    add x4, x4, #1             //incrementa contador de dígitos

    mov x0, x7                 //actualiza num = cociente
    b ita_loop

ita_reverse:
    //invierte el buffer
    mov x1, x5            //x1 = inicio del buffer
    mov x2,x5            //x2 = inicio del buffer
    add x2,x2, x4
    sub x2, x2, #1

ita_rev_loop:

    cmp x1, x2
    b.ge ita_rev_done

    ldrb w6, [x1]
    ldrb w7, [x2]
    strb w7, [x1], #1
    strb w6, [x2], #-1

    b ita_rev_loop

ita_rev_done:
    mov x0, x4
    ret
