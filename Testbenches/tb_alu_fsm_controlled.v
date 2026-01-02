`timescale 1ns / 1ps

module tb_alu_fsm_controlled;

    reg        clk;
    reg        start;
    reg [3:0]  opcode;
    reg [7:0]  A;
    reg [7:0]  B;

    wire [7:0] result;
    wire       busy;
    wire       done;

    // -----------------------------------------
    // DUT: ALU FSM
    // -----------------------------------------
    alu_fsm_controlled DUT (
        .clk(clk),
        .start(start),
        .opcode(opcode),
        .A(A),
        .B(B),
        .result(result),
        .busy(busy),
        .done(done)
    );

    // -----------------------------------------
    // Clock generation (10 ns period)
    // -----------------------------------------
    initial clk = 0;
    always #5 clk = ~clk;

    // -----------------------------------------
    // Task to apply one ALU operation
    // -----------------------------------------
    task run_op;
        input [3:0] op;
        input [7:0] a;
        input [7:0] b;
        begin
            @(negedge clk);
            opcode = op;
            A      = a;
            B      = b;
            start  = 1'b1;

            @(negedge clk);
            start  = 1'b0;

            // Wait for done
            wait(done);

            $display(
                "TIME=%0t | OPCODE=%b | A=%0d | B=%0d | RESULT=%0d",
                $time, op, a, b, result
            );

            @(negedge clk);
        end
    endtask

    // -----------------------------------------
    // Test sequence
    // -----------------------------------------
    initial begin
        // Init
        start  = 0;
        opcode = 0;
        A      = 0;
        B      = 0;

        // Wait for reset-less stabilization
        repeat(2) @(negedge clk);

        // ADD
        run_op(4'b0000, 8'd10, 8'd5);

        // SUB
        run_op(4'b0001, 8'd20, 8'd7);

        // AND
        run_op(4'b0010, 8'b10101010, 8'b11001100);

        // OR
        run_op(4'b0011, 8'b10101010, 8'b11001100);

        // XOR
        run_op(4'b0100, 8'b10101010, 8'b11001100);

        // NOT
        run_op(4'b0101, 8'b10101010, 8'b00000000);

        $display("ALU TESTBENCH COMPLETED SUCCESSFULLY");
        $stop;
    end

endmodule
