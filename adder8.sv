module adder8 (
    input logic [7:0] A,
    input logic [7:0] B,
    input logic sub,
    output logic [7:0] S,
    output logic cout
);
    logic [7:0] B_in;
    logic [7:0] c;

    genvar i;
    generate
        for (i = 0; i < 8; i++) begin : xor_bit
            xor (B_in[i], B[i], sub);
        end
    endgenerate

    adder1 adder_bit0 (
        .a   (A[0]),
        .b   (B_in[0]),
        .cin (sub),
        .sum (S[0]),
        .cout(c[0])
    );

    genvar j;
    generate
        for (j = 1; j < 8; j = j + 1) begin : add_loop
            adder1 adder_bit (
                .a   (A[j]),
                .b   (B_in[j]),
                .cin (c[j-1]),
                .sum (S[j]),
                .cout(c[j])
            );
        end
    endgenerate

    assign cout = c[7];

endmodule
