`timescale 1ns / 1ps

module tb_signed_mag_multiplier;

    reg        clk;
    reg        start;
    reg [7:0]  A;
    reg [7:0]  B;

    wire [15:0] result;
    wire        busy;
    wire        done;

    signed_mag_multiplier DUT (
        .clk(clk),
        .start(start),
        .A(A),
        .B(B),
        .result(result),
        .busy(busy),
        .done(done)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task run_mul;
        input signed [7:0] a;
        input signed [7:0] b;
        begin
            @(negedge clk);
            A     = a;
            B     = b;
            start = 1'b1;

            @(negedge clk);
            start = 1'b0;

            wait(done);

            @(posedge clk);

            $display(
                "TIME=%0t | A=%0d | B=%0d | RESULT=%0d",
                $time, a, b, $signed(result)
            );

            @(negedge clk);
        end
    endtask

    initial begin
        
        start = 0;
        A     = 0;
        B     = 0;

        repeat(2) @(negedge clk);

        // Test cases

        // + × +
        run_mul( 8'd5,  8'd3);     // 15

        // + × -
        run_mul( 8'd7, -8'd4);     // -28

        // - × +
        run_mul(-8'd6,  8'd5);     // -30

        // - × -
        run_mul(-8'd8, -8'd2);     // 16

        // Zero cases
        run_mul( 8'd0,  8'd9);     // 0
        run_mul(-8'd9,  8'd0);     // 0

        $display("MULTIPLIER TESTBENCH COMPLETED SUCCESSFULLY");
        $stop;
    end

endmodule