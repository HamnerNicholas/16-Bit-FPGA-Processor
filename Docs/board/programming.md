# Programming the FPGA

The FPGA implementation is programmed using Intel Quartus Prime and a USB-Blaster connection.

---

## Build

Compile the Quartus project.

---

## Assemble

Generate

- instruction_ram.hex
- global_memory.hex
- ivt.hex

using the assembler.

---

## Update Memories

Replace the memory initialization files within the Quartus project.

---

## Compile

Recompile the Quartus project.

---

## Program

Program the FPGA using Quartus Programmer.

---

## Reset

After programming, assert the reset input to begin execution from address zero.
