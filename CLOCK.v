module CLOCK #(
	parameter WIDTH = 16
)(
	input external_clock,
	input halt,
	
	output clk
);
	assign clk = halt ? {{(WIDTH-1){1'b0}}, 1'b0} : external_clock; // if halt is high, hold at 0, else let external clock drive CPU
endmodule 