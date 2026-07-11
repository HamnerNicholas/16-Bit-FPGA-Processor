# Instruction Cycle

The processor executes one instruction per clock cycle.

Each instruction progresses through the following sequence.

## 1. Fetch

The Program Counter addresses Instruction Memory.

The current instruction is loaded into the instruction decoder.

## 2. Decode

The opcode and sub-operation fields generate the required control signals.

Source register selection, immediate values, and memory accesses are determined during this stage.

## 3. Execute

Depending on the instruction:

- ALU performs arithmetic
- Memory is accessed
- Registers are updated
- Branches are evaluated
- I/O operations occur

## 4. Write Back

Results are written into the destination register, accumulator, or memory.

## 5. Update Program Counter

The Program Counter advances to the next instruction unless modified by:

- Branch instructions
- Function calls
- Function returns
- Interrupts
