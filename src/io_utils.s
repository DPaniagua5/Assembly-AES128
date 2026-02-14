// Funciones de lectura y de entrada de usuario.

.include "macros.s"
.include "data.s"

.section .text

// Incluir funciones de otros modulos
.extern separator_line

.extern matState
.extern key
.extern criptograma
.extern buffer

// Funciones auxiliares (no globales, solo usadas internamente)
is_hex_char:
    cmp w4, #'0'
    b.lt not_hex
    cmp w4, #'9'
    b.le is_hex
    
    orr w4, w4, #0x20 // Convertir a minuscula
    cmp w4, #'a'
    b.lt not_hex
    cmp w4, #'f'
    b.le is_hex
    
not_hex:
    mov w0, #0
    ret
is_hex:
    mov w0, #1
    ret

hex_char_to_nibble:
    cmp w4, #'0'
    b.lt hex_error
    cmp w4, #'9'
    b.le hex_digit
    
    orr w4, w4, #0x20 // Convertir a minúscula
    cmp w4, #'a'
    b.lt hex_error
    cmp w4, #'f'
    b.gt hex_error
    
    sub w0, w4, #'a'
    add w0, w0, #10
    ret
    
hex_digit:
    sub w0, w4, #'0'
    ret
    
hex_error:
    print 1, key_err_msg, lenKeyErr
    mov w0, #0
    ret


// Función para leer cadena de texto y convertir a bytes ASCII
.type readTextInput, %function
.global readTextInput
readTextInput:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // Leer entrada del usuario
    read 0, buffer, 256
    
    // Convertir caracteres a bytes ASCII y almacenar en matriz
    ldr x1, =buffer 
    ldr x2, =matState 
    mov x3, #0 
    
convert_text_loop:
    cmp x3, #16
    b.ge pad_remaining_bytes
    
    ldrb w4, [x1, x3] 
    cmp w4, #10 
    b.eq pad_remaining_bytes
    cmp w4, #0 
    b.eq pad_remaining_bytes
    
    // Almacenar caracter como byte ASCII en column-major order
    // Calcular índice: (index % 4) + (index / 4) * 4
    mov x7, #4
    udiv x8, x3, x7 
    msub x9, x8, x7, x3 
    mul x10, x9, x7 
    add x10, x10, x8 
    
    strb w4, [x2, x10] 
    add x3, x3, #1
    b convert_text_loop
    
pad_remaining_bytes:
    // Rellenar bytes restantes con ceros
    cmp x3, #16
    b.ge convert_text_done
    
    mov x7, #4
    udiv x8, x3, x7 
    msub x9, x8, x7, x3 
    mul x10, x9, x7 
    add x10, x10, x8 
    
    mov w4, #0 
    strb w4, [x2, x10]
    add x3, x3, #1
    b pad_remaining_bytes
    
convert_text_done:
    ldp x29, x30, [sp], #16
    ret
.size readTextInput, (. - readTextInput)


// Función para convertir clave hexadecimal
.type convertHexKey, %function
.global convertHexKey
convertHexKey:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // Leer clave hexadecimal
    read 0, buffer, 33
    
    ldr x1, =buffer 
    ldr x2, =key 
    mov x3, #0 
    mov x11, #0 
    
convert_hex_loop:
    cmp x3, #16
    b.ge convert_hex_done
    
skip_non_hex:
    ldrb w4, [x1, x11]
    cmp w4, #0
    b.eq convert_hex_done
    cmp w4, #10 
    b.eq convert_hex_done
    
    // Verificar si es carácter hex válido
    bl is_hex_char
    cmp w0, #1
    b.eq process_hex_pair
    
    add x11, x11, #1
    b skip_non_hex
    
process_hex_pair:
    // Procesar par de caracteres hex
    ldrb w4, [x1, x11] 
    add x11, x11, #1
    bl hex_char_to_nibble
    lsl w5, w0, #4
    
    ldrb w4, [x1, x11] 
    add x11, x11, #1
    bl hex_char_to_nibble
    orr w5, w5, w0
    
    strb w5, [x2, x3]
    add x3, x3, #1
    b convert_hex_loop
    
convert_hex_done:
    ldp x29, x30, [sp], #16
    ret
    .size convertHexKey, (. - convertHexKey)

// Función para imprimir separador
.type print_separator, %function
.global print_separator
print_separator:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    ldr x0, =separator_line
    mov x1, #0
separator_count:
    ldrb w2, [x0, x1]
    cmp w2, #0
    beq separator_print
    add x1, x1, #1
    b separator_count
    
separator_print:
    mov x2, x1
    mov x1, x0
    mov x0, #1
    mov x8, #64
    svc #0
    
    ldp x29, x30, [sp], #16
    ret
.size print_separator, (. - print_separator)
