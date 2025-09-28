
; This one is a different version of the previous example with
; main.c and max.asm. In this case we are going to call the printf
; function directly from here.

; Instructions:
; nasm -f elf64 main.asm -o main.o 
; gcc -no-pie main.o -o result

%include "defines.inc"

global main
extern printf       ; We are promising NASM that printf exists.

section .data
    my_array dq 34, 12, 99, 7, 50, 101, 88, -5, 200
    array_len equ ($ - my_array) / 8

    ; Okay, we are working with printf. It will expect a C-string.
    ; Therefore it must be null-terminated.
    ; %ld is the format specifier for "long decimal" (64-bit int).
    format_string db "The maximum value found is: %ld", NEWLINE, 0

section .text


; Instructions:
; nasm -f elf64 max.asm -o max.o
; gcc -c main.c -o main.o
; gcc main.o max.o -o result

global array_max

section .text

; (The function doesn't change).
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

; Main program entry. In this case, to prevent issues, we are going to use main.
main:
    ; First we have to get our result.
    MOV RDI, my_array
    MOV RSI, array_len
    CALL array_max

    MOV R12, RAX

    ; Now we have to prepare the call to the C external function.
    ; Arg 1 (RDI): the address of our format string.
    ; Arg 2 (RSI): the value we want to print.
    MOV RDI, format_string
    MOV RSI, R12

    ; ABI rule for variadic function (just know this has to be 0 here).
    XOR RAX, RAX

    CALL printf

    MOV RAX, SYS_EXIT
    MOV RDI, EXIT_SUCCESS
    syscall
