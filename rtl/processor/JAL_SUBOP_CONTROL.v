module JAL_SUBOP_CONTROL #(
	parameter SUBOP_WIDTH = 2
)(
	input jal,
	
	// databus inputs
	input [SUBOP_WIDTH - 1 : 0] SubopField,
	
	output RALoad,
	output RAReturn,
	output LoadJalRegisters,
	output ReadJalRegisters
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
	
	assign RALoad = jal & decoder_out[0];
	assign RAReturn = jal & decoder_out[1];
	assign LoadJalRegisters = jal & decoder_out[2];
	assign ReadJalRegisters = jal & decoder_out[3];

endmodule 