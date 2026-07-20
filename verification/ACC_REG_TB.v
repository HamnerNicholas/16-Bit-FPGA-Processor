`timescale 1ns / 1ps

module ACC_REG_TB;

    parameter REG_WIDTH = 8;
    parameter CLK_PERIOD = 20;

    reg clk;
    reg halt;
    reg rst;
    reg ALUI;
    reg ALU;
    reg load;
    reg ReadJalRegisters;

    reg [REG_WIDTH-1:0] ALUOut;
    reg [REG_WIDTH-1:0] globalOut;
    reg [REG_WIDTH-1:0] JALRegOut;

    wire [REG_WIDTH-1:0] accOut;

    integer tests_run;
    integer tests_failed;

    ACCUMULATOR_REGISTER #(
        .REG_WIDTH(REG_WIDTH)
    ) dut (
        .clk(clk),
        .halt(halt),
        .rst(rst),
        .ALUI(ALUI),
        .ALU(ALU),
        .load(load),
        .ReadJalRegisters(ReadJalRegisters),
        .ALUOut(ALUOut),
        .globalOut(globalOut),
        .JALRegOut(JALRegOut),
        .accOut(accOut)
    );

    /*
     * Clock generation
     *
     * 20 ns clock period = 50 MHz.
     */
    initial begin
        clk = 1'b0;

        forever begin
            #(CLK_PERIOD / 2);
            clk = ~clk;
        end
    end

    /*
     * Reset all DUT inputs to known values.
     */
    task clear_inputs;
        begin
            halt = 1'b0;
            rst = 1'b0;
            ALUI = 1'b0;
            ALU = 1'b0;
            load = 1'b0;
            ReadJalRegisters = 1'b0;

            ALUOut = {REG_WIDTH{1'b0}};
            globalOut = {REG_WIDTH{1'b0}};
            JALRegOut = {REG_WIDTH{1'b0}};
        end
    endtask

    /*
     * Wait for the next positive clock edge, then compare accOut
     * against the expected value.
     *
     * test_number is used instead of a SystemVerilog string because
     * this testbench is written in Verilog-2001.
     */
    task check_accumulator;
        input [REG_WIDTH-1:0] expected;
        input integer test_number;

        begin
            tests_run = tests_run + 1;

            @(posedge clk);

            /*
             * Allow the DUT's nonblocking assignment to complete
             * before checking accOut.
             */
            #1;

            if (accOut !== expected) begin
                tests_failed = tests_failed + 1;

                $display(
                    "FAIL - Test %0d: expected accOut = 0x%0h, actual = 0x%0h",
                    test_number,
                    expected,
                    accOut
                );
            end
            else begin
                $display(
                    "PASS - Test %0d: accOut = 0x%0h",
                    test_number,
                    accOut
                );
            end
        end
    endtask

    initial begin
        tests_run = 0;
        tests_failed = 0;

        clear_inputs;

        $display("");
        $display("========================================");
        $display("ACCUMULATOR REGISTER TESTBENCH");
        $display("========================================");

        /*
         * Test 1:
         * Reset clears the accumulator.
         */
        rst = 1'b1;

        check_accumulator(
            8'h00,
            1
        );

        rst = 1'b0;

        /*
         * Test 2:
         * ALUI causes ALUOut to be written.
         */
        ALUI = 1'b1;
        ALUOut = 8'h35;

        check_accumulator(
            8'h35,
            2
        );

        ALUI = 1'b0;

        /*
         * Test 3:
         * ALU causes ALUOut to be written.
         */
        ALU = 1'b1;
        ALUOut = 8'hA7;

        check_accumulator(
            8'hA7,
            3
        );

        ALU = 1'b0;

        /*
         * Test 4:
         * load selects globalOut.
         */
        load = 1'b1;
        ALUOut = 8'h11;
        globalOut = 8'hC4;

        check_accumulator(
            8'hC4,
            4
        );

        load = 1'b0;

        /*
         * Test 5:
         * ReadJalRegisters selects JALRegOut.
         */
        ReadJalRegisters = 1'b1;

        ALUOut = 8'h22;
        globalOut = 8'h33;
        JALRegOut = 8'hE8;

        check_accumulator(
            8'hE8,
            5
        );

        ReadJalRegisters = 1'b0;

        /*
         * Test 6:
         * No enable signals means the accumulator holds its value.
         */
        ALUOut = 8'h01;
        globalOut = 8'h02;
        JALRegOut = 8'h03;

        check_accumulator(
            8'hE8,
            6
        );

        /*
         * Test 7:
         * halt prevents an ALUI write.
         */
        halt = 1'b1;
        ALUI = 1'b1;
        ALUOut = 8'h55;

        check_accumulator(
            8'hE8,
            7
        );

        ALUI = 1'b0;

        /*
         * Test 8:
         * halt prevents a load write.
         */
        load = 1'b1;
        globalOut = 8'h66;

        check_accumulator(
            8'hE8,
            8
        );

        load = 1'b0;

        /*
         * Test 9:
         * Reset must still work while the CPU is halted.
         */
        rst = 1'b1;

        check_accumulator(
            8'h00,
            9
        );

        rst = 1'b0;
        halt = 1'b0;

        /*
         * Test 10:
         * Initialize the accumulator for priority testing.
         */
        ALUI = 1'b1;
        ALUOut = 8'h10;

        check_accumulator(
            8'h10,
            10
        );

        ALUI = 1'b0;

        /*
         * Test 11:
         * load has priority over ALUOut.
         */
        ALUI = 1'b1;
        ALU = 1'b1;
        load = 1'b1;

        ALUOut = 8'h44;
        globalOut = 8'h99;

        check_accumulator(
            8'h99,
            11
        );

        ALUI = 1'b0;
        ALU = 1'b0;
        load = 1'b0;

        /*
         * Test 12:
         * ReadJalRegisters has priority over load and ALUOut.
         */
        ALUI = 1'b1;
        ALU = 1'b1;
        load = 1'b1;
        ReadJalRegisters = 1'b1;

        ALUOut = 8'h12;
        globalOut = 8'h34;
        JALRegOut = 8'h56;

        check_accumulator(
            8'h56,
            12
        );

        ALUI = 1'b0;
        ALU = 1'b0;
        load = 1'b0;
        ReadJalRegisters = 1'b0;

        /*
         * Test 13:
         * Changing data inputs without an enable must not update ACC.
         */
        ALUOut = 8'hAA;
        globalOut = 8'hBB;
        JALRegOut = 8'hCC;

        check_accumulator(
            8'h56,
            13
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