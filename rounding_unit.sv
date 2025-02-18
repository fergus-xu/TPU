module rounding_unit(
    input logic [26:0] ext_mant,
    output logic [23:0] mant_out,
    output logic round_overflow
);
    logic [23:0] M;

    assign M = ext_mant[26:3];

    logic G, R, S;
    assign G = ext_mant[2];
    assign R = ext_mant[1];
    assign S = ext_mant[0];

    logic rs_or;
    or (rs_or, R, S);

    logic round_sel;
    or (round_sel, rs_or, M[0]);

    logic round_inc;
    and (round_inc, G, round_sel);

    logic [23:0] M_rounded;
    logic carry;

    adder24_gate add_round (
        .A(M),
        .B({23'b0, round_inc}),
        .cin(1'b0),
        .S(M_rounded),
        .cout(carry)
    );
    
    assign round_overflow = carry;
    assign mant_out = M_rounded;
endmodule
