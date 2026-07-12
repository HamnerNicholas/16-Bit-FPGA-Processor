# Execution Model

This document describes how the 16-Bit CPU executes instructions.

Every instruction follows the same basic execution sequence regardless of its operation. This fixed execution model simplifies the processor design while providing predictable program execution.

---

# Instruction Cycle

The processor executes instructions using a repeating instruction cycle.

```
Fetch

    │

    ▼

Decode

    │

    ▼

Execute

    │

    ▼

Write Back

    │

    ▼

Next Instruction
```

This sequence repeats until program execution is halted or interrupted.

---

# Fetch Stage

During the fetch stage, the processor reads the instruction pointed to by the Program Counter (PC).

```
Program Counter

        │

        ▼

Instruction Memory

        │

        ▼

Instruction Register
```

After the instruction has been fetched, the Program Counter advances to the next sequential instruction.

Conceptually,

```
IR ← Instruction Memory[PC]

PC ← PC + 1
```

---

# Decode Stage

The Instruction Register contains the current 16-bit instruction.

The control unit separates the instruction into its individual fields.

```
Instruction Register

        │

        ▼

+------------------------------+
| Opcode                       |
| SubOp                        |
| Register                     |
| Immediate                    |
+------------------------------+
```

The Opcode field determines the instruction family.

The SubOp field selects the specific instruction.

The Register and Immediate fields are routed to the appropriate hardware.

---

# Execute Stage

During execution, the selected functional unit performs the requested operation.

Examples include:

- Arithmetic operations
- Memory access
- Branch evaluation
- Subroutine control
- Interrupt return
- Terminal output

Only the hardware required by the current instruction is active.

---

# Write Back Stage

Instructions that produce a result write their output back to the appropriate destination.

Examples include:

```
General-Purpose Register

Accumulator

Global Memory

Subroutine Register File

Program Counter
```

Not every instruction performs a write-back operation.

For example,

```assembly
halt
```

terminates execution without modifying processor state.

---

# Arithmetic Execution

Arithmetic instructions operate using the accumulator.

Example

```assembly
addi r1 5
```

Execution proceeds conceptually as

```
Accumulator

+

Immediate

↓

ALU

↓

Destination Register
```

Register arithmetic follows the same process except the second operand comes from a general-purpose register.

---

# Memory Access

Memory instructions communicate with global memory.

For a load instruction,

```assembly
load r1 VALUE
```

execution becomes

```
Global Memory

↓

Accumulator

↓

Destination Register
```

Store instructions perform the opposite operation.

```
Register

↓

Global Memory
```

---

# Branch Execution

Conditional branches compare the accumulator against a general-purpose register.

```
Accumulator

↓

Comparator

↓

Register

↓

Branch Decision
```

If the branch condition evaluates true, the Program Counter is updated using the supplied offset.

Otherwise, execution continues sequentially.

---

# Subroutine Execution

Subroutine instructions interact with the Subroutine Register File (SRF).

A typical function call follows the sequence

```
Store Parameters

↓

JSR

↓

Execute Subroutine

↓

Store Return Value

↓

RSR

↓

Continue Execution
```

The compiler automatically generates this sequence for every function call.

---

# Interrupt Execution

Interrupts temporarily suspend normal execution.

When an interrupt is accepted,

```
Current Program Counter

↓

Interrupt Return Register

↓

Read Interrupt Vector

↓

Execute ISR

↓

RINT

↓

Restore Program Counter
```

Execution then resumes exactly where it was interrupted.

---

# Sequential Execution

In the absence of branches, subroutines, or interrupts, instructions execute sequentially.

```
Instruction 0

↓

Instruction 1

↓

Instruction 2

↓

Instruction 3
```

The Program Counter automatically advances after each instruction.

---

# Control Flow

Several instruction families modify normal sequential execution.

| Instruction | Effect |
|-------------|--------|
| JUMP | Unconditional branch |
| BEQ | Conditional branch |
| BNE | Conditional branch |
| BLT | Conditional branch |
| JSR | Call subroutine |
| RSR | Return from subroutine |
| RINT | Return from interrupt |

These instructions replace the normal Program Counter update with a new target address.

---

# Program Execution

A complete program therefore follows this general pattern.

```
Reset

↓

Program Counter = 0

↓

Fetch

↓

Decode

↓

Execute

↓

Write Back

↓

Next Instruction

↓

...

↓

HALT
```

Program execution continues until a `HALT` instruction is encountered or the processor is reset.

---

# Execution Characteristics

The execution model of the 16-Bit CPU was designed around several principles.

- Fixed-width instructions
- Sequential instruction execution
- Accumulator-based arithmetic
- Dedicated hardware for subroutines
- Hardware-assisted interrupt handling
- Predictable control flow

These design decisions simplify the processor implementation while providing a straightforward programming model for both assembly programmers and the compiler backend.

---

# Relationship to the Architecture

The execution model described here defines the logical behavior of the processor.

The **Architecture** documentation describes how this behavior is implemented in hardware through the datapath, control unit, register file, ALU, and memory interfaces.
