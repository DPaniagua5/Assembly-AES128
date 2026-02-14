// Funciones para imprimir estado y claves para depuración.

.include "macros.s"
.include "data.s"

.section .text

// Necesita llamar a funciones de otros modulos
.extern addRoundKey
.extern subBytes
.extern shiftRows
.extern mixColumns

.extern matState
.extern key
.extern criptograma
.extern buffer

// Funcion para imprimir byte en hexadecimal
.global print_hex_byte
print_hex_byte:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    // Separar nibbles
    and w1, w0, #0xF0
    lsr w1, w1, #4
    and w2, w0, #0x0F
    
    // Convertir nibble alto
    cmp w1, #10
    b.lt high_digit
    add w1, w1, #'A' - 10
    b high_done
high_digit:
    add w1, w1, #'0'
high_done:
    
    // Convertir nibble bajo
    cmp w2, #10
    b.lt low_digit
    add w2, w2, #'A' - 10
    b low_done
low_digit:
    add w2, w2, #'0'
low_done:
    // Imprimir
    sub sp, sp, #16
    strb w1, [sp]
    strb w2, [sp, #1]
    mov w3, #' '
    strb w3, [sp, #2]
    
    mov x0, #1
    mov x1, sp
    mov x2, #3
    mov x8, #64
    svc #0
    
    add sp, sp, #16
    ldp x29, x30, [sp], #16
    ret

// Función para imprimir matriz
.type printMatrix, %function
.global printMatrix
printMatrix:
    stp x29, x30, [sp, #-48]!
    mov x29, sp
    
    // Guardar parametros
    str x0, [sp, #16] 
    str x1, [sp, #24] 
    str x2, [sp, #32] 
    
    // Imprimir mensaje
    mov x0, #1
    ldr x1, [sp, #24]
    ldr x2, [sp, #32]
    mov x8, #64
    svc #0
    
    // Imprimir matriz 4x4
    mov x23, #0 
    
print_row_loop:
    cmp x23, #4
    b.ge print_matrix_done
    
    mov x24, #0 
    
print_col_loop:
    cmp x24, #4
    b.ge print_row_newline
    
    // Calcular índice column-major: fila*4 + columna
    mov x25, #4
    mul x25, x23, x25
    add x25, x25, x24
    
    // Cargar y mostrar byte
    ldr x20, [sp, #16] 
    ldrb w0, [x20, x25]
    bl print_hex_byte
    
    add x24, x24, #1
    b print_col_loop
    
print_row_newline:
    print 1, newline, 1
    add x23, x23, #1
    b print_row_loop
    
print_matrix_done:
    print 1, newline, 1
    ldp x29, x30, [sp], #48
    ret
.size printMatrix, (. - printMatrix)

.type testAddRoundKey, %function
.global testAddRoundKey
testAddRoundKey:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    // Mensaje antes de AddRoundKey
    mov w0, #0
    print 1, msg_before_addroundkey, lenMsgBeforeAdd
    ldr x0, =matState
    ldr x1, =debug_state
    mov x2, lenDebugState
    bl printMatrix
    mov w0, #0
    
    // Aplicar AddRoundKey
    bl addRoundKeyWithRound
    
    // Mensaje después de AddRoundKey
    print 1, msg_after_addroundkey, lenMsgAfterAdd
    ldr x0, =matState
    ldr x1, =debug_state
    mov x2, lenDebugState
    bl printMatrix
    
    ldp x29, x30, [sp], #16
    ret
    .size testAddRoundKey, (. - testAddRoundKey)


// Muestra el estado antes y después de la transformación
.type testSubBytes, %function
.global testSubBytes
testSubBytes:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    // Mensaje antes de SubBytes
    print 1, msg_before_subbytes, lenMsgBeforeSub
    ldr x0, =matState
    ldr x1, =debug_state
    mov x2, lenDebugState
    bl printMatrix
    
    // Aplicar SubBytes
    bl subBytes
    
    // Mensaje despues de SubBytes
    print 1, msg_after_subbytes, lenMsgAfterSub
    ldr x0, =matState
    ldr x1, =debug_state
    mov x2, lenDebugState
    bl printMatrix
    
    ldp x29, x30, [sp], #16
    ret
    .size testSubBytes, (. - testSubBytes)
    

    .type testShiftRows, %function
.global testShiftRows
testShiftRows:
    stp x29, x30, [sp, #-16]!
    mov x29, sp


    // Mensaje antes de ShiftRows
    print 1, msg_before_shiftrows, lenMsgBeforeShift
    ldr x0, =matState
    ldr x1, =debug_state
    mov x2, lenDebugState
    bl printMatrix

    // Aplicar ShiftRows
    bl shiftRows

    // Mensaje después de ShiftRows e impresión
    print 1, msg_after_shiftrows, lenMsgAfterShift
    ldr x0, =matState
    ldr x1, =debug_state
    mov x2, lenDebugState
    bl printMatrix

    ldp x29, x30, [sp], #16
    ret
.size testShiftRows, (. - testShiftRows)

// Función para MixColumns
.type testMixColumns, %function
.global testMixColumns
testMixColumns:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    print 1, msg_before_mixcolumns, lenMsgBeforeMix
    ldr x0, =matState
    ldr x1, =debug_state
    mov x2, lenDebugState
    bl printMatrix
    
    bl mixColumns
    
    print 1, msg_after_mixcolumns, lenMsgAfterMix
    ldr x0, =matState
    ldr x1, =debug_state
    mov x2, lenDebugState
    bl printMatrix

    ldp x29, x30, [sp], #16
    ret
.size testMixColumns, (. - testMixColumns)

.type testKeyExpansion, %function
.global testKeyExpansion
testKeyExpansion:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    // Imprimir clave original
    print 1, debug_key, lenDebugKey
    ldr x0, =key
    ldr x1, =debug_key
    mov x2, lenDebugKey
    bl printMatrix
    
    // Generar subclaves
    bl keyExpansion
    
    // Imprimir algunas subclaves generadas
    mov x19, #1                 // Empezar con ronda 1
print_subkeys_loop:
    cmp x19, #11                // Imprimir hasta ronda 10
    b.ge print_subkeys_done
    
    // Cargar subclave de la ronda x19
    mov x0, x19
    bl getRoundKey
    
    // Imprimir subclave
    ldr x0, =key
    ldr x1, =debug_key
    mov x2, lenDebugKey
    bl printMatrix
    
    add x19, x19, #1
    b print_subkeys_loop
    
print_subkeys_done:
    ldp x29, x30, [sp], #16
    ret
.size testKeyExpansion, (. - testKeyExpansion)
