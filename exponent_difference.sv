module exponent_difference (
    input  logic [7:0] EA,
    input  logic [7:0] EB,
    output logic [7:0] diff,
    output logic EA_lt_EB
);
    logic [7:0] AB;
    logic       c0;

    adder8 sub0 (
        .A   (EA),
        .B   (EB),
        .sub (1'b1),
        .S   (AB),
        .cout(c0)
    );

    logic [7:0] BA;
    logic       c1;

    adder8 sub1 (
        .A   (EB),
        .B   (EA),
        .sub (1'b1),
        .S   (BA),
        .cout(c1)
    );

    //c0=1 => EA < EB.
    assign EA_lt_EB = c0;

    genvar i;
    generate
        for (i = 0; i < 8; i++) begin : mux_loop
            mux21 u_mux (
                .x({BA[i], AB[i]}),
                .s(c0),
                .out(diff[i])
            );
        end
    endgenerate

endmodule