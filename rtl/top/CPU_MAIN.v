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
	 input CLOCK_50,

    output [6:0] HEX0,
    output [6:0] HEX1,
	 output [7:0] LEDR,
	 
	 //////////// CLOCKS //////////
    input               ADC_CLK_10,
    input               MAX10_CLK1_50,
    input               MAX10_CLK2_50,

    //////////// VGA SIGNALS //////////
    output reg [3:0]    VGA_R,
    output reg [3:0]    VGA_G,
    output reg [3:0]    VGA_B,
    output reg          VGA_HS,
	 output reg          VGA_VS
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
	 
	 wire cpu_clk;
	 
	 wire [7:0] display_debug;
	 
	 CLOCK_DIVIDER #(
			 .DIVIDER(1_000_000)
		) divider (
			 .clk(MAX10_CLK1_50),
			 .rst(rst),
			 .slow_clk(cpu_clk)
		);

    // Instruction RAM / decoder
    INSTRUCTION_RAM #(
        .WIDTH(16),
        .ADDR_WIDTH(ADDR_WIDTH),
        .IMM_WIDTH(IMM_WIDTH),
        .REG_FIELD_WIDTH(REG_ADDR_WIDTH),
        .OP_CODE_WIDTH(3),
        .SUB_OP_WIDTH(SUBOP_WIDTH)
    ) instruction_ram_inst (
        .clk(cpu_clk),
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
        .clk(cpu_clk),
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
        .clk(cpu_clk),
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
        .clk(cpu_clk),
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
        .clk(cpu_clk),
        .halt(halt),
        .LoadJalRegisters(LoadJalRegisters),
        .accOut(accOut),
        .regField(regField),
        .JALRegOut(JALRegOut)
    );

    RETURN_ADDRESS_REGISTER #(
        .WIDTH(ADDR_WIDTH)
    ) return_address_register_inst (
        .clk(cpu_clk),
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
        .clk(cpu_clk),
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
        .clk(cpu_clk),
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
        .clk(cpu_clk),
        .rst(rst),
        .halt(halt),
        .ttyLoad(ttyLoad),
        .ttyALoad(ttyALoad),
        .accOut(accOut),
        .imm(imm),
		  .display_debug(display_debug),
        .HEX0(HEX0),
        .HEX1(HEX1)
    );
	 
	assign LEDR = display_debug;
	
	// VGA STUFF
	wire [31:0]    col, row;
	wire [3:0]     red, green, blue;

	// Timing signals - don't touch these.
	wire           h_sync, v_sync;
	wire           disp_ena;
	wire           vga_clk;

	//============================================================================
	// Your combinational logic block that determines RGB color outputs given
	// a certain row and column pixel address. Also has all KEY push button and 
	// SW switch values. The module also determines what is displayed on the
	// LEDR LEDs and the HEX displays.
	//============================================================================
	comb_ckt_generator comb_ckt (
		.vga_clk   (vga_clk),         // Drives continuous screen reading
		.cpu_clk   (cpu_clk),         // Matches your CPU execution clock domain
		.clk_50mhz (MAX10_CLK1_50), 
		.rst       (rst),             // System reset to clear the VRAM buffer
		.halt      (halt),            // Prevents writes if CPU halts
		.ttyLoad   (ttyLoad),         // Write pulse from your CPU decoder
		.ttyALoad  (ttyALoad),        // Write pulse from your CPU decoder
		.accOut    (accOut),          // Route raw Accumulator data bus for ttya
		.imm       (imm),             // Route raw Immediate data bus for tty
		.col       (col[9:0]),        // Active horizontal pixel position
		.row       (row[8:0]),        // Active vertical pixel position
		.red       (red),             // Output Red video pins
		.green     (green),           // Output Green video pins
		.blue      (blue)             // Output Blue video pins
	);
	//============================================================================
	// Display-related and PLL stuff. Don't touch!
	//============================================================================

	// Register VGA output signals for timing purposes
	always @(posedge vga_clk) begin
		if (disp_ena == 1'b1) begin
			VGA_R <= red;
			VGA_B <= blue;
			VGA_G <= green;
		end else begin
			VGA_R <= 4'd0;
			VGA_B <= 4'd0;
			VGA_G <= 4'd0;
		end
		VGA_HS <= h_sync;
		VGA_VS <= v_sync;
	end

	// Instantiate PLL to convert the 50 MHz clock to a 25 MHz clock for timing.
	pll vgapll_inst (
		 .inclk0    (MAX10_CLK1_50),
		 .c0        (vga_clk)
		 );

	// Instantite VGA controller
	vga_controller control (
		.pixel_clk  (vga_clk),
		.reset_n    (~rst),
		.h_sync     (h_sync),
		.v_sync     (v_sync),
		.disp_ena   (disp_ena),
		.column     (col),
		.row        (row)
		);

endmodule