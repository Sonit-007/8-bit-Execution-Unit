`timescale 1ns / 1ps

module tb_execution_unit_top;

    reg        clk;
    reg        start;
    reg [3:0]  opcode;
    reg [7:0]  A;
    reg [7:0]  B;

    wire [15:0] result;
    wire        busy;
    wire        done;

    // --------------------------------------------------
    // DUT: Execution Unit Top
    // --------------------------------------------------
    execution_unit_top DUT (
        .clk(clk),
        .start(start),
        .opcode(opcode),
        .A(A),
        .B(B),
        .result(result),
        .busy(busy),
        .done(done)
    );

    // --------------------------------------------------
    // Clock generation (10 ns period)
    // --------------------------------------------------
    initial clk = 0;
    always #5 clk = ~clk;

    // --------------------------------------------------
    // Task: run one instruction
    // --------------------------------------------------
    task run_inst;
        input [3:0] op;
        input signed [7:0] a;
        input signed [7:0] b;
        begin
            @(negedge clk);
            opcode = op;
            A      = a;
            B      = b;
            start  = 1'b1;

            @(negedge clk);
            start  = 1'b0;

            // Wait for completion
            wait(done);

            // Sample result cleanly
            @(posedge clk);

            $display(
                "TIME=%0t | OPCODE=%b | A=%0d | B=%0d | RESULT=%0d",
                $time, op, a, b, $signed(result)
            );

            @(negedge clk);
        end
    endtask

    // --------------------------------------------------
    // Test sequence
    // --------------------------------------------------
    initial begin
        // Init
        start  = 0;
        opcode = 0;
        A      = 0;
        B      = 0;

        // Let system settle
        repeat(2) @(negedge clk);

        // -------------------------------
        // ALU operations
        // -------------------------------
        run_inst(4'b0000,  8'd10,  8'd5);   // ADD → 15
        run_inst(4'b0001,  8'd20,  8'd7);   // SUB → 13
        run_inst(4'b0010,  8'hAA,  8'hCC);  // AND → 88
        run_inst(4'b0011,  8'hAA,  8'hCC);  // OR  → EE
        run_inst(4'b0100,  8'hAA,  8'hCC);  // XOR → 66
        run_inst(4'b0101,  8'hAA,  8'hCC);  // NOT → 77
        // -------------------------------
        // MULTIPLICATION
        // -------------------------------
        run_inst(4'b1000,  8'd6,   8'd5);   // MUL → 30

        // -------------------------------
        // DIVISION
        // -------------------------------
        run_inst(4'b1001,  8'd20,  8'd4);   // DIV → 5

        $display("EXECUTION UNIT TOP TESTBENCH COMPLETED SUCCESSFULLY");
        $stop;
    end

endmodule