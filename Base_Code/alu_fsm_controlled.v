// ======================================================
// ALU with FSM-based control (Phase 2.3)
// - Pure combinational ALU datapath
// - Explicit FSM for operation lifecycle
// - Registered outputs
// - start / busy / done handshake
// ======================================================

module alu_fsm_controlled (
    input        clk,
    input        start,
    input  [7:0] A,
    input  [7:0] B,
    input  [3:0] opcode,

    output reg [7:0] result,
    output reg       Z,
    output reg       N,
    output reg       C,
    output reg       V,

    output            busy,
    output            done
);

    // --------------------------------------------------
    // FSM STATE DEFINITIONS
    // --------------------------------------------------
    typedef enum logic [1:0] {
        IDLE = 2'b00,   // waiting for start
        EXEC = 2'b01,   // operation executing
        DONE = 2'b10    // operation just completed
    } state_t;

    state_t state, next_state;

    // --------------------------------------------------
    // COMBINATIONAL ALU (DATAPATH)
    // --------------------------------------------------
    wire [7:0] alu_result;
    wire Z_int, N_int, C_int, V_int;

    alu_top U_ALU (
        .A(A),
        .B(B),
        .opcode(opcode),
        .result(alu_result),
        .Z(Z_int),
        .N(N_int),
        .C(C_int),
        .V(V_int)
    );

    // --------------------------------------------------
    // STATE REGISTER (TIME MEMORY)
    // --------------------------------------------------
    always @(posedge clk) begin
        state <= next_state;
    end

    // --------------------------------------------------
    // NEXT-STATE LOGIC (CONTROL DECISIONS)
    // --------------------------------------------------
    always @(*) begin
        next_state = state;

        case (state)
            IDLE: begin
                if (start)
                    next_state = EXEC;
            end

            EXEC: begin
                // Single-cycle operations complete here
                next_state = DONE;
            end

            DONE: begin
                // DONE is a transient state (one cycle only)
                next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

    // --------------------------------------------------
    // REGISTERED OUTPUT CAPTURE
    // --------------------------------------------------
    always @(posedge clk) begin
        if (state == EXEC) begin
            result <= alu_result;
            Z      <= Z_int;
            N      <= N_int;
            C      <= C_int;
            V      <= V_int;
        end
    end

    // --------------------------------------------------
    // CONTROL SIGNALS DERIVED FROM STATE
    // --------------------------------------------------
    assign busy = (state == EXEC);
    assign done = (state == DONE);

endmodule
