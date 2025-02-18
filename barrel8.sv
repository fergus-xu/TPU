module barrel8 (
    input  logic [7:0] in,     // 8-bit input
    input  logic [2:0] shift,  // 3-bit shift amount (0-7)
    output logic [7:0] out     // 8-bit rotated output
);

    genvar i;
    generate
        for (i = 0; i < 8; i = i+1) begin : stage0_loop
            mux21 stage0_mux (
                .x({ in[i], in[(i == 0 ? 7 : i - 1)] }),
                .s(shift[0]),
                .out(stage0[i])
            );
        end
    endgenerate

    generate
        for (i = 0; i < 8; i = i+1) begin : stage1_loop
            mux21 stage1_mux (
                .x({ stage0[i], stage0[(i < 2 ? i + 6 : i - 2)] }),
                .s(shift[1]),
                .out(stage1[i])
            );
        end
    endgenerate

    generate
        for (i = 0; i < 8; i = i+1) begin : stage2_loop
            mux21 stage2_mux (
                .x({ stage1[i], stage1[(i < 4 ? i + 4 : i - 4)] }),
                .s(shift[2]),
                .out(out[i])
            );
        end
    endgenerate

endmodule