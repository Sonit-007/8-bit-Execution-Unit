// Signed Restoring Divider (8-bit)
// Quotient and Remainder
// FSM-controlled, multi-cycle

module signed_restoring_divider (
    input        clk,
    input        start,
    input  [7:0] A,        // dividend
    input  [7:0] B,        // divisor

    output reg [7:0] quotient,
    output reg [7:0] remainder,
    output            busy,
    output            done
);

    parameter IDLE      = 3'b000;
    parameter INIT      = 3'b001;
    parameter SHIFT     = 3'b010;
    parameter SUB       = 3'b011;
    parameter REST      = 3'b100;
    parameter COUNT_DEC = 3'b101;
    parameter DONE      = 3'b110;

    reg [2:0] state, next_state;

    reg [8:0] R;        // remainder (extra bit for sign)
    reg [7:0] Q;        // quotient
    reg [7:0] M;        // divisor magnitude
    reg [2:0] COUNT;    // loop counter
    reg       SIGN;     // quotient sign

    always @(posedge clk) begin
        state <= next_state;
    end

    always @(*) begin
        next_state = state;

        case (state)
            IDLE: begin
                if (start)
                    next_state = INIT;
            end

            INIT: begin
                next_state = SHIFT;
            end

            SHIFT: begin
                next_state = SUB;
            end

            SUB: begin
                if (R[8])        // subtraction went negative
                    next_state = REST;
                else
                    next_state = COUNT_DEC;
            end

            REST: begin
                next_state = COUNT_DEC;
            end

            COUNT_DEC: begin
                if (COUNT == 3'b000)
                    next_state = DONE;
                else
                    next_state = SHIFT;
            end

            DONE: begin
                next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

    always @(posedge clk) begin
        case (state)

            INIT: begin
                // Extract magnitudes
                Q     <= A[7] ? (~A + 1'b1) : A;
                M     <= B[7] ? (~B + 1'b1) : B;
                R     <= 9'b0;
                COUNT <= 3'd7;
                SIGN  <= A[7] ^ B[7];
            end

            SHIFT: begin
                {R, Q} <= {R, Q} << 1;
            end

            SUB: begin
                R <= R - M;
                if (!R[8])
                    Q[0] <= 1'b1;
            end

            REST: begin
                R <= R + M;
                Q[0] <= 1'b0;
            end

            COUNT_DEC: begin
                COUNT <= COUNT - 1'b1;
            end

            DONE: begin
                quotient  <= SIGN ? (~Q + 1'b1) : Q;
                remainder <= R[7:0];   // remainder kept positive
            end

        endcase
    end

    assign busy = (state != IDLE && state != DONE);
    assign done = (state == DONE);

endmodule
