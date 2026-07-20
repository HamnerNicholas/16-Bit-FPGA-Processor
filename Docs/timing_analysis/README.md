# Timing Analysis

This document summarizes the static timing analysis performed on the 16-bit FPGA Processor after synthesis, placement, and routing using the Intel Quartus Prime TimeQuest Timing Analyzer.

The processor was implemented on an Intel MAX 10 FPGA and analyzed under the **Slow Timing Model** across a junction temperature range of **0°C to 85°C**, representing worst-case operating conditions.

---

# Timing Constraints

Timing constraints were defined using an SDC (Synopsys Design Constraints) file describing the primary system clock, internally generated CPU clock, and PLL-generated VGA clock.

The processor uses the onboard 50 MHz oscillator as the master clock.

```tcl
create_clock -name MAX10_CLK1_50 \
    -period 20.000 \
    [get_ports {MAX10_CLK1_50}]

create_generated_clock \
    -name cpu_clk \
    -source [get_ports {MAX10_CLK1_50}] \
    -divide_by 2 \
    [get_registers {CLOCK_DIVIDER:divider|slow_clk}]

derive_pll_clocks
derive_clock_uncertainty
```

---

# Clock Architecture

The processor operates using three primary clock domains.

| Clock Domain | Source | Operating Frequency |
|--------------|--------|--------------------:|
| System Clock | MAX10 Oscillator | 50.00 MHz |
| CPU Clock | Divide-by-2 Clock Divider | 25.00 MHz |
| VGA Pixel Clock | PLL Output | 25.00 MHz |

The CPU executes at **25 MHz**, while the VGA controller independently operates from a PLL-generated pixel clock.

---

# Maximum Operating Frequency

Post-fit maximum operating frequencies reported by the TimeQuest Timing Analyzer are shown below.

| Clock Domain | Operating Frequency | Post-Fit Fmax |
|--------------|--------------------:|--------------:|
| CPU Clock | 25.00 MHz | **77.44 MHz** |
| VGA Pixel Clock | 25.00 MHz | **69.32 MHz** |
| 50 MHz System Clock | 50.00 MHz | **207.90 MHz** |

The processor currently operates at **25 MHz**, while timing analysis indicates that the CPU clock domain could operate at approximately **77.44 MHz** under the analyzed operating conditions.

This provides more than **3× timing margin** relative to the processor's configured operating frequency.

---

# Setup Timing Results

Static timing analysis reported:

| Metric | Result |
|--------|--------|
| Setup Violations | **0** |
| Worst Setup Slack | **27.087 ns** |
| CPU Clock Period | **40.000 ns** |

No setup timing violations were detected in any constrained clock domain.

The worst setup path within the CPU clock domain exhibits **27.087 ns** of positive slack, providing substantial operating margin while executing at the target 25 MHz clock frequency. :contentReference[oaicite:0]{index=0}

---

# CPU Timing Analysis

The longest setup path within the processor clock domain originates from the Program Counter and terminates at the memory-mapped VGA text buffer.

```
Program Counter
        │
        ▼
Instruction ROM
        │
        ▼
Instruction Decode
        │
        ▼
TTY Output Decode
        │
        ▼
Video RAM Write Logic
```

Interestingly, the processor arithmetic datapath is **not** the limiting timing path.

The accumulator architecture produces a relatively shallow arithmetic datapath, allowing ALU operations to complete well within the required clock period. Instead, the longest processor timing path is associated with instruction fetch, instruction decoding, and memory-mapped display output.

This demonstrates that the integrated VGA text console contributes more combinational delay than the processor execution hardware itself. :contentReference[oaicite:1]{index=1}

---

# VGA Timing Analysis

Independent path analysis was also performed on the VGA rendering subsystem.

The longest combinational path in the complete design occurs entirely within the VGA display pipeline.

```
VGA Column Counter
        │
        ▼
Character Address Generation
        │
        ▼
Video RAM Read Multiplexer
        │
        ▼
Character Output Register
```

TimeQuest reported a maximum combinational delay of approximately **14.24 ns** for this path.

This path exists entirely within the VGA rendering hardware and is independent of processor execution. :contentReference[oaicite:2]{index=2}

---

# Discussion

Several architectural decisions contribute to the favorable timing characteristics of the processor.

The processor uses an **8-bit accumulator architecture**, significantly reducing arithmetic datapath complexity compared to traditional register-register processor architectures. As a result, ALU operations are not the dominant source of combinational delay.

Instead, the largest delays occur within the memory-mapped VGA terminal interface, where instruction decoding directly controls writes into the text display buffer.

The completed implementation comfortably satisfies all setup timing requirements while maintaining significant operating margin across every constrained clock domain.

---

# Future Improvements

Although the design successfully meets timing, several architectural improvements could further increase the maximum operating frequency.

- Replace the internally generated CPU clock with a synchronous **clock enable** signal, allowing the processor to operate entirely within a single clock domain.
- Pipeline portions of the VGA text output path to reduce combinational delay.
- Improve block RAM inference for the video memory subsystem.
- Continue minimizing clock-domain crossings between the processor and display logic.

---

# Timing Summary

| Metric | Result |
|--------|-------:|
| CPU Operating Frequency | **25.00 MHz** |
| CPU Post-Fit Fmax | **77.44 MHz** |
| VGA Post-Fit Fmax | **69.32 MHz** |
| System Clock Fmax | **207.90 MHz** |
| Worst CPU Setup Slack | **27.087 ns** |
| Setup Violations | **0** |

---

# Conclusion

Static timing analysis confirms that the processor meets all timing requirements under worst-case operating conditions.

The CPU executes at **25 MHz** while achieving a post-fit maximum operating frequency of **77.44 MHz**, providing more than three times the required timing margin.

Analysis of the critical paths shows that the processor execution hardware is not the limiting factor. Instead, the longest timing paths are associated with the integrated memory-mapped VGA text output subsystem, demonstrating that the accumulator-based CPU architecture achieves efficient arithmetic execution while the display interface dominates overall combinational delay.

Overall, the implemented design satisfies all constrained timing requirements with **zero setup violations**, indicating that the processor is suitable for reliable operation on the target Intel MAX 10 FPGA.
