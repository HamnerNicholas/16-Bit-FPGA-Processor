module video_vram (
    input cpu_clk,       // Keeps your CPU synchronization
    input clk_50mhz,     // NEW: Connect to MAX10_CLK1_50 for absolute precision edge detection
    input rst,
    input halt,
    input ttyLoad,   
    input ttyALoad,  
    input [7:0] cpu_imm,
    input [7:0] cpu_acc,
    
    input vga_clk,
    input [7:0] vga_read_addr, 
    output reg [7:0] vga_char_out
);

    reg [7:0] ram [255:0];
    reg [7:0] write_ptr; 
    
    // 1. Shift the edge detection pipeline onto the fast 50MHz master board clock
    reg ttyLoad_sync0, ttyLoad_sync1;
    reg ttyALoad_sync0, ttyALoad_sync1;
    
    always @(posedge clk_50mhz or posedge rst) begin
        if (rst) begin
            ttyLoad_sync0  <= 1'b0;
            ttyLoad_sync1  <= 1'b0;
            ttyALoad_sync0 <= 1'b0;
            ttyALoad_sync1 <= 1'b0;
        end else begin
            ttyLoad_sync0  <= ttyLoad;
            ttyLoad_sync1  <= ttyLoad_sync0;
            ttyALoad_sync0 <= ttyALoad;
            ttyALoad_sync1 <= ttyALoad_sync0;
        end
    end
    
    // This creates an absolute 1-cycle spike at 50MHz, completely ignoring 
    // how long or short the slow cpu_clk cycle holds the original signal wire.
    wire ttyLoad_pulse  = ttyLoad_sync0  && !ttyLoad_sync1;
    wire ttyALoad_pulse = ttyALoad_sync0 && !ttyALoad_sync1;

    wire cpu_enable = !halt;
    integer i;

    // 2. Handle memory updates safely on the fast clock domain
    always @(posedge clk_50mhz or posedge rst) begin
        if (rst) begin
            write_ptr <= 8'd0;
            for (i = 0; i < 256; i = i + 1) begin
                ram[i] <= 8'h20; // Clear screen map to spaces
            end
        end else if (cpu_enable) begin
            if (ttyLoad_pulse) begin
                ram[write_ptr] <= cpu_imm;
                write_ptr      <= write_ptr + 1'b1;
            end 
            else if (ttyALoad_pulse) begin
                ram[write_ptr] <= cpu_acc;
                write_ptr      <= write_ptr + 1'b1;
            end
        end
    end

    // VGA continuous reading loop remains unchanged on its own clock domain
    always @(posedge vga_clk) begin
        vga_char_out <= ram[vga_read_addr];
    end

endmodule
