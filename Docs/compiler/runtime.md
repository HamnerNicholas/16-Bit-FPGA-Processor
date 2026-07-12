# Runtime Library

The compiler automatically generates runtime routines when required by a program.

Runtime routines provide functionality that cannot be represented by a single machine instruction. Rather than emitting duplicate code throughout the generated assembly, the compiler emits reusable subroutines that may be called from multiple locations.

Only the runtime routines required by the current program are included in the generated assembly.

---

# Overview

The runtime library is generated as part of compilation and appended to the end of the generated assembly program.

Current runtime routines include:

| Routine | Purpose |
|----------|----------|
| `printNum` | Converts an unsigned integer into ASCII characters and prints it to the terminal |

Additional runtime routines may be added in future compiler releases.

---

# Runtime Generation

The compiler tracks whether a runtime routine is required during code generation.

For example, whenever a numeric value is printed,

```c
print x

print 42

print RETVAL
```

the compiler records that the number-printing routine is needed.

After all source code has been processed, the runtime routine is emitted exactly once.

This approach prevents duplicate copies of the same subroutine from appearing in the generated assembly.

---

# printNum

The `printNum` routine converts an unsigned integer into its decimal ASCII representation before transmitting the characters to the terminal.

Since the processor prints ASCII characters rather than integers directly, numeric values must first be converted into individual decimal digits.

---

# Algorithm

The current implementation uses repeated subtraction.

The number is decomposed into

- Hundreds
- Tens
- Ones

Each digit is then converted into its ASCII equivalent before being transmitted.

The process is illustrated below.

```
Input Number

      │

      ▼

Subtract 100

      │

      ▼

Count Hundreds

      │

      ▼

Subtract 10

      │

      ▼

Count Tens

      │

      ▼

Remaining Value

      │

      ▼

Ones Digit

      │

      ▼

Convert to ASCII

      │

      ▼

Terminal Output
```

---

# Example

Given

```text
137
```

the routine computes

```
Hundreds = 1

Tens = 3

Ones = 7
```

Each digit is converted into its ASCII representation by adding the ASCII value for `'0'`.

```
1 → '1'

3 → '3'

7 → '7'
```

The resulting character sequence is transmitted through the terminal interface.

---

# Output Format

The current implementation appends a space after every printed number.

Example

```
1 25 137 255
```

This simplifies printing multiple values consecutively without requiring the programmer to manually insert separators.

---

# Register Usage

`printNum` temporarily uses several general-purpose registers during execution.

| Register | Purpose |
|----------|----------|
| r0 | Current value being converted |
| r1 | Hundreds counter |
| r2 | Tens counter |
| r3 | Zero constant |
| r6 | Ones digit |
| r7 | Temporary constant register |

The routine preserves the Subroutine Register File and returns control using the standard subroutine return instruction.

---

# Compiler Integration

The runtime routine is never called directly by the programmer.

Instead,

```c
print x
```

is translated into

```assembly
load r1 address
copy r1
ssrf r0
jsr printNum
```

Likewise,

```c
print RETVAL
```

becomes

```assembly
rsrf r0
copy r1
ssrf r0
jsr printNum
```

The compiler automatically inserts the appropriate call whenever a numeric value is printed.

---

# Runtime Philosophy

The runtime library is intentionally minimal.

Rather than implementing a large standard library, the compiler generates only the functionality required by the source program.

This design offers several advantages:

- Smaller generated programs
- No unused runtime code
- Simpler compiler implementation
- Easy expansion as new language features are added

As additional language features are introduced, new runtime routines will be emitted using the same demand-driven approach.

---

# Future Runtime Routines

The runtime library is expected to grow alongside the compiler and processor.

Potential additions include:

- String output
- String input
- Keyboard buffer handling
- Memory copy
- Memory fill
- Integer parsing
- Hexadecimal printing
- Character classification
- Software multiplication and division
- Dynamic memory allocation

Each routine will be generated only when required by the compiled program.

---

# Summary

The runtime library provides reusable functionality that extends the capabilities of the instruction set without increasing hardware complexity.

By generating runtime routines only when necessary, the compiler minimizes program size while providing a simple interface for higher-level language features.
