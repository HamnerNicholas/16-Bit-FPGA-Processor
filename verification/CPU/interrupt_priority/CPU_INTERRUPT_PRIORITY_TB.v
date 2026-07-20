`timescale 1ns / 1ps

module CPU_INTERRUPT_PRIORITY_TB;

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

    integer saw_int1_handler;
    integer saw_int5_handler;
    integer saw_return;
    integer interrupt_jump_count;

    reg [ADDR_WIDTH-1:0] first_isr_address;
    reg first_isr_recorded;

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

            if (
                dut.jal_register_file_inst.jal_registers[address]
                !== expected
            ) begin
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

    task check_interrupt_return;
        input [ADDR_WIDTH-1:0] expected;
        input integer test_number;

        begin
            tests_run = tests_run + 1;

            if (debug_INT_RET_REG !== expected) begin
                tests_failed = tests_failed + 1;

                $display(
                    "FAIL - Test %0d: INT_RET_REG expected 0x%0h, actual 0x%0h",
                    test_number,
                    expected,
                    debug_INT_RET_REG
                );
            end
            else begin
                $display(
                    "PASS - Test %0d: INT_RET_REG = 0x%0h",
                    test_number,
                    debug_INT_RET_REG
                );
            end
        end
    endtask

    /*
     * Monitor interrupt-related control flow.
     */
    always @(posedge clk) begin
        if (!rst) begin
            if (dut.ISRJumpControl) begin
                interrupt_jump_count = interrupt_jump_count + 1;

                if (!first_isr_recorded) begin
                    first_isr_address = dut.ISRVector;
                    first_isr_recorded = 1'b1;
                end
            end

            if (debug_PC == 16'h0007)
                saw_int1_handler = 1;

            if (debug_PC == 16'h000C)
                saw_int5_handler = 1;

            if (saw_int1_handler && debug_PC == 16'h0003)
                saw_return = 1;
        end
    end

    initial begin
        tests_run = 0;
        tests_failed = 0;
        cycles = 0;

        saw_int1_handler = 0;
        saw_int5_handler = 0;
        saw_return = 0;
        interrupt_jump_count = 0;

        first_isr_address = {ADDR_WIDTH{1'b0}};
        first_isr_recorded = 1'b0;

        rst = 1'b1;
        interrupts = {INT_LINES_WIDTH{1'b0}};

        $display("");
        $display("========================================");
        $display("CPU SIMULTANEOUS INTERRUPT PRIORITY TEST");
        $display("========================================");

        /*
         * Reset processor.
         */
        repeat (2) begin
            @(posedge clk);
            #1;
        end

        @(negedge clk);
        rst = 1'b0;

        /*
         * Wait for the instruction before the interrupted address.
         */
        wait (debug_PC == 16'h0002);

        /*
         * Assert INT1 and INT5 together. Both remain asserted for
         * exactly one clock period.
         */
        @(negedge clk);
        interrupts[1] = 1'b1;
        interrupts[5] = 1'b1;

        @(negedge clk);
        interrupts[1] = 1'b0;
        interrupts[5] = 1'b0;

        /*
         * Run until halt or timeout.
         */
        while ((halt !== 1'b1) && (cycles < MAX_CYCLES)) begin
            @(posedge clk);
            #1;

            cycles = cycles + 1;
        end

        /*
         * Test 1: CPU halted.
         */
        tests_run = tests_run + 1;

        if (halt !== 1'b1) begin
            tests_failed = tests_failed + 1;

            $display(
                "FAIL - Test 1: CPU timed out after %0d monitored cycles",
                cycles
            );
        end
        else begin
            $display(
                "PASS - Test 1: CPU halted successfully"
            );
        end

        /*
         * Test 2: A priority decision was recorded.
         */
        tests_run = tests_run + 1;

        if (!first_isr_recorded) begin
            tests_failed = tests_failed + 1;

            $display(
                "FAIL - Test 2: no interrupt vector was selected"
            );
        end
        else begin
            $display(
                "PASS - Test 2: interrupt vector selection was recorded"
            );
        end

        /*
         * Test 3: INT1 won the simultaneous priority decision.
         */
        tests_run = tests_run + 1;

        if (first_isr_address !== 16'h0007) begin
            tests_failed = tests_failed + 1;

            $display(
                "FAIL - Test 3: first ISR expected 0x0007, actual 0x%0h",
                first_isr_address
            );
        end
        else begin
            $display(
                "PASS - Test 3: INT1 won with vector 0x0007"
            );
        end

        /*
         * Test 4: INT1 handler was reached.
         */
        tests_run = tests_run + 1;

        if (saw_int1_handler != 1) begin
            tests_failed = tests_failed + 1;

            $display(
                "FAIL - Test 4: INT1 handler was never reached"
            );
        end
        else begin
            $display(
                "PASS - Test 4: INT1 handler was reached"
            );
        end

        /*
         * Test 5: Lower-priority INT5 handler was not reached.
         */
        tests_run = tests_run + 1;

        if (saw_int5_handler != 0) begin
            tests_failed = tests_failed + 1;

            $display(
                "FAIL - Test 5: lower-priority INT5 handler executed"
            );
        end
        else begin
            $display(
                "PASS - Test 5: lower-priority INT5 handler did not execute"
            );
        end

        /*
         * Test 6: rint returned to interrupted address.
         */
        tests_run = tests_run + 1;

        if (saw_return != 1) begin
            tests_failed = tests_failed + 1;

            $display(
                "FAIL - Test 6: rint did not return to PC 0x0003"
            );
        end
        else begin
            $display(
                "PASS - Test 6: rint returned to PC 0x0003"
            );
        end

        /*
         * Test 7: Interrupted address was saved.
         */
        check_interrupt_return(
            16'h0003,
            7
        );

        /*
         * Tests 8 and 9: IVT entries contain the correct vectors.
         */
        tests_run = tests_run + 1;

        if (dut.isr_control_inst.ISRVectorTable[1] !== 16'h0007) begin
            tests_failed = tests_failed + 1;

            $display(
                "FAIL - Test 8: INT1 vector expected 0x0007, actual 0x%0h",
                dut.isr_control_inst.ISRVectorTable[1]
            );
        end
        else begin
            $display(
                "PASS - Test 8: INT1 vector = 0x0007"
            );
        end

        tests_run = tests_run + 1;

        if (dut.isr_control_inst.ISRVectorTable[5] !== 16'h000C) begin
            tests_failed = tests_failed + 1;

            $display(
                "FAIL - Test 9: INT5 vector expected 0x000C, actual 0x%0h",
                dut.isr_control_inst.ISRVectorTable[5]
            );
        end
        else begin
            $display(
                "PASS - Test 9: INT5 vector = 0x000C"
            );
        end

        /*
         * Main-program results.
         */
        check_register(
            3'd1,
            8'h02,
            10
        );

        check_register(
            3'd2,
            8'h55,
            11
        );

        /*
         * INT1 handler result.
         */
        check_register(
            3'd3,
            8'hA1,
            12
        );

        /*
         * INT5 handler must not execute.
         */
        check_register(
            3'd4,
            8'h00,
            13
        );

        /*
         * Context-save registers.
         */
        check_jal_register(
            3'd6,
            8'h02,
            14
        );

        check_jal_register(
            3'd7,
            8'h00,
            15
        );

        /*
         * Final architectural state.
         */
        check_acc(
            8'h55,
            16
        );

        check_pc(
            16'h0006,
            17
        );

        /*
         * Exactly one ISR jump should result from the simultaneous
         * one-clock pulse.
         */
        tests_run = tests_run + 1;

        if (interrupt_jump_count !== 1) begin
            tests_failed = tests_failed + 1;

            $display(
                "FAIL - Test 18: expected one ISR jump, actual %0d",
                interrupt_jump_count
            );
        end
        else begin
            $display(
                "PASS - Test 18: simultaneous pulse caused one ISR jump"
            );
        end

        /*
         * Both external lines must have been cleared.
         */
        tests_run = tests_run + 1;

        if (
            (interrupts[1] !== 1'b0) ||
            (interrupts[5] !== 1'b0)
        ) begin
            tests_failed = tests_failed + 1;

            $display(
                "FAIL - Test 19: interrupt pulse remained asserted"
            );
        end
        else begin
            $display(
                "PASS - Test 19: INT1 and INT5 pulse was cleared"
            );
        end

        /*
         * Verify halt stability.
         */
        repeat (3) begin
            @(posedge clk);
            #1;
        end

        check_register(
            3'd1,
            8'h02,
            20
        );

        check_register(
            3'd2,
            8'h55,
            21
        );

        check_register(
            3'd3,
            8'hA1,
            22
        );

        check_register(
            3'd4,
            8'h00,
            23
        );

        check_interrupt_return(
            16'h0003,
            24
        );

        check_acc(
            8'h55,
            25
        );

        check_pc(
            16'h0006,
            26
        );

        $display("");
        $display("========================================");
        $display("FINAL STATE");
        $display("PC:             0x%0h", debug_PC);
        $display("ACC:            0x%0h", debug_ACC);
        $display("R1:             0x%0h",
                 dut.register_file_inst.registers[1]);
        $display("R2:             0x%0h",
                 dut.register_file_inst.registers[2]);
        $display("R3 / INT1:      0x%0h",
                 dut.register_file_inst.registers[3]);
        $display("R4 / INT5:      0x%0h",
                 dut.register_file_inst.registers[4]);
        $display("SRF6:           0x%0h",
                 dut.jal_register_file_inst.jal_registers[6]);
        $display("SRF7:           0x%0h",
                 dut.jal_register_file_inst.jal_registers[7]);
        $display("INT_RET_REG:    0x%0h", debug_INT_RET_REG);
        $display("First ISR:      0x%0h", first_isr_address);
        $display("ISR jump count: %0d", interrupt_jump_count);
        $display("HALT:           %b", halt);
        $display("========================================");

        $display("");
        $display("========================================");
        $display("TEST SUMMARY");
        $display("Tests run:    %0d", tests_run);
        $display("Tests passed: %0d",
                 tests_run - tests_failed);
        $display("Tests failed: %0d", tests_failed);
        $display("========================================");

        if (tests_failed == 0)
            $display("RESULT: ALL TESTS PASSED");
        else
            $display("RESULT: TEST FAILURE");

        $finish;
    end

endmodule
