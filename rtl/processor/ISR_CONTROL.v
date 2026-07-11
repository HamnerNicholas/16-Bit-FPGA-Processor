module ISR_CONTROL #(
    parameter ADDR_WIDTH = 16,
    parameter INT_LINES_WIDTH = 8
)(
    input clk,
    input rst,
    input halt,

    // databus inputs
    input [ADDR_WIDTH - 1 : 0] PCOut,
    input [INT_LINES_WIDTH - 1 : 0] interrupts,

    // databus outputs
    output reg [ADDR_WIDTH - 1 : 0] INT_RET_REG,
    output [ADDR_WIDTH - 1 : 0] ISRVector,
    output reg ISRJumpControl
);

    wire cpu_enable = !halt;

    reg [INT_LINES_WIDTH - 1 : 0] pending_interrupts;
    reg [2 : 0] ISRControl;

    // Re-sample interrupt lines every clock cycle
    always @(posedge clk) begin
        if (rst)
            pending_interrupts <= {INT_LINES_WIDTH{1'b0}};
        else if (cpu_enable)
            pending_interrupts <= interrupts;
    end

    // Priority encoder
    always @(*) begin
        ISRJumpControl = 1'b0;
        ISRControl = 3'd0;

        if (pending_interrupts[0]) begin
            ISRJumpControl = 1'b1;
            ISRControl = 3'd0;
        end else if (pending_interrupts[1]) begin
            ISRJumpControl = 1'b1;
            ISRControl = 3'd1;
        end else if (pending_interrupts[2]) begin
            ISRJumpControl = 1'b1;
            ISRControl = 3'd2;
        end else if (pending_interrupts[3]) begin
            ISRJumpControl = 1'b1;
            ISRControl = 3'd3;
        end else if (pending_interrupts[4]) begin
            ISRJumpControl = 1'b1;
            ISRControl = 3'd4;
        end else if (pending_interrupts[5]) begin
            ISRJumpControl = 1'b1;
            ISRControl = 3'd5;
        end else if (pending_interrupts[6]) begin
            ISRJumpControl = 1'b1;
            ISRControl = 3'd6;
        end else if (pending_interrupts[7]) begin
            ISRJumpControl = 1'b1;
            ISRControl = 3'd7;
        end
    end

    // Interrupt Vector Table
    reg [ADDR_WIDTH - 1 : 0] ISRVectorTable [0 : INT_LINES_WIDTH - 1];

    initial begin
        $readmemh("ivt.hex", ISRVectorTable);
    end

    assign ISRVector = ISRVectorTable[ISRControl];

    // Interrupt return register
    always @(posedge clk) begin
        if (rst)
            INT_RET_REG <= {ADDR_WIDTH{1'b0}};
        else if (cpu_enable && ISRJumpControl)
            INT_RET_REG <= PCOut;
    end

endmodule