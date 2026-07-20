`timescale 1ns / 1ps

module PC_TB;

    parameter WIDTH = 16;
    parameter ADDR_WIDTH = 16;
    parameter IMM_WIDTH = 8;
    parameter SUBOP_WIDTH = 2;
    parameter CLK_PERIOD = 20;

    reg clk;
    reg rst;
    reg halt;
    reg RINT;
    reg RAReturn;
    reg RALoad;
    reg ISRJumpControl;
    reg beq;

    reg [WIDTH-1:0] INT_RET_REG;
    reg [WIDTH-1:0] ISR_VECTOR;
    reg [WIDTH-1:0] RAOut;

    reg [IMM_WIDTH-1:0] regOut;
    reg [IMM_WIDTH-1:0] accOut;
    reg [IMM_WIDTH-1:0] imm;

    reg [SUBOP_WIDTH-1:0] SubopField;

    wire [WIDTH-1:0] PCOut;

    integer tests_run;
    integer tests_failed;

    PC #(
        .WIDTH(WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .IMM_WIDTH(IMM_WIDTH),
        .SUBOP_WIDTH(SUBOP_WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .halt(halt),
        .RINT(RINT),
        .RAReturn(RAReturn),
        .RALoad(RALoad),
        .ISRJumpControl(ISRJumpControl),
        .beq(beq),

        .INT_RET_REG(INT_RET_REG),
        .ISR_VECTOR(ISR_VECTOR),
        .RAOut(RAOut),
        .regOut(regOut),
        .accOut(accOut),
        .imm(imm),
        .SubopField(SubopField),

        .PCOut(PCOut)
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
     * Return all controls and data inputs to inactive values.
     *
     * This task does not modify rst or halt because those signals are
     * often deliberately held across a test.
     */
    task clear_controls;
        begin
            RINT = 1'b0;
            RAReturn = 1'b0;
            RALoad = 1'b0;
            ISRJumpControl = 1'b0;
            beq = 1'b0;

            INT_RET_REG = {WIDTH{1'b0}};
            ISR_VECTOR = {WIDTH{1'b0}};
            RAOut = {WIDTH{1'b0}};

            regOut = {IMM_WIDTH{1'b0}};
            accOut = {IMM_WIDTH{1'b0}};
            imm = {IMM_WIDTH{1'b0}};

            SubopField = 2'b00;
        end
    endtask

    /*
     * Wait for the next active clock edge and verify PCOut.
     */
    task check_pc;
        input [WIDTH-1:0] expected;
        input integer test_number;

        begin
            tests_run = tests_run + 1;

            @(posedge clk);
            #1;

            if (PCOut !== expected) begin
                tests_failed = tests_failed + 1;

                $display(
                    "FAIL - Test %0d: expected PC = 0x%0h, actual PC = 0x%0h",
                    test_number,
                    expected,
                    PCOut
                );
            end
            else begin
                $display(
                    "PASS - Test %0d: PC = 0x%0h",
                    test_number,
                    PCOut
                );
            end
        end
    endtask

    initial begin
        tests_run = 0;
        tests_failed = 0;

        rst = 1'b0;
        halt = 1'b0;

        clear_controls;

        $display("");
        $display("========================================");
        $display("PROGRAM COUNTER TESTBENCH");
        $display("========================================");

        /*
         * Test 1:
         * Reset clears the PC.
         */
        rst = 1'b1;

        check_pc(
            16'h0000,
            1
        );

        rst = 1'b0;

        /*
         * Test 2:
         * Normal execution increments PC by one.
         */
        clear_controls;

        check_pc(
            16'h0001,
            2
        );

        /*
         * Test 3:
         * Halt prevents PC updates.
         */
        halt = 1'b1;

        check_pc(
            16'h0001,
            3
        );

        /*
         * Test 4:
         * Normal increment resumes after halt is removed.
         */
        halt = 1'b0;

        check_pc(
            16'h0002,
            4
        );

        /*
         * Test 5:
         * Equal branch is taken.
         *
         * Current PC = 2
         * Immediate = +5
         * Expected PC = 7
         */
        clear_controls;

        beq = 1'b1;
        SubopField = 2'b00;
        regOut = 8'h35;
        accOut = 8'h35;
        imm = 8'h05;

        check_pc(
            16'h0007,
            5
        );

        /*
         * Test 6:
         * Equal branch is not taken.
         *
         * Current PC = 7
         * Expected PC = 8
         */
        clear_controls;

        beq = 1'b1;
        SubopField = 2'b00;
        regOut = 8'h10;
        accOut = 8'h20;
        imm = 8'h05;

        check_pc(
            16'h0008,
            6
        );

        /*
         * Test 7:
         * Not-equal branch is taken.
         *
         * Current PC = 8
         * Immediate = +3
         * Expected PC = 11
         */
        clear_controls;

        beq = 1'b1;
        SubopField = 2'b01;
        regOut = 8'h12;
        accOut = 8'h34;
        imm = 8'h03;

        check_pc(
            16'h000B,
            7
        );

        /*
         * Test 8:
         * Not-equal branch is not taken.
         */
        clear_controls;

        beq = 1'b1;
        SubopField = 2'b01;
        regOut = 8'h44;
        accOut = 8'h44;
        imm = 8'h06;

        check_pc(
            16'h000C,
            8
        );

        /*
         * Test 9:
         * Signed less-than branch is taken.
         *
         * regOut = 0xFE = -2 signed
         * accOut = 0x01 = +1 signed
         *
         * Current PC = 12
         * Immediate = +4
         * Expected PC = 16
         */
        clear_controls;

        beq = 1'b1;
        SubopField = 2'b10;
        regOut = 8'hFE;
        accOut = 8'h01;
        imm = 8'h04;

        check_pc(
            16'h0010,
            9
        );

        /*
         * Test 10:
         * Signed less-than branch is not taken.
         */
        clear_controls;

        beq = 1'b1;
        SubopField = 2'b10;
        regOut = 8'h05;
        accOut = 8'h01;
        imm = 8'h04;

        check_pc(
            16'h0011,
            10
        );

        /*
         * Test 11:
         * Subop 11 performs an unconditional relative jump when beq
         * is asserted.
         *
         * Current PC = 17
         * Immediate = +6
         * Expected PC = 23
         */
        clear_controls;

        beq = 1'b1;
        SubopField = 2'b11;
        imm = 8'h06;

        check_pc(
            16'h0017,
            11
        );

        /*
         * Test 12:
         * Subop 11 does not jump when beq is low.
         */
        clear_controls;

        beq = 1'b0;
        SubopField = 2'b11;
        imm = 8'h06;

        check_pc(
            16'h0018,
            12
        );

        /*
         * Test 13:
         * Negative immediates are sign extended.
         *
         * Current PC = 24
         * Immediate 0xFC = -4
         * Expected PC = 20
         */
        clear_controls;

        beq = 1'b1;
        SubopField = 2'b00;
        regOut = 8'h55;
        accOut = 8'h55;
        imm = 8'hFC;

        check_pc(
            16'h0014,
            13
        );

        /*
         * Test 14:
         * RALoad causes a relative PC update independently of the
         * branch comparator.
         *
         * Current PC = 20
         * Immediate = +10
         * Expected PC = 30
         */
        clear_controls;

        RALoad = 1'b1;
        imm = 8'h0A;

        check_pc(
            16'h001E,
            14
        );

        /*
         * Test 15:
         * RAReturn loads RAOut directly into the PC.
         */
        clear_controls;

        RAReturn = 1'b1;
        RAOut = 16'h1234;

        check_pc(
            16'h1234,
            15
        );

        /*
         * Test 16:
         * ISRJumpControl loads ISR_VECTOR directly.
         */
        clear_controls;

        ISRJumpControl = 1'b1;
        ISR_VECTOR = 16'hABCD;

        check_pc(
            16'hABCD,
            16
        );

        /*
         * Test 17:
         * RINT loads the saved interrupt return address.
         */
        clear_controls;

        RINT = 1'b1;
        INT_RET_REG = 16'h0F00;

        check_pc(
            16'h0F00,
            17
        );

        /*
         * Test 18:
         * RINT overrides branch, return-address, and ISR controls.
         */
        clear_controls;

        RINT = 1'b1;
        RAReturn = 1'b1;
        RALoad = 1'b1;
        ISRJumpControl = 1'b1;
        beq = 1'b1;

        INT_RET_REG = 16'h2222;
        RAOut = 16'h3333;
        ISR_VECTOR = 16'h4444;

        SubopField = 2'b11;
        imm = 8'h20;

        check_pc(
            16'h2222,
            18
        );

        /*
         * Test 19:
         * RAReturn and ISRJumpControl asserted simultaneously.
         *
         * The current RTL explicitly maps third_mux_control 2'b11
         * to zero.
         */
        clear_controls;

        RAReturn = 1'b1;
        ISRJumpControl = 1'b1;

        RAOut = 16'h1111;
        ISR_VECTOR = 16'h5555;

        check_pc(
            16'h0000,
            19
        );

        /*
         * Test 20:
         * Reset overrides halt and all control inputs.
         */
        clear_controls;

        halt = 1'b1;
        rst = 1'b1;

        RINT = 1'b1;
        INT_RET_REG = 16'hFFFF;

        check_pc(
            16'h0000,
            20
        );

        rst = 1'b0;

        /*
         * Test 21:
         * PC remains held while halt remains asserted after reset.
         */
        clear_controls;

        check_pc(
            16'h0000,
            21
        );

        /*
         * Test 22:
         * PC resumes incrementing when halt is removed.
         */
        halt = 1'b0;

        check_pc(
            16'h0001,
            22
        );

        /*
         * Test 23:
         * A valid branch condition must still be ignored when beq is
         * not asserted.
         */
        clear_controls;

        beq = 1'b0;
        SubopField = 2'b00;
        regOut = 8'h99;
        accOut = 8'h99;
        imm = 8'h20;

        check_pc(
            16'h0002,
            23
        );

        /*
         * Test 24:
         * ISRJumpControl has priority over a taken branch.
         */
        clear_controls;

        ISRJumpControl = 1'b1;
        ISR_VECTOR = 16'h8000;

        beq = 1'b1;
        SubopField = 2'b00;
        regOut = 8'h01;
        accOut = 8'h01;
        imm = 8'h10;

        check_pc(
            16'h8000,
            24
        );

        /*
         * Test 25:
         * RAReturn has priority over a taken branch.
         */
        clear_controls;

        RAReturn = 1'b1;
        RAOut = 16'h4000;

        beq = 1'b1;
        SubopField = 2'b11;
        imm = 8'h30;

        check_pc(
            16'h4000,
            25
        );

        /*
         * Test 26:
         * Halt prevents RINT from changing the PC.
         *
         * halt is checked before the selected PC input is stored.
         */
        clear_controls;

        halt = 1'b1;
        RINT = 1'b1;
        INT_RET_REG = 16'h7777;

        check_pc(
            16'h4000,
            26
        );

        halt = 1'b0;

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