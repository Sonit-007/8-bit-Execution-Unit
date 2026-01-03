// 8-bit ALU 
// Supports ADD, SUB, AND, OR, XOR, NOT

module alu_top (
    input  [7:0] A,       
    input  [7:0] B,        
    input  [3:0] opcode,   

    output reg [7:0] result, 
    output        Z,         // Zero flag
    output        N,         // Negative flag
    output        C,         // Carry flag
    output        V          // Overflow flag
);

    // ADD / SUB control
    // SUB is selected when opcode = 0001

    wire is_sub = (opcode == 4'b0001);

    // For subtraction:
    // A - B = A + ~B + 1
    wire [7:0] B_mod = is_sub ? ~B : B;
    wire       cin   = is_sub ? 1'b1 : 1'b0;

    wire [7:0] add_sum;
    wire       add_cout;

    adder_8bit U_ADD (
        .a   (A),
        .b   (B_mod),
        .cin (cin),
        .sum (add_sum),
        .cout(add_cout)
    );

    // Logic unit
    wire [7:0] logic_out;

    logic_unit U_LOGIC (
        .a   (A),
        .b   (B),
        .sel (opcode[2:0]),
        .y   (logic_out)
    );

    // Result selection multiplexer

    always @(*) begin
        case (opcode)
            4'b0000, // ADD
            4'b0001: // SUB
                result = add_sum;

            4'b0010, // AND
            4'b0011, // OR
            4'b0100, // XOR
            4'b0101: // NOT
                result = logic_out;

            default:
                result = 8'b0;
        endcase
    end

    // Zero flag: result is all zeros
    assign Z = (result == 8'b0);

    // Negative flag: MSB of result (2's complement sign bit)
    assign N = result[7];

    // Carry flag: valid only for ADD and SUB
    assign C = add_cout & (opcode == 4'b0000 || opcode == 4'b0001);

    // Overflow flag (signed arithmetic)
    // ADD: same sign inputs, different sign output
    // SUB: different sign inputs, output sign differs from A
    assign V = (opcode == 4'b0000) ?
               (~(A[7] ^ B[7]) & (A[7] ^ result[7])) :
               (opcode == 4'b0001) ?
               ((A[7] ^ B[7]) & (A[7] ^ result[7])) :
               1'b0;

endmodule