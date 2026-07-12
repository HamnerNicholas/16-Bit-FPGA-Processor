# FPGA Implementation

The 16-Bit CPU is currently implemented on the Intel DE10-Lite FPGA development board.

The project is developed using Intel Quartus Prime and targets the onboard MAX 10 FPGA.

---

## Development Board

| Item | Value |
|------|-------|
| Board | Intel DE10-Lite |
| FPGA | Intel MAX 10 |
| Toolchain | Quartus Prime |

---

## Top-Level Components

The FPGA implementation currently consists of:

- 16-Bit CPU
- Instruction RAM
- Global Memory
- Interrupt Vector Table Memory
- VGA Controller
- Reset Logic

Future revisions may include:

- PS/2 Keyboard
- UART
- Hardware Timer

---

## Clock

The processor currently uses the onboard 50 MHz oscillator.

| Signal | Description |
|---------|-------------|
| MAX10_CLK1_50 | 50 MHz system clock |

---

## Reset

The processor uses an active-low reset input.

| Signal | Description |
|---------|-------------|
| notrst | Active-low processor reset |

---

## Interrupt Inputs

Eight interrupt inputs are connected directly to the processor.

| Signal |
|---------|
| interrupts[0] |
| interrupts[1] |
| ... |
| interrupts[7] |

These inputs may be driven by external hardware or future peripherals.
