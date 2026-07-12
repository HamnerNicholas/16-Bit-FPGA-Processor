# Calling Convention

This document describes the calling convention implemented by the compiler for the 16-Bit CPU.

Unlike most modern processors, which rely on a software-managed stack to transfer function parameters and return values, the 16-Bit CPU provides dedicated hardware support for subroutine calls through the **Subroutine Register File (SRF)**.

The compiler automatically generates all instructions required to move data between the CPU registers, memory, and the SRF, allowing functions to be written without requiring the programmer to manage parameter passing manually.

---

# Overview

A function call follows the sequence below.

```
Caller

    │

    ▼

Evaluate Arguments

    │

    ▼

Store Arguments in SRF

    │

    ▼

JSR

    │

    ▼

Subroutine Executes

    │

    ▼

Store Return Value in SRF0

    │

    ▼

RSR

    │

    ▼

Caller Reads RETVAL
```

The compiler handles every stage of this process automatically.

---

# Subroutine Register File (SRF)

The processor contains a dedicated **Subroutine Register File (SRF)** used exclusively for communication between callers and subroutines.

The SRF eliminates the need for a software stack when passing function parameters.

| Register | Purpose |
|----------|----------|
| SRF0 | Return Value |
| SRF1 | Parameter 1 |
| SRF2 | Parameter 2 |
| SRF3 | Parameter 3 |

The compiler reserves these registers exclusively for function calls.

Programs should never attempt to access them directly.

---

# Function Parameters

Functions currently support a maximum of **three parameters**.

Example

```c
func add a b = {

    return a + b

}
```

During compilation, each parameter is mapped to a fixed SRF register.

| Parameter | Register |
|-----------|----------|
| a | SRF1 |
| b | SRF2 |

Whenever the function references a parameter, the compiler automatically generates the instructions required to read the appropriate SRF register.

Conceptually,

```assembly
rsrf r1
copy r1
```

loads the first parameter into a working register.

---

# Calling a Function

Arguments are evaluated before the function is entered.

Example

```c
call add(x, 5)
```

Compilation proceeds as follows.

1. Evaluate each argument.
2. Copy each argument into its assigned SRF register.
3. Execute the `JSR` instruction.
4. Begin execution at the subroutine label.

Conceptual assembly

```assembly
load r1 x
copy r1
ssrf r1

addi r0 5
copy r1
ssrf r2

jsr FUNCadd
```

After the jump, the subroutine immediately has access to both parameters.

---

# Returning a Value

Functions return a value through **SRF0**.

Example

```c
func square x = {

    return x * x

}
```

Before returning, the compiler generates

```assembly
ssrf r0
rsr
```

The value written to **SRF0** becomes available to the caller after the `RSR` instruction completes.

---

# RETVAL

The language exposes the most recent function return value through the reserved keyword

```text
RETVAL
```

Example

```c
call square(12)

print RETVAL
```

Whenever `RETVAL` is referenced, the compiler generates an instruction to read **SRF0**.

Conceptually,

```assembly
rsrf r0
```

retrieves the most recently returned value.

---

# Function Entry

Every function is translated into a unique assembly label.

Example

```c
func multiply a b = {

    return a * b

}
```

becomes

```assembly
: FUNCmultiply
```

If functions are declared before the main program, the compiler automatically inserts an initial jump instruction so execution begins at the application's entry point rather than inside a function.

Conceptually,

```assembly
jump MAINSTART

: FUNCmultiply

...

: MAINSTART
```

---

# Function Exit

Functions terminate using the processor's **Return from Subroutine** instruction.

```assembly
rsr
```

If a function reaches its closing brace without executing a `return` statement, the compiler automatically inserts an `RSR` instruction so control returns correctly to the caller.

---

# Calling Sequence

The complete sequence for a function call is shown below.

```
Caller

↓

Evaluate Arguments

↓

Copy Arguments into SRF

↓

JSR

↓

Execute Function

↓

Store Result in SRF0

↓

RSR

↓

Caller Reads RETVAL
```

This sequence is generated automatically by the compiler.

---

# Register Usage

The compiler distinguishes between temporary CPU registers and the Subroutine Register File.

| Resource | Purpose |
|----------|----------|
| General Purpose Registers | Temporary expression evaluation |
| SRF Registers | Function parameters and return values |

General-purpose registers are temporary and may be reused throughout an expression.

SRF registers remain dedicated to communication between the caller and subroutine.

---

# Nested Function Calls

Since return values are stored in **SRF0**, each function call overwrites the previous return value.

For this reason, the compiler expects return values to be consumed or stored before another function call is made.

Example

```c
call multiply(3,4)

let result = RETVAL

call add(result,2)

print RETVAL
```

This guarantees that the first function's result is preserved before the second function updates **SRF0**.

---

# Current Limitations

The current calling convention intentionally remains simple.

Current limitations include:

- Maximum of three function parameters
- Single return value
- No recursive functions
- No stack frames
- No local stack allocation
- No variable-length parameter lists

These limitations closely match the capabilities of the current processor architecture.

---

# Design Philosophy

The Subroutine Register File was introduced to provide dedicated hardware support for function calls.

Rather than relying on a software-managed stack, parameters and return values are exchanged through dedicated hardware registers. This significantly simplifies both the processor implementation and the compiler backend while producing deterministic function call behavior.

The design offers several advantages:

- Eliminates stack accesses for parameter passing
- Reduces memory traffic during subroutine calls
- Simplifies compiler code generation
- Produces predictable execution behavior
- Closely couples the language with the processor architecture

Although this approach is less flexible than conventional stack-based calling conventions, it provides an efficient and easy-to-understand mechanism for function calls that is well suited to the architecture of the 16-Bit CPU.
