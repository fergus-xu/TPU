module mantissa (
    input  logic [7:0]  exp_in,
    input  logic [22:0] frac_in,
    output logic [23:0] mant_out
);
    logic or0, or1, or2, or3;
    or (or0, exp_in[0], exp_in[1]);
    or (or1, exp_in[2], exp_in[3]);
    or (or2, exp_in[4], exp_in[5]);
    or (or3, exp_in[6], exp_in[7]);

    logic or01, or23, leading_bit;
    or (or01, or0, or1);
    or (or23, or2, or3);
    or (leading_bit, or01, or23);

    buf (mant_out[23], leading_bit);

    genvar i;
    generate
        for (i=0; i<23; i++) begin : frac_copy
            buf (mant_out[i], frac_in[i]);
        end
    endgenerate

endmodule
