module IO_MEMORY #(
    parameter WIDTH = 8,
    parameter ADDR_WIDTH = 8
)(
    input clk,
    input halt,
    input rst,
    input storeIO,

    // Databus inputs
    input [ADDR_WIDTH - 1:0] imm,
    input [WIDTH - 1:0] accOut,

    // Databus output
    output [WIDTH - 1:0] ioOut,

    // VGA control registers
    output [WIDTH - 1:0] gfxX,
    output [WIDTH - 1:0] gfxY,
    output [WIDTH - 1:0] gfxColor,
    output reg             gfxDraw
);

    localparam [ADDR_WIDTH - 1:0] GFX_X_ADDR =
        8'h10;

    localparam [ADDR_WIDTH - 1:0] GFX_Y_ADDR =
        8'h11;

    localparam [ADDR_WIDTH - 1:0] GFX_COLOR_ADDR =
        8'h12;

    localparam [ADDR_WIDTH - 1:0] GFX_DRAW_ADDR =
        8'h13;

    wire cpu_enable = !halt;

    reg [WIDTH - 1:0] io_mem
        [0:(1 << ADDR_WIDTH) - 1];

    always @(posedge clk) begin
        if (rst) begin
            gfxDraw <= 1'b0;
        end
        else begin
            // Draw is a one-clock pulse rather than a stored state.
            gfxDraw <= 1'b0;

            if (cpu_enable && storeIO) begin
                io_mem[imm] <= accOut;

                if (
                    (imm == GFX_DRAW_ADDR) &&
                    (accOut != {WIDTH{1'b0}})
                ) begin
                    gfxDraw <= 1'b1;
                end
            end
        end
    end

    assign ioOut = io_mem[imm];

    assign gfxX =
        io_mem[GFX_X_ADDR];

    assign gfxY =
        io_mem[GFX_Y_ADDR];

    assign gfxColor =
        io_mem[GFX_COLOR_ADDR];

endmodule