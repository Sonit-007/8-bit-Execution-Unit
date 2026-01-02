`timescale 1ns / 1ps

module tb_signed_restoring_divider;

    reg        clk;
    reg        start;
    reg [7:0]  A;   // dividend
    reg [7:0]  B;   // divisor

    wire [7:0] quotient;
    wire [7:0] remainder;
    wire       busy;
    wire       done;

    // --------------------------------------------------
    // DUT: Signed Restoring Divider
    // --------------------------------------------------
    signed_restoring_divider DUT (
        .clk(clk),
        .start(start),
        .A(A),
        .B(B),
        .quotient(quotient),
        .remainder(remainder),
        .busy(busy),
        .done(done)
    );

    // --------------------------------------------------
    // Clock generation (10 ns period)
    // --------------------------------------------------
    initial clk = 0;
    always #5 clk = ~clk;

    // --------------------------------------------------
    // Task: run one division
    // --------------------------------------------------
    task run_div;
        input signed [7:0] a;
        input signed [7:0] b;
        begin
            @(negedge clk);
            A     = a;
            B     = b;
            start = 1'b1;

            @(negedge clk);
            start = 1'b0;

            // Wait until division completes
            wait(done);

            // Sample outputs cleanly
            @(posedge clk);

            $display(
                "TIME=%0t | A=%0d | B=%0d | QUOT=%0d | REM=%0d",
                $time, a, b, $signed(quotient), remainder
            );

            @(negedge clk);
        end
    endtask

    // --------------------------------------------------
    // Test sequence
    // --------------------------------------------------
    initial begin
        // Init
        start = 0;
        A     = 0;
        B     = 1;

        // Allow FSM to settle
        repeat(2) @(negedge clk);

        // -------------------------------
        // Test cases
        // -------------------------------

        // + / +
        run_div( 8'd13,  8'd3);   // 4 r 1

        // + / -
        run_div( 8'd20, -8'd4);   // -5 r 0

        // - / +
        run_div(-8'd18,  8'd3);   // -6 r 0

        // - / -
        run_div(-8'd21, -8'd7);   // 3 r 0

        // Dividend < divisor
        run_div( 8'd5,  8'd9);    // 0 r 5

        // Zero dividend
        run_div( 8'd0,  8'd6);    // 0 r 0

        $display("DIVIDER TESTBENCH COMPLETED SUCCESSFULLY");
        $stop;
    end

endmodule
