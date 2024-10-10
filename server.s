.section .data
buffer:         .space 1024               @ Buffer para los mensajes recibidos
msg:            .ascii "Message: \0"      @ Mensaje de inicio
ip:             .ascii "127.0.0.1\0"      @ Dirección IP (loopback)
port:           .word 8080                @ Puerto a usar

.section .text
.global _start

_start:
    @ Crear socket
    mov x0, 2                             @ AF_INET (IPv4)
    mov x1, 1                             @ SOCK_STREAM (TCP)
    mov x2, 0                             @ Protocolo
    mov x8, 198                           @ Syscall número para socket en ARM64
    svc 0                                 @ Crear socket
    mov x19, x0                           @ Guardar descriptor del socket en x19

    @ Configurar dirección IP y puerto
    mov x0, x19                           @ Descriptor de socket
    mov x1, 2                             @ AF_INET (IPv4)
    ldr x2, =ip                           @ Dirección IP
    ldr x3, =port                         @ Puerto
    mov x8, 200                           @ Syscall bind (en ARM64)
    svc 0

    @ Escuchar conexiones
    mov x0, x19                           @ Descriptor de socket
    mov x1, 5                             @ Backlog
    mov x8, 201                           @ Syscall listen
    svc 0

    @ Aceptar conexiones
    mov x0, x19                           @ Descriptor de socket
    mov x8, 202                           @ Syscall accept
    svc 0
    mov x20, x0                           @ Guardar el descriptor del cliente

server_loop:
    @ Recibir mensaje
    mov x0, x20                           @ Descriptor del cliente
    ldr x1, =buffer                       @ Buffer para recibir el mensaje
    mov x2, 1024                          @ Tamaño del buffer
    mov x8, 207                           @ Syscall recv
    svc 0

    @ Mostrar el mensaje recibido
    mov x0, 1                             @ stdout
    ldr x1, =buffer                       @ Buffer
    mov x2, 1024                          @ Tamaño
    mov x8, 64                            @ Syscall write
    svc 0

    @ Leer el mensaje de la terminal
    mov x0, 0                             @ stdin
    ldr x1, =buffer                       @ Buffer
    mov x2, 1024                          @ Tamaño del buffer
    mov x8, 63                            @ Syscall read
    svc 0

    @ Enviar el mensaje al cliente
    mov x0, x20                           @ Descriptor del cliente
    ldr x1, =buffer                       @ Buffer que contiene el mensaje
    mov x2, 1024                          @ Tamaño del mensaje
    mov x8, 206                           @ Syscall send
    svc 0

    b server_loop                         @ Bucle continuo

    @ Cerrar el socket
    mov x0, x19                           @ Descriptor del socket
    mov x8, 57                            @ Syscall close
    svc 0

    mov x8, 93                            @ Syscall exit
    svc 0
