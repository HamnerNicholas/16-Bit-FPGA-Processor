`timescale 1ns / 1ps

module CPU_SUBROUTINE_TB;

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

    task check_jal_register;
        input [REG_ADDR_WIDTH-1:0] address;
        input [DATA_WIDTH-1:0] expected;
        input integer test_number;

        begin
            tests_run = tests_run + 1;

            if (dut.jal_register_file_inst.jal_registers[address]
                !== expected) begin

                tests_failed = tests_failed + 1;

                $display(
                    "FAIL - Test %0d: SRF%0d expected 0x%0h, actual 0x%0h",
                    test_number,
                    address,
                    expected,
                    dut.jal_register_file_inst.jal_registers[address]
                );
            end
            else begin
                $display(
                    "PASS - Test %0d: SRF%0d = 0x%0h",
                    test_number,
                    address,
                    dut.jal_register_file_inst.jal_registers[address]
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

    task check_ra;
        input [ADDR_WIDTH-1:0] expected;
        input integer test_number;

        begin
            tests_run = tests_run + 1;

            if (debug_RA !== expected) begin
                tests_failed = tests_failed + 1;

                $display(
                    "FAIL - Test %0d: RAOut expected 0x%0h, actual 0x%0h",
                    test_number,
                    expected,
                    debug_RA
                );
            end
            else begin
                $display(
                    "PASS - Test %0d: RAOut = 0x%0h",
                    test_number,
                    debug_RA
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
        $display("CPU SUBROUTINE AND JAL REGISTER TEST");
        $display("========================================");

        /*
         * Reset the complete processor.
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
         * Execute until halt or timeout.
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
                "PASS - Test 1: CPU halted after %0d cycles",
                cycles
            );
        end

        /*
         * General-purpose register results.
         */
        check_register(
            3'd1,
            8'h05,
            2
        );

        check_register(
            3'd2,
            8'h22,
            3
        );

        /*
         * R4 proves rsrf restored the value stored by ssrf.
         */
        check_register(
            3'd4,
            8'h0C,
            4
        );

        /*
         * Verify the special subroutine register file.
         */
        check_jal_register(
            3'd3,
            8'h0C,
            5
        );

        /*
         * Main resumes after the call and leaves ACC at 0x22.
         */
        check_acc(
            8'h22,
            6
        );

        /*
         * The call occurred at PC 2, so RAOut must be 3.
         */
        check_ra(
            16'h0003,
            7
        );

        /*
         * Halt is located at address 5.
         */
        check_pc(
            16'h0005,
            8
        );

        /*
         * Verify the dynamic instruction count.
         */
        tests_run = tests_run + 1;

        if (cycles !== 11) begin
            tests_failed = tests_failed + 1;

            $display(
                "FAIL - Test 9: expected 11 executed cycles, actual %0d",
                cycles
            );
        end
        else begin
            $display(
                "PASS - Test 9: call, subroutine, and return flow executed"
            );
        end

        /*
         * Directly inspect the internal stored RA.
         *
         * RA stores the call instruction address, while RAOut adds one.
         */
        tests_run = tests_run + 1;

        if (dut.return_address_register_inst.RA !== 16'h0002) begin
            tests_failed = tests_failed + 1;

            $display(
                "FAIL - Test 10: internal RA expected 0x2, actual 0x%0h",
                dut.return_address_register_inst.RA
            );
        end
        else begin
            $display(
                "PASS - Test 10: internal RA captured call PC 0x2"
            );
        end

        /*
         * Verify that the value was cleared before rsrf restored it.
         * The final R4 and SRF3 values together prove that path.
         */
        tests_run = tests_run + 1;

        if ((dut.jal_register_file_inst.jal_registers[3] !== 8'h0C) ||
            (dut.register_file_inst.registers[4] !== 8'h0C)) begin

            tests_failed = tests_failed + 1;

            $display(
                "FAIL - Test 11: ssrf/rsrf data path failed"
            );
        end
        else begin
            $display(
                "PASS - Test 11: ssrf stored and rsrf restored 0x0C"
            );
        end

        /*
         * Verify halt freezes all relevant state.
         */
        repeat (3) begin
            @(posedge clk);
            #1;
        end

        check_register(
            3'd2,
            8'h22,
            12
        );

        check_register(
            3'd4,
            8'h0C,
            13
        );

        check_jal_register(
            3'd3,
            8'h0C,
            14
        );

        check_acc(
            8'h22,
            15
        );

        check_ra(
            16'h0003,
            16
        );

        check_pc(
            16'h0005,
            17
        );

        $display("");
        $display("========================================");
        $display("FINAL STATE");
        $display("PC:        0x%0h", debug_PC);
        $display("ACC:       0x%0h", debug_ACC);
        $display("R1:        0x%0h",
                 dut.register_file_inst.registers[1]);
        $display("R2:        0x%0h",
                 dut.register_file_inst.registers[2]);
        $display("R4:        0x%0h",
                 dut.register_file_inst.registers[4]);
        $display("SRF3:      0x%0h",
                 dut.jal_register_file_inst.jal_registers[3]);
        $display("Stored RA: 0x%0h",
                 dut.return_address_register_inst.RA);
        $display("RAOut:     0x%0h", debug_RA);
        $display("HALT:      %b", halt);
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
