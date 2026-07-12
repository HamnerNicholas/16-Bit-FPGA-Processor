# Instruction Set

This document describes every instruction supported by the 16-Bit CPU.

Instructions are organized by opcode family. Every instruction occupies a single 16-bit instruction word and executes according to the processor's fixed instruction format.

---

# Instruction Families

The instruction set is divided into the following families.

| Opcode | Family |
|:------:|---------------------------|
| `000` | Subroutine Instructions |
| `001` | Immediate Arithmetic |
| `010` | Register Arithmetic |
| `011` | Input / Output |
| `100` | Copy & Interrupt Control |
| `101` | Branch Instructions |
| `110` | Memory Load |
| `111` | Memory Store |

---

# Subroutine Instructions

These instructions provide hardware support for function calls using the Subroutine Register File (SRF).

---

## JSR — Jump to Subroutine

Transfers control to a subroutine.

**Syntax**

```assembly
jsr LABEL
```

**Operation**

```
PC ← LABEL
```

The current program counter is automatically saved so execution may later resume using `RSR`.

---

## RSR — Return from Subroutine

Returns execution to the instruction following the corresponding `JSR`.

**Syntax**

```assembly
rsr
```

**Operation**

```
PC ← Saved Return Address
```

---

## SSRF — Store to Subroutine Register File

Stores the accumulator into an SRF register.

**Syntax**

```assembly
ssrf rN
```

**Operation**

```
SRF[rN] ← ACC
```

Used by the compiler to pass function parameters and return values.

---

## RSRF — Read from Subroutine Register File

Loads an SRF register into the accumulator.

**Syntax**

```assembly
rsrf rN
```

**Operation**

```
ACC ← SRF[rN]
```

---

# Immediate Arithmetic

Immediate arithmetic instructions operate using an 8-bit immediate value.

---

## ADDI — Add Immediate

Adds an immediate value to the accumulator.

```assembly
addi r1 5
```

```
r1 ← ACC + Immediate
```

---

## SUBI — Subtract Immediate

Subtracts an immediate value from the accumulator.

```assembly
subi r1 1
```

```
r1 ← ACC − Immediate
```

---

## MULTI — Multiply Immediate

Multiplies the accumulator by an immediate value.

```assembly
multi r2 4
```

```
r2 ← ACC × Immediate
```

---

## DIVI — Divide Immediate

Divides the accumulator by an immediate value.

```assembly
divi r2 2
```

```
r2 ← ACC ÷ Immediate
```

---

# Register Arithmetic

Register arithmetic instructions operate using a register operand.

---

## ADD

```assembly
add r1
```

```
ACC ← ACC + r1
```

---

## SUB

```assembly
sub r2
```

```
ACC ← ACC − r2
```

---

## MULT

```assembly
mult r3
```

```
ACC ← ACC × r3
```

---

## DIV

```assembly
div r4
```

```
ACC ← ACC ÷ r4
```

---

# Input / Output

---

## TTY

Outputs a string literal to the terminal.

```assembly
tty "Hello"
```

The assembler expands the string into individual output instructions.

---

## TTYA

Outputs the ASCII character currently stored in the accumulator.

```assembly
ttya
```

---

## HALT

Stops processor execution.

```assembly
halt
```

Execution remains halted until the processor is reset.

---

# Copy & Interrupt Control

---

## COPY

Copies the accumulator into a general-purpose register.

```assembly
copy r3
```

```
r3 ← ACC
```

---

## RINT

Returns from an interrupt service routine.

```assembly
rint
```

Restores execution using the address stored in the Interrupt Return Register (IRR).

---

# Branch Instructions

Branch instructions compare the accumulator against a register operand.

---

## BEQ — Branch if Equal

```assembly
beq r1 LABEL
```

Branches if

```
ACC == r1
```

---

## BNE — Branch if Not Equal

```assembly
bne r2 LABEL
```

Branches if

```
ACC != r2
```

---

## BLT — Branch if Less Than

```assembly
blt r3 LABEL
```

Branches if

```
ACC < r3
```

---

## JUMP

Performs an unconditional branch.

```assembly
jump LOOP
```

```
PC ← LABEL
```

---

# Memory Instructions

---

## LOAD

Loads a value from global memory into the accumulator.

```assembly
load r1 ADDRESS
```

```
ACC ← Memory[ADDRESS]

r1 ← ACC
```

The loaded value is also written to the destination register.

---

## STORE

Stores a register value into global memory.

```assembly
store r2 ADDRESS
```

```
Memory[ADDRESS] ← r2
```

---

# Instruction Summary

| Instruction | Description |
|--------------|-------------------------------|
| JSR | Jump to subroutine |
| RSR | Return from subroutine |
| SSRF | Store to SRF |
| RSRF | Read from SRF |
| ADDI | Add immediate |
| SUBI | Subtract immediate |
| MULTI | Multiply immediate |
| DIVI | Divide immediate |
| ADD | Add register |
| SUB | Subtract register |
| MULT | Multiply register |
| DIV | Divide register |
| TTY | Print string literal |
| TTYA | Print accumulator register |
| HALT | Halt execution |
| COPY | Copy accumulator to register |
| RINT | Return from interrupt |
| BEQ | Branch if equal |
| BNE | Branch if not equal |
| BLT | Branch if less than |
| JUMP | Unconditional jump |
| LOAD | Load from memory |
| STORE | Store to memory |

---

# Design Philosophy

The instruction set was designed around several principles.

- Fixed-width 16-bit instructions
- Simple instruction decoding
- Small number of orthogonal instruction families
- Dedicated hardware support for subroutines
- Minimal hardware complexity
- Close integration with the compiler and assembler

Rather than providing a large number of specialized instructions, the ISA focuses on a compact collection of primitives that can be combined to implement higher-level language features.
