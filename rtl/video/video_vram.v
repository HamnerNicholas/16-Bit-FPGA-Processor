module video_vram (
    input  cpu_clk,          // Used to clock CPU data smoothly
    input  clk_50mhz,        // Left in port list so you don't change instantiation
    input  rst,
    input  halt,
    input  ttyLoad,
    input  ttyALoad,
    input  [7:0] cpu_imm,
    input  [7:0] cpu_acc,
    input  vga_clk,
    input  [7:0] vga_read_addr,
    output reg [7:0] vga_char_out
);

    // Dual-port Block RAM storage
    reg [7:0] ram [255:0];
    reg [7:0] write_ptr;

    wire cpu_enable = !halt;
    integer i;

    // Memory Writing Loop (Synchronous to CPU clock instructions)
    // This catches every distinct instruction cycle, even if ttyLoad stays high.
    always @(posedge cpu_clk or posedge rst) begin
        if (rst) begin
            write_ptr <= 8'd0;
            for (i = 0; i < 256; i = i + 1) begin
                ram[i] <= 8'h20; // Clear screen to space characters
            end
        end else if (cpu_enable) begin
            if (ttyLoad) begin
                ram[write_ptr] <= cpu_imm;
                write_ptr      <= write_ptr + 1'b1;
            end else if (ttyALoad) begin
                ram[write_ptr] <= cpu_acc;
                write_ptr      <= write_ptr + 1'b1;
            end
        end
    end

    // VGA Reading Loop (VGA Clock Domain)
    // Read operations remain completely safe and independent
    always @(posedge vga_clk) begin
        vga_char_out <= ram[vga_read_addr];
    end

endmodule
