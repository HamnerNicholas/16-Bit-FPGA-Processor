# Instruction Set Architecture (ISA)

This section documents the Instruction Set Architecture (ISA) implemented by the 16-Bit CPU.

The ISA defines the programming model exposed by the processor, including the available instructions, register architecture, instruction encoding, addressing modes, and interrupt model.

While the processor architecture describes **how** the CPU is implemented in hardware, the ISA describes **what** the processor is capable of executing.

---

## Documents

| Document | Description |
|----------|-------------|
| [Instruction Set](instruction-set.md) | Complete reference for every instruction supported by the CPU. |
| [Registers](registers.md) | General-purpose and architectural registers available to software. |
| [Instruction Format](instruction-format.md) | Layout and decoding of the 16-bit instruction word. |
| [Addressing Modes](addressing.md) | Supported operand and addressing modes. |
| [Interrupts](interrupts.md) | Interrupt architecture, vector table, and interrupt handling. |
| [Execution Model](execution-model.md) | The fetch–decode–execute cycle of the processor. |

---

## ISA Features

The current instruction set includes support for:

- Arithmetic operations
- Memory access
- Conditional and unconditional branching
- Subroutine calls and returns
- Interrupt handling
- Terminal output
- Register-to-register data movement

The ISA uses a fixed-width 16-bit instruction format, allowing each instruction to be decoded using a common hardware datapath.

---

## Programming Model

The processor exposes:

- Eight general-purpose registers (`r0`–`r7`)
- A dedicated Subroutine Register File (SRF) for parameter passing and return values
- Program Counter (PC)
- Instruction Register (IR)
- Accumulator (ACC)
- Interrupt Return Register (IRR)

Additional architectural registers are described in the **Registers** documentation.

---

## Instruction Categories

Instructions are organized into the following families:

- Subroutine Instructions
- Immediate Arithmetic
- Register Arithmetic
- Memory Access
- Branch Instructions
- Input / Output
- Copy Instructions
- Interrupt Control

Each instruction family shares a common encoding format and opcode structure.

---

## Relationship to the Software Toolchain

The ISA serves as the interface between software and hardware.

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
 Machine Code (ISA)
        │
        ▼
    16-Bit CPU
```

Assembly language programs target the ISA directly, while programs written in the high-level language are translated into ISA instructions by the compiler.

---

## Design Goals

The instruction set was designed with the following objectives:

- Simple and consistent instruction encoding
- Efficient implementation in hardware
- Clear separation of instruction families
- Straightforward decoding logic
- Educational accessibility
- Seamless integration with the compiler and assembler

These goals provide a clean programming model while keeping the processor implementation relatively compact and easy to understand.
