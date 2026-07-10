module IO_MODULE #(
    parameter DATA_WIDTH = 8
)(
    input clk,
    input rst,
    input halt,

    input ttyLoad,
    input ttyALoad,

    input [DATA_WIDTH-1:0] accOut,
    input [DATA_WIDTH-1:0] imm,

    output [6:0] HEX0,
    output [6:0] HEX1
);

    wire cpu_enable = !halt;

    reg [DATA_WIDTH-1:0] display_reg;

    always @(posedge clk) begin
        if (rst)
            display_reg <= {DATA_WIDTH{1'b0}};
        else if (cpu_enable && ttyLoad)
            display_reg <= imm;
        else if (cpu_enable && ttyALoad)
            display_reg <= accOut;
    end

    SEVEN_SEG hex_low (
        .nibble(display_reg[3:0]),
        .segments(HEX0)
    );

    SEVEN_SEG hex_high (
        .nibble(display_reg[7:4]),
        .segments(HEX1)
    );

endmodule