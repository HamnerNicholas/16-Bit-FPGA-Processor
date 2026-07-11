# 16-Bit FPGA Processor Assembler

The assembler translates programs written in the custom assembly language into machine code for the **16-Bit FPGA Processor**. It performs label resolution, instruction encoding, directive processing, and memory layout generation, producing output files that can be executed in both the **Logisim CPU model** and the **Verilog FPGA implementation**.

The assembler uses a two-pass design to resolve labels and symbolic references before generating the final machine code. This allows forward references, branches, function calls, and interrupt vectors to be assembled correctly.

---

## Features

- Two-pass assembler with label resolution
- Custom 16-bit instruction encoding
- Separate `.text`, `.data`, and `.ivt` memory sections
- Automatic branch offset calculation
- Symbolic labels and constants
- Automatic interrupt vector table generation
- Generates memory images for both Logisim and Quartus FPGA builds
- Compatible with the project's custom C-like compiler

---

## Usage

```bash
python assembler.py <source_file.asm>
```

Example:

```bash
python assembler.py examples/program.asm
```

---

## Assembler Directives

| Directive | Description |
|-----------|-------------|
| `.text` | Beginning of program code section |
| `.data` | Beginning of global data section |
| `.word` | Defines a byte/word of initialized data |
| `.org` | Sets the current assembly address |
| `.define` | Creates symbolic constants |
| `.ivt` | Defines interrupt vector table entries |

---

## Output Files

The assembler generates two complete sets of output files.

### Logisim Output

These files are formatted for Logisim Evolution and include the required `v2.0 raw` header.

```
machineCode2.txt
globalMem.txt
ivt.txt
```

---

### Quartus / FPGA Output

These files are formatted for the Verilog implementation and are loaded using Verilog's `$readmemh()` system task.

```
instruction_ram.hex
global_memory.hex
ivt.hex
```

Unlike the Logisim output, the Quartus memory files:

- do **not** contain the `v2.0 raw` header
- contain **one hexadecimal value per line**
- can be loaded directly into the FPGA instruction, data, and interrupt memories

---

## Assembly Flow

```
Assembly Source (.asm)
          │
          ▼
      Two-Pass Assembler
          │
          ├──────────────┐
          ▼              ▼
 Logisim Memory      Quartus Memory
    Images              Images
          │              │
          ▼              ▼
     Logisim CPU     FPGA CPU
```

---

## Integration

The assembler is part of the complete software toolchain for the processor.

```
C-like Source Code
        │
        ▼
Compiler
        │
        ▼
Assembly (.asm)
        │
        ▼
Assembler
        │
        ├─────────────┐
        ▼             ▼
 Logisim Files    FPGA Memory Images
                        │
                        ▼
                 16-Bit FPGA Processor
```

The same assembly program can be assembled for both the Logisim reference implementation and the FPGA implementation without modification.

---

## Project Status

The assembler currently supports the complete instruction set implemented by the processor, including:

- Arithmetic instructions
- Register operations
- Memory load/store
- Branch instructions
- Function calls and returns
- Interrupt vector generation
- Text and data sections

It is used as the backend for the project's custom C-like compiler and generates executable programs that run on both the Logisim CPU model and the FPGA implementation.
