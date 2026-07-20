`timescale 1ns / 1ps

module ISR_CONTROL_TB;

    parameter ADDR_WIDTH = 16;
    parameter INT_LINES_WIDTH = 8;
    parameter CLK_PERIOD = 20;

    reg clk;
    reg rst;
    reg halt;

    reg [ADDR_WIDTH-1:0] PCOut;
    reg [INT_LINES_WIDTH-1:0] interrupts;

    wire [ADDR_WIDTH-1:0] INT_RET_REG;
    wire [ADDR_WIDTH-1:0] ISRVector;
    wire ISRJumpControl;

    integer tests_run;
    integer tests_failed;

    ISR_CONTROL #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .INT_LINES_WIDTH(INT_LINES_WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .halt(halt),
        .PCOut(PCOut),
        .interrupts(interrupts),
        .INT_RET_REG(INT_RET_REG),
        .ISRVector(ISRVector),
        .ISRJumpControl(ISRJumpControl)
    );

    /*
     * 50 MHz clock.
     */
    initial begin
        clk = 1'b0;

        forever begin
            #(CLK_PERIOD / 2);
            clk = ~clk;
        end
    end

    /*
     * Verify the combinational interrupt-control outputs.
     */
    task check_isr_output;
        input expected_jump;
        input [ADDR_WIDTH-1:0] expected_vector;
        input integer test_number;

        begin
            tests_run = tests_run + 1;

            #1;

            if ((ISRJumpControl !== expected_jump) ||
                (ISRVector !== expected_vector)) begin

                tests_failed = tests_failed + 1;

                $display(
                    "FAIL - Test %0d: jump expected %b actual %b, vector expected 0x%0h actual 0x%0h",
                    test_number,
                    expected_jump,
                    ISRJumpControl,
                    expected_vector,
                    ISRVector
                );
            end
            else begin
                $display(
                    "PASS - Test %0d: jump = %b, vector = 0x%0h",
                    test_number,
                    ISRJumpControl,
                    ISRVector
                );
            end
        end
    endtask

    /*
     * Verify the stored interrupt return address.
     */
    task check_return_register;
        input [ADDR_WIDTH-1:0] expected;
        input integer test_number;

        begin
            tests_run = tests_run + 1;

            #1;

            if (INT_RET_REG !== expected) begin
                tests_failed = tests_failed + 1;

                $display(
                    "FAIL - Test %0d: expected INT_RET_REG = 0x%0h, actual = 0x%0h",
                    test_number,
                    expected,
                    INT_RET_REG
                );
            end
            else begin
                $display(
                    "PASS - Test %0d: INT_RET_REG = 0x%0h",
                    test_number,
                    INT_RET_REG
                );
            end
        end
    endtask

    /*
     * Apply an interrupt before a rising clock edge so it is sampled
     * into pending_interrupts.
     */
    task sample_interrupt;
        input [INT_LINES_WIDTH-1:0] interrupt_value;

        begin
            @(negedge clk);
            interrupts = interrupt_value;

            @(posedge clk);
            #1;
        end
    endtask

    /*
     * Remove the external interrupt and allow pending_interrupts to
     * update on the next clock edge.
     */
    task clear_interrupt;
        begin
            @(negedge clk);
            interrupts = {INT_LINES_WIDTH{1'b0}};

            @(posedge clk);
            #1;
        end
    endtask

    initial begin
        tests_run = 0;
        tests_failed = 0;

        rst = 1'b0;
        halt = 1'b0;
        PCOut = {ADDR_WIDTH{1'b0}};
        interrupts = {INT_LINES_WIDTH{1'b0}};

        $display("");
        $display("========================================");
        $display("ISR CONTROL TESTBENCH");
        $display("========================================");

        /*
         * Test 1:
         * Reset pending interrupts and return register.
         */
        @(negedge clk);

        rst = 1'b1;
        interrupts = 8'hFF;
        PCOut = 16'hAAAA;

        @(posedge clk);
        #1;

        check_isr_output(
            1'b0,
            16'h0100,
            1
        );

        /*
         * With no pending interrupt, ISRControl defaults to zero, so
         * ISRVector points at vector-table entry zero even though the
         * jump-control output is low.
         */
        check_return_register(
            16'h0000,
            2
        );

        @(negedge clk);
        rst = 1'b0;
        interrupts = 8'h00;

        /*
         * Test 3:
         * No interrupt remains inactive.
         */
        @(posedge clk);
        #1;

        check_isr_output(
            1'b0,
            16'h0100,
            3
        );

        /*
         * Tests 4-11:
         * Verify each individual interrupt vector.
         */

        sample_interrupt(8'b00000001);
        check_isr_output(1'b1, 16'h0100, 4);
        clear_interrupt;

        sample_interrupt(8'b00000010);
        check_isr_output(1'b1, 16'h0200, 5);
        clear_interrupt;

        sample_interrupt(8'b00000100);
        check_isr_output(1'b1, 16'h0300, 6);
        clear_interrupt;

        sample_interrupt(8'b00001000);
        check_isr_output(1'b1, 16'h0400, 7);
        clear_interrupt;

        sample_interrupt(8'b00010000);
        check_isr_output(1'b1, 16'h0500, 8);
        clear_interrupt;

        sample_interrupt(8'b00100000);
        check_isr_output(1'b1, 16'h0600, 9);
        clear_interrupt;

        sample_interrupt(8'b01000000);
        check_isr_output(1'b1, 16'h0700, 10);
        clear_interrupt;

        sample_interrupt(8'b10000000);
        check_isr_output(1'b1, 16'h0800, 11);
        clear_interrupt;

        /*
         * Test 12:
         * INT0 has highest priority when every interrupt is pending.
         */
        sample_interrupt(8'b11111111);

        check_isr_output(
            1'b1,
            16'h0100,
            12
        );

        clear_interrupt;

        /*
         * Test 13:
         * Of INT2, INT4, and INT7, INT2 has highest priority.
         */
        sample_interrupt(8'b10010100);

        check_isr_output(
            1'b1,
            16'h0300,
            13
        );

        clear_interrupt;

        /*
         * Test 14:
         * Of INT3 and INT6, INT3 has highest priority.
         */
        sample_interrupt(8'b01001000);

        check_isr_output(
            1'b1,
            16'h0400,
            14
        );

        clear_interrupt;

        /*
         * Test 15:
         * Save PCOut while servicing an interrupt.
         *
         * First edge samples INT5.
         */
        @(negedge clk);

        PCOut = 16'h1234;
        interrupts = 8'b00100000;

        @(posedge clk);
        #1;

        check_isr_output(
            1'b1,
            16'h0600,
            15
        );

        /*
         * Test 16:
         * On the following rising edge, ISRJumpControl was already
         * high, so INT_RET_REG captures PCOut.
         *
         * The interrupt line is removed before this edge. The old
         * pending value still drives ISRJumpControl during the edge.
         */
        @(negedge clk);

        interrupts = 8'h00;
        PCOut = 16'h1234;

        @(posedge clk);
        #1;

        check_return_register(
            16'h1234,
            16
        );

        /*
         * After the edge, pending_interrupts has become zero.
         */
        check_isr_output(
            1'b0,
            16'h0100,
            17
        );

        /*
         * Test 18:
         * A new interrupt captures a new return address.
         */
        @(negedge clk);

        PCOut = 16'hBEEF;
        interrupts = 8'b00000100;

        @(posedge clk);
        #1;

        check_isr_output(
            1'b1,
            16'h0300,
            18
        );

        @(negedge clk);

        interrupts = 8'h00;

        @(posedge clk);
        #1;

        check_return_register(
            16'hBEEF,
            19
        );

        /*
         * Test 20:
         * halt prevents new interrupt lines from being sampled.
         */
        clear_interrupt;

        @(negedge clk);

        halt = 1'b1;
        interrupts = 8'b00000010;
        PCOut = 16'h5555;

        @(posedge clk);
        #1;

        check_isr_output(
            1'b0,
            16'h0100,
            20
        );

        /*
         * Test 21:
         * INT_RET_REG also holds while halted.
         */
        check_return_register(
            16'hBEEF,
            21
        );

        /*
         * Test 22:
         * Once halt is removed, the interrupt is sampled.
         */
        @(negedge clk);

        halt = 1'b0;

        @(posedge clk);
        #1;

        check_isr_output(
            1'b1,
            16'h0200,
            22
        );

        /*
         * Test 23:
         * The return register captures after the interrupt becomes
         * pending.
         */
        @(negedge clk);

        interrupts = 8'h00;
        PCOut = 16'h5555;

        @(posedge clk);
        #1;

        check_return_register(
            16'h5555,
            23
        );

        /*
         * Test 24:
         * Reset overrides an interrupt and clears the return register.
         */
        @(negedge clk);

        rst = 1'b1;
        interrupts = 8'b10000000;
        PCOut = 16'hFFFF;

        @(posedge clk);
        #1;

        check_isr_output(
            1'b0,
            16'h0100,
            24
        );

        check_return_register(
            16'h0000,
            25
        );

        /*
         * Test 26:
         * Reset still clears state while halt is asserted.
         */
        @(negedge clk);

        halt = 1'b1;
        rst = 1'b1;
        interrupts = 8'hFF;
        PCOut = 16'hAAAA;

        @(posedge clk);
        #1;

        check_isr_output(
            1'b0,
            16'h0100,
            26
        );

        check_return_register(
            16'h0000,
            27
        );

        @(negedge clk);

        rst = 1'b0;
        halt = 1'b0;
        interrupts = 8'h00;

        $display("");
        $display("========================================");
        $display("TEST SUMMARY");
        $display("Tests run:    %0d", tests_run);
        $display("Tests passed: %0d", tests_run - tests_failed);
        $display("Tests failed: %0d", tests_failed);
        $display("========================================");

        if (tests_failed == 0) begin
            $display("RESULT: ALL TESTS PASSED");
        end
        else begin
            $display("RESULT: TEST FAILURE");
        end

        $finish;
    end

endmodule