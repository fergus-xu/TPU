module BarrelShifter (
    input  logic [23:0] In,
    input  logic [4:0]  Shift,
    output logic [23:0] Out
);
    logic [23:0] a;
    
    genvar i;
    generate
        for (i = 0; i < 23; i = i + 1) begin : shift_by_1
            Mux M (
                .d0 (In[i]),
                .d1 (In[i+1]),
                .sel(Shift[0]),
                .out(a[i])
            );
        end

        Mux M_end (
            .d0 (In[23]),
            .d1 (1'b0),
            .sel(Shift[0]),
            .out(a[23])
        );
    endgenerate

    logic [23:0] a1;
    genvar j, k;

    generate
        for (j = 0; j < 22; j = j + 1) begin : shift_by_2_a
            Mux M2 (
                .d0 (a[j]),
                .d1 (a[j+2]),
                .sel(Shift[1]),
                .out(a1[j])
            );
        end

        for (k = 22; k < 24; k = k + 1) begin : shift_by_2_b
            Mux M3 (
                .d0 (a[k]),
                .d1 (1'b0),
                .sel(Shift[1]),
                .out(a1[k])
            );
        end
    endgenerate

    logic [23:0] a2;
    genvar p;
    generate
        for (p = 0; p < 20; p = p + 1) begin : shift_by_4_a
            Mux M4 (
                .d0 (a1[p]),
                .d1 (a1[p+4]),
                .sel(Shift[2]),
                .out(a2[p])
            );
        end

        for (k = 20; k < 24; k = k + 1) begin : shift_by_4_b
            Mux M5 (
                .d0 (a1[k]),
                .d1 (1'b0),
                .sel(Shift[2]),
                .out(a2[k])
            );
        end
    endgenerate

    logic [23:0] a3;
    genvar x, y;
    generate
        for (x = 0; x < 16; x = x + 1) begin : shift_by_8_a
            Mux M6 (
                .d0 (a2[x]),
                .d1 (a2[x+8]),
                .sel(Shift[3]),
                .out(a3[x])
            );
        end

        for (y = 16; y < 24; y = y + 1) begin : shift_by_8_b
            Mux M7 (
                .d0 (a2[y]),
                .d1 (1'b0),
                .sel(Shift[3]),
                .out(a3[y])
            );
        end
    endgenerate

    logic [23:0] a4;
    genvar s, t;
    generate
        for (s = 0; s < 8; s = s + 1) begin : shift_by_16_a
            Mux M8 (
                .d0 (a3[s]),
                .d1 (a3[s+16]),
                .sel(Shift[4]),
                .out(a4[s])
            );
        end
        
        for (t = 8; t < 24; t = t + 1) begin : shift_by_16_b
            Mux M9 (
                .d0 (a3[t]),
                .d1 (1'b0),
                .sel(Shift[4]),
                .out(a4[t])
            );
        end
    endgenerate

    assign Out = a4;

endmodule
