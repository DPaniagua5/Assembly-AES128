.include "macros.s"
.include "data.s"

.section .text

// Incluir funciones de otros módulos para ensamblado
.extern readTextInput
.extern convertHexKey
.extern printMatrix
.extern print_separator

.extern testAddRoundKey
.extern testSubBytes
.extern testShiftRows
.extern testMixColumns
.extern addRoundKeyWithRound

.extern matState
.extern key
.extern criptograma
.extern buffer

.type _start, %function
.global _start
_start:
    // Leer texto
    print 1, msg_txt, lenMsgTxt
    bl readTextInput
    
    // Mostrar estado inicial del texto
    ldr x0, =matState
    ldr x1, =debug_state
    mov x2, lenDebugState
    bl printMatrix
    
    // Leer clave
    print 1, msg_key, lenMsgKey
    bl convertHexKey
    
    // Mostrar clave
    ldr x0, =key
    ldr x1, =debug_key
    mov x2, lenDebugKey
    
    bl keyExpansion
    
    bl printExpandedKeys
    
    mov w0, #0
    bl printRoundHeader
    
    print 1, msg_before_addroundkey, lenMsgBeforeAdd
    ldr x0, =matState
    ldr x1, =debug_state
    mov x2, lenDebugState
    bl printMatrix
    
    mov w0, #0
    bl addRoundKeyWithRound
    
    print 1, msg_after_addroundkey, lenMsgAfterAdd
    ldr x0, =matState
    ldr x1, =debug_state
    mov x2, lenDebugState
    bl printMatrix
    
    mov w19, #1
    
main_rounds_loop:
    cmp w19, #10
    b.ge final_round
    
    // Imprimir encabezado de ronda
    mov w0, w19
    bl printRoundHeader
    
    // --- SubBytes ---
    print 1, msg_before_subbytes, lenMsgBeforeSub
    ldr x0, =matState
    ldr x1, =debug_state
    mov x2, lenDebugState
    bl printMatrix
    
    bl subBytes
    
    print 1, msg_after_subbytes, lenMsgAfterSub
    ldr x0, =matState
    ldr x1, =debug_state
    mov x2, lenDebugState
    bl printMatrix
    
    // --- ShiftRows ---
    print 1, msg_before_shiftrows, lenMsgBeforeShift
    ldr x0, =matState
    ldr x1, =debug_state
    mov x2, lenDebugState
    bl printMatrix
    
    bl shiftRows
    
    print 1, msg_after_shiftrows, lenMsgAfterShift
    ldr x0, =matState
    ldr x1, =debug_state
    mov x2, lenDebugState
    bl printMatrix
    
    // --- MixColumns ---
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
    
    // --- AddRoundKey ---
    print 1, msg_before_addroundkey, lenMsgBeforeAdd
    ldr x0, =matState
    ldr x1, =debug_state
    mov x2, lenDebugState
    bl printMatrix
    
    mov w0, w19
    bl addRoundKeyWithRound
    
    print 1, msg_after_addroundkey, lenMsgAfterAdd
    ldr x0, =matState
    ldr x1, =debug_state
    mov x2, lenDebugState
    bl printMatrix
    
    // Separador entre rondas
    bl print_separator
    
    add w19, w19, #1
    b main_rounds_loop
    
final_round:
    mov w0, #10
    bl printRoundHeader
    
    // --- SubBytes ---
    print 1, msg_before_subbytes, lenMsgBeforeSub
    ldr x0, =matState
    ldr x1, =debug_state
    mov x2, lenDebugState
    bl printMatrix
    
    bl subBytes
    
    print 1, msg_after_subbytes, lenMsgAfterSub
    ldr x0, =matState
    ldr x1, =debug_state
    mov x2, lenDebugState
    bl printMatrix
    
    // --- ShiftRows ---
    print 1, msg_before_shiftrows, lenMsgBeforeShift
    ldr x0, =matState
    ldr x1, =debug_state
    mov x2, lenDebugState
    bl printMatrix
    
    bl shiftRows
    
    print 1, msg_after_shiftrows, lenMsgAfterShift
    ldr x0, =matState
    ldr x1, =debug_state
    mov x2, lenDebugState
    bl printMatrix
    
    // --- AddRoundKey (última clave) ---
    print 1, msg_before_addroundkey, lenMsgBeforeAdd
    ldr x0, =matState
    ldr x1, =debug_state
    mov x2, lenDebugState
    bl printMatrix
    
    mov w0, #10
    bl addRoundKeyWithRound
    
    print 1, msg_after_addroundkey, lenMsgAfterAdd
    ldr x0, =matState
    ldr x1, =debug_state
    mov x2, lenDebugState
    bl printMatrix
    
    bl print_separator
    
    print 1, msg_final_state, lenMsgFinalState
    ldr x0, =matState
    ldr x1, =debug_state
    mov x2, lenDebugState
    bl printMatrix
    
    print 1, msg_final, lenMsgFinal
    
    ldr x20, =matState
    ldr x21, =criptograma
    mov x22, #0  // contador de salida
    mov x23, #0  // columna
    
copy_by_columns:
    cmp x23, #4
    b.ge copy_columns_done
    
    mov x24, #0 
copy_column_rows:
    cmp x24, #4
    b.ge next_column
    
    mov x25, #4
    mul x25, x24, x25
    add x25, x25, x23
    
    ldrb w26, [x20, x25]
    strb w26, [x21, x22]
    
    add x22, x22, #1
    add x24, x24, #1
    b copy_column_rows
    
next_column:
    add x23, x23, #1
    b copy_by_columns
    
copy_columns_done:
    ldr x20, =criptograma
    mov x21, #0
print_criptograma_loop:
    cmp x21, #16
    b.ge print_criptograma_done
    ldrb w0, [x20, x21]
    bl print_hex_byte
    add x21, x21, #1
    b print_criptograma_loop
print_criptograma_done:
    
    print 1, newline, 1
    bl print_separator

    
    print 1, msg_Calificacion, lenMsg_Calificacion
    
    // Salir del programa
    mov x0, #0
    mov x8, #93
    svc #0
    
.size _start, (. - _start)
