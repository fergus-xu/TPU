module clamp8 (
    input  logic [7:0] in_shift,
    output logic [7:0] out_shift,
    output logic shift_ge24
);
    logic [7:0] const24;
    const24 c24 (
        .val(const24)
    );

    logic [7:0] sub_res;
    logic       cout_sub;
    adder8 sub_24 (
        .A   (in_shift),
        .B   (const24),
        .sub (1'b1),
        .S   (sub_res),
        .cout(cout_sub) 
    );
    assign shift_ge24 = cout_sub;

    genvar i;
    generate
        for (i=0; i<8; i++) begin : clamp_mux
            logic d0 = in_shift[i];
            logic d1 = const24[i];
            mux21_gate m (
                .d0(d0),
                .d1(d1),
                .s(shift_ge24),
                .y(out_shift[i])
            );
        end
    endgenerate
endmodule


module const24 (
    output logic [7:0] val
);
    buf (val[0], 1'b0);
    buf (val[1], 1'b0);
    buf (val[2], 1'b0);
    buf (val[3], 1'b1);
    buf (val[4], 1'b1);
    buf (val[5], 1'b0);
    buf (val[6], 1'b0);
    buf (val[7], 1'b0);
endmodule
