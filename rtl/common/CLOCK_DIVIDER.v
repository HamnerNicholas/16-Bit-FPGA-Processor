module CLOCK_DIVIDER #(
    parameter DIVIDER = 25_000_000
)(
    input clk,
    input rst,

    output reg slow_clk
);

    reg [31:0] counter;

    always @(posedge clk) begin
        if (rst) begin
            counter  <= 32'd0;
            slow_clk <= 1'b0;
        end
        else begin
            if (counter == DIVIDER - 1) begin
                counter  <= 32'd0;
                slow_clk <= ~slow_clk;
            end
            else begin
                counter <= counter + 1'b1;
            end
        end
    end

endmodule