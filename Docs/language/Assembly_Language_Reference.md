# Assembly Language Reference

This document describes the assembly language supported by the assembler for the 16-Bit CPU.

The assembly language provides direct access to the processor instruction set, registers, memory operations, I/O instructions, subroutine control, and interrupt vector setup.

---

# Comments

Comments begin with a semicolon (`;`).

```assembly
; This is a comment

addi r0 5
```

---

# Registers

The CPU exposes eight general-purpose registers.

```assembly
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

Both forms are valid.

---

# Labels

Labels are declared using `:` followed by the label name.

```assembly
: LOOP

addi r0 1

jump LOOP
```

Labels may be used as branch, jump, subroutine, or interrupt targets.

---

# Sections

Assembly programs may contain text and data sections.

## Text Section

The `.text` section contains executable instructions.

```assembly
.text

addi r0 5
halt
```

## Data Section

The `.data` section contains global memory values.

```assembly
.data

.word 10
.word 20
.word 30
```

---

# Directives

## `.text`

Switches the assembler into instruction output mode.

```assembly
.text
```

---

## `.data`

Switches the assembler into data output mode.

```assembly
.data
```

---

## `.word`

Writes one byte-sized value into global memory.

```assembly
.word 42
.word 0x2A
.word A
```

`.word` may be used only inside the `.data` section.

---

## `.org`

Moves the current output address forward.

```assembly
.org 16
```

When used in `.text`, it advances the instruction memory address.

When used in `.data`, it advances the global memory address.

`.org` cannot move the output address backward.

---

## `.define`

Defines a constant or register alias.

```assembly
.define COUNT 10
.define TEMP r3
```

The defined name may be used later as an immediate value or register equivalent.

---

## `.ivt`

Defines an interrupt vector table entry.

```assembly
.ivt INT0 ISR_LABEL
```

Supported interrupt entries:

```assembly
INT0
INT1
INT2
INT3
INT4
INT5
INT6
INT7
```

The second argument must be a valid label.

Example:

```assembly
.ivt INT0 ISR_KEYBOARD

.text

: ISR_KEYBOARD

; interrupt handler code

rint
```

---

# Instruction Format

Most instructions follow one of four formats.

## No Operand

```assembly
halt
rsr
rint
ttya
```

## Register Operand

```assembly
copy r1
add r2
ssrf r1
rsrf r0
```

## Immediate Operand

```assembly
jump LOOP
jsr SUBROUTINE
tty "Hello"
```

## Register + Immediate Operand

```assembly
addi r1 5
load r2 10
store r3 12
beq r1 LABEL
```

---

# Arithmetic Immediate Instructions

Immediate arithmetic instructions operate using a register and an immediate value.

| Instruction | Description |
|------------|-------------|
| `addi` | Add immediate |
| `subi` | Subtract immediate |
| `multi` | Multiply immediate |
| `divi` | Divide immediate |

Examples:

```assembly
addi r1 5
subi r1 1
multi r2 4
divi r2 2
```

---

# Arithmetic Register Instructions

Register arithmetic instructions operate using a register operand.

| Instruction | Description |
|------------|-------------|
| `add` | Add register |
| `sub` | Subtract register |
| `mult` | Multiply register |
| `div` | Divide register |

Examples:

```assembly
add r1
sub r2
mult r3
div r4
```

---

# Memory Instructions

## `load`

Loads a value from global memory.

```assembly
load r1 0
load r2 VALUE_ADDR
```

## `store`

Stores a value into global memory.

```assembly
store r1 0
store r2 VALUE_ADDR
```

---

# Copy Instruction

## `copy`

Copies the accumulator value into a register.

```assembly
copy r1
```

This is commonly used after arithmetic or load operations.

---

# Branch Instructions

Branch instructions compare against a register and branch to a label.

| Instruction | Description |
|------------|-------------|
| `beq` | Branch if equal |
| `bne` | Branch if not equal |
| `blt` | Branch if less than |
| `jump` | Unconditional jump |

Examples:

```assembly
beq r1 DONE
bne r2 LOOP
blt r3 LESS_THAN

jump LOOP
```

---

# Subroutine Instructions

The CPU supports subroutines using the Subroutine Register File.

| Instruction | Description |
|------------|-------------|
| `jsr` | Jump to subroutine |
| `rsr` | Return from subroutine |
| `ssrf` | Store to Subroutine Register File |
| `rsrf` | Read from Subroutine Register File |

Examples:

```assembly
ssrf r1
jsr PRINT_NUM

: PRINT_NUM

rsrf r0

rsr
```

---

# Interrupt Return

## `rint`

Returns from an interrupt handler.

```assembly
rint
```

This restores execution after servicing an interrupt.

---

# I/O Instructions

## `tty`

Prints a string literal.

```assembly
tty "Hello"
```

The assembler expands each character into an individual terminal output instruction.

---

## `ttya`

Prints the current accumulator value.

```assembly
ttya
```

---

## `halt`

Stops program execution.

```assembly
halt
```

---

# Interrupt Vector Table Example

```assembly
.ivt INT0 KEYBOARD_ISR

.text

jump MAIN

: KEYBOARD_ISR

; handle interrupt

rint

: MAIN

halt
```

---

# Complete Example

```assembly
.data

.word 5
.word 10

.text

load r1 0
copy r1

load r2 1
copy r2

add r1
copy r3

store r3 0

halt
```

---

# Output Files

The assembler generates memory initialization files for both Logisim and Quartus.

## Logisim Output

```text
machineCode2.txt
globalMem.txt
ivt.txt
```

## Quartus Output

```text
instruction_ram.hex
global_memory.hex
ivt.hex
```

---

# Current Limitations

- Immediate values must fit within the assembler-supported range.
- `.word` values are emitted as byte-sized data.
- `.org` can only move addresses forward.
- `.ivt` entries must point to defined labels.
- Instructions should normally be placed in `.text`.
- Data should normally be placed in `.data`.
