module fp_exception_handler(
    input  logic [31:0] A,
    input  logic [31:0] B,
    input  logic        op_sub,
    input  logic [31:0] normal_result,
    input  logic        is_sum_zero,
    input  logic        sign_out,
    output logic [31:0] final_result,
    output logic        use_normal_path
);
    logic signA, signB, signB_eff;
    assign signA = A[31];
    xor(signB_eff, B[31], op_sub);

    logic expA_all_ones, expB_all_ones;
    logic expA_all_zeros, expB_all_zeros;
    
    logic expA_ones_high, expA_ones_low;
    logic expB_ones_high, expB_ones_low;
    and(expA_ones_high, A[30], A[29], A[28], A[27]);
    and(expA_ones_low, A[26], A[25], A[24], A[23]);
    and(expA_all_ones, expA_ones_high, expA_ones_low);
    
    and(expB_ones_high, B[30], B[29], B[28], B[27]);
    and(expB_ones_low, B[26], B[25], B[24], B[23]);
    and(expB_all_ones, expB_ones_high, expB_ones_low);
    
    logic fracA_zeros_0, fracA_zeros_1, fracA_zeros_2, fracA_zeros_3, fracA_zeros_4, fracA_zeros_5;
    logic fracA_group_0, fracA_group_1, fracA_group_2, fracA_group_3, fracA_group_4, fracA_group_5;
    
    nor(fracA_zeros_0, A[22], A[21], A[20], A[19]);
    nor(fracA_zeros_1, A[18], A[17], A[16], A[15]);
    nor(fracA_zeros_2, A[14], A[13], A[12], A[11]);
    nor(fracA_zeros_3, A[10], A[9], A[8], A[7]);
    nor(fracA_zeros_4, A[6], A[5], A[4], A[3]);
    nor(fracA_zeros_5, A[2], A[1], A[0]);
    
    and(fracA_group_0, fracA_zeros_0, fracA_zeros_1);
    and(fracA_group_1, fracA_zeros_2, fracA_zeros_3);
    and(fracA_group_2, fracA_zeros_4, fracA_zeros_5);
    and(fracA_group_3, fracA_group_0, fracA_group_1);
    and(fracA_all_zeros, fracA_group_3, fracA_group_2);
    
    logic fracB_zeros_0, fracB_zeros_1, fracB_zeros_2, fracB_zeros_3, fracB_zeros_4, fracB_zeros_5;
    logic fracB_group_0, fracB_group_1, fracB_group_2, fracB_group_3, fracB_group_4, fracB_group_5;
    
    nor(fracB_zeros_0, B[22], B[21], B[20], B[19]);
    nor(fracB_zeros_1, B[18], B[17], B[16], B[15]);
    nor(fracB_zeros_2, B[14], B[13], B[12], B[11]);
    nor(fracB_zeros_3, B[10], B[9], B[8], B[7]);
    nor(fracB_zeros_4, B[6], B[5], B[4], B[3]);
    nor(fracB_zeros_5, B[2], B[1], B[0]);
    
    and(fracB_group_0, fracB_zeros_0, fracB_zeros_1);
    and(fracB_group_1, fracB_zeros_2, fracB_zeros_3);
    and(fracB_group_2, fracB_zeros_4, fracB_zeros_5);
    and(fracB_group_3, fracB_group_0, fracB_group_1);
    and(fracB_all_zeros, fracB_group_3, fracB_group_2);
    
    logic expA_zeros_high, expA_zeros_low;
    logic expB_zeros_high, expB_zeros_low;
    
    nor(expA_zeros_high, A[30], A[29], A[28], A[27]);
    nor(expA_zeros_low, A[26], A[25], A[24], A[23]);
    and(expA_all_zeros, expA_zeros_high, expA_zeros_low);
    
    nor(expB_zeros_high, B[30], B[29], B[28], B[27]);
    nor(expB_zeros_low, B[26], B[25], B[24], B[23]);
    and(expB_all_zeros, expB_zeros_high, expB_zeros_low);

    logic A_is_inf, B_is_inf;
    and(A_is_inf, expA_all_ones, fracA_all_zeros);
    and(B_is_inf, expB_all_ones, fracB_all_zeros);
    
    logic A_is_nan, B_is_nan, any_nan;
    logic fracA_not_all_zeros, fracB_not_all_zeros;
    not(fracA_not_all_zeros, fracA_all_zeros);
    not(fracB_not_all_zeros, fracB_all_zeros);
    and(A_is_nan, expA_all_ones, fracA_not_all_zeros);
    and(B_is_nan, expB_all_ones, fracB_not_all_zeros);
    or(any_nan, A_is_nan, B_is_nan);
    
    logic A_is_zero, B_is_zero, both_zero;
    and(A_is_zero, expA_all_zeros, fracA_all_zeros);
    and(B_is_zero, expB_all_zeros, fracB_all_zeros);
    and(both_zero, A_is_zero, B_is_zero);
    
    logic diff_inf_same_sign;
    logic signAB_equal, inf_sub_op;
    xnor(signAB_equal, signA, signB_eff);
    and(inf_sub_op, op_sub, signAB_equal);
    
    logic diff_inf_temp;
    and(diff_inf_temp, A_is_inf, B_is_inf);
    and(diff_inf_same_sign, diff_inf_temp, inf_sub_op);
    
    logic add_inf_diff_sign;
    logic signAB_diff, inf_add_op;
    xor(signAB_diff, signA, signB_eff);
    not(inf_add_op, op_sub);
    
    logic add_inf_temp1, add_inf_temp2;
    and(add_inf_temp1, A_is_inf, B_is_inf);
    and(add_inf_temp2, signAB_diff, inf_add_op);
    and(add_inf_diff_sign, add_inf_temp1, add_inf_temp2);
    
    logic result_is_nan, nan_temp1;
    or(nan_temp1, any_nan, diff_inf_same_sign);
    or(result_is_nan, nan_temp1, add_inf_diff_sign);
    
    logic both_inf_same_sign, result_is_inf;
    logic both_inf_temp;
    and(both_inf_temp, A_is_inf, B_is_inf);
    and(both_inf_same_sign, both_inf_temp, signAB_equal);
    
    logic B_inf_nonspecial, A_inf_nonspecial;
    logic B_inf_temp1, B_inf_temp2, B_inf_temp3;
    logic not_diff_inf, not_add_inf;
    
    not(not_diff_inf, diff_inf_same_sign);
    not(not_add_inf, add_inf_diff_sign);
    and(B_inf_temp1, B_is_inf, ~A_is_inf);
    and(B_inf_temp2, not_diff_inf, not_add_inf);
    and(B_inf_nonspecial, B_inf_temp1, B_inf_temp2);
    
    and(A_inf_nonspecial, A_is_inf, ~B_is_inf);
    
    logic inf_temp1;
    or(inf_temp1, both_inf_same_sign, A_inf_nonspecial);
    or(result_is_inf, inf_temp1, B_inf_nonspecial);
    
    logic inf_sign;
    logic A_inf_signA, B_inf_signB;
    and(A_inf_signA, A_is_inf, signA);
    and(B_inf_signB, B_is_inf, signB_eff);
    or(inf_sign, A_inf_signA, B_inf_signB);
    
    logic zero_from_opp_signs, final_is_zero;
    and(zero_from_opp_signs, both_zero, signAB_diff);
    or(final_is_zero, zero_from_opp_signs, is_sum_zero);
    
    logic zero_sign;
    and(zero_sign, signA, signB_eff);
    
    logic [31:0] nan_value, inf_value, zero_value;
    assign nan_value = {1'b0, {8{1'b1}}, 1'b1, 22'b0};
    assign inf_value = {inf_sign, {8{1'b1}}, 23'b0};
    assign zero_value = {zero_sign, 31'b0};
    
    genvar i;
    generate
        for(i = 0; i < 32; i = i + 1) begin : gen_final_value
            logic nan_bit, inf_bit, zero_bit, sel_nan, sel_inf, sel_zero;
            
            assign nan_bit = nan_value[i];
            assign inf_bit = inf_value[i];
            assign zero_bit = zero_value[i];
            
            not(sel_nan, result_is_nan);
            and(sel_inf, sel_nan, result_is_inf);
            
            logic sel_zero_temp;
            and(sel_zero_temp, sel_nan, ~result_is_inf);
            and(sel_zero, sel_zero_temp, final_is_zero);
            
            logic mux_out1, mux_out2, mux_out3;
            mux21 mux1(.x({nan_bit, inf_bit}), .s(sel_nan), .out(mux_out1));
            mux21 mux2(.x({mux_out1, zero_bit}), .s(sel_inf), .out(mux_out2));
            mux21 mux3(.x({mux_out2, normal_result[i]}), .s(sel_zero), .out(mux_out3));
            
            assign final_result[i] = mux_out3;
        end
    endgenerate
    
    logic use_exception, exception_temp;
    or(exception_temp, result_is_nan, result_is_inf);
    or(use_exception, exception_temp, final_is_zero);
    not(use_normal_path, use_exception);

endmodule