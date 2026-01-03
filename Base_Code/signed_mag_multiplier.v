// Signed-Magnitude Multiplier (8-bit)
// FSM-controlled, multi-cycle, shift-add algorithm

module signed_mag_multiplier (
    input        clk,
    input        start,
    input  [7:0] A,
    input  [7:0] B,

    output reg [15:0] result,
    output            busy,
    output            done
);

    parameter IDLE      = 3'b000;
    parameter INIT      = 3'b001;
    parameter CHECK     = 3'b010;
    parameter ADD       = 3'b011;
    parameter SHIFT     = 3'b100;
    parameter COUNT_DEC = 3'b101;
    parameter DONE      = 3'b110;

    reg [2:0] state, next_state;

    reg [7:0] M;        // multiplicand magnitude
    reg [7:0] Q;        // multiplier magnitude
    reg [7:0] ACC;      // accumulator
    reg [2:0] COUNT;    // loop counter
    reg       SIGN;     // final sign

    always @(posedge clk) begin
        state <= next_state;
    end

    // NEXT STATE LOGIC
    always @(*) begin
        next_state = state;

        case (state)
            IDLE: begin
                if (start)
                    next_state = INIT;
            end

            INIT: begin
                next_state = CHECK;
            end

            CHECK: begin
                if (Q[0])
                    next_state = ADD;
                else
                    next_state = SHIFT;
            end

            ADD: begin
                next_state = SHIFT;
            end

            SHIFT: begin
                next_state = COUNT_DEC;
            end

            COUNT_DEC: begin
                if (COUNT == 3'b000)
                    next_state = DONE;
                else
                    next_state = CHECK;
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
                M     <= A[7] ? (~A + 1'b1) : A;
                Q     <= B[7] ? (~B + 1'b1) : B;
                ACC   <= 8'b0;
                COUNT <= 3'd7;
                SIGN  <= A[7] ^ B[7];
            end

            ADD: begin
                ACC <= ACC + M;
            end

            SHIFT: begin
                {ACC, Q} <= {ACC, Q} >> 1;
            end

            COUNT_DEC: begin
                COUNT <= COUNT - 1'b1;
            end

            DONE: begin
                result <= SIGN ? (~{ACC, Q} + 1'b1) : {ACC, Q};
            end

        endcase
    end

    assign busy = (state != IDLE && state != DONE);
    assign done = (state == DONE);

endmodule
