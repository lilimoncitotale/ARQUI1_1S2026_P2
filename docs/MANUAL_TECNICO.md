# Manual Técnico del Proyecto

## Motor de álgebra lineal optimizado en ARM64

**Arquitectura de Computadores y Ensambladores 1**  
Universidad de San Carlos de Guatemala | Facultad de Ingeniería | Ingeniería en Ciencias y Sistemas

---

## Índice

1. Resumen Ejecutivo
2. Descripción técnica del problema
3. Alcance técnico
4. Representación en memoria
5. Arquitectura del código
6. Operaciones implementadas
7. Manejo de memoria dinámico
8. Metodología de desarrollo
9. Build y ejecución
10. Notas técnicas

---

## 1. Resumen Ejecutivo

Este proyecto implementa un motor de álgebra lineal en ensamblador ARM64 orientado a operaciones con matrices desde consola. El sistema permite:

- Ingreso dinámico de matrices con validación de dimensiones (1 a 10 filas/columnas).
- Almacenamiento en memoria contigua (row-major, `int32` en escala x1000).
- Ejecución de operaciones: identidad, transpuesta, Gauss, Gauss-Jordan, inversa, determinante, operaciones aritméticas.
- Menú interactivo con submenú para operaciones aritméticas.
- Modo debug (verbose) para depuración de operaciones de eliminación.
- Validaciones de restricciones matemáticas: cuadrada, singularidad, dimensiones compatibles.

El proyecto prioriza comprensión de arquitectura ARM64, control de flujo con registros, llamadas a subrutinas, preservación de estado y administración de memoria dinámica con `mmap`/`munmap` en Linux emulado con QEMU.

---

## 2. Descripción técnica del problema

Se requiere automatizar operaciones de álgebra lineal sobre matrices en ARM64 para reforzar comprensión a bajo nivel. El sistema debe:

- Pedir filas y columnas de la matriz.
- Reservar memoria dinámica para `m × n` elementos.
- Cargar cada celda desde consola (entrada ASCII).
- Acceder a elementos por fórmula row-major.
- Ejecutar operaciones desde menú interactivo.
- Validar restricciones matemáticas y casos singulares.

---

## 3. Alcance técnico

La aplicación implementa algoritmos de álgebra lineal en ensamblador ARM64, con foco en exactitud funcional, validaciones e implementación correcta en bajo nivel:

### 3.1 Operaciones de álgebra lineal

- **Identidad**: genera matriz cuadrada con 1 en diagonal.
- **Transpuesta**: intercambia filas y columnas.
- **Gauss (triangulación superior)**: eliminación con pivoteo parcial.
- **Gauss-Jordan (reducción total)**: eliminación hacia forma reducida.
- **Matriz inversa**: mediante Gauss-Jordan sobre matriz aumentada.
- **Determinante**: producto de diagonal triangular × paridad de swaps.

### 3.2 Operaciones aritméticas

- Suma matricial.
- Resta matricial.
- Hadamard (elemento por elemento).
- Multiplicación cruz.
- División matricial (`A / B = A × inv(B)`).

### 3.3 Validaciones

- Rango de dimensiones (1–10).
- Matriz cuadrada (para identidad, inversa, determinante).
- Matriz singular (inversa, determinante).
- Dimensiones compatibles (para operaciones binarias).
- Opciones de menú válidas.

### 3.4 Requerimientos técnicos

- **Lenguaje**: Ensamblador ARM64 (AArch64).
- **Emulación**: `qemu-aarch64`.
- **Sistema base**: Linux.
- **Herramientas**: toolchain GNU cruzado (`aarch64-linux-gnu-*`).
- **Editor**: Visual Studio Code.

---

## 4. Representación en memoria

### 4.1 Layout de matriz

Cada matriz se almacena como bloque contiguo de `int32` en escala x1000 (punto fijo).

Para `A[i][j]` con `m` filas y `n` columnas:

```
dirección = base_address + ((i * n + j) * 4)
```

Donde 4 es el tamaño de `int32` en bytes.

### 4.2 Ejemplo

Matriz 2×3:
```
A = | 1.5   2.0   3.5 |
    | 4.0   5.5   6.0 |
```

En memoria x1000:
```
A[0][0] = 1500
A[0][1] = 2000
A[0][2] = 3500
A[1][0] = 4000
A[1][1] = 5500
A[1][2] = 6000
```

Orden lineal: `[1500, 2000, 3500, 4000, 5500, 6000]`

---

## 5. Arquitectura del código

### 5.1 Módulos

| Archivo | Propósito |
|---------|-----------|
| `src/main.s` | Flujo principal, menú, I/O, memory management, lógica de depuración. |
| `src/io.s` | Primitivos de I/O: lectura de línea, conversión ASCII ↔ entero ↔ punto fijo. |
| `src/fixed_math.s` | Aritmética point fijo: `fixed_mul`, `fixed_div`, `fixed_abs`. |
| `src/ops_identity.s` | Genera matriz identidad. |
| `src/ops_transpose.s` | Transpuesta de matriz. |
| `src/ops_gauss.s` | Triangulación superior mediante eliminación Gaussiana. |
| `src/ops_det_inv.s` | Inversa por Gauss-Jordan, determinante. |
| `src/ops_determinant.s` | Determinante por triangulación. |
| `src/ops_arith.s` | Suma, resta, Hadamard, multiplicación, división matricial. |

### 5.2 Convenciones

- **Parámetros**: `x0–x7` (registros de argumento por AArch64 calling convention).
- **Retorno**: `x0` (casi siempre), `x1` (en algunos casos).
- **Callee-saved**: `x19–x28`, `x29` (`fp`), `x30` (`lr`) preservados por llamadas.
- **Clobber**: `x8–x18` y registros no callee-saved pueden modificarse.

### 5.3 Contrato de funciones principales

#### Ingreso de matrices

```asm
read_matrix_from_console(rows, cols) → x0 = address
  x0: rows
  x1: cols
  → x0: base address (allocado con mmap)
```

#### Operación unaria (identidad, transpuesta)

```asm
operation(A, rows, cols) → x0 = result_address
  x0: base de A
  x1: filas de A
  x2: columnas de A
  → x0: base de resultado
```

#### Operación binaria (suma, resta, hadamard, matmul)

```asm
op_binary(A, B, rows, cols) → x0 = result_address | error_code
  x0: base de A
  x1: base de B
  x2: filas
  x3: columnas
  → x0: base de resultado (0 si error)
```

#### Códigos de error

| Código | Significado |
|--------|-------------|
| 0 | Éxito |
| 1 | Dimensiones incompatibles |
| 2 | Matriz no cuadrada |
| 3 | Matriz singular |
| 4 | Opción de menú inválida |

---

## 6. Operaciones implementadas

### 6.1 Identidad

- **Entrada**: filas (validada cuadrada).
- **Salida**: matriz con 1.0 (1000 en x1000) en diagonal, 0 fuera.
- **Archivo**: `src/ops_identity.s`.

### 6.2 Transpuesta

- **Entrada**: matriz `m × n`.
- **Salida**: matriz `n × m` con elementos intercambiados.
- **Fórmula**: `T[j][i] = A[i][j]`.
- **Archivo**: `src/ops_transpose.s`.

### 6.3 Triangulación Gaussiana

- **Entrada**: matriz `m × n` (típicamente cuadrada).
- **Salida**: matriz triangular superior.
- **Algoritmo**: 
  1. Para cada columna `k`:
     - Buscar pivote máximo en `A[k..m][k]`.
     - Intercambiar filas si necesario.
     - Eliminar elementos debajo del pivote.
- **Archivo**: `src/ops_gauss.s`.

### 6.4 Gauss-Jordan (reducción total)

- **Entrada**: matriz cuadrada no singular.
- **Salida**: forma reducida (aproximadamente identidad).
- **Algoritmo**: Similar a Gauss, pero elimina arriba **y** abajo del pivote.
- **Usada por**: inversa, determinante.
- **Archivo**: `src/ops_det_inv.s`.

### 6.5 Matriz inversa

- **Entrada**: matriz `n × n` no singular.
- **Salida**: `A⁻¹` (matriz `n × n`).
- **Algoritmo**: 
  1. Construir matriz aumentada `[A | I]`.
  2. Aplicar Gauss-Jordan.
  3. Extraer lado derecho (es `A⁻¹`).
- **Validaciones**: cuadrada, determinante ≠ 0.
- **Archivo**: `src/ops_det_inv.s`.

### 6.6 Determinante

- **Entrada**: matriz `n × n`.
- **Salida**: escalalar (det en x1000).
- **Algoritmo**: 
  1. Triangular con Gauss.
  2. Calcular producto diagonal.
  3. Ajustar signo por número de swaps.
- **Archivo**: `src/ops_determinant.s`.

### 6.7 Operaciones aritméticas

#### 6.7.1 Suma

- `R[i][j] = A[i][j] + B[i][j]`.
- Validación: `A` y `B` mismas dimensiones.

#### 6.7.2 Resta

- `R[i][j] = A[i][j] - B[i][j]`.
- Validación: `A` y `B` mismas dimensiones.

#### 6.7.3 Hadamard

- `R[i][j] = A[i][j] * B[i][j]` (elemento por elemento en x1000).
- Validación: `A` y `B` mismas dimensiones.

#### 6.7.4 Multiplicación cruz

- `R[i][j] = Σ(A[i][k] * B[k][j])` para `k=0..A.cols–1`.
- Validación: `A.cols == B.rows`.
- Resultado: `A.rows × B.cols`.

#### 6.7.5 División matricial

- `R = A / B = A * inv(B)`.
- Validación: `B` cuadrada, no singular, `B.rows == A.rows`.

---

## 7. Manejo de memoria dinámico

### 7.1 Asignación

```asm
allocate(rows, cols, &address) → 0 (éxito) o -1 (error)
  x0: filas
  x1: columnas
  x2: dirección de salida (&address)
  → x0: 0 (éxito) o -1 (error)
```

**Internamente**: uso de syscall `mmap` (syscall 222 en AArch64) para pedir páginas a Linux.

- Cálculo de tamaño: `size = rows * cols * 4` (bytes).
- Protección: PROT_READ | PROT_WRITE.
- Flags: MAP_ANONYMOUS | MAP_PRIVATE (no archivo, privado al proceso).

### 7.2 Liberación

```asm
free_memory(address, rows, cols) → void
  x0: base address
  x1: filas
  x2: columnas
```

**Internamente**: syscall `munmap` (syscall 215 en AArch64).

- Cálculo de tamaño: igual que alloc.
- Devuelve páginas al OS.

### 7.3 Ciclo de vida

1. `alloc_matrix`: reserva `A`, `B`, `R` al inicio.
2. Operaciones: reutilizan las direcciones.
3. Opción de menú 9: permite limpiar mem y recargar `A` desde cero.
4. `cleanup_all`: libera `A`, `B`, `R` al salir.

---

## 8. Metodología de desarrollo

### 8.1 Enfoque modular

- Desarrollo por archivo (`ops_*`) aisla operaciones.
- Contrato claro para cada función (parámetros, registro, retorno).
- Validaciones tempranas evitan cómputo innecesario.

### 8.2 Testing

- Pruebas manuales vía menú en consola.
- Validación de output vs. cálculo manual o herramienta externa (ej. NumPy).
- Edge cases: matriz 1×1, matriz singular, matriz no cuadrada.

### 8.3 Depuración

**Modo debug** (opción 10 del menú):

- Alterna flag global `debug_verbose`.
- Cuando activo, Gauss y Gauss-Jordan imprimen snapshots columnares de la matriz en puntos clave:
  - Antes de empezar eliminación.
  - Después de cada fila de pivoteo.

**Función helper**: `debug_print_matrix(address, rows, cols)`.
- Preserva todos los registros callee-saved (`x19–x26`).
- Evita clobber que causaría segfault.

---

## 9. Build y ejecución

### 9.1 Compilación

```bash
# Limpiar builds anteriores
make clean

# Compilar binario principal
make main

# Compilar todo (incluyendo tests)
make

# Compilar en paralelo (4 jobs)
make -j4
```

### 9.2 Ejecución

```bash
# Ejecutar programa principal
make run-main

# O directamente con qemu
qemu-aarch64 bin/main
```

### 9.3 Makefile

- **Target `main`**: compila `src/*.s` en `bin/main`.
- **Target `run-main`**: ejecuta `bin/main` en qemu.
- **Target `run-test-input`**: test de I/O.
- **Target `run-test-row`**: test de acceso row-major.

---

## 10. Notas técnicas

### 10.1 Escala numérica

Todos los valores se almacenan en **punto fijo x1000**:

- `1.5` → `1500` (en `int32`).
- `−0.75` → `−750`.
- `0.001` → `1`.

Operaciones:
- **Suma/resta**: `int_result = int_a + int_b` (directo).
- **Multiplicación**: `int_result = (int_a * int_b) / 1000`.
- **División**: `int_result = (int_a * 1000) / int_b`.

### 10.2 Pivoteo parcial

En Gauss, se busca el elemento de máximo valor absoluto en cada columna (debajo de diagonal) y se intercambian filas. Esto mejora estabilidad numérica.

### 10.3 Tratamiento de matrices singulares

Si determinante ≈ 0 (comparado con umbral pequeño):

- Inversa: retorna código 3 (singular).
- Determinante: retorna 0.
- División (`A / B`): retorna 0 si `B` singular.

### 10.4 Registro de estado

Algunas operaciones retornan:
- `x0 = 0` → éxito.
- `x0 ≠ 0` → error (código específico).

En operaciones unarias que devuelven matriz, `x0` es la dirección (no nula si éxito, 0 si error).

### 10.5 Inicialización de memoria

Matrices se inicializan a **0** por defecto (`mmap` con MAP_ANONYMOUS da página limpia).

---

## Anexo: Referencias y material de apoyo

1. ARM Architecture Reference Manual for A-profile Architecture (ARMv8-A)  
   https://developer.arm.com/documentation/ddi0487/latest

2. ARM Cortex-A Series Programmer's Guide for ARMv8-A  
   https://developer.arm.com/documentation/den0024

3. ARM GNU Toolchain Documentation  
   https://gcc.gnu.org/onlinedocs/

4. Learning ARM64 Assembly — Azeria Labs  
   https://azeria-labs.com

5. Linux AArch64 Syscall Reference  
   https://github.com/torvalds/linux/blob/master/arch/arm64/kernel/syscalls/syscall.tbl

---

