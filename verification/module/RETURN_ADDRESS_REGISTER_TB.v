`timescale 1ns / 1ps

module RETURN_ADDRESS_REGISTER_TB;

    parameter WIDTH = 16;
    parameter CLK_PERIOD = 20;

    reg clk;
    reg halt;
    reg rst;
    reg RALoad;

    reg [WIDTH-1:0] PCOut;

    wire [WIDTH-1:0] RAOut;

    integer tests_run;
    integer tests_failed;

    RETURN_ADDRESS_REGISTER #(
        .WIDTH(WIDTH)
    ) dut (
        .clk(clk),
        .halt(halt),
        .rst(rst),
        .RALoad(RALoad),
        .PCOut(PCOut),
        .RAOut(RAOut)
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
     * Wait for the next rising edge and verify RAOut.
     */
    task check_ra;
        input [WIDTH-1:0] expected;
        input integer test_number;

        begin
            tests_run = tests_run + 1;

            @(posedge clk);
            #1;

            if (RAOut !== expected) begin
                tests_failed = tests_failed + 1;

                $display(
                    "FAIL - Test %0d: expected RAOut = 0x%0h, actual = 0x%0h",
                    test_number,
                    expected,
                    RAOut
                );
            end
            else begin
                $display(
                    "PASS - Test %0d: RAOut = 0x%0h",
                    test_number,
                    RAOut
                );
            end
        end
    endtask

    initial begin
        tests_run = 0;
        tests_failed = 0;

        clk = 1'b0;
        halt = 1'b0;
        rst = 1'b0;
        RALoad = 1'b0;
        PCOut = {WIDTH{1'b0}};

        $display("");
        $display("========================================");
        $display("RETURN ADDRESS REGISTER TESTBENCH");
        $display("========================================");

        /*
         * Test 1:
         * Reset clears the internal RA register.
         *
         * Since RAOut is RA + 1, reset produces RAOut = 1.
         */
        rst = 1'b1;

        check_ra(
            16'h0001,
            1
        );

        rst = 1'b0;

        /*
         * Test 2:
         * Load PCOut = 0.
         *
         * Stored RA = 0
         * Output RAOut = 1
         */
        RALoad = 1'b1;
        PCOut = 16'h0000;

        check_ra(
            16'h0001,
            2
        );

        RALoad = 1'b0;

        /*
         * Test 3:
         * Load a normal return address.
         *
         * Stored RA = 0x1234
         * Output RAOut = 0x1235
         */
        RALoad = 1'b1;
        PCOut = 16'h1234;

        check_ra(
            16'h1235,
            3
        );

        RALoad = 1'b0;

        /*
         * Test 4:
         * Hold the previous value when RALoad is low.
         */
        PCOut = 16'hAAAA;

        check_ra(
            16'h1235,
            4
        );

        /*
         * Test 5:
         * halt blocks a write.
         */
        halt = 1'b1;
        RALoad = 1'b1;
        PCOut = 16'h5678;

        check_ra(
            16'h1235,
            5
        );

        /*
         * Test 6:
         * Writes resume after halt is removed.
         */
        halt = 1'b0;

        check_ra(
            16'h5679,
            6
        );

        RALoad = 1'b0;

        /*
         * Test 7:
         * Changing PCOut without RALoad must not update the register.
         */
        PCOut = 16'hBEEF;

        check_ra(
            16'h5679,
            7
        );

        /*
         * Test 8:
         * Overwrite the stored return address.
         */
        RALoad = 1'b1;
        PCOut = 16'h00FE;

        check_ra(
            16'h00FF,
            8
        );

        RALoad = 1'b0;

        /*
         * Test 9:
         * Reset overrides halt and RALoad.
         *
         * Internal RA becomes zero, so RAOut becomes one.
         */
        halt = 1'b1;
        rst = 1'b1;
        RALoad = 1'b1;
        PCOut = 16'hFFFF;

        check_ra(
            16'h0001,
            9
        );

        rst = 1'b0;
        RALoad = 1'b0;

        /*
         * Test 10:
         * halt keeps the reset value held.
         */
        PCOut = 16'h2222;

        check_ra(
            16'h0001,
            10
        );

        halt = 1'b0;

        /*
         * Test 11:
         * Maximum PC value wraps after adding one.
         *
         * Stored RA = 0xFFFF
         * RAOut = 0x0000
         */
        RALoad = 1'b1;
        PCOut = 16'hFFFF;

        check_ra(
            16'h0000,
            11
        );

        RALoad = 1'b0;

        /*
         * Test 12:
         * Verify hold behavior after wraparound.
         */
        PCOut = 16'h1111;

        check_ra(
            16'h0000,
            12
        );

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