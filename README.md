# 16-Bit CPU

<img width="3433" height="594" alt="IMG_9878" src="https://github.com/user-attachments/assets/34ad6e51-8702-440b-a295-6805964479a6" />


A complete hardware and software ecosystem built around a custom 16-bit processor.

This project explores the full computer engineering stack by implementing a processor from the ground up, including the instruction set architecture, assembler, compiler, FPGA implementation, and supporting development tools.

Unlike projects that focus solely on hardware, this repository demonstrates the complete path from high-level source code to execution on a custom processor.

---

## Features

### Hardware

- Custom 16-bit CPU architecture
- Verilog implementation
- Intel DE10-Lite FPGA support
- Interrupt handling with dedicated Interrupt Vector Table (IVT)
- VGA graphics output
- Memory-mapped instruction and data memories

### Software

- Custom Instruction Set Architecture (ISA)
- Two-pass assembler
- Custom C-inspired programming language
- Two-pass compiler
- Automatic runtime generation
- Interrupt Vector Table generation

### Documentation

Comprehensive documentation covering every layer of the system:

- CPU Architecture
- Instruction Set Architecture
- Assembly Language
- High-Level Programming Language
- Assembler Design
- Compiler Design
- FPGA Implementation

---

## Software Stack

```
High-Level Language
        │
        ▼
     Compiler
        │
        ▼
 Assembly Language
        │
        ▼
     Assembler
        │
        ▼
   Machine Code
        │
        ▼
    16-Bit CPU
```
---

## Current Language Features

The compiler currently supports:

- Variables
- Arrays
- Arithmetic expressions
- Functions
- Return values
- If statements
- While loops
- For loops
- Inline assembly

Programs written in the high-level language are compiled into the custom assembly language before being assembled into machine code.

---

## Current Hardware Features

The FPGA implementation currently includes:

- 16-Bit CPU
- Instruction RAM
- Global Memory
- Interrupt Vector Table
- VGA Output
- Eight External Interrupt Inputs

Additional peripherals are planned for future revisions.

---

## Documentation

The complete documentation for the project can be found in the `docs` directory.

| Section | Description |
|---------|-------------|
| Architecture | Processor design and hardware implementation |
| ISA | Instruction Set Architecture |
| Language | High-level and assembly language references |
| Compiler | Compiler implementation and calling convention |
| Assembler | Assembler implementation and instruction encoding |
| Board | FPGA implementation and programming |

---

## Project Goals

This project was developed to explore every major layer of computer engineering through the design of a complete computing platform.

Areas explored include:

- Digital logic design
- Computer architecture
- Instruction set design
- Assembly language
- Compiler construction
- Hardware/software co-design
- FPGA development
- System documentation

Rather than targeting an existing architecture, every major component of the system was designed specifically for this processor.

---

## Future Work

Planned improvements include:

- PS/2 keyboard support
- Expanded runtime library
- Additional compiler optimizations
- New language features
- Additional peripherals
- Graphics improvements

---

## Author

**Nicholas Hamner**

Computer Engineering Student  
California State University, Sacramento

GitHub: https://github.com/HamnerNicholas
