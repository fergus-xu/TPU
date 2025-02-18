module fpu_align (
    input  logic [23:0] mant_in,
    input  logic [7:0]  exp_diff,
    output logic [23:0] mant_out
);

    logic [7:0] shift_clamped;
    logic       ge24;
    clamp_8_no_rtl clamp_mod (
        .in_shift (exp_diff),
        .out_shift(shift_clamped),
        .shift_ge24(ge24)
    );

    barrel_shifter_24 bsh (
        .in_data( mant_in ),
        .shift  ( shift_clamped[4:0] ),
        .out_data( mant_out )
    );

endmodule
