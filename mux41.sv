module mux41 (
    input  logic [3:0] x,
    input  logic [1:0] s,
    output logic       out
);

    logic s0_bar, s1_bar;

    not U1(s0_bar, s[0]);
    not U2(s1_bar, s[1]);

    logic and0, and1, and2, and3;
    logic temp0, temp1, temp2, temp3;

    and U3(temp0, s1_bar, s0_bar);
    and U4(and0, x[0], temp0);

    and U5(temp1, s1_bar, s[0]);
    and U6(and1, x[1], temp1);

    and U7(temp2, s[1], s0_bar);
    and U8(and2, x[2], temp2);

    and U9(temp3, s[1], s[0]);
    and U10(and3, x[3], temp3);

    logic or0, or1;
    or  U11(or0, and0, and1);
    or  U12(or1, and2, and3);
    or  U13(out, or0, or1);

endmodule