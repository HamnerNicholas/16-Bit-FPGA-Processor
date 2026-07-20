`timescale 1ns / 1ps

module CPU_INTERRUPT_TB;

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

    integer saw_isr;
    integer saw_return;
    integer interrupt_jump_count;

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
     * Observe important control-flow events.
     */
    always @(posedge clk) begin
        if (!rst) begin
            /*
             * Count cycles where the interrupt controller requests
             * an ISR jump.
             */
            if (dut.ISRJumpControl)
                interrupt_jump_count = interrupt_jump_count + 1;

            /*
             * Record arrival at the ISR.
             */
            if (debug_PC == 16'h0007)
                saw_isr = 1;

            /*
             * Record the return to the interrupted instruction.
             *
             * Require that the ISR was already visited so the initial
             * normal passage through low addresses is not mistaken
             * for an interrupt return.
             */
            if (saw_isr && debug_PC == 16'h0003)
                saw_return = 1;
        end
    end

    initial begin
        tests_run = 0;
        tests_failed = 0;
        cycles = 0;

        saw_isr = 0;
        saw_return = 0;
        interrupt_jump_count = 0;

        rst = 1'b1;
        interrupts = {INT_LINES_WIDTH{1'b0}};

        $display("");
        $display("========================================");
        $display("CPU INTERRUPT ENTRY AND RETURN TEST");
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
         * Wait until the processor reaches instruction address 2.
         */
        wait (debug_PC == 16'h0002);

        /*
         * Assert INT3 on a falling edge so it is stable before the
         * next rising edge.
         */
        @(negedge clk);
        interrupts[3] = 1'b1;

        /*
         * The next rising edge samples the interrupt request.
         *
         * Hold the line for exactly one processor clock period.
         */
        @(negedge clk);
        interrupts[3] = 1'b0;

        /*
         * Run until halt or timeout.
         */
        while ((halt !== 1'b1) && (cycles < MAX_CYCLES)) begin
            @(posedge clk);
            #1;

            cycles = cycles + 1;
        end

        /*
         * Test 1: Processor reaches halt.
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
         * Test 2:
         * Confirm the ISR target was reached.
         */
        tests_run = tests_run + 1;

        if (saw_isr != 1) begin
            tests_failed = tests_failed + 1;

            $display(
                "FAIL - Test 2: ISR address 0x0007 was never reached"
            );
        end
        else begin
            $display(
                "PASS - Test 2: ISR address 0x0007 was reached"
            );
        end

        /*
         * Test 3:
         * Confirm rint returned to the interrupted instruction.
         */
        tests_run = tests_run + 1;

        if (saw_return != 1) begin
            tests_failed = tests_failed + 1;

            $display(
                "FAIL - Test 3: rint did not return to PC 0x0003"
            );
        end
        else begin
            $display(
                "PASS - Test 3: rint returned to PC 0x0003"
            );
        end

        /*
         * Test 4:
         * Interrupt return register contains the interrupted address.
         */
        check_interrupt_return(
            16'h0003,
            4
        );

        /*
         * Test 5:
         * The selected IVT entry is the custom ISR address.
         */
        tests_run = tests_run + 1;

        if (dut.isr_control_inst.ISRVectorTable[3] !== 16'h0007) begin
            tests_failed = tests_failed + 1;

            $display(
                "FAIL - Test 5: INT3 vector expected 0x0007, actual 0x%0h",
                dut.isr_control_inst.ISRVectorTable[3]
            );
        end
        else begin
            $display(
                "PASS - Test 5: INT3 vector = 0x0007"
            );
        end

        /*
         * Main-program results.
         */
        check_register(
            3'd1,
            8'h02,
            6
        );

        check_register(
            3'd2,
            8'h55,
            7
        );

        /*
         * ISR result.
         */
        check_register(
            3'd3,
            8'hAA,
            8
        );

        /*
         * Final accumulator and halt location.
         */
        check_acc(
            8'h55,
            9
        );

        check_pc(
            16'h0006,
            10
        );

        /*
         * A one-clock pulse should result in one interrupt entry,
         * not repeated ISR jumps.
         */
        tests_run = tests_run + 1;

        if (interrupt_jump_count !== 1) begin
            tests_failed = tests_failed + 1;

            $display(
                "FAIL - Test 11: expected one ISR jump request, actual %0d",
                interrupt_jump_count
            );
        end
        else begin
            $display(
                "PASS - Test 11: one-clock INT3 pulse caused one ISR jump"
            );
        end

        /*
         * Confirm that the external interrupt line was removed.
         */
        tests_run = tests_run + 1;

        if (interrupts[3] !== 1'b0) begin
            tests_failed = tests_failed + 1;

            $display(
                "FAIL - Test 12: INT3 remained asserted"
            );
        end
        else begin
            $display(
                "PASS - Test 12: INT3 pulse was cleared"
            );
        end

        /*
         * Verify that halt freezes all relevant state.
         */
        repeat (3) begin
            @(posedge clk);
            #1;
        end

        check_register(
            3'd1,
            8'h02,
            13
        );

        check_register(
            3'd2,
            8'h55,
            14
        );

        check_register(
            3'd3,
            8'hAA,
            15
        );

        check_interrupt_return(
            16'h0003,
            16
        );

        check_acc(
            8'h55,
            17
        );

        check_pc(
            16'h0006,
            18
        );

        $display("");
        $display("========================================");
        $display("FINAL STATE");
        $display("PC:          0x%0h", debug_PC);
        $display("ACC:         0x%0h", debug_ACC);
        $display("R1:          0x%0h",
                 dut.register_file_inst.registers[1]);
        $display("R2:          0x%0h",
                 dut.register_file_inst.registers[2]);
        $display("R3:          0x%0h",
                 dut.register_file_inst.registers[3]);
        $display("INT_RET_REG: 0x%0h", debug_INT_RET_REG);
        $display("INT3 VECTOR: 0x%0h",
                 dut.isr_control_inst.ISRVectorTable[3]);
        $display("HALT:        %b", halt);
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
