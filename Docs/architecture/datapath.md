# Datapath

The processor uses an accumulator-based datapath.

Unlike register-register architectures such as MIPS or RISC-V, arithmetic operations are performed using the accumulator as one of the ALU operands.

## Major Components

- Program Counter
- Instruction Memory
- Register File
- JAL Register File
- Arithmetic Logic Unit
- Accumulator Register
- Global Memory
- Interrupt Controller
- I/O Module

## Data Flow

A typical arithmetic instruction follows the sequence:

```
Program Counter
        │
        ▼
Instruction Memory
        │
        ▼
Instruction Decode
        │
        ▼
Register File
        │
        ▼
ALU
        │
        ▼
Accumulator
```

Memory operations route the accumulator through Global Memory, while output operations send accumulator contents to the I/O subsystem.

The modular datapath allows each hardware block to be developed and tested independently before integration into the complete processor.
