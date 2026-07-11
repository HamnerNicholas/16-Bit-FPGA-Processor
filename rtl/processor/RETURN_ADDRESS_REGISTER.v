module RETURN_ADDRESS_REGISTER #(
	parameter WIDTH = 16
)(
	input clk,
	input halt,
	input rst,
	input RALoad,
	
	// databus inputs
	
	input [WIDTH - 1 : 0] PCOut,
	
	// databus outputs
	
	output [WIDTH - 1 : 0] RAOut
);

	wire cpu_enable = !halt;
	
	reg [WIDTH - 1 : 0] RA;
	
	always @(posedge clk) begin
		if(rst)
			RA <= {WIDTH{1'b0}};
		else if(cpu_enable && RALoad)
			RA <= PCOut;
	end
	
	assign RAOut = RA + {{(WIDTH-1){1'b0}}, 1'b1};
	
	
endmodule 