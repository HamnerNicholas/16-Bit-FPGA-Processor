`timescale 1ns / 1ps

module CPU_BRANCH_SIGNED_LT_TB;

    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 16;
    parameter IMM_WIDTH = 8;
    parameter REG_ADDR_WIDTH = 3;
    parameter SUBOP_WIDTH = 2;
    parameter INT_LINES_WIDTH = 8;

    parameter CLK_PERIOD = 20;
    parameter MAX_CYCLES = 100;

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
     * 50 MHz simulation clock.
     */
    initial begin
        clk = 1'b0;

        forever begin
            #(CLK_PERIOD / 2);
            clk = ~clk;
        end
    end

    task check_register;
        input [REG_ADDR_WIDTH-1:0] address;
        input [DATA_WIDTH-1:0] expected;
        input integer test_number;

        begin
            tests_run = tests_run + 1;

            if (dut.register_file_inst.registers[address] !== expected) begin
                tests_failed = tests_failed + 1;

                $display(
                    "FAIL - Test %0d: R%0d expected 0x%0h, actual 0x%0h",
                    test_number,
                    address,
                    expected,
                    dut.register_file_inst.registers[address]
                );
            end
            else begin
                $display(
                    "PASS - Test %0d: R%0d = 0x%0h",
                    test_number,
                    address,
                    dut.register_file_inst.registers[address]
                );
            end
        end
    endtask

    task check_acc;
        input [DATA_WIDTH-1:0] expected;
        input integer test_number;

        begin
            tests_run = tests_run + 1;

            if (debug_ACC !== expected) begin
                tests_failed = tests_failed + 1;

                $display(
                    "FAIL - Test %0d: ACC expected 0x%0h, actual 0x%0h",
                    test_number,
                    expected,
                    debug_ACC
                );
            end
            else begin
                $display(
                    "PASS - Test %0d: ACC = 0x%0h",
                    test_number,
                    debug_ACC
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

        rst = 1'b1;
        interrupts = {INT_LINES_WIDTH{1'b0}};

        $display("");
        $display("========================================");
        $display("CPU SIGNED LESS-THAN BRANCH TEST");
        $display("========================================");

        /*
         * Reset the complete processor.
         */
        repeat (2) begin
            @(posedge clk);
            #1;
        end

        /*
         * Release reset away from the rising clock edge.
         */
        @(negedge clk);
        rst = 1'b0;

        /*
         * Execute until halt or timeout.
         */
        while ((halt !== 1'b1) && (cycles < MAX_CYCLES)) begin
            @(posedge clk);
            #1;

            cycles = cycles + 1;
        end

        /*
         * Test 1: CPU must reach halt.
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
                "PASS - Test 1: CPU halted after %0d cycles",
                cycles
            );
        end

        /*
         * Register values proving each branch path.
         */
        check_register(3'd1, 8'h03, 2);
        check_register(3'd2, 8'h11, 3);
        check_register(3'd3, 8'h22, 4);
        check_register(3'd4, 8'h44, 5);
        check_register(3'd5, 8'hFE, 6);
        check_register(3'd6, 8'h33, 7);
        check_register(3'd7, 8'h01, 8);

        /*
         * Final accumulator and halt address.
         */
        check_acc(8'h44, 9);
        check_pc(16'h001A, 10);

        /*
         * Twenty-two non-halt instructions should execute.
         *
         * Each taken branch skips two instructions.
         */
        tests_run = tests_run + 1;

        if (cycles !== 22) begin
            tests_failed = tests_failed + 1;

            $display(
                "FAIL - Test 11: expected 22 executed cycles, actual %0d",
                cycles
            );
        end
        else begin
            $display(
                "PASS - Test 11: signed branch paths executed correctly"
            );
        end

        /*
         * Explicit proof that signed values are interpreted correctly.
         *
         * R5 contains 0xFE, which represents -2 rather than 254.
         * Its branch was taken, allowing R6 to receive 0x33.
         */
        tests_run = tests_run + 1;

        if ((dut.register_file_inst.registers[5] !== 8'hFE) ||
            (dut.register_file_inst.registers[6] !== 8'h33)) begin

            tests_failed = tests_failed + 1;

            $display(
                "FAIL - Test 12: negative-versus-positive signed comparison failed"
            );
        end
        else begin
            $display(
                "PASS - Test 12: -2 < 1 branch was taken"
            );
        end

        /*
         * R4 receives 0x44 only if 1 < -2 evaluates false.
         */
        tests_run = tests_run + 1;

        if (dut.register_file_inst.registers[4] !== 8'h44) begin
            tests_failed = tests_failed + 1;

            $display(
                "FAIL - Test 13: positive-versus-negative comparison failed"
            );
        end
        else begin
            $display(
                "PASS - Test 13: 1 < -2 branch was not taken"
            );
        end

        /*
         * Verify halt freezes architectural state.
         */
        repeat (3) begin
            @(posedge clk);
            #1;
        end

        check_register(3'd4, 8'h44, 14);
        check_register(3'd6, 8'h33, 15);
        check_acc(8'h44, 16);
        check_pc(16'h001A, 17);

        $display("");
        $display("========================================");
        $display("FINAL STATE");
        $display("PC:   0x%0h", debug_PC);
        $display("ACC:  0x%0h", debug_ACC);
        $display("R1:   0x%0h",
                 dut.register_file_inst.registers[1]);
        $display("R2:   0x%0h",
                 dut.register_file_inst.registers[2]);
        $display("R3:   0x%0h",
                 dut.register_file_inst.registers[3]);
        $display("R4:   0x%0h",
                 dut.register_file_inst.registers[4]);
        $display("R5:   0x%0h",
                 dut.register_file_inst.registers[5]);
        $display("R6:   0x%0h",
                 dut.register_file_inst.registers[6]);
        $display("R7:   0x%0h",
                 dut.register_file_inst.registers[7]);
        $display("HALT: %b", halt);
        $display("========================================");

        $display("");
        $display("========================================");
        $display("TEST SUMMARY");
        $display("Tests run:    %0d", tests_run);
        $display("Tests passed: %0d",
                 tests_run - tests_failed);
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
