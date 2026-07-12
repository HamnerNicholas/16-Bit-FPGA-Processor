# Compiler Design

This document describes the internal architecture and implementation of the Hamner CPU Compiler.

Unlike traditional compilers targeting commercial architectures, the Hamner compiler was developed alongside a custom Instruction Set Architecture (ISA), assembler, and processor implementation. As a result, every stage of compilation is designed specifically around the capabilities and conventions of the Hamner 16-bit CPU.

---

# Table of Contents

1. Compiler Architecture
2. Compilation Pipeline
3. Lexical Analysis
4. First Pass
5. Symbol Tables
6. Second Pass
7. Expression Parsing
8. Register Allocation
9. Code Generation
10. Runtime Generation
11. Error Handling

---

# Compiler Architecture

The compiler follows a traditional two-pass architecture.

```
                 Source File
                      │
                      ▼
              Lexical Analysis
                      │
                      ▼
                 First Pass
      ┌────────────────────────────┐
      │ Variable Allocation        │
      │ Array Allocation           │
      │ Memory Address Assignment  │
      │ .data Generation           │
      └────────────────────────────┘
                      │
                      ▼
                Second Pass
      ┌────────────────────────────┐
      │ Statement Parsing          │
      │ Expression Parsing         │
      │ Function Parsing           │
      │ Control Flow Generation    │
      │ Assembly Emission          │
      └────────────────────────────┘
                      │
                      ▼
          assembly.txt + ivt.txt
```

Each stage performs a single well-defined task before passing information to the next stage.

---

# Compilation Pipeline

Compilation begins by reading the entire source file into memory.

```
Source Code
      │
      ▼
Tokenization
      │
      ▼
Pass 1
      │
      ▼
Pass 2
      │
      ▼
Assembly Output
```

The compiler intentionally separates memory allocation from instruction generation.

This allows variables to be referenced before code generation begins while ensuring every object has a fixed memory location.

---

# Lexical Analysis

Each source line is tokenized independently.

The compiler uses Python's built-in `shlex` module to perform lexical analysis.

Example

```c
let x = a + b
```

becomes

```
["let", "x", "=", "a", "+", "b"]
```

Comments beginning with `;` are ignored during tokenization.

Whitespace is not significant outside of string literals.

---

# First Pass

The first pass scans the entire program before any instructions are generated.

Its responsibilities are

- Variable allocation
- Array allocation
- Memory address assignment
- Data section generation

Example

```c
let x = 5
let y = 10
let nums[] = 1,2,3
```

produces

```
.data

.word 5
.word 10
.word 1
.word 2
.word 3
```

During this stage every variable receives a permanent memory address.

```
x → address 0

y → address 1

nums → address 2
```

No executable instructions are generated during the first pass.

---

# Symbol Tables

The compiler maintains several symbol tables during compilation.

## Variable Table

Stores scalar variables and their memory addresses.

```
variables

{
    "x":0,
    "y":1
}
```

---

## Array Table

Stores

- starting address
- length

```
arrays

{
    "numbers":
    {
        addr : 8,
        length : 5
    }
}
```

---

## Function Table

Maps source-level function names to assembly labels.

```
function_names

{
    add : FUNCadd
}
```

---

## Parameter Table

Stores parameter locations for each function.

```
function_params

{
    add :

    a → SRF1

    b → SRF2
}
```

---

# Second Pass

Once memory allocation is complete, the compiler begins instruction generation.

Each source statement is examined individually.

Examples include

- assignments
- loops
- function definitions
- function calls
- inline assembly
- returns
- printing

Each statement emits one or more assembly instructions.

---

# Expression Parsing

Expressions are parsed using the **Shunting Yard Algorithm**.

The compiler first converts infix notation into postfix notation before generating assembly.

Example

```
a = (b + c) * d
```

becomes

```
b c + d *
```

This greatly simplifies code generation since operator precedence has already been resolved.

Supported operators

```
+

-

*

/
```

Parentheses are fully supported.

---

# Register Allocation

Expression evaluation uses temporary CPU registers.

Registers are allocated sequentially.

```
r1

↓

r2

↓

r3
```

Each operand occupies a temporary register until the expression has been evaluated.

Current implementation

```
Expression

↓

Temporary Registers

↓

Assembly
```

The compiler currently performs no register spilling.

Expressions requiring more than seven temporary registers produce a compilation error.

---

# Code Generation

Each high-level language construct has a dedicated code generation routine.

---

## Assignment

```
x = a + b
```

↓

```
load

add

store
```

---

## If Statements

The compiler automatically generates labels.

```
IFTRUE1

IFEND1
```

Assembly resembles

```
comparison

branch

jump

true block

end label
```

---

## While Loops

Generated labels

```
WHILESTART1

WHILEBODY1

WHILEEND1
```

---

## For Loops

Generated labels

```
FORSTART1

FORBODY1

FOREND1
```

Initialization, comparison, update, and loop body are emitted separately.

---

## Functions

Function definitions generate assembly labels.

```
func add a b
```

↓

```
FUNCadd
```

Parameters are passed through Saved Register File (SRF) registers.

```
SRF1

SRF2

SRF3
```

The return value is stored in

```
SRF0
```

Function calls use

```
JSR
```

while returns use

```
RSR
```

---

# Runtime Generation

The compiler automatically emits helper routines only when required.

Currently implemented

```
printNum
```

This routine converts integer values into ASCII characters before printing through the CPU's terminal peripheral.

Unused runtime routines are omitted from the generated assembly.

---

# Error Handling

Compilation stops immediately after the first error.

Detected errors include

- Duplicate variables
- Undeclared variables
- Invalid expressions
- Register overflow
- Invalid function calls
- Invalid arguments
- Missing endif
- Missing ewhile
- Missing efor
- Array bounds violations
- Invalid syntax

Each error reports the offending source line whenever possible.

---

# Design Philosophy

The compiler emphasizes

- readability
- deterministic code generation
- simplicity
- educational value
- close correspondence between source language and generated assembly

Rather than implementing complex optimization passes, the compiler prioritizes transparent output that closely mirrors the original source program.

---

# Current Limitations

Current compiler limitations include

- Maximum of three function parameters
- Seven temporary registers
- No register spilling
- Static arrays only
- No recursion
- No optimization passes
- Integer-only arithmetic

These limitations were intentionally chosen to keep the compiler tightly coupled to the current processor architecture.

---

s
