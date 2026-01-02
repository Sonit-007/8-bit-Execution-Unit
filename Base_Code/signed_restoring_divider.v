// ======================================================
// Signed Restoring Divider (8-bit dividend / divisor)
// Quotient: 8-bit, Remainder: 8-bit
// FSM-controlled, multi-cycle
// ======================================================

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

    // --------------------------------------------------
    // FSM STATES
    // --------------------------------------------------
    typedef enum logic [2:0] {
        IDLE  = 3'b000,
        INIT  = 3'b001,
        SHIFT = 3'b010,
        SUB   = 3'b011,
        REST  = 3'b100,
        DONE  = 3'b101
    } state_t;

    state_t state, next_state;

    // --------------------------------------------------
    // DATAPATH REGISTERS
    // --------------------------------------------------
    reg [8:0]  R;        // remainder register (extra bit for sign)
    reg [7:0]  Q;        // quotient register
    reg [7:0]  M;        // divisor magnitude
    reg [2:0]  COUNT;    // iteration counter
    reg        SIGN;     // final quotient sign

    // --------------------------------------------------
    // STATE REGISTER
    // --------------------------------------------------
    always @(posedge clk)
        state <= next_state;

    // --------------------------------------------------
    // NEXT STATE LOGIC
    // --------------------------------------------------
    always @(*) begin
        next_state = state;

        case (state)
            IDLE:  if (start) next_state = INIT;
            INIT:  next_state = SHIFT;
            SHIFT: next_state = SUB;
            SUB:   next_state = (R[8] ? REST : SHIFT);
            REST:  next_state = (COUNT == 0 ? DONE : SHIFT);
            DONE:  next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // --------------------------------------------------
    // DATAPATH OPERATIONS
    // --------------------------------------------------
    always @(posedge clk) begin
        case (state)

            INIT: begin
                // Magnitude extraction
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
                COUNT <= COUNT - 1'b1;
            end

            DONE: begin
                quotient  <= SIGN ? (~Q + 1'b1) : Q;
                remainder <= R[7:0];  // keep remainder positive
            end

        endcase
    end

    // --------------------------------------------------
    // CONTROL SIGNALS
    // --------------------------------------------------
    assign busy = (state != IDLE && state != DONE);
    assign done = (state == DONE);

endmodule
