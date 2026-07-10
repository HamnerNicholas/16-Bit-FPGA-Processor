module CPU_MAIN #(
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

    output [6:0] HEX0,
    output [6:0] HEX1
);


    // Instruction fields
    wire [ADDR_WIDTH-1:0] PCOut;
    wire [IMM_WIDTH-1:0] imm;
    wire [REG_ADDR_WIDTH-1:0] regField;
    wire [SUBOP_WIDTH-1:0] SubopField;

    // Opcode control lines
    wire jal, ALUI, ALU, tty, copy, beq, load, store;

    // Subop control lines
    wire RALoad, RAReturn, LoadJalRegisters, ReadJalRegisters;
    wire ttyLoad, ttyALoad, halt;
    wire COPYSTD, RINT;

    // Datapath wires
    wire [DATA_WIDTH-1:0] accOut;
    wire [DATA_WIDTH-1:0] regOut;
    wire [DATA_WIDTH-1:0] JALRegOut;
    wire [DATA_WIDTH-1:0] ALUOut;
    wire [DATA_WIDTH-1:0] globalOut;

    // Address / interrupt wires
    wire [ADDR_WIDTH-1:0] RAOut;
    wire [ADDR_WIDTH-1:0] INT_RET_REG;
    wire [ADDR_WIDTH-1:0] ISRVector;
    wire ISRJumpControl;

    // Instruction RAM / decoder
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

    IO_MODULE #(
        .DATA_WIDTH(DATA_WIDTH)
    ) io_module_inst (
        .clk(clk),
        .rst(rst),
        .halt(halt),
        .ttyLoad(ttyLoad),
        .ttyALoad(ttyALoad),
        .accOut(accOut),
        .imm(imm),
        .HEX0(HEX0),
        .HEX1(HEX1)
    );

endmodule