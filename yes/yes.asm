
%include "defines.inc"

global _start

section .data
    usage_str db "[USAGE]: ./program-name <string>", NEWLINE
    usage_len equ $ - usage_str

    newline db NEWLINE
    space   db SPACE

section .bss
    BUFFER_SIZE equ 64      ; We could make it bigger, but this seems alright.
    buffer_echo resb BUFFER_SIZE

section .text

; Helper function to print a null-terminated string.
; Arg 1 (RDI): Pointer to string.
print_zstring:
    ; This is going to be like strlen
    MOV RSI, RDI
    XOR RAX, RAX
    MOV RCX, -1         ; RCX as a max length counter.

    ; repne scasb looks like Chinese, but what it does is
    ; scanning bytes in memory [RDI] against AL until there's a match.
    ; It decrements RCX and increments RDI per byte.
    REPNE SCASB

    ; Length is simple to calculate: (RDI) - (RSI) - 1.
    SUB RDI, RSI
    DEC RDI
    MOV RDX, RDI        ; We move it here for the syscall.

    MOV RAX, SYS_WRITE
    MOV RDI, STDOUT
    ; RSI already holds the pointer.
    syscall

    RET

_start:
    ; So, for you to know, the kernel places argc and argv on the stack.
    ; POP RCX         ; We get argc.
    ; MOV R12, RCX    ; We move argc into a safe register.

    ; RSP points to argv[0].
    ; MOV R13, RSP

    ; Okay, what we did there is non-standard and kinda fragile. Let's move to a better option.
    MOV R12, [RSP]
    

    ; RSP points to argv[0]. LEA = Load Effective Address. R13 points to argv[0].
    LEA R13, [RSP + 8]

    CMP R12, 1
    JLE _usage

_args_loop:
    ; We will loop from argv[1] to argv[argc-1]
    MOV RBX, 1

_print_args_again:
    MOV RDI, [R13 + RBX * 8]
    CALL print_zstring

    INC RBX
    CMP RBX, R12
    JL print_space

    ; If it's the end, we need a newline.
    MOV RAX, SYS_WRITE
    MOV RDI, STDOUT
    MOV RSI, newline
    MOV RDX, 1 
    syscall

    JMP _args_loop

print_space:
    MOV RAX, SYS_WRITE
    MOV RDI, STDOUT
    MOV RSI, space
    MOV RDX, 1 
    syscall

    JMP _print_args_again

_usage:
    MOV RAX, SYS_WRITE
    MOV RDI, STDERR
    MOV RSI, usage_str
    MOV RDX, usage_len
    syscall

    ; We exit with the error exit code.
    MOV RAX, SYS_EXIT
    MOV RDI, EXIT_FAILURE
    syscall
