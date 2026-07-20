`timescale 1ns / 1ps

module ALU_TB;

    parameter REG_WIDTH = 8;
    parameter SUBOP_WIDTH = 2;

    reg ALU;

    reg [SUBOP_WIDTH-1:0] SubopField;
    reg [REG_WIDTH-1:0] regOut;
    reg [REG_WIDTH-1:0] imm;
    reg [REG_WIDTH-1:0] accOut;

    wire [REG_WIDTH-1:0] ALUOut;

    integer tests_run;
    integer tests_failed;

    /*
     * Device under test
     */
    ALU #(
        .REG_WIDTH(REG_WIDTH),
        .SUBOP_WIDTH(SUBOP_WIDTH)
    ) dut (
        .ALU(ALU),
        .SubopField(SubopField),
        .regOut(regOut),
        .imm(imm),
        .accOut(accOut),
        .ALUOut(ALUOut)
    );

    /*
     * Applies one ALU test and checks the result.
     *
     * ALU = 0 selects imm as the second operand.
     * ALU = 1 selects accOut as the second operand.
     */
    task check_alu;
        input operand_select;
        input [SUBOP_WIDTH-1:0] operation;
        input [REG_WIDTH-1:0] reg_value;
        input [REG_WIDTH-1:0] immediate_value;
        input [REG_WIDTH-1:0] accumulator_value;
        input [REG_WIDTH-1:0] expected;
        input integer test_number;

        begin
            tests_run = tests_run + 1;

            ALU = operand_select;
            SubopField = operation;
            regOut = reg_value;
            imm = immediate_value;
            accOut = accumulator_value;

            /*
             * Allow combinational logic to settle.
             */
            #1;

            if (ALUOut !== expected) begin
                tests_failed = tests_failed + 1;

                $display(
                    "FAIL - Test %0d: expected ALUOut = 0x%0h, actual = 0x%0h",
                    test_number,
                    expected,
                    ALUOut
                );
            end
            else begin
                $display(
                    "PASS - Test %0d: ALUOut = 0x%0h",
                    test_number,
                    ALUOut
                );
            end
        end
    endtask

    /*
     * Division by zero does not have a defined numerical result in
     * the current ALU design. Most simulators produce X values.
     *
     * The reduction XOR becomes X when any output bit is unknown.
     */
    task check_divide_by_zero;
        input operand_select;
        input [REG_WIDTH-1:0] numerator;
        input integer test_number;

        begin
            tests_run = tests_run + 1;

            ALU = operand_select;
            SubopField = 2'b11;
            regOut = numerator;

            if (operand_select == 1'b0) begin
                imm = {REG_WIDTH{1'b0}};
                accOut = 8'h55;
            end
            else begin
                imm = 8'h55;
                accOut = {REG_WIDTH{1'b0}};
            end

            #1;

            if (^ALUOut === 1'bx) begin
                $display(
                    "PASS - Test %0d: divide by zero produced unknown result",
                    test_number
                );
            end
            else begin
                tests_failed = tests_failed + 1;

                $display(
                    "FAIL - Test %0d: divide by zero unexpectedly produced 0x%0h",
                    test_number,
                    ALUOut
                );
            end
        end
    endtask

    initial begin
        tests_run = 0;
        tests_failed = 0;

        ALU = 1'b0;
        SubopField = 2'b00;
        regOut = {REG_WIDTH{1'b0}};
        imm = {REG_WIDTH{1'b0}};
        accOut = {REG_WIDTH{1'b0}};

        $display("");
        $display("========================================");
        $display("ALU TESTBENCH");
        $display("========================================");

        /*
         * Immediate-mode addition
         *
         * ALU = 0 selects imm.
         */
        check_alu(
            1'b0,
            2'b00,
            8'h05,
            8'h03,
            8'h70,
            8'h08,
            1
        );

        /*
         * Register/accumulator-mode addition
         *
         * ALU = 1 selects accOut.
         */
        check_alu(
            1'b1,
            2'b00,
            8'h12,
            8'h60,
            8'h08,
            8'h1A,
            2
        );

        /*
         * Addition with zero.
         */
        check_alu(
            1'b0,
            2'b00,
            8'hA5,
            8'h00,
            8'h37,
            8'hA5,
            3
        );

        /*
         * Addition overflow.
         *
         * 0xFF + 0x01 = 0x100, but only the lower eight bits
         * are retained, so the expected result is 0x00.
         */
        check_alu(
            1'b0,
            2'b00,
            8'hFF,
            8'h01,
            8'h00,
            8'h00,
            4
        );

        /*
         * Immediate-mode subtraction.
         */
        check_alu(
            1'b0,
            2'b01,
            8'h0A,
            8'h03,
            8'h50,
            8'h07,
            5
        );

        /*
         * Accumulator-mode subtraction.
         */
        check_alu(
            1'b1,
            2'b01,
            8'h20,
            8'h01,
            8'h08,
            8'h18,
            6
        );

        /*
         * Subtract equal operands.
         */
        check_alu(
            1'b1,
            2'b01,
            8'h5A,
            8'h20,
            8'h5A,
            8'h00,
            7
        );

        /*
         * Subtraction underflow.
         *
         * 0x00 - 0x01 wraps to 0xFF in an unsigned
         * eight-bit result.
         */
        check_alu(
            1'b0,
            2'b01,
            8'h00,
            8'h01,
            8'h20,
            8'hFF,
            8
        );

        /*
         * Immediate-mode multiplication.
         */
        check_alu(
            1'b0,
            2'b10,
            8'h06,
            8'h07,
            8'h30,
            8'h2A,
            9
        );

        /*
         * Accumulator-mode multiplication.
         */
        check_alu(
            1'b1,
            2'b10,
            8'h09,
            8'h40,
            8'h05,
            8'h2D,
            10
        );

        /*
         * Multiplication by zero.
         */
        check_alu(
            1'b0,
            2'b10,
            8'hA7,
            8'h00,
            8'h20,
            8'h00,
            11
        );

        /*
         * Multiplication overflow/truncation.
         *
         * 0x20 * 0x10 = 0x0200. The eight-bit ALU output
         * retains only the lower eight bits, producing 0x00.
         */
        check_alu(
            1'b0,
            2'b10,
            8'h20,
            8'h10,
            8'h02,
            8'h00,
            12
        );

        /*
         * Another multiplication truncation case.
         *
         * 0xFF * 0x02 = 0x01FE, producing 0xFE after truncation.
         */
        check_alu(
            1'b0,
            2'b10,
            8'hFF,
            8'h02,
            8'h10,
            8'hFE,
            13
        );

        /*
         * Immediate-mode division.
         */
        check_alu(
            1'b0,
            2'b11,
            8'h20,
            8'h04,
            8'h02,
            8'h08,
            14
        );

        /*
         * Accumulator-mode division.
         */
        check_alu(
            1'b1,
            2'b11,
            8'h64,
            8'h05,
            8'h0A,
            8'h0A,
            15
        );

        /*
         * Integer division truncates the fractional remainder.
         *
         * 10 / 3 = 3 with remainder 1.
         */
        check_alu(
            1'b0,
            2'b11,
            8'h0A,
            8'h03,
            8'h50,
            8'h03,
            16
        );

        /*
         * Zero divided by a nonzero operand.
         */
        check_alu(
            1'b1,
            2'b11,
            8'h00,
            8'h20,
            8'h07,
            8'h00,
            17
        );

        /*
         * Verify that ALU = 0 selects imm rather than accOut.
         *
         * 0x10 + imm 0x02 = 0x12.
         * Using accOut incorrectly would produce 0x50.
         */
        check_alu(
            1'b0,
            2'b00,
            8'h10,
            8'h02,
            8'h40,
            8'h12,
            18
        );

        /*
         * Verify that ALU = 1 selects accOut rather than imm.
         *
         * 0x10 + accOut 0x40 = 0x50.
         * Using imm incorrectly would produce 0x12.
         */
        check_alu(
            1'b1,
            2'b00,
            8'h10,
            8'h02,
            8'h40,
            8'h50,
            19
        );

        /*
         * Maximum-value subtraction without underflow.
         */
        check_alu(
            1'b0,
            2'b01,
            8'hFF,
            8'hFF,
            8'h01,
            8'h00,
            20
        );

        /*
         * Division by zero behavior.
         */
        check_divide_by_zero(
            1'b0,
            8'h64,
            21
        );

        check_divide_by_zero(
            1'b1,
            8'h64,
            22
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