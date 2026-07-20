# Verification

This directory contains the directed verification environment for the 16-Bit FPGA Processor.

The goal of this verification suite is to validate the functionality of each hardware module independently before performing full processor integration testing. Each module is verified using a self-checking Verilog testbench that exercises both normal operation and edge-case behavior.

Module-level verification follows a bottom-up methodology:

---

# Verification Strategy

Each module is verified independently using self-checking Verilog testbenches.

Every testbench:

- Applies deterministic input stimulus
- Automatically compares expected and actual outputs
- Reports PASS/FAIL for every test case
- Produces a verification summary upon completion

The objective is to verify all architectural behavior before integrating the processor as a complete system.

---

# Current Verification Status

| Module | Tests | Status |
|---------|------:|:------:|
| Accumulator Register | 13 | Pass |
| Arithmetic Logic Unit (ALU) | 22 | Pass |
| Register File | 38 | Pass |
| Program Counter | 26 | Pass |
| Return Address Register | 12 | Pass |
| Interrupt Controller | 27 | Pass |
| **Total** | **138** | **138 / 138 Passed** |

---

# Verified Functionality

## Accumulator Register

- Reset behavior
- ALU writes
- Immediate writes
- Memory loads
- Return-address reads
- Hold behavior
- Halt behavior
- Input priority

---

## Arithmetic Logic Unit

- Addition
- Subtraction
- Multiplication
- Division
- Operand selection
- Signed arithmetic
- Overflow behavior
- Underflow behavior
- Divide-by-zero behavior

---

## Register File

- Register reset
- Register writes
- Register overwrites
- Asynchronous reads
- Halt protection
- Write enable
- Register isolation
- Reset priority

---

## Program Counter

- Sequential execution (PC + 1)
- Conditional branches
- Unconditional jumps
- Signed branch comparisons
- Relative addressing
- Return-address loading
- Interrupt vector jumps
- Interrupt returns
- Control signal priority
- Halt behavior

---

## Return Address Register

- Reset behavior
- Return address capture
- PC + 1 generation
- Halt behavior
- Hold behavior
- Address wraparound

---

## Interrupt Controller

- Interrupt sampling
- Priority encoder
- Interrupt vector lookup
- Interrupt return register
- Reset behavior
- Halt behavior
- Simultaneous interrupt priority

---

# Running Simulations

Each module can be simulated independently using ModelSim.

Typical simulation flow:

```tcl
vlib work

vlog <module>.v
vlog <module>_TB.v

vsim work.<module>_TB

add wave -r *

run -all
```

Each simulation produces a PASS/FAIL summary similar to:

```
========================================
TEST SUMMARY
Tests Run:    XX
Tests Passed: XX
Tests Failed: 0
========================================

RESULT: ALL TESTS PASSED
```

---

