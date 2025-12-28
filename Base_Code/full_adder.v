// Full Adder 
// Implements: sum = a ^ b ^ cin
//             cout = ab + ac + bc

module full_adder (
    input  a,
    input  b,
    input  cin,
    output sum,
    output cout
);
    wire axb;
    wire ab, ac, bc;

    // Sum logic

    xor (axb, a, b);            // axb = a ^ b
    xor (sum, axb, cin);        // sum = axb ^ cin

    // Carry logic

    and (ab, a, b);             // ab= a + b
    and (ac, a, cin);           // ac= a + cin
    and (bc, b, cin);           // bc= b + cin

    or  (cout, ab, ac, bc);     // cout = ab + ac + bc
endmodule
