# Memory

The FPGA implementation currently contains three independent memories.

| Memory | Purpose |
|---------|----------|
| Instruction RAM | Program instructions |
| Global Memory | Variables and arrays |
| Interrupt Vector Table | Interrupt handler addresses |

The compiler and assembler automatically generate initialization files for each memory.

| File | Memory |
|------|--------|
| instruction_ram.hex | Instruction RAM |
| global_memory.hex | Global Memory |
| ivt.hex | Interrupt Vector Table |
