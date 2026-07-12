# Board Documentation

This section documents the FPGA implementation of the 16-Bit CPU on the Intel DE10-Lite development board.

The board documentation covers the hardware platform, memory organization, VGA output, and the process of building and programming the FPGA.

---

## Documents

| Document | Description |
|----------|-------------|
| [FPGA Implementation](fpga.md) | Overview of the FPGA hardware and top-level system architecture. |
| [Memory](memory.md) | Instruction memory, global memory, and interrupt vector memory organization. |
| [VGA Output](vga.md) | VGA interface, signal descriptions, and pin assignments. |
| [Programming](programming.md) | Building the project and programming the FPGA. |

---

## Current Hardware Features

The current FPGA implementation includes:

- 16-Bit CPU
- Instruction RAM
- Global Memory
- Interrupt Vector Table (IVT)
- VGA Output
- Eight External Interrupt Inputs

Future revisions are expected to add additional peripherals such as keyboard input and serial communication.

---

## Development Platform

| Component | Description |
|----------|-------------|
| FPGA Board | Intel DE10-Lite |
| FPGA Device | Intel MAX 10 |
| Development Software | Intel Quartus Prime |

---

## System Overview

```text
          Compiler
              │
              ▼
          Assembler
              │
              ▼
 Memory Initialization Files
              │
              ▼
      Intel Quartus Prime
              │
              ▼
         Intel DE10-Lite
              │
              ▼
          16-Bit CPU
              │
              ├── Instruction RAM
              ├── Global Memory
              ├── Interrupt Vector Table
              └── VGA Output
```

The FPGA implementation serves as the hardware platform for executing programs compiled for the 16-Bit CPU.
