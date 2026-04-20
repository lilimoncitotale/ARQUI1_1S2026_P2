.global fixed_mul
.global fixed_div
.global fixed_abs

.section .text

//fixed mul
// x0 = a (fixed x1000)
//x1 = b (fixed x1000)
//ret x0 = (a*b)/1000 (fixed x1000)

fixed_mul:
    mov x2, #1000
    mul x3, x0, x1
    sdiv x0, x3, x2
    ret

//fixed div
//x0 = a (fixed x1000)
//x1 = b (fixed x1000)
//ret x0 = (a*1000)/b (fixed x1000)
//asumimos b !0 (gauss ya valida pivote)

fixed_div:
    mov x2, #1000
    mul x3, x0, x2
    sdiv x0, x3,x1
    ret


//fixed abs:
//x0 = a
//ret x0 = abs(a)

fixed_abs:
    cmp x0, #0
    b.ge fixed_abs_done
    neg x0, x0

fixed_abs_done:
    ret
    