# Instruction Encoding

This document describes how assembly instructions are encoded into the 16-bit machine code executed by the 16-Bit CPU.

Every instruction occupies exactly **one 16-bit word**.

The assembler translates assembly mnemonics into binary by combining four fields:

- Immediate Value
- Sub-operation
- Register
- Opcode Family

---

# Instruction Format

Every instruction follows the same layout.

```
15                             0

+--------------+--------+--------+--------+
|  Immediate   | SubOp  |  Reg   | Opcode |
+--------------+--------+--------+--------+

     8 bits      2 bits   3 bits   3 bits
```

| Field | Width | Description |
|--------|------:|-------------|
| Immediate | 8 bits | Immediate value, address, or branch offset |
| SubOp | 2 bits | Selects the instruction within an opcode family |
| Register | 3 bits | Register operand |
| Opcode | 3 bits | Instruction family |

---

# Opcode Families

The three least-significant bits identify the instruction family.

| Opcode | Family |
|---------|--------|
| `000` | Subroutine |
| `001` | Arithmetic (Immediate) |
| `010` | Arithmetic (Register) |
| `011` | Input / Output |
| `100` | Copy |
| `101` | Branch |
| `110` | Load |
| `111` | Store |

---

# Subroutine Instructions

Opcode Family

```
000
```

| SubOp | Instruction |
|-------:|-------------|
| `00` | JSR |
| `01` | RSR |
| `10` | SSRF |
| `11` | RSRF |

Example

```assembly
jsr PRINT
```

Machine format

```
Immediate = Relative Address

SubOp = 00

Register = 000

Opcode = 000
```

---

# Immediate Arithmetic

Opcode Family

```
001
```

| SubOp | Instruction |
|-------:|-------------|
| `00` | ADDI |
| `01` | SUBI |
| `10` | MULTI |
| `11` | DIVI |

Example

```assembly
addi r1 5
```

Machine format

```
Immediate = 5

SubOp = 00

Register = r1

Opcode = 001
```

---

# Register Arithmetic

Opcode Family

```
010
```

| SubOp | Instruction |
|-------:|-------------|
| `00` | ADD |
| `01` | SUB |
| `10` | MULT |
| `11` | DIV |

Example

```assembly
add r3
```

Machine format

```
Immediate = 0

SubOp = 00

Register = r3

Opcode = 010
```

---

# Input / Output

Opcode Family

```
011
```

| SubOp | Instruction |
|-------:|-------------|
| `00` | TTY |
| `01` | TTYA |
| `10` | HALT |

Example

```assembly
tty "Hello"
```

The assembler expands the string into one encoded instruction per character.

---

# Copy Instructions

Opcode Family

```
100
```

| SubOp | Instruction |
|-------:|-------------|
| `00` | COPY |
| `01` | RINT |

Example

```assembly
copy r1
```

---

# Branch Instructions

Opcode Family

```
101
```

| SubOp | Instruction |
|-------:|-------------|
| `00` | BEQ |
| `01` | BNE |
| `10` | BLT |
| `11` | JUMP |

Example

```assembly
jump LOOP
```

For branch instructions, the immediate field contains a relative instruction offset calculated by the assembler.

---

# Memory Instructions

## Load

Opcode Family

```
110
```

| SubOp | Instruction |
|-------:|-------------|
| `00` | LOAD |

Example

```assembly
load r2 VALUE
```

---

## Store

Opcode Family

```
111
```

| SubOp | Instruction |
|-------:|-------------|
| `00` | STORE |

Example

```assembly
store r2 VALUE
```

---

# Register Encoding

Registers are encoded using the three-bit register field.

| Register | Binary |
|----------|--------|
| r0 | 000 |
| r1 | 001 |
| r2 | 010 |
| r3 | 011 |
| r4 | 100 |
| r5 | 101 |
| r6 | 110 |
| r7 | 111 |

---

# Immediate Field

The upper eight bits contain an immediate value.

The immediate field is used for

- Integer constants
- Memory addresses
- Branch offsets
- Jump offsets
- Label addresses

The assembler automatically determines the correct value based on the instruction being assembled.

---

# Label Resolution

Labels are resolved during the assembler's second pass.

Example

```assembly
jump LOOP

...

: LOOP
```

The assembler replaces `LOOP` with the appropriate relative instruction offset before encoding the machine instruction.

---

# Example Encoding

Assembly

```assembly
addi r1 5
```

Instruction fields

| Field | Value |
|--------|-------|
| Immediate | `00000101` |
| SubOp | `00` |
| Register | `001` |
| Opcode | `001` |

Final instruction

```
00000101 00 001 001
```

Hexadecimal

```
0x0509
```

---

# Encoding Process

Every instruction follows the same encoding pipeline.

```
Assembly Instruction

        │

        ▼

Parse Operands

        │

        ▼

Resolve Labels

        │

        ▼

Encode Fields

        │

        ▼

Combine Immediate

SubOp

Register

Opcode

        │

        ▼

16-Bit Machine Code
```

---

# Summary

The fixed-width instruction format simplifies instruction decoding within the CPU while allowing every instruction family to share a common encoding structure.

By separating instructions into opcode families and sub-operations, the assembler can efficiently translate assembly source into compact 16-bit machine code while maintaining a consistent instruction layout across the entire instruction set.
