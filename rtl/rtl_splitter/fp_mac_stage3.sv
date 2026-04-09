// fp_mac_stage3.sv
// Stage 3: 加法、符号处理、前导零计数(LZC)
// Generated from fp_mac.sv as part of code split
//
// ============================================================================
// Stage 3: Addition and Leading Zero Count (LZC)
// ============================================================================
// Function:
//   - Adds aligned product mantissa and C mantissa (72-bit addition).
//   - Handles sign of operands and computes absolute value of sum.
//   - Performs leading zero count (LZC) on absolute sum for normalization.
//   - Detects overflow (extra bit) and determines normalization direction.
//
// Pipeline:
//   Inputs: Aligned mantissas, exponents, signs from Stage 2.
//   Outputs: Absolute sum, LZC result, overflow flag, control signals.
//
// Key Operations:
//   1. Signed addition of product and C mantissas.
//   2. Absolute value conversion and overflow detection.
//   3. Leading zero count via priority encoder (72-bit).
//   4. Classification: normal, large subnormal, huge zero (based on LZC).
// ============================================================================


`timescale 1ns/1ps

module fp_mac_stage3 (
  // Clock and reset
  input clk,
  input resetn,

  // Stage 2 inputs (registered)
  input [71:0] c_man_align_r2,
  input [7:0]  product_exp_shift_r2,
  input [71:0] product_man_align_r2,
  input        product_sign_r2,
  input        c_sign_r2,
  input        output_nan_inf_r2,
  input        inf_sign_r2,
  input        a_b_inf_r2,
  input        c_is_inf_r2,

  // Stage 3 outputs (registered)
  output reg [73:0] sum_man_abs_all_r3,
  output reg [7:0]  product_exp_shift_r3,
  output reg        output_nan_inf_r3,
  output reg        inf_sign_r3,
  output reg        a_b_inf_r3,
  output reg        c_is_inf_r3,
  output reg        sum_man_sign_r3,

  // Internal signals (combinational)
  output wire [73:0] sum_man_abs_all,
  output wire        sum_man_sign,
  output wire [6:0]  lzc_real,
  output wire        lzc_large_subnormal,
  output wire        lzc_huge_zero,
  output wire        lzc_normal
);

  // Wire declarations from original fp_mac.sv
  wire       [72:0]   tmp_prod_mag_s;
  wire       [72:0]   tmp_c_mag_s;
  wire       [72:0]   tmp_prod_val;
  wire       [72:0]   tmp_c_val;
  wire       [73:0]   tmp_sum_man;
  wire       [73:0]   tmp_sum_man_1;
  wire       [73:0]   tmp_sum_man_abs_all;
  wire       [73:0]   tmp_sum_man_abs_all_1;
  wire       [73:0]   tmp_sum_man_abs_all_2;
  wire       [0:0]    tmp_sum_man_abs_all_3;
  wire       [73:0]   tmp_sum_man_sign_r3;
  wire       [73:0]   tmp_sum_man_sign_r3_1;
  wire       [71:0]   tmp_sum_man_vec_0;
  wire       [71:0]   tmp_sum_man_vec_1;
  wire       [71:0]   tmp_sum_man_vec_2;
  wire       [71:0]   tmp_sum_man_vec_3;
  wire       [71:0]   tmp_sum_man_vec_4;
  wire       [71:0]   tmp_sum_man_vec_5;
  wire       [71:0]   tmp_sum_man_vec_6;
  wire       [71:0]   tmp_sum_man_vec_7;
  wire       [71:0]   tmp_sum_man_vec_8;
  wire       [71:0]   tmp_sum_man_vec_9;
  wire       [71:0]   tmp_sum_man_vec_10;
  wire       [71:0]   tmp_sum_man_vec_11;
  wire       [71:0]   tmp_sum_man_vec_12;
  wire       [71:0]   tmp_sum_man_vec_13;
  wire       [71:0]   tmp_sum_man_vec_14;
  wire       [71:0]   tmp_sum_man_vec_15;
  wire       [71:0]   tmp_sum_man_vec_16;
  wire       [71:0]   tmp_sum_man_vec_17;
  wire       [71:0]   tmp_sum_man_vec_18;
  wire       [71:0]   tmp_sum_man_vec_19;
  wire       [71:0]   tmp_sum_man_vec_20;
  wire       [71:0]   tmp_sum_man_vec_21;
  wire       [71:0]   tmp_sum_man_vec_22;
  wire       [71:0]   tmp_sum_man_vec_23;
  wire       [71:0]   tmp_sum_man_vec_24;
  wire       [71:0]   tmp_sum_man_vec_25;
  wire       [71:0]   tmp_sum_man_vec_26;
  wire       [71:0]   tmp_sum_man_vec_27;
  wire       [71:0]   tmp_sum_man_vec_28;
  wire       [71:0]   tmp_sum_man_vec_29;
  wire       [71:0]   tmp_sum_man_vec_30;
  wire       [71:0]   tmp_sum_man_vec_31;
  wire       [71:0]   tmp_sum_man_vec_32;
  wire       [71:0]   tmp_sum_man_vec_33;
  wire       [71:0]   tmp_sum_man_vec_34;
  wire       [71:0]   tmp_sum_man_vec_35;
  wire       [71:0]   tmp_sum_man_vec_36;
  wire       [71:0]   tmp_sum_man_vec_37;
  wire       [71:0]   tmp_sum_man_vec_38;
  wire       [71:0]   tmp_sum_man_vec_39;
  wire       [71:0]   tmp_sum_man_vec_40;
  wire       [71:0]   tmp_sum_man_vec_41;
  wire       [71:0]   tmp_sum_man_vec_42;
  wire       [71:0]   tmp_sum_man_vec_43;
  wire       [71:0]   tmp_sum_man_vec_44;
  wire       [71:0]   tmp_sum_man_vec_45;
  wire       [71:0]   tmp_sum_man_vec_46;
  wire       [71:0]   tmp_sum_man_vec_47;
  wire       [71:0]   tmp_sum_man_vec_48;
  wire       [71:0]   tmp_sum_man_vec_49;
  wire       [71:0]   tmp_sum_man_vec_50;
  wire       [71:0]   tmp_sum_man_vec_51;
  wire       [71:0]   tmp_sum_man_vec_52;
  wire       [71:0]   tmp_sum_man_vec_53;
  wire       [71:0]   tmp_sum_man_vec_54;
  wire       [71:0]   tmp_sum_man_vec_55;
  wire       [71:0]   tmp_sum_man_vec_56;
  wire       [71:0]   tmp_sum_man_vec_57;
  wire       [71:0]   tmp_sum_man_vec_58;
  wire       [71:0]   tmp_sum_man_vec_59;
  wire       [71:0]   tmp_sum_man_vec_60;
  wire       [71:0]   tmp_sum_man_vec_61;
  wire       [71:0]   tmp_sum_man_vec_62;
  wire       [71:0]   tmp_sum_man_vec_63;
  wire       [71:0]   tmp_sum_man_vec_64;
  wire       [71:0]   tmp_sum_man_vec_65;
  wire       [71:0]   tmp_sum_man_vec_66;
  wire       [71:0]   tmp_sum_man_vec_67;
  wire       [71:0]   tmp_sum_man_vec_68;
  wire       [71:0]   tmp_sum_man_vec_69;
  wire       [71:0]   tmp_sum_man_vec_70;
  wire       [71:0]   tmp_sum_man_vec_71;
  wire                sum_man_vec_0;
  wire                sum_man_vec_1;
  wire                sum_man_vec_2;
  wire                sum_man_vec_3;
  wire                sum_man_vec_4;
  wire                sum_man_vec_5;
  wire                sum_man_vec_6;
  wire                sum_man_vec_7;
  wire                sum_man_vec_8;
  wire                sum_man_vec_9;
  wire                sum_man_vec_10;
  wire                sum_man_vec_11;
  wire                sum_man_vec_12;
  wire                sum_man_vec_13;
  wire                sum_man_vec_14;
  wire                sum_man_vec_15;
  wire                sum_man_vec_16;
  wire                sum_man_vec_17;
  wire                sum_man_vec_18;
  wire                sum_man_vec_19;
  wire                sum_man_vec_20;
  wire                sum_man_vec_21;
  wire                sum_man_vec_22;
  wire                sum_man_vec_23;
  wire                sum_man_vec_24;
  wire                sum_man_vec_25;
  wire                sum_man_vec_26;
  wire                sum_man_vec_27;
  wire                sum_man_vec_28;
  wire                sum_man_vec_29;
  wire                sum_man_vec_30;
  wire                sum_man_vec_31;
  wire                sum_man_vec_32;
  wire                sum_man_vec_33;
  wire                sum_man_vec_34;
  wire                sum_man_vec_35;
  wire                sum_man_vec_36;
  wire                sum_man_vec_37;
  wire                sum_man_vec_38;
  wire                sum_man_vec_39;
  wire                sum_man_vec_40;
  wire                sum_man_vec_41;
  wire                sum_man_vec_42;
  wire                sum_man_vec_43;
  wire                sum_man_vec_44;
  wire                sum_man_vec_45;
  wire                sum_man_vec_46;
  wire                sum_man_vec_47;
  wire                sum_man_vec_48;
  wire                sum_man_vec_49;
  wire                sum_man_vec_50;
  wire                sum_man_vec_51;
  wire                sum_man_vec_52;
  wire                sum_man_vec_53;
  wire                sum_man_vec_54;
  wire                sum_man_vec_55;
  wire                sum_man_vec_56;
  wire                sum_man_vec_57;
  wire                sum_man_vec_58;
  wire                sum_man_vec_59;
  wire                sum_man_vec_60;
  wire                sum_man_vec_61;
  wire                sum_man_vec_62;
  wire                sum_man_vec_63;
  wire                sum_man_vec_64;
  wire                sum_man_vec_65;
  wire                sum_man_vec_66;
  wire                sum_man_vec_67;
  wire                sum_man_vec_68;
  wire                sum_man_vec_69;
  wire                sum_man_vec_70;
  wire                sum_man_vec_71;
  wire                tmp_found;
  wire                tmp_found_1;
  wire                tmp_found_2;
  wire                tmp_found_3;
  wire                tmp_found_4;
  wire                tmp_found_5;
  wire                tmp_found_6;
  wire                tmp_found_7;
  wire                tmp_found_8;
  wire                tmp_found_9;
  wire                tmp_found_10;
  wire                tmp_found_11;
  wire                tmp_found_12;
  wire                tmp_found_13;
  wire                tmp_found_14;
  wire                tmp_found_15;
  wire                tmp_found_16;
  wire                tmp_found_17;
  wire                tmp_found_18;
  wire                tmp_found_19;
  wire                tmp_found_20;
  wire                tmp_found_21;
  wire                tmp_found_22;
  wire                tmp_found_23;
  wire                tmp_found_24;
  wire                tmp_found_25;
  wire                tmp_found_26;
  wire                tmp_found_27;
  wire                tmp_found_28;
  wire                tmp_found_29;
  wire                tmp_found_30;
  wire                tmp_found_31;
  wire                tmp_found_32;
  wire                tmp_found_33;
  wire                tmp_found_34;
  wire                tmp_found_35;
  wire                tmp_found_36;
  wire                tmp_found_37;
  wire                tmp_found_38;
  wire                tmp_found_39;
  wire                tmp_found_40;
  wire                tmp_found_41;
  wire                tmp_found_42;
  wire                tmp_found_43;
  wire                tmp_found_44;
  wire                tmp_found_45;
  wire                tmp_found_46;
  wire                tmp_found_47;
  wire                tmp_found_48;
  wire                tmp_found_49;
  wire                tmp_found_50;
  wire                tmp_found_51;
  wire                tmp_found_52;
  wire                tmp_found_53;
  wire                tmp_found_54;
  wire                tmp_found_55;
  wire                tmp_found_56;
  wire                tmp_found_57;
  wire                tmp_found_58;
  wire                tmp_found_59;
  wire                tmp_found_60;
  wire                tmp_found_61;
  wire                tmp_found_62;
  wire                tmp_found_63;
  wire                tmp_found_64;
  wire                tmp_found_65;
  wire                tmp_found_66;
  wire                tmp_found_67;
  wire                tmp_found_68;
  wire                tmp_found_69;
  wire                tmp_found_70;
  wire                tmp_found_71;
  wire                tmp_found_72;
  wire                tmp_found_73;
  wire                tmp_found_74;
  wire                found;
  wire       [6:0]    lzc;
  wire       [6:0]    tmp_lzc;
  wire       [6:0]    tmp_lzc_1;
  wire       [6:0]    tmp_lzc_2;
  wire       [6:0]    tmp_lzc_3;
  wire       [6:0]    tmp_lzc_4;
  wire       [6:0]    tmp_lzc_5;
  wire       [6:0]    tmp_lzc_6;
  wire       [6:0]    tmp_lzc_7;
  wire       [6:0]    tmp_lzc_8;
  wire       [6:0]    tmp_lzc_9;
  wire       [6:0]    tmp_lzc_10;
  wire       [6:0]    tmp_lzc_11;
  wire       [6:0]    tmp_lzc_real;
  wire                sum_man_overflow;
  wire       [71:0]   sum_man_abs;

  // Intermediate signals
  wire [72:0] prod_mag_s;
  wire [72:0] c_mag_s;
  wire [72:0] prod_val;
  wire [72:0] c_val;
  wire [73:0] sum_man;

  // Combinational logic from original fp_mac.sv
  assign tmp_prod_mag_s = {1'd0, product_man_align_r2};
  assign tmp_c_mag_s = {1'd0, c_man_align_r2};
  assign tmp_prod_val = (- prod_mag_s);
  assign tmp_c_val = (- c_mag_s);
  assign tmp_sum_man = {{1{prod_val[72]}}, prod_val};
  assign tmp_sum_man_1 = {{1{c_val[72]}}, c_val};
  assign tmp_sum_man_abs_all = (sum_man[73] ? tmp_sum_man_abs_all_1 : sum_man);
  assign tmp_sum_man_abs_all_1 = (~ sum_man);
  assign tmp_sum_man_abs_all_3 = sum_man[73];
  assign tmp_sum_man_abs_all_2 = {73'd0, tmp_sum_man_abs_all_3};
  assign tmp_sum_man_sign_r3 = 74'h0000000000000000000;
  assign tmp_sum_man_sign_r3_1 = 74'h0000000000000000000;

  // Vector assignments (from original lines 640-711)
  assign tmp_sum_man_vec_0 = sum_man_abs;
  assign tmp_sum_man_vec_1 = sum_man_abs;
  assign tmp_sum_man_vec_2 = sum_man_abs;
  assign tmp_sum_man_vec_3 = sum_man_abs;
  assign tmp_sum_man_vec_4 = sum_man_abs;
  assign tmp_sum_man_vec_5 = sum_man_abs;
  assign tmp_sum_man_vec_6 = sum_man_abs;
  assign tmp_sum_man_vec_7 = sum_man_abs;
  assign tmp_sum_man_vec_8 = sum_man_abs;
  assign tmp_sum_man_vec_9 = sum_man_abs;
  assign tmp_sum_man_vec_10 = sum_man_abs;
  assign tmp_sum_man_vec_11 = sum_man_abs;
  assign tmp_sum_man_vec_12 = sum_man_abs;
  assign tmp_sum_man_vec_13 = sum_man_abs;
  assign tmp_sum_man_vec_14 = sum_man_abs;
  assign tmp_sum_man_vec_15 = sum_man_abs;
  assign tmp_sum_man_vec_16 = sum_man_abs;
  assign tmp_sum_man_vec_17 = sum_man_abs;
  assign tmp_sum_man_vec_18 = sum_man_abs;
  assign tmp_sum_man_vec_19 = sum_man_abs;
  assign tmp_sum_man_vec_20 = sum_man_abs;
  assign tmp_sum_man_vec_21 = sum_man_abs;
  assign tmp_sum_man_vec_22 = sum_man_abs;
  assign tmp_sum_man_vec_23 = sum_man_abs;
  assign tmp_sum_man_vec_24 = sum_man_abs;
  assign tmp_sum_man_vec_25 = sum_man_abs;
  assign tmp_sum_man_vec_26 = sum_man_abs;
  assign tmp_sum_man_vec_27 = sum_man_abs;
  assign tmp_sum_man_vec_28 = sum_man_abs;
  assign tmp_sum_man_vec_29 = sum_man_abs;
  assign tmp_sum_man_vec_30 = sum_man_abs;
  assign tmp_sum_man_vec_31 = sum_man_abs;
  assign tmp_sum_man_vec_32 = sum_man_abs;
  assign tmp_sum_man_vec_33 = sum_man_abs;
  assign tmp_sum_man_vec_34 = sum_man_abs;
  assign tmp_sum_man_vec_35 = sum_man_abs;
  assign tmp_sum_man_vec_36 = sum_man_abs;
  assign tmp_sum_man_vec_37 = sum_man_abs;
  assign tmp_sum_man_vec_38 = sum_man_abs;
  assign tmp_sum_man_vec_39 = sum_man_abs;
  assign tmp_sum_man_vec_40 = sum_man_abs;
  assign tmp_sum_man_vec_41 = sum_man_abs;
  assign tmp_sum_man_vec_42 = sum_man_abs;
  assign tmp_sum_man_vec_43 = sum_man_abs;
  assign tmp_sum_man_vec_44 = sum_man_abs;
  assign tmp_sum_man_vec_45 = sum_man_abs;
  assign tmp_sum_man_vec_46 = sum_man_abs;
  assign tmp_sum_man_vec_47 = sum_man_abs;
  assign tmp_sum_man_vec_48 = sum_man_abs;
  assign tmp_sum_man_vec_49 = sum_man_abs;
  assign tmp_sum_man_vec_50 = sum_man_abs;
  assign tmp_sum_man_vec_51 = sum_man_abs;
  assign tmp_sum_man_vec_52 = sum_man_abs;
  assign tmp_sum_man_vec_53 = sum_man_abs;
  assign tmp_sum_man_vec_54 = sum_man_abs;
  assign tmp_sum_man_vec_55 = sum_man_abs;
  assign tmp_sum_man_vec_56 = sum_man_abs;
  assign tmp_sum_man_vec_57 = sum_man_abs;
  assign tmp_sum_man_vec_58 = sum_man_abs;
  assign tmp_sum_man_vec_59 = sum_man_abs;
  assign tmp_sum_man_vec_60 = sum_man_abs;
  assign tmp_sum_man_vec_61 = sum_man_abs;
  assign tmp_sum_man_vec_62 = sum_man_abs;
  assign tmp_sum_man_vec_63 = sum_man_abs;
  assign tmp_sum_man_vec_64 = sum_man_abs;
  assign tmp_sum_man_vec_65 = sum_man_abs;
  assign tmp_sum_man_vec_66 = sum_man_abs;
  assign tmp_sum_man_vec_67 = sum_man_abs;
  assign tmp_sum_man_vec_68 = sum_man_abs;
  assign tmp_sum_man_vec_69 = sum_man_abs;
  assign tmp_sum_man_vec_70 = sum_man_abs;
  assign tmp_sum_man_vec_71 = sum_man_abs;

  // Main computations
  assign prod_mag_s = tmp_prod_mag_s;
  assign c_mag_s = tmp_c_mag_s;
  assign prod_val = (product_sign_r2 ? tmp_prod_val : prod_mag_s);
  assign c_val = (c_sign_r2 ? tmp_c_val : c_mag_s);
  assign sum_man = ($signed(tmp_sum_man) + $signed(tmp_sum_man_1));
  assign sum_man_abs_all = (tmp_sum_man_abs_all + tmp_sum_man_abs_all_2);
  assign sum_man_abs = sum_man_abs_all[71 : 0];
  assign sum_man_overflow = sum_man_abs_all[72];

  // Bit extraction for LZC (from original lines 640-711)
  assign sum_man_vec_0 = tmp_sum_man_vec_0[71];
  assign sum_man_vec_1 = tmp_sum_man_vec_1[70];
  assign sum_man_vec_2 = tmp_sum_man_vec_2[69];
  assign sum_man_vec_3 = tmp_sum_man_vec_3[68];
  assign sum_man_vec_4 = tmp_sum_man_vec_4[67];
  assign sum_man_vec_5 = tmp_sum_man_vec_5[66];
  assign sum_man_vec_6 = tmp_sum_man_vec_6[65];
  assign sum_man_vec_7 = tmp_sum_man_vec_7[64];
  assign sum_man_vec_8 = tmp_sum_man_vec_8[63];
  assign sum_man_vec_9 = tmp_sum_man_vec_9[62];
  assign sum_man_vec_10 = tmp_sum_man_vec_10[61];
  assign sum_man_vec_11 = tmp_sum_man_vec_11[60];
  assign sum_man_vec_12 = tmp_sum_man_vec_12[59];
  assign sum_man_vec_13 = tmp_sum_man_vec_13[58];
  assign sum_man_vec_14 = tmp_sum_man_vec_14[57];
  assign sum_man_vec_15 = tmp_sum_man_vec_15[56];
  assign sum_man_vec_16 = tmp_sum_man_vec_16[55];
  assign sum_man_vec_17 = tmp_sum_man_vec_17[54];
  assign sum_man_vec_18 = tmp_sum_man_vec_18[53];
  assign sum_man_vec_19 = tmp_sum_man_vec_19[52];
  assign sum_man_vec_20 = tmp_sum_man_vec_20[51];
  assign sum_man_vec_21 = tmp_sum_man_vec_21[50];
  assign sum_man_vec_22 = tmp_sum_man_vec_22[49];
  assign sum_man_vec_23 = tmp_sum_man_vec_23[48];
  assign sum_man_vec_24 = tmp_sum_man_vec_24[47];
  assign sum_man_vec_25 = tmp_sum_man_vec_25[46];
  assign sum_man_vec_26 = tmp_sum_man_vec_26[45];
  assign sum_man_vec_27 = tmp_sum_man_vec_27[44];
  assign sum_man_vec_28 = tmp_sum_man_vec_28[43];
  assign sum_man_vec_29 = tmp_sum_man_vec_29[42];
  assign sum_man_vec_30 = tmp_sum_man_vec_30[41];
  assign sum_man_vec_31 = tmp_sum_man_vec_31[40];
  assign sum_man_vec_32 = tmp_sum_man_vec_32[39];
  assign sum_man_vec_33 = tmp_sum_man_vec_33[38];
  assign sum_man_vec_34 = tmp_sum_man_vec_34[37];
  assign sum_man_vec_35 = tmp_sum_man_vec_35[36];
  assign sum_man_vec_36 = tmp_sum_man_vec_36[35];
  assign sum_man_vec_37 = tmp_sum_man_vec_37[34];
  assign sum_man_vec_38 = tmp_sum_man_vec_38[33];
  assign sum_man_vec_39 = tmp_sum_man_vec_39[32];
  assign sum_man_vec_40 = tmp_sum_man_vec_40[31];
  assign sum_man_vec_41 = tmp_sum_man_vec_41[30];
  assign sum_man_vec_42 = tmp_sum_man_vec_42[29];
  assign sum_man_vec_43 = tmp_sum_man_vec_43[28];
  assign sum_man_vec_44 = tmp_sum_man_vec_44[27];
  assign sum_man_vec_45 = tmp_sum_man_vec_45[26];
  assign sum_man_vec_46 = tmp_sum_man_vec_46[25];
  assign sum_man_vec_47 = tmp_sum_man_vec_47[24];
  assign sum_man_vec_48 = tmp_sum_man_vec_48[23];
  assign sum_man_vec_49 = tmp_sum_man_vec_49[22];
  assign sum_man_vec_50 = tmp_sum_man_vec_50[21];
  assign sum_man_vec_51 = tmp_sum_man_vec_51[20];
  assign sum_man_vec_52 = tmp_sum_man_vec_52[19];
  assign sum_man_vec_53 = tmp_sum_man_vec_53[18];
  assign sum_man_vec_54 = tmp_sum_man_vec_54[17];
  assign sum_man_vec_55 = tmp_sum_man_vec_55[16];
  assign sum_man_vec_56 = tmp_sum_man_vec_56[15];
  assign sum_man_vec_57 = tmp_sum_man_vec_57[14];
  assign sum_man_vec_58 = tmp_sum_man_vec_58[13];
  assign sum_man_vec_59 = tmp_sum_man_vec_59[12];
  assign sum_man_vec_60 = tmp_sum_man_vec_60[11];
  assign sum_man_vec_61 = tmp_sum_man_vec_61[10];
  assign sum_man_vec_62 = tmp_sum_man_vec_62[9];
  assign sum_man_vec_63 = tmp_sum_man_vec_63[8];
  assign sum_man_vec_64 = tmp_sum_man_vec_64[7];
  assign sum_man_vec_65 = tmp_sum_man_vec_65[6];
  assign sum_man_vec_66 = tmp_sum_man_vec_66[5];
  assign sum_man_vec_67 = tmp_sum_man_vec_67[4];
  assign sum_man_vec_68 = tmp_sum_man_vec_68[3];
  assign sum_man_vec_69 = tmp_sum_man_vec_69[2];
  assign sum_man_vec_70 = tmp_sum_man_vec_70[1];
  assign sum_man_vec_71 = tmp_sum_man_vec_71[0];

  // LZC detection logic (from original lines 712-788)
  assign tmp_found = (sum_man_vec_0 == 1'b1);
  assign tmp_found_1 = (sum_man_vec_1 == 1'b1);
  assign tmp_found_2 = (sum_man_vec_2 == 1'b1);
  assign tmp_found_3 = (sum_man_vec_3 == 1'b1);
  assign tmp_found_4 = (sum_man_vec_4 == 1'b1);
  assign tmp_found_5 = (sum_man_vec_5 == 1'b1);
  assign tmp_found_6 = (sum_man_vec_6 == 1'b1);
  assign tmp_found_7 = (sum_man_vec_7 == 1'b1);
  assign tmp_found_8 = (sum_man_vec_8 == 1'b1);
  assign tmp_found_9 = (sum_man_vec_9 == 1'b1);
  assign tmp_found_10 = (sum_man_vec_10 == 1'b1);
  assign tmp_found_11 = (sum_man_vec_11 == 1'b1);
  assign tmp_found_12 = (sum_man_vec_12 == 1'b1);
  assign tmp_found_13 = (sum_man_vec_13 == 1'b1);
  assign tmp_found_14 = (sum_man_vec_14 == 1'b1);
  assign tmp_found_15 = (sum_man_vec_15 == 1'b1);
  assign tmp_found_16 = (sum_man_vec_16 == 1'b1);
  assign tmp_found_17 = (sum_man_vec_17 == 1'b1);
  assign tmp_found_18 = (sum_man_vec_18 == 1'b1);
  assign tmp_found_19 = (sum_man_vec_19 == 1'b1);
  assign tmp_found_20 = (sum_man_vec_20 == 1'b1);
  assign tmp_found_21 = (sum_man_vec_21 == 1'b1);
  assign tmp_found_22 = (sum_man_vec_22 == 1'b1);
  assign tmp_found_23 = (sum_man_vec_23 == 1'b1);
  assign tmp_found_24 = (sum_man_vec_24 == 1'b1);
  assign tmp_found_25 = (sum_man_vec_25 == 1'b1);
  assign tmp_found_26 = (sum_man_vec_26 == 1'b1);
  assign tmp_found_27 = (sum_man_vec_27 == 1'b1);
  assign tmp_found_28 = (sum_man_vec_28 == 1'b1);
  assign tmp_found_29 = (sum_man_vec_29 == 1'b1);
  assign tmp_found_30 = (sum_man_vec_30 == 1'b1);
  assign tmp_found_31 = (sum_man_vec_31 == 1'b1);
  assign tmp_found_32 = (sum_man_vec_32 == 1'b1);
  assign tmp_found_33 = (sum_man_vec_33 == 1'b1);
  assign tmp_found_34 = (sum_man_vec_34 == 1'b1);
  assign tmp_found_35 = (sum_man_vec_35 == 1'b1);
  assign tmp_found_36 = (sum_man_vec_36 == 1'b1);
  assign tmp_found_37 = (sum_man_vec_37 == 1'b1);
  assign tmp_found_38 = (sum_man_vec_38 == 1'b1);
  assign tmp_found_39 = (sum_man_vec_39 == 1'b1);
  assign tmp_found_40 = (sum_man_vec_40 == 1'b1);
  assign tmp_found_41 = (sum_man_vec_41 == 1'b1);
  assign tmp_found_42 = (sum_man_vec_42 == 1'b1);
  assign tmp_found_43 = (sum_man_vec_43 == 1'b1);
  assign tmp_found_44 = (sum_man_vec_44 == 1'b1);
  assign tmp_found_45 = (sum_man_vec_45 == 1'b1);
  assign tmp_found_46 = (sum_man_vec_46 == 1'b1);
  assign tmp_found_47 = (sum_man_vec_47 == 1'b1);
  assign tmp_found_48 = (sum_man_vec_48 == 1'b1);
  assign tmp_found_49 = (sum_man_vec_49 == 1'b1);
  assign tmp_found_50 = (sum_man_vec_50 == 1'b1);
  assign tmp_found_51 = (sum_man_vec_51 == 1'b1);
  assign tmp_found_52 = (sum_man_vec_52 == 1'b1);
  assign tmp_found_53 = (sum_man_vec_53 == 1'b1);
  assign tmp_found_54 = (sum_man_vec_54 == 1'b1);
  assign tmp_found_55 = (sum_man_vec_55 == 1'b1);
  assign tmp_found_56 = (sum_man_vec_56 == 1'b1);
  assign tmp_found_57 = (sum_man_vec_57 == 1'b1);
  assign tmp_found_58 = (sum_man_vec_58 == 1'b1);
  assign tmp_found_59 = (sum_man_vec_59 == 1'b1);
  assign tmp_found_60 = (sum_man_vec_60 == 1'b1);
  assign tmp_found_61 = (sum_man_vec_61 == 1'b1);
  assign tmp_found_62 = (sum_man_vec_62 == 1'b1);
  assign tmp_found_63 = (sum_man_vec_63 == 1'b1);
  assign tmp_found_64 = (sum_man_vec_64 == 1'b1);
  assign tmp_found_65 = (sum_man_vec_65 == 1'b1);
  assign tmp_found_66 = (sum_man_vec_66 == 1'b1);
  assign tmp_found_67 = (sum_man_vec_67 == 1'b1);
  assign tmp_found_68 = (sum_man_vec_68 == 1'b1);
  assign tmp_found_69 = (sum_man_vec_69 == 1'b1);
  assign tmp_found_70 = (sum_man_vec_70 == 1'b1);

  // LZC combination logic (from original lines 536-551 and 783-788)
  assign tmp_found_71 = ((((((((((((((((tmp_found_72 || tmp_found_41) || tmp_found_42) || tmp_found_43) || tmp_found_44) || tmp_found_45) || tmp_found_46) || tmp_found_47) || tmp_found_48) || tmp_found_49) || tmp_found_50) || tmp_found_51) || tmp_found_52) || tmp_found_53) || tmp_found_54) || tmp_found_55) || tmp_found_56);
  assign tmp_found_72 = ((((((((((((((((tmp_found_73 || tmp_found_25) || tmp_found_26) || tmp_found_27) || tmp_found_28) || tmp_found_29) || tmp_found_30) || tmp_found_31) || tmp_found_32) || tmp_found_33) || tmp_found_34) || tmp_found_35) || tmp_found_36) || tmp_found_37) || tmp_found_38) || tmp_found_39) || tmp_found_40);
  assign tmp_found_73 = ((((((((((((((((tmp_found_74 || tmp_found_9) || tmp_found_10) || tmp_found_11) || tmp_found_12) || tmp_found_13) || tmp_found_14) || tmp_found_15) || tmp_found_16) || tmp_found_17) || tmp_found_18) || tmp_found_19) || tmp_found_20) || tmp_found_21) || tmp_found_22) || tmp_found_23) || tmp_found_24);
  assign tmp_found_74 = ((((((((tmp_found || tmp_found_1) || tmp_found_2) || tmp_found_3) || tmp_found_4) || tmp_found_5) || tmp_found_6) || tmp_found_7) || tmp_found_8);
  assign found = (((((((((((((((tmp_found_71 || tmp_found_57) || tmp_found_58) || tmp_found_59) || tmp_found_60) || tmp_found_61) || tmp_found_62) || tmp_found_63) || tmp_found_64) || tmp_found_65) || tmp_found_66) || tmp_found_67) || tmp_found_68) || tmp_found_69) || tmp_found_70) || (sum_man_vec_71 == 1'b1));

  // LZC value calculation (from original lines 540-551 and 784-785)
  assign tmp_lzc = 7'h0a;
  assign tmp_lzc_1 = (tmp_found_11 ? 7'h0b : (tmp_found_12 ? 7'h0c : (tmp_found_13 ? 7'h0d : (tmp_found_14 ? 7'h0e : (tmp_found_15 ? 7'h0f : (tmp_found_16 ? 7'h10 : (tmp_found_17 ? 7'h11 : (tmp_found_18 ? 7'h12 : (tmp_found_19 ? 7'h13 : (tmp_found_20 ? 7'h14 : (tmp_found_21 ? tmp_lzc_2 : tmp_lzc_3)))))))))));
  assign tmp_lzc_2 = 7'h15;
  assign tmp_lzc_3 = (tmp_found_22 ? 7'h16 : (tmp_found_23 ? 7'h17 : (tmp_found_24 ? 7'h18 : (tmp_found_25 ? 7'h19 : (tmp_found_26 ? 7'h1a : (tmp_found_27 ? 7'h1b : (tmp_found_28 ? 7'h1c : (tmp_found_29 ? 7'h1d : (tmp_found_30 ? 7'h1e : (tmp_found_31 ? 7'h1f : (tmp_found_32 ? tmp_lzc_4 : tmp_lzc_5)))))))))));
  assign tmp_lzc_4 = 7'h20;
  assign tmp_lzc_5 = (tmp_found_33 ? 7'h21 : (tmp_found_34 ? 7'h22 : (tmp_found_35 ? 7'h23 : (tmp_found_36 ? 7'h24 : (tmp_found_37 ? 7'h25 : (tmp_found_38 ? 7'h26 : (tmp_found_39 ? 7'h27 : (tmp_found_40 ? 7'h28 : (tmp_found_41 ? 7'h29 : (tmp_found_42 ? 7'h2a : (tmp_found_43 ? tmp_lzc_6 : tmp_lzc_7)))))))))));
  assign tmp_lzc_6 = 7'h2b;
  assign tmp_lzc_7 = (tmp_found_44 ? 7'h2c : (tmp_found_45 ? 7'h2d : (tmp_found_46 ? 7'h2e : (tmp_found_47 ? 7'h2f : (tmp_found_48 ? 7'h30 : (tmp_found_49 ? 7'h31 : (tmp_found_50 ? 7'h32 : (tmp_found_51 ? 7'h33 : (tmp_found_52 ? 7'h34 : (tmp_found_53 ? 7'h35 : (tmp_found_54 ? tmp_lzc_8 : tmp_lzc_9)))))))))));
  assign tmp_lzc_8 = 7'h36;
  assign tmp_lzc_9 = (tmp_found_55 ? 7'h37 : (tmp_found_56 ? 7'h38 : (tmp_found_57 ? 7'h39 : (tmp_found_58 ? 7'h3a : (tmp_found_59 ? 7'h3b : (tmp_found_60 ? 7'h3c : (tmp_found_61 ? 7'h3d : (tmp_found_62 ? 7'h3e : (tmp_found_63 ? 7'h3f : (tmp_found_64 ? 7'h40 : (tmp_found_65 ? tmp_lzc_10 : tmp_lzc_11)))))))))));
  assign tmp_lzc_10 = 7'h41;
  assign tmp_lzc_11 = (tmp_found_66 ? 7'h42 : (tmp_found_67 ? 7'h43 : (tmp_found_68 ? 7'h44 : (tmp_found_69 ? 7'h45 : (tmp_found_70 ? 7'h46 : 7'h47)))));
  assign tmp_lzc_real = lzc;
  assign lzc = (tmp_found ? 7'h00 : (tmp_found_1 ? 7'h01 : (tmp_found_2 ? 7'h02 : (tmp_found_3 ? 7'h03 : (tmp_found_4 ? 7'h04 : (tmp_found_5 ? 7'h05 : (tmp_found_6 ? 7'h06 : (tmp_found_7 ? 7'h07 : (tmp_found_8 ? 7'h08 : (tmp_found_9 ? 7'h09 : (tmp_found_10 ? tmp_lzc : tmp_lzc_1)))))))))));
  assign lzc_real = (sum_man_overflow ? 7'h00 : ((! found) ? 7'h48 : tmp_lzc_real));
  assign lzc_large_subnormal = ((7'h30 <= lzc_real) && (lzc_real < 7'h48));
  assign lzc_huge_zero = (7'h48 <= lzc_real);
  assign lzc_normal = (lzc_real < 7'h30);

  // Sign calculation
  assign sum_man_sign = (($signed(sum_man) < $signed(tmp_sum_man_sign_r3)) && (! ($signed(sum_man) == $signed(tmp_sum_man_sign_r3_1))));

  // Register assignments (pipeline stage 3)
  always @(posedge clk) begin
    if (!resetn) begin
      sum_man_abs_all_r3 <= 74'b0;
      product_exp_shift_r3 <= 8'b0;
      output_nan_inf_r3 <= 1'b0;
      inf_sign_r3 <= 1'b0;
      a_b_inf_r3 <= 1'b0;
      c_is_inf_r3 <= 1'b0;
      sum_man_sign_r3 <= 1'b0;
    end else begin
      sum_man_abs_all_r3 <= sum_man_abs_all;
      product_exp_shift_r3 <= product_exp_shift_r2;
      output_nan_inf_r3 <= output_nan_inf_r2;
      inf_sign_r3 <= inf_sign_r2;
      a_b_inf_r3 <= a_b_inf_r2;
      c_is_inf_r3 <= c_is_inf_r2;
      sum_man_sign_r3 <= sum_man_sign;
    end
  end

endmodule
