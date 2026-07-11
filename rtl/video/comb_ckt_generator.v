module comb_ckt_generator (
    input  vga_clk,
    input  cpu_clk,
	 input  clk_50mhz,
    input  rst,
    input  halt,
    input  ttyLoad,
    input  ttyALoad,
    input  [7:0] accOut,
    input  [7:0] imm,
    input  [9:0] col,
    input  [8:0] row,
    output [3:0] red,
    output [3:0] green,
    output [3:0] blue
);

    // Pipeline delay horizontal synchronization tuning
    wire [9:0] adj_col = col - 10'd12; 
    wire [8:0] adj_row = row;

    // Separate coordinates into active character tiles
    wire [6:0] tile_col = adj_col[9:3]; // 0 to 79 columns
    wire [5:0] tile_row = adj_row[8:3]; // 0 to 59 rows
    
    wire [2:0] pixel_x  = adj_col[2:0]; 
    wire [2:0] pixel_y  = adj_row[2:0];

    // Check if within the 32x8 console display text box limits
    wire is_inside_text_window = (tile_col < 7'd32) && (tile_row < 6'd8);

    // Generate flat 1D lookup grid reference: (tile_row * 32) + tile_col
    wire [7:0] vga_vram_addr = {tile_row[2:0], tile_col[4:0]};

    // Instantiate Sequential Stream Video RAM Block
    wire [7:0] active_ascii;
    video_vram vram_inst (
        .cpu_clk(cpu_clk),
		  .clk_50mhz(clk_50mhz),
        .rst(rst),
        .halt(halt),
        .ttyLoad(ttyLoad),
        .ttyALoad(ttyALoad),
        .cpu_imm(imm),
        .cpu_acc(accOut),
        
        .vga_clk(vga_clk),
        .vga_read_addr(vga_vram_addr),
        .vga_char_out(active_ascii)
    );

    // Font Library Generator ROM
    wire [7:0] font_byte;
    font_rom font_unit (
        .ascii_code(active_ascii),
        .row_addr(pixel_y),
        .bit_row(font_byte)
    );

    // Target individual bit parsing logic
    wire pixel_on = font_byte[3'd7 - pixel_x] && is_inside_text_window;

    // Route final signals (White Text on Slate Blue Background Profile)
    assign red   = pixel_on ? 4'hF : 4'h1;
    assign green = pixel_on ? 4'hF : 4'h1;
    assign blue  = pixel_on ? 4'hF : 4'h4;

endmodule