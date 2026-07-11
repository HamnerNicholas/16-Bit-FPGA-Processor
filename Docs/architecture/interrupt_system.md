# Interrupt System

The processor supports eight external interrupt sources.

Interrupt requests are prioritized using a hardware priority encoder before transferring execution to an Interrupt Service Routine (ISR).

## Components

- Interrupt Request Register
- Priority Encoder
- Interrupt Vector Table
- Interrupt Return Register

## Interrupt Flow

```
Interrupt Request
        │
        ▼
Priority Encoder
        │
        ▼
Interrupt Vector Table
        │
        ▼
ISR
        │
        ▼
rint
        │
        ▼
Resume Program
```

The assembler generates the Interrupt Vector Table automatically using the `.ivt` directive.

The `rint` instruction restores execution to the interrupted program after the ISR completes.
