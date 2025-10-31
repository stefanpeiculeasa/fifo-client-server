# FIFO-Based Client-Server Manual Page Service

A robust client-server application built in Bash that provides manual pages for Unix/Linux commands using named pipes (FIFOs) for inter-process communication.

## 📋 Overview

This project implements a simple but efficient client-server architecture where clients can request manual pages for commands, and the server responds by sending the requested documentation through FIFO (First In First Out) pipes. The system supports multiple concurrent clients and provides a clean, colorized interface.

## ✨ Features

- **FIFO-based IPC**: Uses named pipes for reliable inter-process communication
- **Multiple Concurrent Clients**: Support for multiple clients connecting simultaneously
- **Robust Error Handling**: Comprehensive error checking and graceful failure handling
- **Clean Shutdown**: Proper resource cleanup with signal handling
- **Timeout Protection**: Prevents client hanging with timeout mechanisms
- **Colorized Output**: Easy-to-read colored terminal output
- **Configuration-based**: External configuration file for easy customization

## 🏗️ Architecture

```
┌─────────────┐                  ┌─────────────┐
│   Client 1  │                  │   Client 2  │
│  (PID: A)   │                  │  (PID: B)   │
└──────┬──────┘                  └──────┬──────┘
       │                                │
       │ client_fifo-A                  │ client_fifo-B
       │                                │
       └────────────┬───────────────────┘
                    │
                    ▼
             ┌──────────────┐
             │    Server    │
             │ (server_fifo)│
             └──────────────┘
```

### Communication Flow

1. **Server Initialization**: Creates a named pipe (FIFO) for receiving requests
2. **Client Connection**: Each client creates its own FIFO for receiving responses
3. **Request Format**: `BEGIN-REQ [PID: command] END-REQ`
4. **Response**: Server sends manual page content through client-specific FIFO
5. **Cleanup**: Both server and clients clean up their FIFOs on exit

## 🚀 Getting Started

### Prerequisites

- Bash shell (4.0 or higher recommended)
- Linux/Unix operating system
- `man` command available (for manual pages)
- Standard Unix utilities: `mkfifo`, `timeout`, `cat`

### Installation

1. Clone the repository:
```bash
git clone https://github.com/stefanpeiculeasa/fifo-client-server.git
cd fifo-client-server
```

2. Make scripts executable:
```bash
chmod +x server.sh client.sh
```

3. (Optional) Customize configuration:
```bash
nano config.cfg
```

## 📖 Usage

### Starting the Server

```bash
./server.sh
```

The server will display:
```
Server is running. Listening for requests (type 'quit' or 'q' to exit)...
```

To stop the server, type `quit` or `q` and press Enter.

### Running a Client

In a new terminal window:

```bash
./client.sh
```

The client will prompt:
```
Client is ready. Type your commands (type 'quit' or 'q' to exit):
> 
```

### Example Session

```bash
> ls
[Manual page for 'ls' is displayed]
Response received!

> grep
[Manual page for 'grep' is displayed]
Response received!

> quit
Exiting...
Client FIFO client_fifo-12345 removed. Client instance closed.
```

## ⚙️ Configuration

Edit `config.cfg` to customize:

```properties
SERVER_FIFO=server_fifo
```

You can change the FIFO filename or add additional configuration parameters.

## 🔧 Technical Details

### Error Handling

- **FIFO Existence Checks**: Validates FIFOs before use
- **Configuration Validation**: Ensures config file exists and is properly formatted
- **Server Availability**: Client checks if server is running before connecting
- **Timeout Protection**: 5-second timeout on client responses
- **Signal Handling**: Proper cleanup on SIGINT, SIGTERM, and EXIT

### Security Considerations

- FIFOs are created with default permissions (0600)
- Client PID-based FIFO naming prevents conflicts
- Input validation prevents command injection
- Only valid commands (verified by `command -v`) are processed

### Process Management

- Background process for handling terminal input on server
- Trap handlers ensure cleanup on unexpected termination
- PID-based resource naming prevents conflicts

## 🐛 Troubleshooting

### Server won't start
- **Issue**: FIFO already exists
- **Solution**: Remove the FIFO manually: `rm server_fifo`

### Client can't connect
- **Issue**: Server not running
- **Solution**: Start the server first with `./server.sh`

### Timeout errors
- **Issue**: Server not responding
- **Solution**: Restart the server and check system resources

### Permission denied
- **Issue**: Scripts not executable
- **Solution**: Run `chmod +x server.sh client.sh`

## 📝 Development

### Project Structure

```
.
├── README.md           # This file
├── LICENSE            # License information
├── .gitignore         # Git ignore rules
├── config.cfg         # Configuration file
├── server.sh          # Server implementation
└── client.sh          # Client implementation
```

### Code Quality

- **Bash Best Practices**: Uses `[[` instead of `[`, proper quoting, error checking
- **Style**: Consistent indentation, meaningful variable names
- **Documentation**: Inline comments explain complex logic
- **Error Handling**: Comprehensive error checking throughout

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Alfredo**

- GitHub: [@yourusername](https://github.com/yourusername)

## 🙏 Acknowledgments

- Inspired by Unix/Linux inter-process communication concepts
- Built as a laboratory project for ITBI course
- Thanks to the open-source community for bash scripting best practices

## 📚 References

- [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/)
- [Bash Manual](https://www.gnu.org/software/bash/manual/)
- [Named Pipes (FIFOs)](https://man7.org/linux/man-pages/man7/fifo.7.html)

---

**Note**: This is an educational project demonstrating client-server architecture using FIFOs. For production use, consider more robust IPC mechanisms like sockets or message queues.
