module mux21 (
    input  logic [1:0] x,
    input  logic       s,
    output logic       out
);

    logic s_bar;
    logic a0, a1;

    not U1(s_bar, s);

    and U2(a0, x[0], s_bar);

    and U3(a1, x[1], s);

    or  U4(out, a0, a1);

endmodule