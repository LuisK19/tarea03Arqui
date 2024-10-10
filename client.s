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
    mov x8, 198                           @ Syscall socket
    svc 0
    mov x19, x0                           @ Guardar el descriptor del socket en x19

    @ Conectar al servidor
    mov x0, x19                           @ Descriptor del socket
    ldr x1, =ip                           @ Dirección IP del servidor
    ldr x2, =port                         @ Puerto del servidor
    mov x8, 203                           @ Syscall connect
    svc 0

client_loop:
    @ Leer mensaje de la terminal
    mov x0, 0                             @ stdin
    ldr x1, =buffer                       @ Buffer para el mensaje
    mov x2, 1024                          @ Tamaño del buffer
    mov x8, 63                            @ Syscall read
    svc 0

    @ Enviar el mensaje al servidor
    mov x0, x19                           @ Descriptor del socket
    ldr x1, =buffer                       @ Buffer que contiene el mensaje
    mov x2, 1024                          @ Tamaño del mensaje
    mov x8, 206                           @ Syscall send
    svc 0

    @ Recibir mensaje del servidor
    mov x0, x19                           @ Descriptor del socket
    ldr x1, =buffer                       @ Buffer para recibir el mensaje
    mov x2, 1024                          @ Tamaño del buffer
    mov x8, 207                           @ Syscall recv
    svc 0

    @ Mostrar mensaje recibido
    mov x0, 1                             @ stdout
    ldr x1, =buffer                       @ Mostrar el mensaje recibido
    mov x2, 1024                          @ Tamaño del mensaje
    mov x8, 64                            @ Syscall write
    svc 0

    b client_loop                         @ Bucle continuo

    @ Cerrar el socket
    mov x0, x19                           @ Descriptor del socket
    mov x8, 57                            @ Syscall close
    svc 0

    mov x8, 93                            @ Syscall exit
    svc 0
