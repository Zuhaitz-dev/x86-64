
%include "defines.inc"

global _start

section .data
    usage_str db "[USAGE]: ./program-name <filename>", NEWLINE
    usage_len equ $ - usage_str

section .bss
    BUFFER_SIZE equ 4096            ; We'll read the file in 4KB chunks.
    file_buffer resb BUFFER_SIZE

section .text

_start:
    CMP qword [RSP], 2      ; In our case we expect two arguments.
    JNE _usage

    ; Let's get argv[1].
    MOV R12, [RSP + 16]

    ; Open the file.
    MOV RAX, SYS_OPEN
    MOV RDI, R12
    MOV RSI, 0              ; Flags: 0 for read-only (we could add this in "defines.inc").
    MOV RDX, 0              ; Mode: 0
    syscall

    ; RAX holds the file descriptor, let's move it to R12
    MOV R12, RAX

    ; Always check just in case.
    CMP R12, 0
    JL _exit_error

_read_loop:
    ; Reading is not that special, it's like echo.asm
    ; but instead of stdin, we pass the file descriptor.
    MOV RAX, SYS_READ
    MOV RDI, R12
    MOV RSI, file_buffer
    MOV RDX, BUFFER_SIZE
    syscall

    MOV R13, RAX    ; RAX holds the number of bytes actually read. We save it in R13
    ; If the number is 0 or less, we are done.
    CMP R13, 0
    JLE _close_file

    ; Time to write the chunk to the screen.
    ; If we wanted to write it in a different file, it would not be that hard.
    ; We would need to open it (to write/overwrite) and use the created file descriptor.
    MOV RAX, SYS_WRITE
    MOV RDI, STDOUT
    MOV RSI, file_buffer
    MOV RDX, R13
    syscall

    JMP _read_loop

_close_file:
    MOV RAX, SYS_CLOSE
    MOV RDI, R12            ; file descriptor.
    syscall

_exit_success:
    MOV RAX, SYS_EXIT
    MOV RDI, EXIT_SUCCESS
    syscall

_usage:
    MOV RAX, SYS_WRITE
    MOV RDI, STDERR         ; stdout is valid too, but let's consider it an error.
    MOV RSI, usage_str
    MOV RDX, usage_len
    syscall

_exit_error:
    MOV RAX, SYS_EXIT
    MOV RDI, EXIT_FAILURE
    syscall
