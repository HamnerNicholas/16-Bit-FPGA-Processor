module CPU_CORE #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 16,
    parameter IMM_WIDTH = 8,
    parameter REG_ADDR_WIDTH = 3,
    parameter SUBOP_WIDTH = 2,
    parameter INT_LINES_WIDTH = 8
)(
    input clk,
    input rst,
    input [INT_LINES_WIDTH-1:0] interrupts,

    // Processor status/debug outputs
    output halt,
    output [ADDR_WIDTH-1:0] debug_PC,
    output [DATA_WIDTH-1:0] debug_ACC,
    output [DATA_WIDTH-1:0] debug_regOut,
    output [DATA_WIDTH-1:0] debug_globalOut,
    output [ADDR_WIDTH-1:0] debug_RA,
    output [ADDR_WIDTH-1:0] debug_INT_RET_REG,

    // I/O instruction outputs
    output ttyLoad,
    output ttyALoad,
    output [DATA_WIDTH-1:0] tty_ACC,
    output [IMM_WIDTH-1:0] tty_imm
);

    // ------------------------------------------------------------
    // Instruction fields
    // ------------------------------------------------------------

    wire [ADDR_WIDTH-1:0] PCOut;
    wire [IMM_WIDTH-1:0] imm;
    wire [REG_ADDR_WIDTH-1:0] regField;
    wire [SUBOP_WIDTH-1:0] SubopField;

    // ------------------------------------------------------------
    // Opcode-family control lines
    // ------------------------------------------------------------

    wire jal;
    wire ALUI;
    wire ALU;
    wire tty;
    wire copy;
    wire beq;
    wire load;
    wire store;

    // ------------------------------------------------------------
    // Sub-operation control lines
    // ------------------------------------------------------------

    wire RALoad;
    wire RAReturn;
    wire LoadJalRegisters;
    wire ReadJalRegisters;

    wire COPYSTD;
    wire RINT;

    // ------------------------------------------------------------
    // Datapath wires
    // ------------------------------------------------------------

    wire [DATA_WIDTH-1:0] accOut;
    wire [DATA_WIDTH-1:0] regOut;
    wire [DATA_WIDTH-1:0] JALRegOut;
    wire [DATA_WIDTH-1:0] ALUOut;
    wire [DATA_WIDTH-1:0] globalOut;

    // ------------------------------------------------------------
    // Return-address and interrupt wires
    // ------------------------------------------------------------

    wire [ADDR_WIDTH-1:0] RAOut;
    wire [ADDR_WIDTH-1:0] INT_RET_REG;
    wire [ADDR_WIDTH-1:0] ISRVector;
    wire ISRJumpControl;

    // ------------------------------------------------------------
    // Instruction RAM and primary decode
    // ------------------------------------------------------------

    INSTRUCTION_RAM #(
        .WIDTH(16),
        .ADDR_WIDTH(ADDR_WIDTH),
        .IMM_WIDTH(IMM_WIDTH),
        .REG_FIELD_WIDTH(REG_ADDR_WIDTH),
        .OP_CODE_WIDTH(3),
        .SUB_OP_WIDTH(SUBOP_WIDTH)
    ) instruction_ram_inst (
        .clk(clk),
        .PCOut(PCOut),
        .imm(imm),
        .regField(regField),
        .SubopField(SubopField),
        .jal(jal),
        .ALUI(ALUI),
        .ALU(ALU),
        .tty(tty),
        .copy(copy),
        .beq(beq),
        .load(load),
        .store(store)
    );

    // ------------------------------------------------------------
    // Sub-operation decoders
    // ------------------------------------------------------------

    JAL_SUBOP_CONTROL #(
        .SUBOP_WIDTH(SUBOP_WIDTH)
    ) jal_subop_control_inst (
        .jal(jal),
        .SubopField(SubopField),
        .RALoad(RALoad),
        .RAReturn(RAReturn),
        .LoadJalRegisters(LoadJalRegisters),
        .ReadJalRegisters(ReadJalRegisters)
    );

    IO_SUBOP_CONTROL #(
        .SUBOP_WIDTH(SUBOP_WIDTH)
    ) io_subop_control_inst (
        .tty(tty),
        .SubopField(SubopField),
        .ttyLoad(ttyLoad),
        .ttyALoad(ttyALoad),
        .halt(halt)
    );

    COPY_SUBOP_CONTROL #(
        .SUBOP_WIDTH(SUBOP_WIDTH)
    ) copy_subop_control_inst (
        .copy(copy),
        .SubopField(SubopField),
        .COPYSTD(COPYSTD),
        .RINT(RINT)
    );

    // ------------------------------------------------------------
    // Program counter
    // ------------------------------------------------------------

    PC #(
        .WIDTH(ADDR_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .IMM_WIDTH(IMM_WIDTH),
        .SUBOP_WIDTH(SUBOP_WIDTH)
    ) pc_inst (
        .clk(clk),
        .rst(rst),
        .halt(halt),
        .RINT(RINT),
        .RAReturn(RAReturn),
        .RALoad(RALoad),
        .ISRJumpControl(ISRJumpControl),
        .beq(beq),
        .INT_RET_REG(INT_RET_REG),
        .ISR_VECTOR(ISRVector),
        .RAOut(RAOut),
        .regOut(regOut),
        .accOut(accOut),
        .imm(imm),
        .SubopField(SubopField),
        .PCOut(PCOut)
    );

    // ------------------------------------------------------------
    // ALU
    // ------------------------------------------------------------

    ALU #(
        .REG_WIDTH(DATA_WIDTH),
        .SUBOP_WIDTH(SUBOP_WIDTH)
    ) alu_inst (
        .ALU(ALU),
        .SubopField(SubopField),
        .regOut(regOut),
        .imm(imm),
        .accOut(accOut),
        .ALUOut(ALUOut)
    );

    // ------------------------------------------------------------
    // Accumulator
    // ------------------------------------------------------------

    ACCUMULATOR_REGISTER #(
        .REG_WIDTH(DATA_WIDTH)
    ) accumulator_inst (
        .clk(clk),
        .halt(halt),
        .rst(rst),
        .ALUI(ALUI),
        .ALU(ALU),
        .load(load),
        .ReadJalRegisters(ReadJalRegisters),
        .ALUOut(ALUOut),
        .globalOut(globalOut),
        .JALRegOut(JALRegOut),
        .accOut(accOut)
    );

    // ------------------------------------------------------------
    // General-purpose register file
    // ------------------------------------------------------------

    REGISTER_FILE #(
        .REG_WIDTH(DATA_WIDTH),
        .REG_COUNT(8),
        .REG_ADDR_WIDTH(REG_ADDR_WIDTH)
    ) register_file_inst (
        .rst(rst),
        .clk(clk),
        .halt(halt),
        .COPYSTD(COPYSTD),
        .accOut(accOut),
        .regField(regField),
        .regOut(regOut)
    );

    // ------------------------------------------------------------
    // JAL register file
    // ------------------------------------------------------------

    JAL_REGISTER_FILE #(
        .REG_WIDTH(DATA_WIDTH),
        .REG_COUNT(8),
        .REG_ADDR_WIDTH(REG_ADDR_WIDTH)
    ) jal_register_file_inst (
        .rst(rst),
        .clk(clk),
        .halt(halt),
        .LoadJalRegisters(LoadJalRegisters),
        .accOut(accOut),
        .regField(regField),
        .JALRegOut(JALRegOut)
    );

    // ------------------------------------------------------------
    // Return-address register
    // ------------------------------------------------------------

    RETURN_ADDRESS_REGISTER #(
        .WIDTH(ADDR_WIDTH)
    ) return_address_register_inst (
        .clk(clk),
        .halt(halt),
        .rst(rst),
        .RALoad(RALoad),
        .PCOut(PCOut),
        .RAOut(RAOut)
    );

    // ------------------------------------------------------------
    // Global data memory
    // ------------------------------------------------------------

    GLOBAL_MEMORY #(
        .WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(IMM_WIDTH)
    ) global_memory_inst (
        .clk(clk),
        .halt(halt),
        .store(store),
        .imm(imm),
        .accOut(accOut),
        .globalOut(globalOut)
    );

    // ------------------------------------------------------------
    // Interrupt system
    // ------------------------------------------------------------

    ISR_CONTROL #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .INT_LINES_WIDTH(INT_LINES_WIDTH)
    ) isr_control_inst (
        .clk(clk),
        .rst(rst),
        .halt(halt),
        .PCOut(PCOut),
        .interrupts(interrupts),
        .INT_RET_REG(INT_RET_REG),
        .ISRVector(ISRVector),
        .ISRJumpControl(ISRJumpControl)
    );

    // ------------------------------------------------------------
    // Debug and external I/O connections
    // ------------------------------------------------------------

    assign debug_PC = PCOut;
    assign debug_ACC = accOut;
    assign debug_regOut = regOut;
    assign debug_globalOut = globalOut;
    assign debug_RA = RAOut;
    assign debug_INT_RET_REG = INT_RET_REG;

    assign tty_ACC = accOut;
    assign tty_imm = imm;

endmodule