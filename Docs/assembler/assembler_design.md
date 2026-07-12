# Assembler Design

This document describes the internal architecture and implementation of the assembler for the 16-Bit CPU.

The assembler translates assembly language source code into machine code and generates memory initialization files for both Logisim and Quartus.

Unlike the compiler, which translates a high-level language into assembly, the assembler operates directly on the processor's native instruction set.

---

# Table of Contents

1. Assembler Architecture
2. Assembly Pipeline
3. Lexical Analysis
4. First Pass
5. Symbol Tables
6. Second Pass
7. Instruction Encoding
8. Directive Processing
9. Output Generation
10. Error Handling
11. Future Improvements

---

# Assembler Architecture

The assembler follows a traditional two-pass architecture.

```
              Assembly Source
                     │
                     ▼
             Lexical Analysis
                     │
                     ▼
                First Pass
      ┌──────────────────────────┐
      │ Label Collection         │
      │ Constant Definitions     │
      │ Address Assignment       │
      └──────────────────────────┘
                     │
                     ▼
               Second Pass
      ┌──────────────────────────┐
      │ Instruction Validation   │
      │ Label Resolution         │
      │ Machine Code Encoding    │
      │ Memory Image Generation  │
      └──────────────────────────┘
                     │
                     ▼
        Logisim & Quartus Outputs
```

Each pass performs a distinct stage of the assembly process.

---

# Assembly Pipeline

The assembler reads the complete source file before generating any output.

```
Assembly Source

      │

      ▼

Lexical Analysis

      │

      ▼

Pass 1

      │

      ▼

Pass 2

      │

      ▼

Machine Code
```

Separating symbol collection from instruction encoding allows forward references to labels without requiring multiple rescans.

---

# Lexical Analysis

Each source line is tokenized independently.

The assembler uses Python's built-in `shlex` module for lexical analysis.

Example

```assembly
addi r1 5
```

becomes

```
["addi", "r1", "5"]
```

Comments beginning with `;` are ignored.

Whitespace outside of string literals is not significant.

---

# First Pass

The first pass scans the entire source file without generating machine code.

Its responsibilities include:

- Collecting labels
- Processing constant definitions
- Assigning instruction addresses
- Assigning data addresses
- Tracking section changes

Labels are stored with both their section and address.

Example

```assembly
: LOOP

addi r1 1
```

becomes

```
LOOP

↓

.text address 0
```

The first pass also determines instruction offsets used by branch and subroutine instructions.

---

# Symbol Tables

Several symbol tables are maintained throughout assembly.

---

## Label Table

Stores the location of every label.

```
labels

{

MAIN :

    (.text, 0)

LOOP :

    (.text, 5)

DATA :

    (.data, 0)

}
```

---

## Constant Table

Constants created using `.define` are stored alongside register aliases.

```
COUNT

↓

10

TEMP

↓

r3
```

These values may be referenced anywhere an immediate operand is expected.

---

# Second Pass

Once every symbol has been collected, the assembler begins machine code generation.

Responsibilities include:

- Instruction validation
- Register validation
- Immediate validation
- Label resolution
- Machine code encoding
- Memory image generation

Each assembly instruction is translated into one 16-bit machine instruction.

---

# Instruction Encoding

Every instruction belongs to one of several instruction families.

Current instruction groups include:

- Subroutine Instructions
- Immediate Arithmetic
- Register Arithmetic
- Input / Output
- Copy Instructions
- Branch Instructions
- Memory Instructions

Each instruction is encoded into a 16-bit machine word containing:

- Opcode family
- Sub-operation
- Register field
- Immediate field

The assembler constructs this encoding automatically during the second pass.

---

# Directives

Assembler directives control program layout rather than generating executable instructions.

Supported directives include:

| Directive | Purpose |
|-----------|----------|
| `.text` | Begin instruction section |
| `.data` | Begin data section |
| `.word` | Store a byte in global memory |
| `.define` | Define a constant |
| `.org` | Advance the current address |
| `.ivt` | Define an interrupt vector |

Directives are processed during assembly and do not produce executable instructions.

---

# Label Resolution

Branch instructions reference labels instead of absolute addresses.

Example

```assembly
jump LOOP
```

During assembly,

```
LOOP

↓

Instruction Address
```

is substituted into the generated machine code.

Relative offsets are automatically calculated where required.

---

# Interrupt Vector Generation

Interrupt vectors are generated using the `.ivt` directive.

Example

```assembly
.ivt INT0 ISR
```

Each interrupt entry is resolved into the address of its associated interrupt service routine.

A complete interrupt vector table is generated as a separate output file.

---

# String Expansion

The `tty` instruction accepts string literals.

Example

```assembly
tty "Hello"
```

Rather than encoding a single instruction, the assembler expands the string into one terminal output instruction per character.

Conceptually,

```
"H"

↓

TTY Instruction

"e"

↓

TTY Instruction

...

"o"

↓

TTY Instruction
```

---

# Output Files

The assembler generates separate outputs for Logisim and Quartus.

## Logisim

```
machineCode2.txt

globalMem.txt

ivt.txt
```

## Quartus

```
instruction_ram.hex

global_memory.hex

ivt.hex
```

This allows the same assembly source to target both simulation and FPGA hardware.

---

# Error Handling

Assembly terminates immediately when an error is encountered.

Detected errors include:

- Invalid instructions
- Invalid registers
- Undefined labels
- Undefined constants
- Immediate overflow
- Invalid directives
- Invalid section usage
- Invalid interrupt vectors
- Address errors
- Missing directive arguments

Whenever possible, the assembler reports the source line responsible for the error.

---

# Design Philosophy

The assembler was designed with several primary goals:

- Deterministic machine code generation
- Readable assembly syntax
- Clear error reporting
- Support for educational exploration of CPU architecture
- Compatibility with both simulation and FPGA implementations

Rather than performing optimization, the assembler focuses on producing an accurate binary representation of the programmer's assembly source.

---

# Current Limitations

Current assembler limitations include:

- Single source file assembly
- No macro processor
- No conditional assembly
- No include directives
- No linker support
- Static interrupt vector table
- Fixed instruction encoding

These limitations keep the assembler lightweight while remaining closely aligned with the architecture of the 16-Bit CPU.

---
