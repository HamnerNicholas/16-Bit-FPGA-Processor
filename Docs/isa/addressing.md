# Addressing Modes

This document describes the operand and addressing modes supported by the 16-Bit CPU.

An addressing mode defines how an instruction interprets its operands. The instruction set uses a small number of addressing modes to simplify both hardware implementation and compiler code generation.

---

# Overview

The processor supports the following addressing modes.

| Addressing Mode | Description |
|-----------------|-------------|
| Immediate | Operand is encoded directly within the instruction |
| Direct Memory | Operand references a memory address |
| Register | Operand references a general-purpose register |
| Relative | Operand is interpreted as an offset from the Program Counter |
| Label | Symbolic address resolved by the assembler |
| Subroutine Register File | Operand references an SRF register |

---

# Immediate Addressing

Immediate addressing embeds a constant value directly within the instruction.

Example

```assembly
addi r1 5

subi r2 1

multi r3 4
```

The immediate value occupies the upper eight bits of the instruction word.

```
Immediate

↓

Instruction

↓

ALU
```

Typical uses include:

- Constants
- Loop increments
- Arithmetic operations
- Small numeric values

---

# Register Addressing

Register addressing uses one of the processor's eight general-purpose registers.

Example

```assembly
add r1

sub r2

copy r3
```

The register field occupies three bits within the instruction.

```
Register Field

↓

Register File

↓

Operand
```

Register addressing provides fast access to temporary values without accessing memory.

---

# Direct Memory Addressing

Memory instructions use direct addressing.

Example

```assembly
load r1 10

store r2 15
```

The immediate field is interpreted as a global memory address.

```
Instruction

↓

Memory Address

↓

Global Memory
```

The assembler also allows labels to be used in place of numeric addresses.

```assembly
load r1 VALUE
```

---

# Relative Addressing

Branch and subroutine instructions use relative addressing.

Example

```assembly
jump LOOP

beq r1 DONE

jsr PRINT
```

Although the programmer writes symbolic labels, the assembler converts these labels into offsets relative to the current Program Counter.

Conceptually,

```
Current PC

+

Relative Offset

↓

Target Instruction
```

Relative addressing allows programs to be relocated without modifying branch instructions.

---

# Label Addressing

Labels provide symbolic names for instruction and data locations.

Example

```assembly
: LOOP

...

jump LOOP
```

or

```assembly
.data

: VALUE

.word 10

.text

load r1 VALUE
```

Labels improve readability by eliminating hard-coded addresses.

During assembly, every label is replaced with its corresponding address or relative offset.

---

# Subroutine Register File Addressing

The `SSRF` and `RSRF` instructions access the Subroutine Register File (SRF).

Example

```assembly
ssrf r1

rsrf r0
```

Unlike general-purpose registers, the SRF is dedicated to communication between callers and subroutines.

Typical uses include:

- Passing function parameters
- Returning function values

---

# Address Resolution

Assembly source often contains symbolic references.

Example

```assembly
jump LOOP
```

The assembler resolves these references during assembly.

```
Source Label

↓

Label Table

↓

Instruction Address

↓

Machine Code
```

Programs never contain symbolic labels after assembly.

---

# Address Spaces

The processor operates using separate instruction and data address spaces.

## Instruction Memory

Instruction memory stores executable machine code.

Examples:

- ADDI
- LOAD
- BEQ
- JSR

---

## Global Memory

Global memory stores program data.

Examples:

- Variables
- Arrays
- Constants

Memory instructions operate exclusively on global memory.

---

# Addressing Summary

| Mode | Used By |
|------|----------|
| Immediate | Arithmetic Immediate |
| Register | Arithmetic, Copy |
| Direct Memory | LOAD, STORE |
| Relative | Branches, JSR |
| Label | Branches, Memory Access |
| SRF | SSRF, RSRF |

---

# Design Philosophy

The 16-Bit CPU intentionally supports a small number of addressing modes.

This simplifies several aspects of the processor:

- Instruction decoding
- Control logic
- Compiler implementation
- Assembler implementation
- Hardware datapath

Rather than supporting numerous specialized addressing modes, the processor relies on a compact set of fundamental mechanisms that can be combined to implement more complex software behavior.
