
; Instructions:
; nasm -f elf64 max.asm -o max.o
; gcc -c main.c -o main.o
; gcc main.o max.o -o result

global array_max

section .text

; Finds the largest value in an array of quadwords.
; Arg1 (RDI): Address of the array.
; Arg2 (RSI): Number of elements in the array.
array_max:
    ; Edge case of an empty array.
    CMP RSI, 0
    JE _empty_array

    ; First element.
    MOV RAX, [RDI]

    ; Loop counter, RCX, to 1.
    MOV RCX, 1

_loop:
    CMP RCX, RSI 
    JE _end

    MOV RDX, [RDI + RCX * 8]
    INC RCX

    CMP RDX, RAX
    JLE _loop

    MOV RAX, RDX
    JMP _loop

_empty_array:
    ; It's good practice to return 0.
    XOR RAX, RAX

_end:
    RET

; We don't need a _start in this case.
