
%include "defines.inc"

global _start

section .data
    fizz_str db "Fizz"
    fizz_len equ $ - fizz_str

    buzz_str db "Buzz"
    buzz_len equ $ - buzz_str

    fizzbuzz_str db "FizzBuzz"
    fizzbuzz_len equ $ - fizzbuzz_str

    newline_char db NEWLINE 

section .bss
    num_buffer resb 20      ; A 64-bit integer can be 20 digits max.


section .text

; Converts an unsigned 64-bit integer to an ASCII string.
; Arg 1 (RDI): Pointer to the buffer to store the string.
; Arg 2 (RSI): The number to convert.
; Returns (RAX): The length of the resulting string.
uint_to_string:
    PUSH RBP
    MOV RBP, RSP
    PUSH R12

    MOV RAX, RSI    ; Move the number to convert into RAX for division.
    MOV RCX, 10     ; In our algorithm, we use 10 as our divisor.
    XOR R12, R12    ; R12 will count the number of digits.

_divide_loop:
    XOR RDX, RDX    ; We MUST clear RDX before DIV. RDX:RAX is the dividend.
    DIV RCX         ; RAX = RAX/10, RDX = RAX % 10 (remainder).

    ADD RDX, '0'    ; Convert the remainder to an ASCII character.
    PUSH RDX
    INC R12


    CMP RAX, 0
    JNE _divide_loop

    MOV RCX, R12    ; RCX will be our loop counter for popping.

_pop_loop:
    ; The algorithm would give us the digits in a reverse order, but with the 
    ; stack this is solved easily as we get the correct order when popping.
    CMP RCX, 0
    JE _end_conversion

    POP RAX         ; Pop a character into RAX
    MOV [RDI], AL   ; Move the single byte character into the buffer.
    INC RDI
    DEC RCX
    JMP _pop_loop

_end_conversion:
    ; In our first design (when we did this code in a different file)
    ; We added a newline over here, but we already do that in the main loop.
    MOV RAX, R12        ; RAX = return value.

    POP R12
    LEAVE
    RET 

; Helper function. Pretty self-explanatory
; Arg 1 (RSI): Address of the string.
; Arg 2 (RDX): Length of the string.
print_string:
    MOV RAX, SYS_WRITE
    MOV RDI, STDOUT
    syscall
    RET

; The main entry point.
_start:
    MOV R12, 1      ; Counter from 1 to 100

 _main_loop:
    CMP R12, 100
    JG _exit

    ; Is it divisible by 3?
    PUSH R12
    MOV RAX, R12
    XOR RDX, RDX
    MOV RCX, 3
    DIV RCX                     ; RAX=R12/3, RDX=R12%3
    CMP RDX, 0
    MOV R8, 0                   ; fizz=0
    JNE .check5
    MOV R8, 1                   ; fizz=1
.check5:
    POP R12

    ; Is it divisible by 5?
    PUSH R12
    MOV RAX, R12
    XOR RDX, RDX
    MOV RCX, 5
    DIV RCX                     ; RAX=R12/5, RDX=R12%5
    CMP RDX, 0
    MOV R9, 0                   ; buzz=0
    JNE .decide
    MOV R9, 1                   ; buzz=1
.decide:
    POP R12

    ; Now we decide what to print.
    CMP R8, 1
    JNE .check_buzz_only
    CMP R9, 1
    JNE .print_fizz

    ; print "FizzBuzz"
    MOV RSI, fizzbuzz_str
    MOV RDX, fizzbuzz_len
    CALL print_string
    JMP _continue_loop

.print_fizz:
    ; Only fizz
    MOV RSI, fizz_str
    MOV RDX, fizz_len
    CALL print_string
    JMP _continue_loop

.check_buzz_only:
    CMP R9, 1
    JNE .print_number

    ; Only buzz
    MOV RSI, buzz_str
    MOV RDX, buzz_len
    CALL print_string
    JMP _continue_loop

.print_number:
    MOV RDI, num_buffer
    MOV RSI, R12
    CALL uint_to_string          ; returns len in RAX
    MOV RSI, num_buffer
    MOV RDX, RAX
    CALL print_string

_continue_loop:
    MOV RSI, newline_char
    MOV RDX, 1 
    CALL print_string

    INC R12
    JMP _main_loop

_exit:
    MOV RAX, SYS_EXIT
    MOV RDI, EXIT_SUCCESS
    syscall
