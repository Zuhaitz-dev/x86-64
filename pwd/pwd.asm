
%include "defines.inc"

global _start

section .data
    newline db NEWLINE

section .bss
    BUFFER_SIZE equ 4096            ; On Linux, by default, PATH_MAX is set to 4096 characters.
    path_buffer resb BUFFER_SIZE
section .text

_start:
    MOV RAX, SYS_GETCWD
    MOV RDI, path_buffer
    MOV RSI, BUFFER_SIZE
    syscall

    CMP RAX, 0
    JLE .exit_failure

    MOV RDX, RAX
    MOV RAX, SYS_WRITE
    MOV RDI, STDOUT
    MOV RSI, path_buffer
    syscall

    MOV RAX, SYS_WRITE
    MOV RDI, STDOUT
    MOV RSI, newline
    MOV RDX, 1
    syscall

.exit_success:
    MOV RAX, SYS_EXIT
    XOR RDI, RDI
    syscall

.exit_failure:
    MOV RAX, SYS_EXIT
    MOV RDI, EXIT_FAILURE 
    syscall
