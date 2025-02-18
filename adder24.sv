module carry_skip_24_gate (
    input logic [23:0] A,
    input logic [23:0] B,
    input logic sub,
    output logic [23:0] S,
    output logic cout
);
    logic [23:0] B_in;
    genvar i;
    generate
        for (i = 0; i < 24; i++) begin : bxor
            xor (B_in[i], B[i], sub);
        end
    endgenerate

    logic [7:0] S0;
    logic       c0;
    logic       cin0;
    assign cin0 = sub;

    ripple8_addsub blk0 (
        .A   (A[7:0]),
        .B_in(B_in[7:0]),
        .cin (cin0),
        .S   (S0),
        .cout(c0)
    );

    logic [7:0] px0;
    generate
        for (i = 0; i < 8; i++) begin : px0_loop
            xor (px0[i], A[i], B_in[i]);
        end
    endgenerate

    logic p0a, p0b, p0c;
    and (p0a, px0[0], px0[1]);
    and (p0b, px0[2], px0[3]);
    and (p0c, p0a, p0b);
    logic p0d, p0e;
    and (p0d, px0[4], px0[5]);
    and (p0e, px0[6], px0[7]);
    logic p0f;
    and (p0f, p0d, p0e);
    logic prop0;
    and (prop0, p0c, p0f);

    logic p0n;
    not (p0n, prop0);

    logic mx0a, mx0b; 
    and (mx0a, p0n, c0);
    and (mx0b, prop0, cin0);
    logic cin1;
    or  (cin1, mx0a, mx0b);

    logic [7:0] S1;
    logic       c1;

    ripple8_addsub blk1 (
        .A   (A[15:8]),
        .B_in(B_in[15:8]),
        .cin (cin1),
        .S   (S1),
        .cout(c1)
    );

    logic [7:0] px1;
    generate
        for (i = 8; i < 16; i++) begin : px1_loop
            xor (px1[i-8], A[i], B_in[i]);
        end
    endgenerate

    logic p1a, p1b, p1c;
    and (p1a, px1[0], px1[1]);
    and (p1b, px1[2], px1[3]);
    and (p1c, p1a, p1b);

    logic p1d, p1e;
    and (p1d, px1[4], px1[5]);
    and (p1e, px1[6], px1[7]);
    logic p1f;
    and (p1f, p1d, p1e);
    logic prop1;
    and (prop1, p1c, p1f);

    logic p1n;
    not (p1n, prop1);

    logic mx1a, mx1b;
    and (mx1a, p1n, c1);
    and (mx1b, prop1, cin1);
    logic cin2;
    or  (cin2, mx1a, mx1b);

    logic [7:0] S2;
    logic       c2;

    ripple8_addsub blk2 (
        .A   (A[23:16]),
        .B_in(B_in[23:16]),
        .cin (cin2),
        .S   (S2),
        .cout(c2)
    );

    logic [7:0] px2;
    generate
        for (i = 16; i < 24; i++) begin : px2_loop
            xor (px2[i-16], A[i], B_in[i]);
        end
    endgenerate

    logic p2a, p2b, p2c;
    and (p2a, px2[0], px2[1]);
    and (p2b, px2[2], px2[3]);
    and (p2c, p2a, p2b);

    logic p2d, p2e;
    and (p2d, px2[4], px2[5]);
    and (p2e, px2[6], px2[7]);
    logic p2f;
    and (p2f, p2d, p2e);
    logic prop2;
    and (prop2, p2c, p2f);

    logic p2n;
    not (p2n, prop2);

    logic mx2a, mx2b;
    and (mx2a, p2n, c2);
    and (mx2b, prop2, cin2);
    or  (cout, mx2a, mx2b);

    assign S[7:0]    = S0;
    assign S[15:8]   = S1;
    assign S[23:16]  = S2;

endmodule
