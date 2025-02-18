module adder1 (
    input  logic a,     // First input bit
    input  logic b,     // Second input bit
    input  logic cin,   // Carry input
    output logic sum,   // Sum output
    output logic cout   // Carry output
);

    // Intermediate signals
    logic xor_ab;
    logic and_ab, and_cin_xor;

    // Compute XOR of a and b
    xor U1(xor_ab, a, b);

    // Sum is the XOR of (a XOR b) and cin
    xor U2(sum, xor_ab, cin);

    // Compute carry terms:
    // First term: a AND b
    and U3(and_ab, a, b);

    // Second term: (a XOR b) AND cin
    and U4(and_cin_xor, xor_ab, cin);

    // Final carry out: OR of the two carry terms
    or  U5(cout, and_ab, and_cin_xor);

endmodule