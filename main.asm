struc sockaddr_in
    .sin_family resw 1   ; 2 bytes
    .sin_port   resw 1   ; 2 bytes
    .sin_addr   resd 1   ; 4 bytes
    .sin_zero   resb 8   ; 8 bytes padding
endstruc

section .bss
  server_socket_fd resq 1   ; reserves 4 bytes same as int in c 
  client_socket_fd resq 1

  server_addr resb sockaddr_in_size

section .data

  ; arguments for socket syscall
  PORT equ 8080
  AF_INET equ 2
  SOCK_STREAM equ 1

  SYS_SOCKET equ 41
  SYS_BIND equ 49
  SYS_LISTEN equ 50
  SYS_ACCEPT equ 43

section .text
  global _start

_start:   
  mov rax, SYS_SOCKET         ; 41 is socket syscall index number
  mov rdi, AF_INET
  mov rsi, SOCK_STREAM
  mov rdx, 0
  syscall

  test rax, rax      ; set flags based on rax
  js  socket_error   ; jump if rax < 0 (SF = 1) | jump if sign flag is true

  mov [server_socket_fd], rax  ; store server fd in memory

  ; add data in addr, addr is just contigues data structure treated as struct here
  mov word  [server_addr + sockaddr_in.sin_family], AF_INET   ;  AF_INET
  mov word  [server_addr + sockaddr_in.sin_port], 0x901F  ; port 8080
  mov dword  [server_addr + sockaddr_in.sin_addr], 0

  ; bind syscall
  mov rax, SYS_BIND    ; 49 is bind syscall index
  mov rdi, [server_socket_fd]    ; pass the server fd
  lea rsi, [server_addr]                ; pass the socket address for bind
  mov rdx, sockaddr_in_size
  syscall 

  test rax, rax
  js   socket_error

  mov rax, SYS_LISTEN           ; now we will listen for clients to connect | 50 listen syscall index number
  mov rdi, [server_socket_fd]
  mov rsi, 20                   ; backlog handling in queue
  syscall

  test rax, rax
  js   socket_error

  mov rax, SYS_ACCEPT    ; add looping here to handle connection again and again
  mov rdi, [server_socket_fd]
  mov rsi, rsi
  mov rdx, rdx
  syscall

  test rax, rax
  js   socket_error

  mov [client_socket_fd], rax


socket_error:
  ; exit the process gracefully and close the socket
