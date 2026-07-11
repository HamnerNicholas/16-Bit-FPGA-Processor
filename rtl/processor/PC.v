module PC #(
	parameter WIDTH = 16,
	parameter ADDR_WIDTH = 16,
	parameter IMM_WIDTH = 8,
	parameter SUBOP_WIDTH = 2
)(
	input clk,
	input rst,
	input halt,
	input RINT,
	input RAReturn,
	input RALoad,
	input ISRJumpControl,
	input beq,
	
	// databus inputs
	input [WIDTH - 1 : 0] INT_RET_REG,
	input [WIDTH - 1 : 0] ISR_VECTOR,
	input [WIDTH - 1 : 0] RAOut,
	input [IMM_WIDTH - 1 : 0] regOut,
	input [IMM_WIDTH - 1 : 0] accOut,	
	input [IMM_WIDTH - 1 : 0] imm,
	input [SUBOP_WIDTH - 1 : 0] SubopField,
	
	// output databus
	output [WIDTH - 1 : 0] PCOut
);
	wire cpu_enable = !halt;

	// comparisons 
	wire reg_acc_equal = (regOut == accOut);
	wire reg_acc_not_equal = (regOut != accOut);
	wire reg_less_acc = ($signed(regOut) < $signed(accOut));
	
	wire subop_3 = (SubopField == 3); // check if doing unconditional jump
	
	reg mux1;
	
	always @(*) begin
		case(SubopField) // first mux
			2'b00 : mux1 = reg_acc_equal;
			2'b01 : mux1 = reg_acc_not_equal;
			2'b10 : mux1 = reg_less_acc;
			2'b11: mux1 = 1'b0;
         default: mux1 = 1'b0;
		endcase
	end
	
	// chooses to load if three conditions: RA load, branch is taken, unconditional jump in order
	wire second_mux_control = RALoad | (mux1 && beq) | (subop_3 && beq);
	
	
	wire [WIDTH - 1 : 0] signExtImm = {{(WIDTH-IMM_WIDTH){imm[IMM_WIDTH-1]}}, imm};// extended sign
	
	wire [WIDTH - 1 : 0] mux2 = second_mux_control ? signExtImm : {{(WIDTH-1){1'b0}}, 1'b1};
	
	// adding current PC to either 1 or imm
	
	reg [WIDTH-1:0] PC;

	wire [WIDTH-1:0] third_mux_input_zero = PC + mux2;
	
	// third mux
	
	wire [1 : 0] third_mux_control;
	
	reg [WIDTH - 1 : 0] third_mux;
	
	assign third_mux_control[0] = RAReturn;
	assign third_mux_control[1] = ISRJumpControl;
	
	always @(*) begin
		case(third_mux_control) 
			2'b00 : third_mux = third_mux_input_zero;
			2'b01 : third_mux = RAOut;
			2'b10 : third_mux = ISR_VECTOR;
			2'b11: third_mux = 1'b0;
         default: third_mux = 1'b0;
		endcase
	end
	
	wire [WIDTH - 1 : 0] mux4 = RINT ? INT_RET_REG : third_mux;
	
	always @(posedge clk) begin
		if(rst)
			PC <= {WIDTH{1'b0}};
		else if(cpu_enable)
			PC <= mux4;
	end
	
	assign PCOut = PC;


endmodule 
