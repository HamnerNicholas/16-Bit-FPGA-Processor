# 16-Bit FPGA Processor Compiler

The compiler translates programs written in the project's custom C-like language into assembly code for the **16-Bit FPGA Processor**. The generated assembly can then be assembled into machine code using the accompanying assembler.

The compiler currently supports variables, arrays, arithmetic expressions, functions, control flow, inline assembly, and basic runtime support for printing decimal numbers.

---

## Usage

```bash
python compiler.py <source_file.c>
```

Example:

```bash
python compiler.py examples/program.c
```

---

## Output

The compiler generates a single assembly file:

```
assembly.txt
```

This file is intended to be passed directly to the assembler, which produces executable machine code for both the Logisim CPU model and the FPGA implementation.

---

## Supported Language Features

The compiler currently supports:

- Global variable declarations
- Arrays
- Integer arithmetic
  - Addition
  - Subtraction
  - Multiplication
  - Division
- Variable assignment
- Array indexing
- Functions
- Function parameters
- Return values
- Function calls
- `if` statements
- `while` loops
- `for` loops
- Inline assembly blocks
- Decimal number printing
- Program termination

---

## Runtime

The compiler automatically generates calls to the built-in runtime routines when required.

Currently included:

- Decimal integer printing
- ASCII character output
- Function call support
- Return value handling

The runtime assembly is appended automatically during compilation when required by the program.

---
---

## Project Status

The compiler currently targets the complete instruction set implemented by the processor and has been successfully used to execute programs on both the Logisim CPU model and the FPGA implementation.

Current functionality includes:

- Arithmetic expressions
- Arrays
- Function calls and returns
- Nested control flow
- Runtime decimal printing
- Inline assembly support

Additional language features and runtime improvements will continue to be added as the processor architecture evolves.
