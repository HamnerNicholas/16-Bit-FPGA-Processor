module SEVEN_SEG(
    input [3:0] nibble,
    output reg [6:0] segments
);

    always @(*) begin
        case (nibble)
            4'h0: segments = 192;
            4'h1: segments = 249;
            4'h2: segments = 164;
            4'h3: segments = 176;
            4'h4: segments = 153;
            4'h5: segments = 146;
            4'h6: segments = 130;
            4'h7: segments = 248;
            4'h8: segments = 128;
            4'h9: segments = 144;
            4'hA: segments = 136;
            4'hB: segments = 131;
            4'hC: segments = 198;
            4'hD: segments = 161;
            4'hE: segments = 134;
            4'hF: segments = 142;
            default: segments = 7'b1111111;
        endcase
    end

endmodule