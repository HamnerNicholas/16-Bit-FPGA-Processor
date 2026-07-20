`timescale 1ns / 1ps

module REGISTER_FILE_TB;

    parameter REG_WIDTH = 8;
    parameter REG_COUNT = 8;
    parameter REG_ADDR_WIDTH = 3;
    parameter CLK_PERIOD = 20;

    reg rst;
    reg clk;
    reg halt;
    reg COPYSTD;

    reg [REG_WIDTH-1:0] accOut;
    reg [REG_ADDR_WIDTH-1:0] regField;

    wire [REG_WIDTH-1:0] regOut;

    integer tests_run;
    integer tests_failed;
    integer index;

    REGISTER_FILE #(
        .REG_WIDTH(REG_WIDTH),
        .REG_COUNT(REG_COUNT),
        .REG_ADDR_WIDTH(REG_ADDR_WIDTH)
    ) dut (
        .rst(rst),
        .clk(clk),
        .halt(halt),
        .COPYSTD(COPYSTD),
        .accOut(accOut),
        .regField(regField),
        .regOut(regOut)
    );

    /*
     * Clock generation
     *
     * 20 ns period = 50 MHz.
     */
    initial begin
        clk = 1'b0;

        forever begin
            #(CLK_PERIOD / 2);
            clk = ~clk;
        end
    end

    /*
     * Check the asynchronously selected register output.
     */
    task check_read;
        input [REG_ADDR_WIDTH-1:0] address;
        input [REG_WIDTH-1:0] expected;
        input integer test_number;

        begin
            tests_run = tests_run + 1;

            regField = address;

            /*
             * Allow the asynchronous read mux to settle.
             */
            #1;

            if (regOut !== expected) begin
                tests_failed = tests_failed + 1;

                $display(
                    "FAIL - Test %0d: R%0d expected 0x%0h, actual 0x%0h",
                    test_number,
                    address,
                    expected,
                    regOut
                );
            end
            else begin
                $display(
                    "PASS - Test %0d: R%0d = 0x%0h",
                    test_number,
                    address,
                    regOut
                );
            end
        end
    endtask

    /*
     * Write one value into a selected register.
     */
    task write_register;
        input [REG_ADDR_WIDTH-1:0] address;
        input [REG_WIDTH-1:0] value;

        begin
            regField = address;
            accOut = value;
            COPYSTD = 1'b1;

            @(posedge clk);
            #1;

            COPYSTD = 1'b0;
        end
    endtask

    /*
     * Attempt a write while halt is asserted.
     */
    task halted_write;
        input [REG_ADDR_WIDTH-1:0] address;
        input [REG_WIDTH-1:0] value;

        begin
            halt = 1'b1;
            regField = address;
            accOut = value;
            COPYSTD = 1'b1;

            @(posedge clk);
            #1;

            COPYSTD = 1'b0;
            halt = 1'b0;
        end
    endtask

    initial begin
        tests_run = 0;
        tests_failed = 0;

        rst = 1'b0;
        halt = 1'b0;
        COPYSTD = 1'b0;
        accOut = {REG_WIDTH{1'b0}};
        regField = {REG_ADDR_WIDTH{1'b0}};

        $display("");
        $display("========================================");
        $display("REGISTER FILE TESTBENCH");
        $display("========================================");

        /*
         * Test 1:
         * Reset all registers to zero.
         */
        rst = 1'b1;

        @(posedge clk);
        #1;

        rst = 1'b0;

        for (index = 0; index < REG_COUNT; index = index + 1) begin
            check_read(
                index,
                8'h00,
                index + 1
            );
        end

        /*
         * Tests 9-16:
         * Write a unique value into every register.
         */
        write_register(3'd0, 8'h10);
        check_read(3'd0, 8'h10, 9);

        write_register(3'd1, 8'h21);
        check_read(3'd1, 8'h21, 10);

        write_register(3'd2, 8'h32);
        check_read(3'd2, 8'h32, 11);

        write_register(3'd3, 8'h43);
        check_read(3'd3, 8'h43, 12);

        write_register(3'd4, 8'h54);
        check_read(3'd4, 8'h54, 13);

        write_register(3'd5, 8'h65);
        check_read(3'd5, 8'h65, 14);

        write_register(3'd6, 8'h76);
        check_read(3'd6, 8'h76, 15);

        write_register(3'd7, 8'h87);
        check_read(3'd7, 8'h87, 16);

        /*
         * Tests 17-24:
         * Verify that writing one register did not corrupt the others.
         */
        check_read(3'd0, 8'h10, 17);
        check_read(3'd1, 8'h21, 18);
        check_read(3'd2, 8'h32, 19);
        check_read(3'd3, 8'h43, 20);
        check_read(3'd4, 8'h54, 21);
        check_read(3'd5, 8'h65, 22);
        check_read(3'd6, 8'h76, 23);
        check_read(3'd7, 8'h87, 24);

        /*
         * Test 25:
         * COPYSTD low prevents a write.
         */
        regField = 3'd3;
        accOut = 8'hAA;
        COPYSTD = 1'b0;

        @(posedge clk);
        #1;

        check_read(
            3'd3,
            8'h43,
            25
        );

        /*
         * Test 26:
         * halt blocks a write.
         */
        halted_write(
            3'd4,
            8'hBB
        );

        check_read(
            3'd4,
            8'h54,
            26
        );

        /*
         * Test 27:
         * Writes resume after halt is removed.
         */
        write_register(
            3'd4,
            8'hCC
        );

        check_read(
            3'd4,
            8'hCC,
            27
        );

        /*
         * Test 28:
         * Overwrite an existing register.
         */
        write_register(
            3'd2,
            8'hF0
        );

        check_read(
            3'd2,
            8'hF0,
            28
        );

        /*
         * Test 29:
         * Changing accOut without COPYSTD must not modify a register.
         */
        regField = 3'd5;
        accOut = 8'hDE;
        COPYSTD = 1'b0;

        @(posedge clk);
        #1;

        check_read(
            3'd5,
            8'h65,
            29
        );

        /*
         * Test 30:
         * Verify asynchronous read behavior.
         *
         * regOut should change when regField changes without waiting
         * for a clock edge.
         */
        tests_run = tests_run + 1;

        regField = 3'd0;
        #1;

        if (regOut !== 8'h10) begin
            tests_failed = tests_failed + 1;

            $display(
                "FAIL - Test 30A: asynchronous read of R0 expected 0x10, actual 0x%0h",
                regOut
            );
        end
        else begin
            regField = 3'd7;
            #1;

            if (regOut !== 8'h87) begin
                tests_failed = tests_failed + 1;

                $display(
                    "FAIL - Test 30B: asynchronous read of R7 expected 0x87, actual 0x%0h",
                    regOut
                );
            end
            else begin
                $display(
                    "PASS - Test 30: asynchronous register selection works"
                );
            end
        end

        /*
         * Test 31:
         * Reset overrides halt.
         */
        halt = 1'b1;
        rst = 1'b1;
        COPYSTD = 1'b1;
        regField = 3'd6;
        accOut = 8'hFF;

        @(posedge clk);
        #1;

        rst = 1'b0;
        COPYSTD = 1'b0;
        halt = 1'b0;

        check_read(
            3'd6,
            8'h00,
            31
        );

        /*
         * Tests 32-38:
         * Confirm reset cleared every remaining register.
         */
        check_read(3'd0, 8'h00, 32);
        check_read(3'd1, 8'h00, 33);
        check_read(3'd2, 8'h00, 34);
        check_read(3'd3, 8'h00, 35);
        check_read(3'd4, 8'h00, 36);
        check_read(3'd5, 8'h00, 37);
        check_read(3'd7, 8'h00, 38);

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