; using struc provided by nasm works as like struct
struc sockaddr_in
    .sin_family resw 1   ; 2 bytes
    .sin_port   resw 1   ; 2 bytes
    .sin_addr   resd 1   ; 4 bytes
    .sin_zero   resb 8   ; 8 bytes padding
endstruc

struc sigaction
  .sa_handler   resq 1
  .sa_flags     resq 1
  .sa_restorer  resq 1
  .sa_mask      resq 2
endstruc


%macro print 2
  mov rax, SYS_WRITE
  mov rdi, 1
  mov rsi, %1 
  mov rdx, %2
  syscall
%endmacro

%macro write 3
  mov rax, SYS_WRITE
  mov rdi, %1 ; fd
  mov rsi, %2 ; message
  mov rdx, %3 ; msg_len of message
  syscall
%endmacro

%macro read 3
  mov rax, SYS_READ
  mov rdi, %1 ; fd
  mov rsi, %2 ; buffer pointer
  mov rdx, %3 ; size
  syscall
%endmacro

%macro close 1
  mov rax, SYS_CLOSE
  mov rdi, %1 
  syscall
%endmacro

%macro exit 1
  mov rax, SYS_EXIT
  mov rdi, %1
  syscall
%endmacro

%macro accept 1
  mov rax, SYS_ACCEPT
  mov rdi, %1
  xor rsi, rsi 
  xor rdx, rdx
  syscall
%endmacro

section .bss
  server_socket_fd resq 1
  client_socket_fd resq 1
  server_addr resb sockaddr_in_size
  client_buffer resb CLIENT_BUFFER_SIZE
  sa resb sigaction_size

section .data

  PORT equ 8080
  AF_INET equ 2
  SOCK_STREAM equ 1

  SYS_SOCKET equ 41
  SYS_BIND equ 49
  SYS_LISTEN equ 50
  SYS_ACCEPT equ 43
  SYS_WRITE equ 1
  SYS_READ equ 0
  SYS_CLOSE equ 3
  SYS_EXIT equ 60
  SYS_RT_SIGACTION equ 13

  CLIENT_BUFFER_SIZE equ 2048

  err_msg db "socket error", 0x0a
  err_msg_len equ $ - err_msg

  msg db "Assembly Server running on http://127.0.0.1:8080 !", 0x0a
  msg_len equ $ - msg

  sigint_msg db "Caught SIGINT! Exiting cleanly.", 10
  sigint_msg_len equ $ - sigint_msg

  ; ------- Response Data -----------

response:
    db "HTTP/1.1 200 OK", 13, 10
    db "Content-Type: text/html; charset=UTF-8", 13, 10
    db "Content-Length: 157", 13, 10
    db "Server: Assembly Server", 13, 10
    db "Accept-Ranges: bytes", 13, 10
    db "Connection: close", 13, 10
    db 13, 10

response_header_len equ $ - response

body:
    db "<html>", 13, 10
    db "  <head>", 13, 10
    db "    <title>An Example Page</title>", 13, 10
    db "  </head>", 13, 10
    db "  <body>", 13, 10
    db "    <p>Hello World, serving from assembly web server !!!</p>", 13, 10
    db "  </body>", 13, 10
    db "</html>", 13, 10

body_len equ $ - body

  
section .text
  global _start

_start:   
  mov rax, SYS_SOCKET
  mov rdi, AF_INET
  mov rsi, SOCK_STREAM
  mov rdx, 0
  syscall

  test rax, rax
  js  socket_error

  mov [server_socket_fd], rax

  mov ax, 8080
  xchg al, ah
  mov word  [server_addr + sockaddr_in.sin_family], AF_INET
  mov word  [server_addr + sockaddr_in.sin_port], ax
  mov dword [server_addr + sockaddr_in.sin_addr], 0

  mov rax, SYS_BIND
  mov rdi, [server_socket_fd]
  lea rsi, [server_addr]
  mov rdx, sockaddr_in_size
  syscall 

  test rax, rax
  js   socket_error

  mov rax, SYS_LISTEN
  mov rdi, [server_socket_fd]
  mov rsi, 20
  syscall

  test rax, rax
  js   socket_error

  print msg, msg_len

  ; -----  SIGNAL HANDLING -----
  lea rdi, [sa]
  mov rcx, sigaction_size
  xor rax, rax
  rep stosb

  mov qword [sa + sigaction.sa_handler], sigint_handler

  mov rax, SYS_RT_SIGACTION
  mov rdi, 2          ; SIGINT
  lea rsi, [sa]
  xor rdx, rdx        ; oldact = NULL
  mov r10, 8          ; sigsetsize
  syscall
  ; ---------------------------------

accept_loop:
  accept [server_socket_fd]

  test rax, rax
  js   socket_error

  mov [client_socket_fd], rax
  
  ; read data from client and print to stdout
  read [client_socket_fd], client_buffer, CLIENT_BUFFER_SIZE
  print client_buffer, CLIENT_BUFFER_SIZE



  write [client_socket_fd], response,response_header_len
  write [client_socket_fd], body, body_len
  close [client_socket_fd]
  
  jmp accept_loop
  
  exit 0

socket_error:
  close [server_socket_fd]
  print err_msg, err_msg_len
  exit 1

sigint_handler:
  close [server_socket_fd]
  print sigint_msg, sigint_msg_len
  exit 1
