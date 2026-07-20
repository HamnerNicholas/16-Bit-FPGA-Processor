`timescale 1ns / 1ps

module CPU_TTY_IMMEDIATE_TB;

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

    reg [IMM_WIDTH-1:0] captured_values [0:7];

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
     * Every rising clock edge with ttyLoad asserted represents one
     * immediate-output transaction. Consecutive tty instructions may
     * therefore keep ttyLoad high across consecutive cycles.
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
             * Capture one immediate output for every clock where
             * ttyLoad is asserted.
             */
            if (ttyLoad) begin
                if (tty_load_count < 8)
                    captured_values[tty_load_count] = tty_imm;

                tty_load_count = tty_load_count + 1;
            end

            /*
             * This program should never execute ttya.
             */
            if (ttyALoad)
                ttya_load_count = ttya_load_count + 1;

            /*
             * Immediate and accumulator output enables should never
             * assert simultaneously.
             */
            if (ttyLoad && ttyALoad)
                simultaneous_assertions =
                    simultaneous_assertions + 1;

            /*
             * Once halt has been observed, no later clock should
             * produce another TTY transaction.
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
        input [IMM_WIDTH-1:0] actual;
        input [IMM_WIDTH-1:0] expected;
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
        $display("CPU IMMEDIATE TTY OUTPUT TEST");
        $display("========================================");

        /*
         * Hold reset for two rising edges.
         */
        repeat (2) begin
            @(posedge clk);
            #1;
        end

        /*
         * Release reset away from the active edge.
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
         * Test 2: Exactly three immediate-output transactions occurred.
         */
        check_integer(
            tty_load_count,
            3,
            2,
            "ttyLoad transaction count"
        );

        /*
         * Test 3: No accumulator-output transactions occurred.
         */
        check_integer(
            ttya_load_count,
            0,
            3,
            "ttyALoad transaction count"
        );

        /*
         * Tests 4 through 6: Verify output sequence.
         */
        check_value(
            captured_values[0],
            8'h41,
            4,
            "first TTY output"
        );

        check_value(
            captured_values[1],
            8'h42,
            5,
            "second TTY output"
        );

        check_value(
            captured_values[2],
            8'h30,
            6,
            "third TTY output"
        );

        /*
         * Test 7:
         * Every asserted ttyLoad clock produced exactly one captured
         * output transaction in the expected order.
         */
        tests_run = tests_run + 1;

        if (
            (tty_load_count !== 3) ||
            (captured_values[0] !== 8'h41) ||
            (captured_values[1] !== 8'h42) ||
            (captured_values[2] !== 8'h30)
        ) begin
            tests_failed = tests_failed + 1;

            $display(
                "FAIL - Test 7: ttyLoad clocks were not captured correctly"
            );
        end
        else begin
            $display(
                "PASS - Test 7: each ttyLoad clock produced one transaction"
            );
        end

        /*
         * Test 8: ttyLoad and ttyALoad never overlapped.
         */
        check_integer(
            simultaneous_assertions,
            0,
            8,
            "simultaneous ttyLoad and ttyALoad assertions"
        );

        /*
         * Test 9: CPU stopped on the halt instruction.
         */
        tests_run = tests_run + 1;

        if (debug_PC !== 16'h0003) begin
            tests_failed = tests_failed + 1;

            $display(
                "FAIL - Test 9: PC expected 0x0003, actual 0x%0h",
                debug_PC
            );
        end
        else begin
            $display(
                "PASS - Test 9: PC = 0x%0h",
                debug_PC
            );
        end

        /*
         * Let the CPU remain halted for several more clocks.
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
         * Test 11: The immediate transaction count stayed unchanged.
         */
        check_integer(
            tty_load_count,
            3,
            11,
            "ttyLoad count after halt"
        );

        /*
         * Test 12: No accumulator transaction appeared after halt.
         */
        check_integer(
            ttya_load_count,
            0,
            12,
            "ttyALoad count after halt"
        );

        /*
         * Test 13: PC remained frozen at the halt instruction.
         */
        tests_run = tests_run + 1;

        if (debug_PC !== 16'h0003) begin
            tests_failed = tests_failed + 1;

            $display(
                "FAIL - Test 13: PC changed after halt, actual 0x%0h",
                debug_PC
            );
        end
        else begin
            $display(
                "PASS - Test 13: PC remained at 0x%0h after halt",
                debug_PC
            );
        end

        /*
         * Test 14: Halt remains asserted.
         */
        tests_run = tests_run + 1;

        if (halt !== 1'b1) begin
            tests_failed = tests_failed + 1;

            $display(
                "FAIL - Test 14: halt deasserted after stopping"
            );
        end
        else begin
            $display(
                "PASS - Test 14: halt remained asserted"
            );
        end

        $display("");
        $display("========================================");
        $display("CAPTURED OUTPUT");
        $display("Output 0:         0x%0h", captured_values[0]);
        $display("Output 1:         0x%0h", captured_values[1]);
        $display("Output 2:         0x%0h", captured_values[2]);
        $display("ttyLoad count:    %0d", tty_load_count);
        $display("ttyALoad count:   %0d", ttya_load_count);
        $display("Overlap count:    %0d", simultaneous_assertions);
        $display("Outputs after halt: %0d", outputs_after_halt);
        $display("Final PC:         0x%0h", debug_PC);
        $display("HALT:             %b", halt);
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
