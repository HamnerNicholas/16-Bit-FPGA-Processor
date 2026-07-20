# CPU Verification

This directory contains the integration test suite for the 16-bit FPGA Processor. These tests verify the functional correctness of the complete processor by executing assembly programs on the RTL implementation and automatically checking the resulting architectural state.

Unlike module-level verification, these tests exercise the processor as a complete system, validating interactions between the instruction fetch unit, decoder, ALU, register files, memory subsystem, interrupt controller, and I/O interface.

All testbenches are self-checking and produce PASS/FAIL results without requiring manual waveform inspection.

---

# Verification Strategy

The processor is verified using directed integration tests.

Each test executes a carefully designed assembly program that targets a specific architectural feature while minimizing unrelated processor activity. After execution completes, the testbench automatically verifies:

* Register contents
* Accumulator state
* Program counter
* Memory contents
* Interrupt state
* Return address registers
* JAL register file contents
* I/O transactions
* Processor halt behavior

This approach verifies not only the individual instructions, but also the interaction between every major subsystem of the processor.

---

# Test Categories

## Arithmetic

Verifies:

* Immediate arithmetic
* Register arithmetic
* Addition
* Subtraction
* Multiplication
* Division
* Overflow behavior
* Underflow behavior
* Arithmetic truncation
* Divide-by-zero handling

---

## Memory

Verifies:

* Global memory loads
* Global memory stores
* Memory overwrites
* Boundary addresses
* Data persistence
* Memory read/write sequencing

---

## Program Control

Verifies:

* Equality branches
* Inequality branches
* Signed comparisons
* Forward jumps
* Backward jumps
* Loop execution
* Program counter updates

---

## Subroutines

Verifies:

* JSR
* RSR
* Return address register
* JAL register file
* Save/restore operations
* Nested control flow

---

## Interrupt System

Verifies:

* Interrupt vector table
* Interrupt entry
* Interrupt return
* Context preservation
* Interrupt priority
* Simultaneous interrupt requests
* Return to interrupted instruction

---

## I/O

Verifies:

* Immediate TTY output
* Accumulator TTY output
* Output transaction ordering
* Control signal generation
* Halt behavior

---

# Self-Checking Testbenches

Every integration test is fully self-checking.

Each testbench automatically:

* Executes the assembled program
* Waits for processor halt
* Compares the final processor state against expected values
* Reports individual PASS/FAIL results
* Produces a verification summary

Typical output:

```text
========================================
TEST SUMMARY

Tests run:    26
Tests passed: 26
Tests failed: 0

RESULT: ALL TESTS PASSED
========================================
```

No manual inspection is required to determine whether a test succeeds.

---

# Current Verification Coverage

| Category                | Status |
| ----------------------- | :----: |
| Arithmetic              |    pass   |
| Register File           |    pass   |
| Global Memory           |    pass   |
| Branch Instructions     |    pass   |
| Jump Instructions       |    pass   |
| Program Counter         |    pass   |
| Subroutines             |    pass   |
| Return Address Register |    pass   |
| JAL Register File       |    pass   |
| Interrupt Entry         |    pass   |
| Interrupt Return        |    pass   |
| Interrupt Priority      |    pass   |
| TTY Immediate Output    |    pass   |
| TTY Accumulator Output  |    pass   |
| Halt Instruction        |    pass   |

---

# Methodology

The verification flow follows the same progression commonly used in digital hardware development:

1. Verify individual hardware modules.
2. Verify processor subsystems.
3. Execute complete assembly programs on the RTL processor.
4. Automatically compare architectural state against expected results.
5. Regress all tests after architectural changes.

By combining module-level verification with processor-level integration testing, the project validates both individual hardware components and complete software-visible processor behavior.

---

# Results

The processor has successfully completed **364 self-checking verification tests** spanning arithmetic, control flow, memory operations, interrupts, subroutines, and I/O.

These tests collectively verify the complete execution path from instruction fetch through decode, execution, writeback, and architectural state updates, providing confidence that the implemented ISA behaves as specified.
