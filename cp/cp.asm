
%include "defines.inc"

global _start

section .data
    usage_str db "[USAGE]: ./program-name <source> <dest>", NEWLINE
    usage_len equ $ - usage_str

section .bss
    BUFFER_SIZE equ 4096            ; We will use 4KB chunks.
    file_buffer resb BUFFER_SIZE

section .text

_start:
    CMP qword [RSP], 3      ; Three arguments: program-name, source and destination.
    JNE _usage

    ; Let's get argv[1].
    MOV R12, [RSP + 16]
    ; And argv[2].
    MOV R13, [RSP + 24]

    ; Open source file.
    MOV RAX, SYS_OPEN
    MOV RDI, R12
    MOV RSI, O_RDONLY
    MOV RDX, 0          ; Mode.
    syscall

    MOV R12, RAX        ; We move the result to R12.

    ; Always check.
    CMP R12, 0
    JL _exit_failure

    ; Open destination file.
    MOV RAX, SYS_OPEN
    MOV RDI, R13
    MOV RSI, O_WRONLY | O_CREAT ; We need to combine the flags.
    MOV RDX, DEFAULT_MODE       ; 0664 in octal (rw-rw-r--)
    syscall

    MOV R13, RAX        ; Pretty much the same with R13.

    CMP R13, 0
    JL _close_source_failure    ; We need to close the source file.

_read_loop:
    MOV RAX, SYS_READ
    MOV RDI, R12
    MOV RSI, file_buffer
    MOV RDX, BUFFER_SIZE
    syscall

    MOV R14, RAX        ; The bytes we actually read.
    
    CMP R14, 0
    JLE _close_files 

    MOV RAX, SYS_WRITE
    MOV RDI, R13
    MOV RSI, file_buffer
    MOV RDX, R14
    syscall

    JMP _read_loop

_close_files:
    MOV RAX, SYS_CLOSE
    MOV RDI, R12
    syscall
    
    MOV RAX, SYS_CLOSE
    MOV RDI, R13
    syscall

_exit_success:
    MOV RAX, SYS_EXIT
    MOV RDI, EXIT_SUCCESS
    syscall

_close_source_failure:
    MOV RAX, SYS_CLOSE
    MOV RDI, R12
    syscall

    JMP _exit_failure

_usage:
    MOV RAX, SYS_WRITE
    MOV RDI, STDERR
    MOV RSI, usage_str
    MOV RDX, usage_len
    syscall

_exit_failure:
    MOV RAX, SYS_EXIT
    MOV RDI, EXIT_FAILURE
    syscall


