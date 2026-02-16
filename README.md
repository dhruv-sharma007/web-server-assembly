# Bare Minimum Assembly Web Server

A bare minimum low-level HTTP server written in **x86_64 Assembly** for Linux. This project demonstrates how to use Linux system calls (syscalls) to create a socket, bind to a port, listen for incoming connections, and serve a static HTML response.

This project is primarily for educational purposes, showcasing how a web server can be implemented at the most fundamental level using assembly language.

---

## ✨ Features

- **Minimalistic Design**: Built with low-level system calls and no external libraries.
- **Static Response**: Sends a predefined HTML response to any incoming HTTP request.
- **x86_64 Assembly**: Demonstrates advanced assembly coding practices, including syscall usage.

---

## 🛠 Prerequisites

To build and run this server, you need:

1. **Linux Environment**: Required to use the Linux-specific syscalls.
2. **NASM**: The Netwide Assembler, for compiling the assembly source.
3. **Binutils**: Specifically `ld` for linking the compiled object file (`main.o`).

---

## ⚡ Quick Start

To quickly set up and run the server, follow these steps:

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/bare-minimum-assembly-web-server.git
cd bare-minimum-assembly-web-server
```

### 2. Build the Project

Use the **NASM assembler** and **ld linker** to compile the project:

```bash
# Assemble the source code into an object file
nasm -f elf64 main.asm -o main.o

# Link the object file to create the executable
ld main.o -o main
```

### 3. Run the Server

Run the server executable:

```bash
./main
```

---

## 🌐 Access the Server

Once the server is running:

1. Open your browser.
2. Navigate to `http://127.0.0.1:8080` (default listening port).

You'll see the predefined HTML response served by the assembly server.

---

## 🕹 Example Output

When running the server and accessing it in a web browser, you may receive a response like:

```http
HTTP/1.1 200 OK
Content-Type: text/html; charset=UTF-8

<!DOCTYPE html>
<html>
<head>
  <title>Bare Minimum Web Server</title>
</head>
<body>
  <h1>Hello, World!</h1>
  <p>This is a static response served by an Assembly web server.</p>
</body>
</html>
```

---

## 🧩 How It Works

This project leverages Linux syscalls to achieve the following steps:

1. **Socket Creation**: A new socket is created using the `socket` syscall.
2. **Binding**: The socket is bound to a specific IP address (0.0.0.0) and port (8080 by default).
3. **Listening for Connections**: The `listen` syscall allows the server to wait for incoming connections.
4. **Accepting Requests**: Once a client connects, the `accept` syscall is used to initialize a connection.
5. **Sending the Response**: The server sends a simple static HTTP response and closes the connection.

For a deeper explanation of the syscalls and code structure, refer to the comments in the `main.asm` file.

---

## 🧑‍💻 Contributions

Contributions are welcome! Feel free to fork this repository and submit a pull request. If you're looking for ideas, consider:

- Adding support for more HTTP methods (e.g., `POST`, `PUT`).
- Adding dynamic content support.
- Improving error handling (e.g., for invalid requests).
- Adding code comments for better readability.

---

## 🛡 License

This project is released under the [MIT License](LICENSE). You are free to use, modify, and distribute this project as long as you include the original license.

---

## 🏗 Future Enhancements

- **Multi-Threading**: To handle multiple concurrent connections.
- **Dynamic Content**: Enhance the server to generate dynamic responses.
- **IPv6 Support**: Update the server for compatibility with IPv6.

---

## Support

If you have any questions or issues, feel free to open an issue in this repository or reach out via email.

Happy hacking!