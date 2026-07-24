module graphics_vram (
    input  cpu_clk,
    input  rst,
    input  halt,

    input        gfxDraw,
    input  [7:0] gfxX,
    input  [7:0] gfxY,
    input  [7:0] gfxColor,

    input        vga_clk,
    input  [6:0] vga_x,
    input  [5:0] vga_y,

    output reg [7:0] vga_pixel_color
);

    localparam SCREEN_WIDTH  = 80;
    localparam SCREEN_HEIGHT = 60;
    localparam DEPTH         = SCREEN_WIDTH * SCREEN_HEIGHT;

    reg [7:0] ram [0:DEPTH-1];

    wire cpu_enable = !halt;

    wire [12:0] cpu_y_extended = {5'd0, gfxY};
    wire [12:0] cpu_x_extended = {5'd0, gfxX};

    wire [12:0] vga_y_extended = {7'd0, vga_y};
    wire [12:0] vga_x_extended = {6'd0, vga_x};

    wire [12:0] cpu_write_addr =
        (cpu_y_extended << 6) +
        (cpu_y_extended << 4) +
        cpu_x_extended;

    wire [12:0] vga_read_addr =
        (vga_y_extended << 6) +
        (vga_y_extended << 4) +
        vga_x_extended;

    always @(posedge cpu_clk) begin
        if (
            cpu_enable &&
            gfxDraw &&
            gfxX < 8'd80 &&
            gfxY < 8'd60
        ) begin
            ram[cpu_write_addr] <= gfxColor;
        end
    end

    always @(posedge vga_clk) begin
        vga_pixel_color <= ram[vga_read_addr];
    end

endmodule