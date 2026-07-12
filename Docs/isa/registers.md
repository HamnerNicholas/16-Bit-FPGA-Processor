# Registers

This document describes the programmer-visible and architectural registers of the 16-Bit CPU.

The processor uses a combination of general-purpose registers and dedicated architectural registers to support arithmetic operations, memory access, branching, subroutines, and interrupt handling.

---

# Register Overview

The processor contains the following register groups.

| Register Group | Purpose |
|---------------|----------|
| General-Purpose Registers | Temporary data storage |
| Accumulator (ACC) | Arithmetic and logic operations |
| Program Counter (PC) | Instruction sequencing |
| Instruction Register (IR) | Current instruction |
| Subroutine Register File (SRF) | Function parameters and return values |
| Interrupt Return Register (IRR) | Stores the interrupted program counter |

---

# General-Purpose Registers

The processor provides eight general-purpose registers.

| Register | Description |
|----------|-------------|
| r0 | General-purpose register |
| r1 | General-purpose register |
| r2 | General-purpose register |
| r3 | General-purpose register |
| r4 | General-purpose register |
| r5 | General-purpose register |
| r6 | General-purpose register |
| r7 | General-purpose register |

These registers are used for temporary storage, arithmetic operations, and data movement.

The compiler also uses them during expression evaluation and code generation.

---

# Accumulator (ACC)

The accumulator is the primary operand register for the processor.

Most arithmetic, comparison, and memory instructions operate implicitly on the accumulator.

For example,

```assembly
addi r1 5
```

performs

```
r1 ← ACC + 5
```

Similarly,

```assembly
add r2
```

performs

```
ACC ← ACC + r2
```

Because the accumulator is implicit in many instructions, it is not referenced directly by assembly syntax.

---

# Program Counter (PC)

The Program Counter contains the address of the next instruction to execute.

During normal execution,

```
PC ← PC + 1
```

after each instruction.

Control-flow instructions modify the Program Counter directly.

Examples include:

- JSR
- JUMP
- BEQ
- BNE
- BLT
- RSR
- RINT

---

# Instruction Register (IR)

The Instruction Register stores the instruction currently being executed.

Each instruction follows the fixed 16-bit instruction format.

```
Instruction Memory

        │

        ▼

Instruction Register

        │

        ▼

Instruction Decoder
```

The Instruction Register is not directly accessible by software.

---

# Subroutine Register File (SRF)

The processor includes a dedicated **Subroutine Register File (SRF)** used to communicate between callers and subroutines.

Unlike stack-based architectures, function parameters and return values are transferred through dedicated hardware registers.

| Register | Purpose |
|----------|----------|
| SRF0 | Return value |
| SRF1 | Parameter 1 |
| SRF2 | Parameter 2 |
| SRF3 | Parameter 3 |

The compiler automatically manages the SRF during function calls.

Assembly programs may access the SRF directly using the `SSRF` and `RSRF` instructions.

---

# Interrupt Return Register (IRR)

The Interrupt Return Register stores the address of the interrupted instruction whenever an interrupt occurs.

Interrupt sequence

```
Current PC

        │

        ▼

IRR

        │

        ▼

Interrupt Service Routine
```

When the interrupt handler completes,

```assembly
rint
```

restores execution using the value stored in the IRR.

The IRR is managed entirely by the processor and is not directly accessible by software.

---

# Register Usage

The following table summarizes how each register group is typically used.

| Register | Typical Usage |
|----------|---------------|
| r0-r7 | General-purpose storage |
| ACC | Arithmetic, comparisons, memory operations |
| PC | Instruction sequencing |
| IR | Current instruction |
| SRF | Subroutine communication |
| IRR | Interrupt return address |

---

# Compiler Register Usage

The compiler makes extensive use of the general-purpose registers during expression evaluation.

Typical usage includes:

| Register | Typical Compiler Usage |
|----------|------------------------|
| r0-r7 | Temporary expression evaluation |
| SRF0 | Function return value |
| SRF1-SRF3 | Function parameters |

The exact register allocation depends on the generated code.

---

# Architectural Registers

Not every processor register is directly visible to software.

| Register | Software Accessible |
|----------|:-------------------:|
| r0-r7 | ✓ |
| SRF | ✓ |
| ACC | Implicit |
| PC | Control flow only |
| IR | No |
| IRR | No |

The Program Counter is modified indirectly through branch and subroutine instructions.

The Accumulator is accessed implicitly by many instructions.

The Instruction Register and Interrupt Return Register are managed entirely by processor hardware.

---

# Design Philosophy

The register architecture was designed to balance hardware simplicity with compiler efficiency.

Key design decisions include:

- Eight general-purpose registers for temporary storage
- An accumulator-based execution model
- Dedicated hardware support for subroutine parameter passing
- Hardware-managed interrupt return mechanism
- Fixed register encoding using three bits

This organization keeps the datapath relatively compact while providing sufficient flexibility for both assembly programming and compiler-generated code.
