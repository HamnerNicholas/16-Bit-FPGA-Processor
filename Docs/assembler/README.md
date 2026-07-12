# Assembler Documentation

This section contains the documentation for the assembler used by the 16-Bit CPU.

The assembler translates assembly language source code into 16-bit machine code and generates memory initialization files compatible with both Logisim and Quartus.

The assembler implements a traditional two-pass design, allowing forward label references, symbolic constants, interrupt vector generation, and automatic machine code encoding.

---

## Documents

| Document | Description |
|----------|-------------|
| [Assembler Reference](assembler-reference.md) | Syntax, directives, and usage of the assembler. |
| [Assembler Design](assembler-design.md) | Internal architecture and implementation of the assembler. |
| [Instruction Encoding](instruction-encoding.md) | Machine code format and instruction encoding. |

---

## Features

The assembler currently supports:

- Two-pass assembly
- Labels and symbolic references
- Forward label resolution
- Constants with `.define`
- Global data sections
- Executable code sections
- Interrupt Vector Table generation
- Automatic instruction encoding
- Logisim memory image generation
- Quartus HEX file generation
- Assembly validation and error reporting

---

## Assembly Process

```
Assembly Source
        │
        ▼
     Assembler
        │
        ▼
 Machine Code
        │
        ├── instruction_ram.hex
        ├── global_memory.hex
        ├── ivt.hex
        │
        ├── machineCode2.txt
        ├── globalMem.txt
        └── ivt.txt
```

---

## Related Documentation

The assembler is one component of the complete software toolchain for the 16-Bit CPU.

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

For information on writing assembly programs, see the **Assembly Language Reference**.

For details on the assembler implementation, see **Assembler Design**.

For a description of the machine code format, see **Instruction Encoding**.
