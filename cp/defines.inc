
; **System Call Constants**
SYS_READ  equ 0
SYS_WRITE equ 1
SYS_OPEN  equ 2
SYS_CLOSE equ 3
SYS_EXIT  equ 60

; **File Descriptor Constants**
STDIN  equ 0
STDOUT equ 1
STDERR equ 2

; **Common Character Constants**
NEWLINE equ 10

; **Exit Code Constants**
EXIT_SUCCESS equ 0
EXIT_FAILURE equ 1

; **Flags for SYS_OPEN**
O_RDONLY equ 0
O_WRONLY equ 1
O_CREAT  equ 64

; **File Creation Mode**
DEFAULT_MODE equ 0664o  ; (rw-rw-r--)
