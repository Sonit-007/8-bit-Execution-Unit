// Logic unit for bitwise operations
// AND, OR, XOR, NOT

module logic_unit (
    input  [7:0] a,
    input  [7:0] b,
    input  [2:0] sel,      // Selects logic operation
    output reg [7:0] y
);

    always @(*) begin
        case (sel)
            3'b010: y = a & b;   // AND
            3'b011: y = a | b;   // OR
            3'b100: y = a ^ b;   // XOR
            3'b101: y = ~a;      // NOT A
            default: y = 8'b0;
        endcase
    end
endmodule