`timescale 1ns / 1ps

module CPU_ARITH_IMM_TB;

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

    CPU_CORE dut (
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
                    expected
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

    initial begin
        tests_run = 0;
        tests_failed = 0;
        cycles = 0;

        rst = 1'b1;
        interrupts = {INT_LINES_WIDTH{1'b0}};

        $display("");
        $display("========================================");
        $display("CPU IMMEDIATE ARITHMETIC TEST");
        $display("========================================");

        repeat (2) @(posedge clk);

        @(negedge clk);
        rst = 1'b0;

        while ((halt !== 1'b1) && (cycles < MAX_CYCLES)) begin
            @(posedge clk);
            #1;
            cycles = cycles + 1;
        end

        tests_run = tests_run + 1;

        if (halt !== 1'b1) begin
            tests_failed = tests_failed + 1;
            $display("FAIL - Test 1: CPU timed out after %0d cycles", cycles);
        end
        else begin
            $display("PASS - Test 1: CPU halted after %0d cycles", cycles);
        end

        check_register(3'd1, 8'd10, 2);
        check_register(3'd2, 8'd7,  3);
        check_register(3'd3, 8'd28, 4);
        check_register(3'd4, 8'd4,  5);
        check_acc(8'd4, 6);

        $display("");
        $display("========================================");
        $display("FINAL STATE");
        $display("PC:  0x%0h", debug_PC);
        $display("ACC: 0x%0h", debug_ACC);
        $display("R1:  0x%0h", dut.register_file_inst.registers[1]);
        $display("R2:  0x%0h", dut.register_file_inst.registers[2]);
        $display("R3:  0x%0h", dut.register_file_inst.registers[3]);
        $display("R4:  0x%0h", dut.register_file_inst.registers[4]);
        $display("========================================");

        $display("");
        $display("Tests run:    %0d", tests_run);
        $display("Tests passed: %0d", tests_run - tests_failed);
        $display("Tests failed: %0d", tests_failed);

        if (tests_failed == 0)
            $display("RESULT: ALL TESTS PASSED");
        else
            $display("RESULT: TEST FAILURE");

        $finish;
    end

endmodule