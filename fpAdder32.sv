module fpAdder32(
    input  logic [31:0] A,
    input  logic [31:0] B,
    input  logic        op_sub,
    output logic [31:0] out
);

    logic signA, signB;
    assign signA = A[31];
    assign signB = B[31];

    logic [7:0] expA, expB;
    assign expA = A[30:23];
    assign expB = B[30:23];

    logic [22:0] fracA, fracB;
    assign fracA = A[22:0];
    assign fracB = B[22:0];

    logic [23:0] mantA, mantB;
    mantissa buildA(
        .exp_in(expA),
        .frac_in(fracA),
        .mant_out(mantA)
    );
    mantissa buildB(
        .exp_in(expB),
        .frac_in(fracB),
        .mant_out(mantB)
    );

    logic [7:0] exp_diff;
    logic       EA_lt_EB;
    exponent_difference expdiff_inst(
        .EA(expA),
        .EB(expB),
        .diff(exp_diff),
        .EA_lt_EB(EA_lt_EB)
    );

    logic [7:0] exp_bigger;
    genvar i;
    generate
        for(i = 0; i < 8; i = i + 1) begin : gen_exp_bigger
            mux21 u_mux(
                .x({expB[i], expA[i]}),
                .s(EA_lt_EB),
                .out(exp_bigger[i])
            );
        end
    endgenerate

    logic [23:0] mant_to_shift, mant_no_shift;
    generate
        for(i = 0; i < 24; i = i + 1) begin : gen_mant_to_shift
            mux21 u_mux(
                .x({mantA[i], mantB[i]}),
                .s(EA_lt_EB),
                .out(mant_to_shift[i])
            );
        end
    endgenerate

    generate
        for(i = 0; i < 24; i = i + 1) begin : gen_mant_no_shift
            mux21 u_mux(
                .x({mantB[i], mantA[i]}),
                .s(EA_lt_EB),
                .out(mant_no_shift[i])
            );
        end
    endgenerate

    logic [23:0] mant_shifted;
    fpu_align align(
        .mant_in(mant_to_shift),
        .exp_diff(exp_diff),
        .mant_out(mant_shifted)
    );

    logic eff_signB;
    xor(eff_signB, signB, op_sub);

    logic [23:0] alignedA, alignedB;
    assign alignedA = mant_no_shift;
    assign alignedB = mant_shifted;

    logic [23:0] B_in;
    genvar j;
    generate
        for(j = 0; j < 24; j = j + 1) begin : gen_b_in
            xor(B_in[j], alignedB[j], eff_signB);
        end
    endgenerate

    logic carry_in;
    assign carry_in = eff_signB;

    logic [23:0] sum24;
    logic        cout24;
    adder24 add_main(
        .A(alignedA),
        .B(B_in),
        .cin(carry_in),
        .S(sum24),
        .cout(cout24)
    );

    logic same_sign;
    xnor(same_sign, signA, signB);

    logic sign_bigger;
    mux21 u_mux_sign_bigger(
        .x({signB, signA}),
        .s(EA_lt_EB),
        .out(sign_bigger)
    );

    logic sign_out;
    logic same_sign_n, and0, and1;
    not(same_sign_n, same_sign);
    and(and0, same_sign, signA);
    and(and1, same_sign_n, sign_bigger);
    or(sign_out, and0, and1);

    logic [26:0] ext_sum;
    assign ext_sum = {cout24, sum24, 3'b000};

    logic [23:0] mant_rounded;
    logic round_overflow;
    rounding_unit round_inst(
        .ext_mant(ext_sum),
        .mant_out(mant_rounded),
        .round_overflow(round_overflow)
    );

    logic [7:0] exp_plus1;
    logic       c_exp;
    adder8 exp_add1(
        .A(exp_bigger),
        .B(8'd1),
        .sub(1'b0),
        .S(exp_plus1),
        .cout(c_exp)
    );

    logic [7:0] exp_final;
    generate
        for(i = 0; i < 8; i = i + 1) begin : gen_exp_final
            mux21 u_mux(
                .x({exp_plus1[i], exp_bigger[i]}),
                .s(round_overflow),
                .out(exp_final[i])
            );
        end
    endgenerate

    assign out[31]    = sign_out;
    assign out[30:23] = exp_final;
    assign out[22:0]  = mant_rounded[22:0];

endmodule
