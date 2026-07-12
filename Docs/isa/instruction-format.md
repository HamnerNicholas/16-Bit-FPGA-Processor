# Instruction Format

This document describes the 16-bit instruction format implemented by the 16-Bit CPU.

Every instruction occupies a single 16-bit instruction word and follows a fixed encoding format. This allows every instruction to be decoded using the same hardware regardless of its operation.

---

# Instruction Layout

Each instruction is divided into four fields.

```text
15                              0

+--------------+--------+--------+--------+
| Immediate    | SubOp  | Reg    | Opcode |
+--------------+--------+--------+--------+

     8 bits      2 bits   3 bits   3 bits
```

| Bits | Field | Description |
|------|--------|-------------|
| 15–8 | Immediate | Constant value, memory address, or branch offset |
| 7–6 | SubOp | Selects an instruction within an opcode family |
| 5–3 | Register | Register operand |
| 2–0 | Opcode | Instruction family |

---

# Instruction Fetch

During the fetch stage, the processor loads a 16-bit instruction from instruction memory.

```text
Instruction Memory

        │

        ▼

Instruction Register (IR)
```

The contents of the Instruction Register are then decoded by the control unit.

---

# Opcode Field

The three least-significant bits determine the instruction family.

| Opcode | Instruction Family |
|:------:|--------------------|
| `000` | Subroutine |
| `001` | Immediate Arithmetic |
| `010` | Register Arithmetic |
| `011` | Input / Output |
| `100` | Copy & Interrupt Control |
| `101` | Branch |
| `110` | Load |
| `111` | Store |

The opcode is decoded first to determine which functional unit will execute the instruction.

---

# Sub-Operation Field

The two-bit SubOp field selects the specific instruction within an opcode family.

For example, the Immediate Arithmetic family contains four instructions.

| SubOp | Instruction |
|:-----:|-------------|
| `00` | ADDI |
| `01` | SUBI |
| `10` | MULTI |
| `11` | DIVI |

The same SubOp values are reused across different opcode families.

---

# Register Field

The register field selects one of the eight general-purpose registers.

| Binary | Register |
|:------:|----------|
| `000` | r0 |
| `001` | r1 |
| `010` | r2 |
| `011` | r3 |
| `100` | r4 |
| `101` | r5 |
| `110` | r6 |
| `111` | r7 |

The interpretation of this field depends on the instruction being executed.

Examples include:

- Destination register
- Source register
- Comparison register
- SRF register index

---

# Immediate Field

The upper eight bits contain an immediate value.

Depending on the instruction, this field may represent:

- Integer constants
- Memory addresses
- Branch offsets
- Jump offsets
- Label addresses
- ASCII character values

The interpretation is determined by the instruction family.

---

# Instruction Decode

After the instruction has been fetched, the control unit separates the instruction into its four fields.

```text
Instruction Register

        │

        ▼

+------------------------------+
| Opcode Decoder               |
+------------------------------+

        │

        ▼

Instruction Family

        │

        ▼

SubOp Decoder

        │

        ▼

Control Signals
```

The control signals generated during this stage configure the processor datapath for the current instruction.

---

# Example

Consider the instruction

```assembly
addi r1 5
```

The instruction fields become

| Field | Value |
|--------|-------|
| Immediate | `00000101` |
| SubOp | `00` |
| Register | `001` |
| Opcode | `001` |

Resulting machine word

```text
00000101 00 001 001
```

Hexadecimal representation

```text
0x0509
```

---

# Fixed-Length Encoding

Every instruction occupies exactly one 16-bit word.

This provides several advantages:

- Constant instruction size
- Simple instruction fetch logic
- Straightforward instruction decoding
- Predictable program layout
- Efficient hardware implementation

Unlike variable-length instruction sets, the Program Counter always advances by one instruction during sequential execution.

---

# Design Philosophy

The instruction format was designed around a small number of fixed instruction families.

By separating instructions into an opcode and sub-operation field, the processor supports multiple related instructions while maintaining a compact and consistent encoding.

This organization simplifies both the processor hardware and the assembler while providing a flexible foundation for future instruction set expansion.
