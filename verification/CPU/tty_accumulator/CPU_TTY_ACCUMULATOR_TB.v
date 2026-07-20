`timescale 1ns / 1ps

module CPU_TTY_ACCUMULATOR_TB;

    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 16;
    parameter IMM_WIDTH = 8;
    parameter REG_ADDR_WIDTH = 3;
    parameter SUBOP_WIDTH = 2;
    parameter INT_LINES_WIDTH = 8;

    parameter CLK_PERIOD = 20;
    parameter MAX_CYCLES = 50;

    reg clk;
    reg rst;
    reg [INT_LINES_WIDTH-1:0] interrupts;

    wire halt;

    wire [ADDR_WIDTH-1:0] debug_PC;
    wire [DATA_WIDTH-1:0] debug_ACC;
    wire [DATA_WIDTH-1:0] debug_regOut;
    wire [DATA_WIDTH-1:0] debug_globalOut;
    wire [ADDR_WIDTH-1:0] debug_RA;
    wire [ADDR_WIDTH-1:0] debug_INT_RET_REG;

    wire ttyLoad;
    wire ttyALoad;
    wire [DATA_WIDTH-1:0] tty_ACC;
    wire [IMM_WIDTH-1:0] tty_imm;

    integer tests_run;
    integer tests_failed;
    integer cycles;

    integer tty_load_count;
    integer ttya_load_count;
    integer simultaneous_assertions;
    integer outputs_after_halt;

    reg halt_seen;

    reg [DATA_WIDTH-1:0] captured_values [0:7];

    CPU_CORE #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .IMM_WIDTH(IMM_WIDTH),
        .REG_ADDR_WIDTH(REG_ADDR_WIDTH),
        .SUBOP_WIDTH(SUBOP_WIDTH),
        .INT_LINES_WIDTH(INT_LINES_WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .interrupts(interrupts),

        .halt(halt),

        .debug_PC(debug_PC),
        .debug_ACC(debug_ACC),
        .debug_regOut(debug_regOut),
        .debug_globalOut(debug_globalOut),
        .debug_RA(debug_RA),
        .debug_INT_RET_REG(debug_INT_RET_REG),

        .ttyLoad(ttyLoad),
        .ttyALoad(ttyALoad),
        .tty_ACC(tty_ACC),
        .tty_imm(tty_imm)
    );

    /*
     * Clock generation.
     */
    initial begin
        clk = 1'b0;

        forever begin
            #(CLK_PERIOD / 2);
            clk = ~clk;
        end
    end

    /*
     * Monitor TTY activity.
     *
     * Every rising clock edge with ttyALoad asserted represents one
     * accumulator-output transaction.
     */
    always @(posedge clk) begin
        if (rst) begin
            tty_load_count = 0;
            ttya_load_count = 0;
            simultaneous_assertions = 0;
            outputs_after_halt = 0;
            halt_seen = 1'b0;
        end
        else begin
            /*
             * Capture one accumulator output for every active
             * ttyALoad clock.
             */
            if (ttyALoad) begin
                if (ttya_load_count < 8)
                    captured_values[ttya_load_count] = tty_ACC;

                ttya_load_count = ttya_load_count + 1;
            end

            /*
             * This program should never execute an immediate tty
             * instruction.
             */
            if (ttyLoad)
                tty_load_count = tty_load_count + 1;

            /*
             * The immediate and accumulator output enables must not
             * assert simultaneously.
             */
            if (ttyLoad && ttyALoad)
                simultaneous_assertions =
                    simultaneous_assertions + 1;

            /*
             * No output transaction should occur after halt has
             * already been observed.
             */
            if (halt_seen && (ttyLoad || ttyALoad))
                outputs_after_halt =
                    outputs_after_halt + 1;

            if (halt)
                halt_seen = 1'b1;
        end
    end

    task check_integer;
        input integer actual;
        input integer expected;
        input integer test_number;
        input [8*64-1:0] description;

        begin
            tests_run = tests_run + 1;

            if (actual !== expected) begin
                tests_failed = tests_failed + 1;

                $display(
                    "FAIL - Test %0d: %0s expected %0d, actual %0d",
                    test_number,
                    description,
                    expected,
                    actual
                );
            end
            else begin
                $display(
                    "PASS - Test %0d: %0s = %0d",
                    test_number,
                    description,
                    actual
                );
            end
        end
    endtask

    task check_value;
        input [DATA_WIDTH-1:0] actual;
        input [DATA_WIDTH-1:0] expected;
        input integer test_number;
        input [8*64-1:0] description;

        begin
            tests_run = tests_run + 1;

            if (actual !== expected) begin
                tests_failed = tests_failed + 1;

                $display(
                    "FAIL - Test %0d: %0s expected 0x%0h, actual 0x%0h",
                    test_number,
                    description,
                    expected,
                    actual
                );
            end
            else begin
                $display(
                    "PASS - Test %0d: %0s = 0x%0h",
                    test_number,
                    description,
                    actual
                );
            end
        end
    endtask

    task check_pc;
        input [ADDR_WIDTH-1:0] expected;
        input integer test_number;

        begin
            tests_run = tests_run + 1;

            if (debug_PC !== expected) begin
                tests_failed = tests_failed + 1;

                $display(
                    "FAIL - Test %0d: PC expected 0x%0h, actual 0x%0h",
                    test_number,
                    expected,
                    debug_PC
                );
            end
            else begin
                $display(
                    "PASS - Test %0d: PC = 0x%0h",
                    test_number,
                    debug_PC
                );
            end
        end
    endtask

    initial begin
        tests_run = 0;
        tests_failed = 0;
        cycles = 0;

        tty_load_count = 0;
        ttya_load_count = 0;
        simultaneous_assertions = 0;
        outputs_after_halt = 0;

        halt_seen = 1'b0;

        captured_values[0] = 8'h00;
        captured_values[1] = 8'h00;
        captured_values[2] = 8'h00;
        captured_values[3] = 8'h00;
        captured_values[4] = 8'h00;
        captured_values[5] = 8'h00;
        captured_values[6] = 8'h00;
        captured_values[7] = 8'h00;

        rst = 1'b1;
        interrupts = {INT_LINES_WIDTH{1'b0}};

        $display("");
        $display("========================================");
        $display("CPU ACCUMULATOR TTY OUTPUT TEST");
        $display("========================================");

        /*
         * Hold reset for two rising clock edges.
         */
        repeat (2) begin
            @(posedge clk);
            #1;
        end

        /*
         * Release reset away from the active clock edge.
         */
        @(negedge clk);
        rst = 1'b0;

        /*
         * Run until halt or timeout.
         */
        while ((halt !== 1'b1) && (cycles < MAX_CYCLES)) begin
            @(posedge clk);
            #1;

            cycles = cycles + 1;
        end

        /*
         * Test 1: CPU reached halt.
         */
        tests_run = tests_run + 1;

        if (halt !== 1'b1) begin
            tests_failed = tests_failed + 1;

            $display(
                "FAIL - Test 1: CPU timed out after %0d cycles",
                cycles
            );
        end
        else begin
            $display(
                "PASS - Test 1: CPU halted successfully after %0d cycles",
                cycles
            );
        end

        /*
         * Test 2: Exactly two accumulator-output transactions occurred.
         */
        check_integer(
            ttya_load_count,
            2,
            2,
            "ttyALoad transaction count"
        );

        /*
         * Test 3: No immediate-output transactions occurred.
         */
        check_integer(
            tty_load_count,
            0,
            3,
            "ttyLoad transaction count"
        );

        /*
         * Tests 4 and 5: Verify captured output values and order.
         */
        check_value(
            captured_values[0],
            8'h55,
            4,
            "first accumulator TTY output"
        );

        check_value(
            captured_values[1],
            8'hAA,
            5,
            "second accumulator TTY output"
        );

        /*
         * Test 6:
         * Confirm the complete transaction sequence.
         */
        tests_run = tests_run + 1;

        if (
            (ttya_load_count !== 2) ||
            (captured_values[0] !== 8'h55) ||
            (captured_values[1] !== 8'hAA)
        ) begin
            tests_failed = tests_failed + 1;

            $display(
                "FAIL - Test 6: ttyALoad transactions were not captured correctly"
            );
        end
        else begin
            $display(
                "PASS - Test 6: each ttyALoad clock produced one transaction"
            );
        end

        /*
         * Test 7: Output enables never overlapped.
         */
        check_integer(
            simultaneous_assertions,
            0,
            7,
            "simultaneous ttyLoad and ttyALoad assertions"
        );

        /*
         * Test 8: Final accumulator contains the second output value.
         */
        check_value(
            debug_ACC,
            8'hAA,
            8,
            "final accumulator"
        );

        /*
         * Test 9: CPU stopped at the halt instruction.
         */
        check_pc(
            16'h0004,
            9
        );

        /*
         * Allow several additional clock edges while halted.
         */
        repeat (4) begin
            @(posedge clk);
            #1;
        end

        /*
         * Test 10: No output transactions occurred after halt.
         */
        check_integer(
            outputs_after_halt,
            0,
            10,
            "output transactions after halt"
        );

        /*
         * Test 11: Accumulator-output count stayed unchanged.
         */
        check_integer(
            ttya_load_count,
            2,
            11,
            "ttyALoad count after halt"
        );

        /*
         * Test 12: Immediate-output count stayed at zero.
         */
        check_integer(
            tty_load_count,
            0,
            12,
            "ttyLoad count after halt"
        );

        /*
         * Test 13: Accumulator remained stable after halt.
         */
        check_value(
            debug_ACC,
            8'hAA,
            13,
            "accumulator after halt"
        );

        /*
         * Test 14: PC remained frozen after halt.
         */
        check_pc(
            16'h0004,
            14
        );

        /*
         * Test 15: Halt remained asserted.
         */
        tests_run = tests_run + 1;

        if (halt !== 1'b1) begin
            tests_failed = tests_failed + 1;

            $display(
                "FAIL - Test 15: halt deasserted after stopping"
            );
        end
        else begin
            $display(
                "PASS - Test 15: halt remained asserted"
            );
        end

        $display("");
        $display("========================================");
        $display("CAPTURED OUTPUT");
        $display("Output 0:           0x%0h", captured_values[0]);
        $display("Output 1:           0x%0h", captured_values[1]);
        $display("ttyALoad count:     %0d", ttya_load_count);
        $display("ttyLoad count:      %0d", tty_load_count);
        $display("Overlap count:      %0d", simultaneous_assertions);
        $display("Outputs after halt: %0d", outputs_after_halt);
        $display("Final ACC:          0x%0h", debug_ACC);
        $display("Final PC:           0x%0h", debug_PC);
        $display("HALT:               %b", halt);
        $display("========================================");

        $display("");
        $display("========================================");
        $display("TEST SUMMARY");
        $display("Tests run:    %0d", tests_run);
        $display(
            "Tests passed: %0d",
            tests_run - tests_failed
        );
        $display("Tests failed: %0d", tests_failed);
        $display("========================================");

        if (tests_failed == 0)
            $display("RESULT: ALL TESTS PASSED");
        else
            $display("RESULT: TEST FAILURE");

        $finish;
    end

endmodule
