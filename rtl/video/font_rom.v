module font_rom (
    input [7:0] ascii_code, // 8-bit standard ASCII input character
    input [2:0] row_addr,   // 3-bit row slice coordinate (0 to 7)
    output reg [7:0] bit_row // 8-bit horizontal pixel row vector
);

    always @(*) begin
        case (ascii_code)
            // ==========================================
            // NUMBERS: 0 - 9
            // ==========================================
            8'h30: // '0'
                case(row_addr)
                    3'd0: bit_row = 8'b00111100;
                    3'd1: bit_row = 8'b01100110;
                    3'd2: bit_row = 8'b01101110;
                    3'd3: bit_row = 8'b01110110;
                    3'd4: bit_row = 8'b01100110;
                    3'd5: bit_row = 8'b01100110;
                    3'd6: bit_row = 8'b00111100;
                    default: bit_row = 8'b00000000;
                endcase
            8'h31: // '1'
                case(row_addr)
                    3'd0: bit_row = 8'b00011000;
                    3'd1: bit_row = 8'b00111000;
                    3'd2: bit_row = 8'b00011000;
                    3'd3: bit_row = 8'b00011000;
                    3'd4: bit_row = 8'b00011000;
                    3'd5: bit_row = 8'b00011000;
                    3'd6: bit_row = 8'b00111100;
                    default: bit_row = 8'b00000000;
                endcase
            8'h32: // '2'
                case(row_addr)
                    3'd0: bit_row = 8'b00111100;
                    3'd1: bit_row = 8'b01100110;
                    3'd2: bit_row = 8'b00000110;
                    3'd3: bit_row = 8'b00001100;
                    3'd4: bit_row = 8'b00011000;
                    3'd5: bit_row = 8'b00110000;
                    3'd6: bit_row = 8'b01111110;
                    default: bit_row = 8'b00000000;
                endcase
            8'h33: // '3'
                case(row_addr)
                    3'd0: bit_row = 8'b00111100;
                    3'd1: bit_row = 8'b01100110;
                    3'd2: bit_row = 8'b00000110;
                    3'd3: bit_row = 8'b00011100;
                    3'd4: bit_row = 8'b00000110;
                    3'd5: bit_row = 8'b01100110;
                    3'd6: bit_row = 8'b00111100;
                    default: bit_row = 8'b00000000;
                endcase
            8'h34: // '4'
                case(row_addr)
                    3'd0: bit_row = 8'b00001100;
                    3'd1: bit_row = 8'b00011100;
                    3'd2: bit_row = 8'b00101100;
                    3'd3: bit_row = 8'b01001100;
                    3'd4: bit_row = 8'b01111110;
                    3'd5: bit_row = 8'b00001100;
                    3'd6: bit_row = 8'b00001100;
                    default: bit_row = 8'b00000000;
                endcase
            8'h35: // '5'
                case(row_addr)
                    3'd0: bit_row = 8'b01111110;
                    3'd1: bit_row = 8'b01100000;
                    3'd2: bit_row = 8'b01111100;
                    3'd3: bit_row = 8'b00000110;
                    3'd4: bit_row = 8'b00000110;
                    3'd5: bit_row = 8'b01100110;
                    3'd6: bit_row = 8'b00111100;
                    default: bit_row = 8'b00000000;
                endcase
            8'h36: // '6'
                case(row_addr)
                    3'd0: bit_row = 8'b00111100;
                    3'd1: bit_row = 8'b01100000;
                    3'd2: bit_row = 8'b01111100;
                    3'd3: bit_row = 8'b01100110;
                    3'd4: bit_row = 8'b01100110;
                    3'd5: bit_row = 8'b01100110;
                    3'd6: bit_row = 8'b00111100;
                    default: bit_row = 8'b00000000;
                endcase
            8'h37: // '7'
                case(row_addr)
                    3'd0: bit_row = 8'b01111110;
                    3'd1: bit_row = 8'b00000110;
                    3'd2: bit_row = 8'b00001100;
                    3'd3: bit_row = 8'b00011000;
                    3'd4: bit_row = 8'b00110000;
                    3'd5: bit_row = 8'b00110000;
                    3'd6: bit_row = 8'b00110000;
                    default: bit_row = 8'b00000000;
                endcase
            8'h38: // '8'
                case(row_addr)
                    3'd0: bit_row = 8'b00111100;
                    3'd1: bit_row = 8'b01100110;
                    3'd2: bit_row = 8'b01100110;
                    3'd3: bit_row = 8'b00111100;
                    3'd4: bit_row = 8'b01100110;
                    3'd5: bit_row = 8'b01100110;
                    3'd6: bit_row = 8'b00111100;
                    default: bit_row = 8'b00000000;
                endcase
            8'h39: // '9'
                case(row_addr)
                    3'd0: bit_row = 8'b00111100;
                    3'd1: bit_row = 8'b01100110;
                    3'd2: bit_row = 8'b01100110;
                    3'd3: bit_row = 8'b00111110;
                    3'd4: bit_row = 8'b00000110;
                    3'd5: bit_row = 8'b01100110;
                    3'd6: bit_row = 8'b00111100;
                    default: bit_row = 8'b00000000;
                endcase

            // ==========================================
            // LETTERS: A - Z
            // ==========================================
            8'h41: // 'A'
                case(row_addr)
                    3'd0: bit_row = 8'b00011000;
                    3'd1: bit_row = 8'b00100100;
                    3'd2: bit_row = 8'b01000010;
                    3'd3: bit_row = 8'b01111110;
                    3'd4: bit_row = 8'b01000010;
                    3'd5: bit_row = 8'b01000010;
                    3'd6: bit_row = 8'b01000010;
                    default: bit_row = 8'b00000000;
                endcase
            8'h42: // 'B'
                case(row_addr)
                    3'd0: bit_row = 8'b01111100;
                    3'd1: bit_row = 8'b01000010;
                    3'd2: bit_row = 8'b01000010;
                    3'd3: bit_row = 8'b01111100;
                    3'd4: bit_row = 8'b01000010;
                    3'd5: bit_row = 8'b01000010;
                    3'd6: bit_row = 8'b01111100;
                    default: bit_row = 8'b00000000;
                endcase
            8'h43: // 'C'
                case(row_addr)
                    3'd0: bit_row = 8'b00111100;
                    3'd1: bit_row = 8'b01100110;
                    3'd2: bit_row = 8'b01000000;
                    3'd3: bit_row = 8'b01000000;
                    3'd4: bit_row = 8'b01000000;
                    3'd5: bit_row = 8'b01100110;
                    3'd6: bit_row = 8'b00111100;
                    default: bit_row = 8'b00000000;
                endcase
            8'h44: // 'D'
                case(row_addr)
                    3'd0: bit_row = 8'b01111000;
                    3'd1: bit_row = 8'b01001100;
                    3'd2: bit_row = 8'b01000110;
                    3'd3: bit_row = 8'b01000110;
                    3'd4: bit_row = 8'b01000110;
                    3'd5: bit_row = 8'b01001100;
                    3'd6: bit_row = 8'b01111000;
                    default: bit_row = 8'b00000000;
                endcase
            8'h45: // 'E'
                case(row_addr)
                    3'd0: bit_row = 8'b01111110;
                    3'd1: bit_row = 8'b01000000;
                    3'd2: bit_row = 8'b01000000;
                    3'd3: bit_row = 8'b01111100;
                    3'd4: bit_row = 8'b01000000;
                    3'd5: bit_row = 8'b01000000;
                    3'd6: bit_row = 8'b01111110;
                    default: bit_row = 8'b00000000;
                endcase
            8'h46: // 'F'
                case(row_addr)
                    3'd0: bit_row = 8'b01111110;
                    3'd1: bit_row = 8'b01000000;
                    3'd2: bit_row = 8'b01000000;
                    3'd3: bit_row = 8'b01111100;
                    3'd4: bit_row = 8'b01000000;
                    3'd5: bit_row = 8'b01000000;
                    3'd6: bit_row = 8'b01000000;
                    default: bit_row = 8'b00000000;
                endcase
            8'h47: // 'G'
                case(row_addr)
                    3'd0: bit_row = 8'b00111100;
                    3'd1: bit_row = 8'b01100110;
                    3'd2: bit_row = 8'b01000000;
                    3'd3: bit_row = 8'b01001110;
                    3'd4: bit_row = 8'b01000110;
                    3'd5: bit_row = 8'b01100110;
                    3'd6: bit_row = 8'b00111110;
                    default: bit_row = 8'b00000000;
                endcase
            8'h48: // 'H'
                case(row_addr)
                    3'd0: bit_row = 8'b01000010;
                    3'd1: bit_row = 8'b01000010;
                    3'd2: bit_row = 8'b01000010;
                    3'd3: bit_row = 8'b01111110;
                    3'd4: bit_row = 8'b01000010;
                    3'd5: bit_row = 8'b01000010;
                    3'd6: bit_row = 8'b01000010;
                    default: bit_row = 8'b00000000;
                endcase
            8'h49: // 'I'
                case(row_addr)
                    3'd0: bit_row = 8'b00111100;
                    3'd1: bit_row = 8'b00011000;
                    3'd2: bit_row = 8'b00011000;
                    3'd3: bit_row = 8'b00011000;
                    3'd4: bit_row = 8'b00011000;
                    3'd5: bit_row = 8'b00011000;
                    3'd6: bit_row = 8'b00111100;
                    default: bit_row = 8'b00000000;
                endcase
				8'h4A: // 'J'
                case(row_addr)
                    3'd0: bit_row = 8'b00001110;
                    3'd1: bit_row = 8'b00000100;
                    3'd2: bit_row = 8'b00000100;
                    3'd3: bit_row = 8'b00000100;
                    3'd4: bit_row = 8'b01000100;
                    3'd5: bit_row = 8'b01100100;
                    3'd6: bit_row = 8'b00111000;
                    default: bit_row = 8'b00000000;
                endcase
            8'h4B: // 'K'
                case(row_addr)
                    3'd0: bit_row = 8'b01000110;
                    3'd1: bit_row = 8'b01001100;
                    3'd2: bit_row = 8'b01011000;
                    3'd3: bit_row = 8'b01110000;
                    3'd4: bit_row = 8'b01011000;
                    3'd5: bit_row = 8'b01001100;
                    3'd6: bit_row = 8'b01000110;
                    default: bit_row = 8'b00000000;
                endcase
            8'h4C: // 'L'
                case(row_addr)
                    3'd0: bit_row = 8'b01000000;
                    3'd1: bit_row = 8'b01000000;
                    3'd2: bit_row = 8'b01000000;
                    3'd3: bit_row = 8'b01000000;
                    3'd4: bit_row = 8'b01000000;
                    3'd5: bit_row = 8'b01000000;
                    3'd6: bit_row = 8'b01111110;
                    default: bit_row = 8'b00000000;
                endcase
            8'h4D: // 'M'
                case(row_addr)
                    3'd0: bit_row = 8'b01000010;
                    3'd1: bit_row = 8'b01100110;
                    3'd2: bit_row = 8'b01011010;
                    3'd3: bit_row = 8'b01000010;
                    3'd4: bit_row = 8'b01000010;
                    3'd5: bit_row = 8'b01000010;
                    3'd6: bit_row = 8'b01000010;
                    default: bit_row = 8'b00000000;
                endcase
            8'h4E: // 'N'
                case(row_addr)
                    3'd0: bit_row = 8'b01000010;
                    3'd1: bit_row = 8'b01100010;
                    3'd2: bit_row = 8'b01010010;
                    3'd3: bit_row = 8'b01001010;
                    3'd4: bit_row = 8'b01000110;
                    3'd5: bit_row = 8'b01000010;
                    3'd6: bit_row = 8'b01000010;
                    default: bit_row = 8'b00000000;
                endcase
            8'h4F: // 'O'
                case(row_addr)
                    3'd0: bit_row = 8'b00111100;
                    3'd1: bit_row = 8'b01100110;
                    3'd2: bit_row = 8'b01000010;
                    3'd3: bit_row = 8'b01000010;
                    3'd4: bit_row = 8'b01000010;
                    3'd5: bit_row = 8'b01100110;
                    3'd6: bit_row = 8'b00111100;
                    default: bit_row = 8'b00000000;
                endcase
            8'h50: // 'P'
                case(row_addr)
                    3'd0: bit_row = 8'b01111100;
                    3'd1: bit_row = 8'b01000010;
                    3'd2: bit_row = 8'b01000010;
                    3'd3: bit_row = 8'b01111100;
                    3'd4: bit_row = 8'b01000000;
                    3'd5: bit_row = 8'b01000000;
                    3'd6: bit_row = 8'b01000000;
                    default: bit_row = 8'b00000000;
                endcase
            8'h51: // 'Q'
                case(row_addr)
                    3'd0: bit_row = 8'b00111100;
                    3'd1: bit_row = 8'b01100110;
                    3'd2: bit_row = 8'b01000010;
                    3'd3: bit_row = 8'b01000010;
                    3'd4: bit_row = 8'b01001010;
                    3'd5: bit_row = 8'b01100100;
                    3'd6: bit_row = 8'b00111010;
                    default: bit_row = 8'b00000000;
                endcase
            8'h52: // 'R'
                case(row_addr)
                    3'd0: bit_row = 8'b01111100;
                    3'd1: bit_row = 8'b01000010;
                    3'd2: bit_row = 8'b01000010;
                    3'd3: bit_row = 8'b01111100;
                    3'd4: bit_row = 8'b01001000;
                    3'd5: bit_row = 8'b01000100;
                    3'd6: bit_row = 8'b01000010;
                    default: bit_row = 8'b00000000;
                endcase
            8'h53: // 'S'
                case(row_addr)
                    3'd0: bit_row = 8'b00111100;
                    3'd1: bit_row = 8'b01100110;
                    3'd2: bit_row = 8'b01100000;
                    3'd3: bit_row = 8'b00111100;
                    3'd4: bit_row = 8'b00000110;
                    3'd5: bit_row = 8'b01100110;
                    3'd6: bit_row = 8'b00111100;
                    default: bit_row = 8'b00000000;
                endcase
            8'h54: // 'T'
                case(row_addr)
                    3'd0: bit_row = 8'b01111110;
                    3'd1: bit_row = 8'b00011000;
                    3'd2: bit_row = 8'b00011000;
                    3'd3: bit_row = 8'b00011000;
                    3'd4: bit_row = 8'b00011000;
                    3'd5: bit_row = 8'b00011000;
                    3'd6: bit_row = 8'b00011000;
                    default: bit_row = 8'b00000000;
                endcase
            8'h55: // 'U'
                case(row_addr)
                    3'd0: bit_row = 8'b01000010;
                    3'd1: bit_row = 8'b01000010;
                    3'd2: bit_row = 8'b01000010;
                    3'd3: bit_row = 8'b01000010;
                    3'd4: bit_row = 8'b01000010;
                    3'd5: bit_row = 8'b01100110;
                    3'd6: bit_row = 8'b00111100;
                    default: bit_row = 8'b00000000;
                endcase
            8'h56: // 'V'
                case(row_addr)
                    3'd0: bit_row = 8'b01000010;
                    3'd1: bit_row = 8'b01000010;
                    3'd2: bit_row = 8'b01000010;
                    3'd3: bit_row = 8'b01000010;
                    3'd4: bit_row = 8'b00100100;
                    3'd5: bit_row = 8'b00011000;
                    3'd6: bit_row = 8'b00000000;
                    default: bit_row = 8'b00000000;
                endcase
            8'h57: // 'W'
                case(row_addr)
                    3'd0: bit_row = 8'b01000010;
                    3'd1: bit_row = 8'b01000010;
                    3'd2: bit_row = 8'b01000010;
                    3'd3: bit_row = 8'b01011010;
                    3'd4: bit_row = 8'b01100110;
                    3'd5: bit_row = 8'b01000010;
                    3'd6: bit_row = 8'b01000010;
                    default: bit_row = 8'b00000000;
                endcase
            8'h58: // 'X'
                case(row_addr)
                    3'd0: bit_row = 8'b01000010;
                    3'd1: bit_row = 8'b01100110;
                    3'd2: bit_row = 8'b00111100;
                    3'd3: bit_row = 8'b00011000;
                    3'd4: bit_row = 8'b00111100;
                    3'd5: bit_row = 8'b01100110;
                    3'd6: bit_row = 8'b01000010;
                    default: bit_row = 8'b00000000;
                endcase
            8'h59: // 'Y'
                case(row_addr)
                    3'd0: bit_row = 8'b01000010;
                    3'd1: bit_row = 8'b01100110;
                    3'd2: bit_row = 8'b00111100;
                    3'd3: bit_row = 8'b00011000;
                    3'd4: bit_row = 8'b00011000;
                    3'd5: bit_row = 8'b00011000;
                    3'd6: bit_row = 8'b00011000;
                    default: bit_row = 8'b00000000;
                endcase
            8'h5A: // 'Z'
                case(row_addr)
                    3'd0: bit_row = 8'b01111110;
                    3'd1: bit_row = 8'b00000100;
                    3'd2: bit_row = 8'b00001000;
                    3'd3: bit_row = 8'b00011000;
                    3'd4: bit_row = 8'b00100000;
                    3'd5: bit_row = 8'b01000000;
                    3'd6: bit_row = 8'b01111110;
                    default: bit_row = 8'b00000000;
                endcase
            8'h20: // Space (' ')
                case(row_addr)
                    default: bit_row = 8'b00000000;
                endcase
				endcase
			end
endmodule 
