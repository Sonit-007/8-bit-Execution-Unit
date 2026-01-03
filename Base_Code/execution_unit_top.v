// CPU-Style Execution Unit Top
// ALU (single-cycle) + MUL & DIV (multi-cycle)

module execution_unit_top (
    input        clk,
    input        start,
    input  [3:0] opcode,
    input  [7:0] A,
    input  [7:0] B,

    output reg [15:0] result,
    output            busy,
    output            done
);

    wire [7:0] alu_result;
    wire       alu_busy, alu_done;

    alu_fsm_controlled U_ALU (
        .clk(clk),
        .start(start && (opcode < 4'b1000)), // ALU ops only
        .A(A),
        .B(B),
        .opcode(opcode),
        .result(alu_result),
        .busy(alu_busy),
        .done(alu_done)
    );

    // MULTIPLIER UNIT (16-bit result)
    wire [15:0] mul_result;
    wire        mul_busy, mul_done;

    signed_mag_multiplier U_MUL (
        .clk(clk),
        .start(start && (opcode == 4'b1000)),
        .A(A),
        .B(B),
        .result(mul_result),
        .busy(mul_busy),
        .done(mul_done)
    );

    // DIVIDER UNIT (8-bit quotient, remainder ignored)
    wire [7:0] div_quotient;
    wire [7:0] div_remainder;
    wire       div_busy, div_done;

    signed_restoring_divider U_DIV (
        .clk(clk),
        .start(start && (opcode == 4'b1001)),
        .A(A),
        .B(B),
        .quotient(div_quotient),
        .remainder(div_remainder),
        .busy(div_busy),
        .done(div_done)
    );

    // GLOBAL BUSY / DONE
    assign busy = alu_busy | mul_busy | div_busy;
    assign done = alu_done | mul_done | div_done;

    // RESULT SELECTION (CPU-style MUX)

    always @(*) begin
        case (opcode)
            4'b1000: result = mul_result;               // MUL
            4'b1001: result = {8'b0, div_quotient};     // DIV (quotient only)
            default: result = {8'b0, alu_result};       // ALU ops
        endcase
    end

endmodule