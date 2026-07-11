# CPU Architecture

This section documents the internal architecture of the custom 16-Bit FPGA Processor.

The processor was originally designed and validated in Logisim before being translated into synthesizable Verilog and implemented on a Terasic DE10-Lite FPGA.

Documentation is organized into the following sections:

| Document | Description |
|----------|-------------|
| `cpu_overview.md` | High-level overview of the processor architecture |
| `datapath.md` | Internal datapath and data movement |
| `control_unit.md` | Instruction decoding and control logic |
| `instruction_cycle.md` | Instruction execution sequence |
| `interrupt_system.md` | Interrupt controller and ISR handling |
| `memory_map.md` | Memory organization and address space |

The processor follows a simple accumulator-based architecture with an 8-bit datapath, 16-bit program counter, custom instruction set, interrupt support, and memory-mapped I/O.
