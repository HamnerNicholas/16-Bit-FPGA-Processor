# Control Unit

The control unit is entirely combinational and is responsible for generating the control signals used throughout the processor.

Each instruction is divided into four fields:

| Bits | Description |
|------|-------------|
| 15–8 | Immediate |
| 7–6 | Sub-operation |
| 5–3 | Register |
| 2–0 | Opcode |

The opcode selects the instruction family while the sub-operation selects the specific instruction within that family.

Instruction families include:

- System Register Functions
- ALU Immediate
- ALU Register
- I/O
- Register Copy
- Branch
- Load
- Store

Each instruction family has its own dedicated decoder module which generates the appropriate control signals for the datapath.
