# High-Level Language Reference

This document describes the syntax and features of the high-level language supported by the compiler.

The language is designed specifically for the 16-Bit CPU and provides a lightweight C-inspired syntax while remaining closely aligned with the underlying hardware architecture.

---

# Comments

Comments begin with a semicolon (`;`).

```c
; This is a comment

let x = 5
```

---

# Variables

Variables are declared using the `let` keyword.

```c
let x = 5
let y = 10
```

Variables are automatically allocated in memory by the compiler.

---

# Arrays

Arrays are declared by appending `[]` to the variable name.

```c
let numbers[] = 1, 2, 3, 4, 5
```

Array elements are accessed using bracket notation.

```c
print numbers[2]

numbers[1] = 42
```

---

# Assignment

Variables may be assigned constants, variables, or expressions.

```c
x = 5

x = y

x = a + b

x = (a + b) * c
```

---

# Arithmetic Operators

The language supports the following arithmetic operators.

| Operator | Description |
|----------|-------------|
| `+` | Addition |
| `-` | Subtraction |
| `*` | Multiplication |
| `/` | Division |

Parentheses may be used to control evaluation order.

```c
x = (a + b) * c
```

---

# Printing

The `print` statement outputs text or numeric values.

```c
print Hello

print x

print 42

print RETVAL
```

Numeric values are automatically converted to ASCII before being printed.

---

# If Statements

Conditional execution is performed using `if`.

```c
if x == y

    print Equal

endif
```

Supported comparison operators are:

| Operator | Description |
|----------|-------------|
| `==` | Equal |
| `!=` | Not Equal |
| `<` | Less Than |

---

# While Loops

A `while` loop repeatedly executes while its condition remains true.

```c
while counter < 10

    print counter

    counter = counter + 1

ewhile
```

---

# For Loops

A `for` loop consists of an initialization, condition, and update expression.

```c
for i = 0, i < 10, i++

    print i

efor
```

Supported update operations:

```c
i++

```

---

# Functions

Functions are declared using the `func` keyword.

```c
func add a b = {

    return a + b

}
```

Functions currently support up to three parameters.

---

# Calling Functions

Functions are invoked using `call`.

```c
call add(5,7)
```

Return values are accessed through `RETVAL`.

```c
call add(5,7)

print RETVAL
```

---

# Returning Values

Functions return values using the `return` statement.

```c
return x

return a + b

return (x + y) * z
```

---

# RETVAL

`RETVAL` contains the value returned by the most recently executed function.

```c
call square(12)

let result = RETVAL
```

---

# Inline Assembly

Assembly code may be embedded directly inside a source file.

```c
asm = {

tty "Hello"

halt

}
```

Instructions inside an assembly block are copied directly into the generated assembly output.

---

# Halt

Program execution may be terminated using

```c
halt
```

---

# Operator Precedence

Expressions follow standard arithmetic precedence.

| Priority | Operators |
|----------|-----------|
| Highest | `()` |
| High | `*` `/` |
| Low | `+` `-` |

---

# Complete Example

```c
; Sum the numbers 0 through 9

let total = 0
let i = 0

for i = 0, i < 10, i++

    total = total + i

efor

print total

halt
```

---

# Current Limitations

The current language implementation includes the following limitations.

- Integer values only
- Static arrays
- Maximum of three function parameters
- Single return value
- No recursion
- No pointers
- No structures
- No floating-point arithmetic
- No dynamic memory allocation

These limitations reflect the current capabilities of both the compiler and the 16-Bit CPU.
