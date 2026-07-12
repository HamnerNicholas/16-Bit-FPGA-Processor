# Assembler Reference

This document describes the syntax and directives supported by the assembler for the 16-Bit CPU.

The assembler translates assembly source code into machine code and generates memory initialization files for both Logisim and Quartus.

---

# Comments

Comments begin with a semicolon (`;`).

```assembly
; This is a comment

addi r0 5
```

Comments may appear on their own line or after an instruction.

```assembly
addi r1 10 ; Increment counter
```

---

# Registers

The processor provides eight general-purpose registers.

```text
r0
r1
r2
r3
r4
r5
r6
r7
```

Register names are case-insensitive.

```assembly
addi r1 5

addi R1 5
```

Both forms are equivalent.

---

# Labels

Labels identify locations within the program.

A label is declared using the `:` directive.

```assembly
: LOOP

addi r0 1

jump LOOP
```

Labels may be referenced before or after they are declared.

---

# Sections

Assembly programs are divided into text and data sections.

## `.text`

The `.text` section contains executable instructions.

```assembly
.text

addi r0 5

halt
```

---

## `.data`

The `.data` section contains initialized global data.

```assembly
.data

.word 5

.word 10
```

---

# Directives

## `.word`

Stores a value in global memory.

```assembly
.word 42

.word 0x2A

.word A
```

Values may be written in decimal, hexadecimal, or as printable ASCII characters.

---

## `.define`

Creates a symbolic constant.

```assembly
.define COUNT 10
```

Constants may be used anywhere an immediate value is accepted.

```assembly
addi r0 COUNT
```

---

## `.org`

Advances the current output address.

```assembly
.org 32
```

`.org` may be used inside either `.text` or `.data`.

Addresses may only move forward.

---

## `.ivt`

Defines an interrupt vector.

```assembly
.ivt INT0 KEYBOARD_ISR
```

Supported interrupt vectors are

```text
INT0
INT1
INT2
INT3
INT4
INT5
INT6
INT7
```

The second operand must be a valid label.

---

# Numeric Literals

Immediate values may be written in multiple formats.

Decimal

```assembly
addi r0 25
```

Hexadecimal

```assembly
addi r0 0x19
```

Named constants

```assembly
.define VALUE 25

addi r0 VALUE
```

---

# Strings

The `tty` instruction accepts string literals.

```assembly
tty "Hello World"
```

The assembler automatically expands the string into one terminal output instruction per character.

---

# Memory Access

Global memory is accessed using the `load` and `store` instructions.

```assembly
load r1 0

store r1 0
```

Labels may also be used as addresses.

```assembly
load r1 VALUE

store r1 VALUE
```

---

# Branching

Labels are commonly used as branch targets.

```assembly
: LOOP

...

jump LOOP
```

Conditional branches also accept labels.

```assembly
beq r1 DONE

bne r2 LOOP

blt r3 SMALLER
```

The assembler automatically computes the required branch offset.

---

# Subroutines

Subroutines are declared using labels.

```assembly
: PRINT

...

rsr
```

Called using

```assembly
jsr PRINT
```

Parameters and return values are exchanged using the Subroutine Register File.

See the Calling Convention documentation for additional details.

---

# Interrupt Service Routines

Interrupt handlers are ordinary labels referenced by the interrupt vector table.

Example

```assembly
.ivt INT0 TIMER_ISR

.text

: TIMER_ISR

...

rint
```

Interrupt service routines terminate using the `rint` instruction.

---

# Complete Example

```assembly
.data

VALUE:

.word 10

.text

load r1 VALUE

copy r1

addi r1 5

copy r1

store r1 VALUE

halt
```

---

# Output Files

After assembly, the assembler generates memory initialization files for both supported environments.

## Logisim

```text
machineCode2.txt

globalMem.txt

ivt.txt
```

## Quartus

```text
instruction_ram.hex

global_memory.hex

ivt.hex
```

---

# Best Practices

- Place executable code inside the `.text` section.
- Place initialized data inside the `.data` section.
- Use labels instead of hard-coded addresses whenever possible.
- Use `.define` for frequently used constants.
- Comment assembly routines to improve readability.
- Organize interrupt handlers near the end of the source file.

---

# Current Limitations

The assembler currently supports:

- One source file per assembly
- Static interrupt vector table generation
- Fixed 16-bit instruction encoding
- Byte-sized global memory values
- Forward label references
