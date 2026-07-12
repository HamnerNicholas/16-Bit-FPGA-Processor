# Compiler

A custom compiler for the **16-bit CPU** that translates a lightweight C-inspired language into the custom assembly language executed by the processor.

The compiler is part of a complete hardware/software ecosystem consisting of:

* Custom 16-bit Instruction Set Architecture (ISA)
* Two-pass assembler
* Custom high-level programming language
* Compiler
* Interrupt support
* FPGA implementation in Verilog
* VGA peripheral

---

## Features

* Two-pass compilation
* Variable and array support
* Arithmetic expression parsing
* Function definitions and calls
* Return values
* Inline assembly
* Conditional statements
* While loops
* For loops
* Automatic memory allocation
* Automatic expression parsing using postfix conversion
* Compiler error checking
* Automatic generation of assembly source
* Interrupt Vector Table (IVT) generation
* Optional runtime library generation (number printing)

---

---

## Compiler Overview

The compiler converts a custom C-like language into the custom assembly language.

Compilation occurs in two major stages:

```
Source Program
      │
      ▼
Lexical Analysis
      │
      ▼
First Pass
• Variable allocation
• Array allocation
• Data section generation
      │
      ▼
Second Pass
• Statement parsing
• Expression parsing
• Function generation
• Control-flow generation
• Assembly generation
      │
      ▼
assembly.txt
```

---

## Supported Language Features

### Variables

```c
let x = 5
let y = 10
```

---

### Arrays

```c
let numbers[] = 1, 2, 3, 4, 5

print numbers[2]
```

---

### Arithmetic

```c
x = a + b
x = a - b
x = a * b
x = a / b

x = (a + b) * c
```

---

### If Statements

```c
if x == y

    print Equal

endif
```

Supported comparison operators:

* `==`
* `!=`
* `<`

---

### While Loops

```c
while counter < 10

    print counter

    counter = counter + 1

ewhile
```

---

### For Loops

```c
for i = 0, i < 10, i++

    print i

efor
```

---

### Functions

```c
func add a b = {

    return a + b

}

call add(5,7)

print RETVAL
```

Functions currently support up to **three parameters**.

---

### Inline Assembly

Assembly instructions can be embedded directly into a program.

```c
asm = {

tty "Hello"

halt

}
```

This allows direct access to the processor instruction set whenever low-level control is required.

---

## Example Program

```c
let total = 0
let i = 0

for i = 0, i < 10, i++

    total = total + i

efor

print total

halt
```

---

## Building

The compiler is written entirely in Python.

Compile a source program using:

```bash
python compiler.py program.cpu
```

The compiler generates:

```
assembly.txt
```

These files can then be assembled into the memory image executed by the CPU.

---


