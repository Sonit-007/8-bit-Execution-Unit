// ALU with FSM-based control 
// - start / busy / done handshake

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

    parameter EXEC = 2'b01;   // operation executing
    parameter IDLE = 2'b00;   // waiting for start
    parameter DONE = 2'b10;   // operation completed

    reg [1:0] state, next_state;

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

    always @(posedge clk) begin
        state <= next_state;
    end

    always @(*) begin
        next_state = state;

        case (state)
            IDLE: begin
                if (start)
                    next_state = EXEC;
            end

            EXEC: begin
                next_state = DONE;
            end

            DONE: begin
                next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

    always @(posedge clk) begin
        if (state == EXEC) begin
            result <= alu_result;
            Z      <= Z_int;
            N      <= N_int;
            C      <= C_int;
            V      <= V_int;
        end
    end

    assign busy = (state == EXEC);
    assign done = (state == DONE);

endmodule