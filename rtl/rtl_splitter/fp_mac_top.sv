// fp_mac_top.sv
// Top-level module integrating all pipeline stages
// Generated from fp_mac.sv as part of code split
// This module replaces the original fp_mac module

`timescale 1ns/1ps

module fp_mac_top (
  input      [31:0]   io_a,
  input      [31:0]   io_b,
  input      [31:0]   io_c,
  input      [2:0]    io_rnd,
  output reg [31:0]   io_z,
  output reg [7:0]    io_status,
  input               clk,
  input               resetn
);

  // Stage 1 outputs
  wire [23:0] a_man_1_r1;
  wire [23:0] b_man_1_r1;
  wire [23:0] c_man_1_r1;
  wire        exp_diff_dir_r1;
  wire [7:0]  exp_diff_r1;
  wire [7:0]  product_exp_r1;
  wire [7:0]  c_exp_r1;
  wire        product_sign_r1;
  wire        c_sign_r1;
  wire        output_nan_inf_r1;
  wire        inf_sign_r1;
  wire        a_b_inf_r1;
  wire        c_is_inf_r1;

  // Stage 1 internal combinational signals
  wire [23:0] a_man_1;
  wire [23:0] b_man_1;
  wire [23:0] c_man_1;
  wire        exp_diff_dir;
  wire [7:0]  exp_diff;
  wire [7:0]  product_exp;
  wire        product_sign;
  wire        c_sign;
  wire        output_nan_inf;
  wire        inf_sign;
  wire        a_b_inf;
  wire        c_is_inf;

  // Stage 2 outputs
  wire [71:0] c_man_align_r2;
  wire [7:0]  product_exp_shift_r2;
  wire [71:0] product_man_align_r2;
  wire        product_sign_r2;
  wire        c_sign_r2;
  wire        output_nan_inf_r2;
  wire        inf_sign_r2;
  wire        a_b_inf_r2;
  wire        c_is_inf_r2;

  // Stage 2 internal combinational signals
  wire [71:0] c_man_align;
  wire [7:0]  product_exp_shift;
  wire [71:0] product_shift;
  wire        product_sign_s2;
  wire        c_sign_s2;
  wire        output_nan_inf_s2;
  wire        inf_sign_s2;
  wire        a_b_inf_s2;
  wire        c_is_inf_s2;

  // Stage 3 outputs
  wire [73:0] sum_man_abs_all_r3;
  wire [7:0]  product_exp_shift_r3;
  wire        output_nan_inf_r3;
  wire        inf_sign_r3;
  wire        a_b_inf_r3;
  wire        c_is_inf_r3;
  wire        sum_man_sign_r3;

  // Stage 3 internal combinational signals
  wire [73:0] sum_man_abs_all;
  wire        sum_man_sign;
  wire [6:0]  lzc_real;
  wire        lzc_large_subnormal;
  wire        lzc_huge_zero;
  wire        lzc_normal;

  // Stage 4 outputs
  wire [6:0]  lzc_real_r4;
  wire [73:0] sum_man_abs_all_r4;
  wire [7:0]  product_exp_shift_r4;
  wire        output_nan_inf_r4;
  wire        inf_sign_r4;
  wire        a_b_inf_r4;
  wire        c_is_inf_r4;
  wire        sum_man_sign_r4;
  wire        lzc_large_subnormal_r4;
  wire        lzc_huge_zero_r4;
  wire        lzc_normal_r4;

  // Instantiate stage 1
  fp_mac_stage1 stage1_inst (
    .io_a(io_a),
    .io_b(io_b),
    .io_c(io_c),
    .io_rnd(io_rnd),
    .clk(clk),
    .resetn(resetn),
    .a_man_1_r1(a_man_1_r1),
    .b_man_1_r1(b_man_1_r1),
    .c_man_1_r1(c_man_1_r1),
    .exp_diff_dir_r1(exp_diff_dir_r1),
    .exp_diff_r1(exp_diff_r1),
    .product_exp_r1(product_exp_r1),
    .c_exp_r1(c_exp_r1),
    .product_sign_r1(product_sign_r1),
    .c_sign_r1(c_sign_r1),
    .output_nan_inf_r1(output_nan_inf_r1),
    .inf_sign_r1(inf_sign_r1),
    .a_b_inf_r1(a_b_inf_r1),
    .c_is_inf_r1(c_is_inf_r1),
    .a_man_1(a_man_1),
    .b_man_1(b_man_1),
    .c_man_1(c_man_1),
    .exp_diff_dir(exp_diff_dir),
    .exp_diff(exp_diff),
    .product_exp(product_exp),
    .product_sign(product_sign),
    .c_sign(c_sign),
    .output_nan_inf(output_nan_inf),
    .inf_sign(inf_sign),
    .a_b_inf(a_b_inf),
    .c_is_inf(c_is_inf)
  );

  // Instantiate stage 2
  fp_mac_stage2 stage2_inst (
    .clk(clk),
    .resetn(resetn),
    .a_man_1_r1(a_man_1_r1),
    .b_man_1_r1(b_man_1_r1),
    .c_man_1_r1(c_man_1_r1),
    .exp_diff_dir_r1(exp_diff_dir_r1),
    .exp_diff_r1(exp_diff_r1),
    .product_exp_r1(product_exp_r1),
    .c_exp_r1(c_exp_r1),
    .product_sign_r1(product_sign_r1),
    .c_sign_r1(c_sign_r1),
    .output_nan_inf_r1(output_nan_inf_r1),
    .inf_sign_r1(inf_sign_r1),
    .a_b_inf_r1(a_b_inf_r1),
    .c_is_inf_r1(c_is_inf_r1),
    .c_man_align_r2(c_man_align_r2),
    .product_exp_shift_r2(product_exp_shift_r2),
    .product_man_align_r2(product_man_align_r2),
    .product_sign_r2(product_sign_r2),
    .c_sign_r2(c_sign_r2),
    .output_nan_inf_r2(output_nan_inf_r2),
    .inf_sign_r2(inf_sign_r2),
    .a_b_inf_r2(a_b_inf_r2),
    .c_is_inf_r2(c_is_inf_r2),
    .c_man_align(c_man_align),
    .product_exp_shift(product_exp_shift),
    .product_shift(product_shift),
    .product_sign(product_sign_s2),
    .c_sign(c_sign_s2),
    .output_nan_inf(output_nan_inf_s2),
    .inf_sign(inf_sign_s2),
    .a_b_inf(a_b_inf_s2),
    .c_is_inf(c_is_inf_s2)
  );

  // Instantiate stage 3
  fp_mac_stage3 stage3_inst (
    .clk(clk),
    .resetn(resetn),
    .c_man_align_r2(c_man_align_r2),
    .product_exp_shift_r2(product_exp_shift_r2),
    .product_man_align_r2(product_man_align_r2),
    .product_sign_r2(product_sign_r2),
    .c_sign_r2(c_sign_r2),
    .output_nan_inf_r2(output_nan_inf_r2),
    .inf_sign_r2(inf_sign_r2),
    .a_b_inf_r2(a_b_inf_r2),
    .c_is_inf_r2(c_is_inf_r2),
    .sum_man_abs_all_r3(sum_man_abs_all_r3),
    .product_exp_shift_r3(product_exp_shift_r3),
    .output_nan_inf_r3(output_nan_inf_r3),
    .inf_sign_r3(inf_sign_r3),
    .a_b_inf_r3(a_b_inf_r3),
    .c_is_inf_r3(c_is_inf_r3),
    .sum_man_sign_r3(sum_man_sign_r3),
    .sum_man_abs_all(sum_man_abs_all),
    .sum_man_sign(sum_man_sign),
    .lzc_real(lzc_real),
    .lzc_large_subnormal(lzc_large_subnormal),
    .lzc_huge_zero(lzc_huge_zero),
    .lzc_normal(lzc_normal)
  );

  // Instantiate stage 4
  fp_mac_stage4 stage4_inst (
    .clk(clk),
    .resetn(resetn),
    .sum_man_abs_all_r3(sum_man_abs_all_r3),
    .product_exp_shift_r3(product_exp_shift_r3),
    .output_nan_inf_r3(output_nan_inf_r3),
    .inf_sign_r3(inf_sign_r3),
    .a_b_inf_r3(a_b_inf_r3),
    .c_is_inf_r3(c_is_inf_r3),
    .sum_man_sign_r3(sum_man_sign_r3),
    .lzc_real(lzc_real),
    .lzc_large_subnormal(lzc_large_subnormal),
    .lzc_huge_zero(lzc_huge_zero),
    .lzc_normal(lzc_normal),
    .io_rnd(io_rnd),
    .lzc_real_r4(lzc_real_r4),
    .sum_man_abs_all_r4(sum_man_abs_all_r4),
    .product_exp_shift_r4(product_exp_shift_r4),
    .output_nan_inf_r4(output_nan_inf_r4),
    .inf_sign_r4(inf_sign_r4),
    .a_b_inf_r4(a_b_inf_r4),
    .c_is_inf_r4(c_is_inf_r4),
    .sum_man_sign_r4(sum_man_sign_r4),
    .lzc_large_subnormal_r4(lzc_large_subnormal_r4),
    .lzc_huge_zero_r4(lzc_huge_zero_r4),
    .lzc_normal_r4(lzc_normal_r4),
    .io_z(io_z),
    .io_status(io_status)
  );

endmodule