# Interrupts

This document describes the interrupt architecture of the 16-Bit CPU.

Interrupts allow external hardware to temporarily suspend normal program execution, execute an Interrupt Service Routine (ISR), and then resume execution exactly where the interrupt occurred.

The processor provides dedicated hardware support for interrupt handling through an Interrupt Vector Table (IVT), an Interrupt Return Register (IRR), and the `RINT` instruction.

---

# Overview

An interrupt occurs when one of the processor's interrupt input lines is asserted.

When an interrupt is accepted, the processor performs the following sequence:

1. Save the current Program Counter.
2. Store the return address in the Interrupt Return Register (IRR).
3. Read the interrupt vector from the Interrupt Vector Table.
4. Load the Program Counter with the interrupt service routine address.
5. Begin executing the interrupt handler.

After the interrupt has been serviced, execution returns to the interrupted program using the `RINT` instruction.

---

# Interrupt Vector Table (IVT)

The Interrupt Vector Table contains the starting addresses of every interrupt service routine.

Each interrupt input corresponds to one entry within the table.

| Interrupt | Vector Entry |
|-----------|--------------|
| INT0 | Entry 0 |
| INT1 | Entry 1 |
| INT2 | Entry 2 |
| INT3 | Entry 3 |
| INT4 | Entry 4 |
| INT5 | Entry 5 |
| INT6 | Entry 6 |
| INT7 | Entry 7 |

The processor uses the asserted interrupt input to select the appropriate vector.

---

# Interrupt Service Routine

An Interrupt Service Routine (ISR) is a normal assembly routine entered automatically by the processor in response to an interrupt.

Example

```assembly
: TIMER_ISR

...

rint
```

Unlike subroutines, interrupt service routines are entered automatically by hardware rather than by a `JSR` instruction.

---

# Interrupt Entry

When an interrupt is accepted, the processor performs the following operations.

```
Current Program Counter

        │

        ▼

Interrupt Return Register (IRR)

        │

        ▼

Read IVT Entry

        │

        ▼

Load Program Counter

        │

        ▼

Execute ISR
```

The interrupted program does not need to manually save its execution address.

---

# Interrupt Return Register (IRR)

The Interrupt Return Register stores the address of the interrupted instruction.

The IRR is managed entirely by processor hardware and is not directly accessible by software.

The value stored in the IRR is used exclusively by the `RINT` instruction.

---

# Returning from an Interrupt

Interrupt handlers terminate using

```assembly
rint
```

The processor restores the Program Counter using the value stored in the Interrupt Return Register.

Conceptually,

```
PC ← IRR
```

Program execution then resumes exactly where it was interrupted.

---

# Interrupt Flow

The complete interrupt sequence is shown below.

```
Program Execution

        │

        ▼

Interrupt Request

        │

        ▼

Save Program Counter

        │

        ▼

Store PC in IRR

        │

        ▼

Read IVT

        │

        ▼

Jump to ISR

        │

        ▼

Execute Handler

        │

        ▼

RINT

        │

        ▼

Restore Program Counter

        │

        ▼

Resume Program
```

---

# Interrupt Vectors

Interrupt vectors are assigned by software during assembly using the Interrupt Vector Table.

Conceptually,

```
INT0

↓

Keyboard ISR

INT1

↓

Timer ISR

INT2

↓

UART ISR
```

The processor itself only reads vector addresses; it does not interpret the purpose of each interrupt.

---

# Software Responsibilities

The processor automatically manages:

- Interrupt entry
- Saving the Program Counter
- Loading the interrupt vector
- Returning from the interrupt

Interrupt service routines are responsible for:

- Performing the required service
- Preserving any registers that must remain unchanged
- Returning using `RINT`

---

# Relationship to Subroutines

Interrupts and subroutines both transfer control to another section of code, but they serve different purposes.

| Subroutine | Interrupt |
|------------|-----------|
| Invoked by software | Invoked by hardware |
| Uses `JSR` | Triggered by interrupt input |
| Returns using `RSR` | Returns using `RINT` |
| Return address stored by subroutine hardware | Return address stored in the IRR |

Although similar, interrupt service routines execute asynchronously with respect to the currently running program.

---

# Current Implementation

The current processor provides:

- Eight interrupt input lines
- Hardware interrupt vector table support
- Dedicated Interrupt Return Register
- Hardware interrupt dispatch
- Dedicated interrupt return instruction

Additional interrupt features may be introduced in future processor revisions.

---

# Design Philosophy

The interrupt system was designed to provide deterministic hardware-assisted interrupt handling while remaining simple to implement.

By providing dedicated hardware for interrupt dispatch and return, software is relieved from manually managing program flow during interrupt handling.

This approach keeps interrupt service routines concise while maintaining predictable processor behavior.
