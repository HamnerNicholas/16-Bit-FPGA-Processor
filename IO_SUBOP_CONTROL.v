module IO_SUBOP_CONTROL #(
	parameter SUBOP_WIDTH = 2
)(
	input tty,
	
	// databus inputs
	input [SUBOP_WIDTH - 1 : 0] SubopField,
	
	output ttyLoad,
	output ttyALoad,
	output halt
);

	reg [3 : 0] decoder_out;

	always @(*) begin
		case(SubopField)
			2'b00 : decoder_out = 4'b0001;
			2'b01 : decoder_out = 4'b0010;
			2'b10 : decoder_out = 4'b0100;
			2'b11 : decoder_out = 4'b1000;
			default: decoder_out = 4'b0000;
		endcase
	end
	
	assign ttyLoad = tty & decoder_out[0];
	assign ttyALoad = tty & decoder_out[1];
	assign halt = tty & decoder_out[2];

endmodule 