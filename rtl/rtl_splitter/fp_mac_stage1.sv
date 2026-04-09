// fp_mac_stage1.sv
// Stage 1: 输入解码、特殊值处理、指数计算、隐藏位添加
// Generated from fp_mac.sv as part of code split
//
// ============================================================================
// Stage 1: Input Decode and Special Case Handling
// ============================================================================
// Function:
//   - Extracts sign, exponent, mantissa from IEEE 754 inputs.
//   - Adds hidden bit to mantissas for normalized numbers.
//   - Detects special values: NaN, Infinity, Zero.
//   - Computes product sign, exponent sum, exponent difference.
//   - Checks for NaN propagation, infinity cancellation, zero multiplication.
//
// Pipeline:
//   Inputs: Raw floating-point inputs io_a, io_b, io_c.
//   Outputs: Registered mantissas, exponents, signs, control signals.
//
// Key Operations:
//   1. Sign extraction and product sign calculation (a_sign ^ b_sign).
//   2. Exponent sum and bias adjustment.
//   3. Hidden bit addition based on exponent zero (subnormal handling).
//   4. Special case flags (NaN, Inf, zero) and exception detection.
// ============================================================================


`timescale 1ns/1ps

module fp_mac_stage1 (
  // Primary inputs
  input [31:0] io_a,
  input [31:0] io_b,
  input [31:0] io_c,
  input [2:0]  io_rnd,
  input        clk,
  input        resetn,

  // Stage 1 outputs (registered)
  output reg [23:0] a_man_1_r1,
  output reg [23:0] b_man_1_r1,
  output reg [23:0] c_man_1_r1,
  output reg        exp_diff_dir_r1,
  output reg [7:0]  exp_diff_r1,
  output reg [7:0]  product_exp_r1,
  output reg [7:0]  c_exp_r1,
  output reg        product_sign_r1,
  output reg        c_sign_r1,
  output reg        output_nan_inf_r1,
  output reg        inf_sign_r1,
  output reg        a_b_inf_r1,
  output reg        c_is_inf_r1,

  // Internal signals (combinational)
  output wire [23:0] a_man_1,
  output wire [23:0] b_man_1,
  output wire [23:0] c_man_1,
  output wire        exp_diff_dir,
  output reg [7:0]  exp_diff,
  output wire [7:0]  product_exp,
  output wire        product_sign,
  output wire        c_sign,
  output wire        output_nan_inf,
  output wire        inf_sign,
  output wire        a_b_inf,
  output wire        c_is_inf
);

  // Wire declarations from original fp_mac.sv (lines 1-180)
  wire       [0:0]    tmp_a_hidden;
  wire       [0:0]    tmp_b_hidden;
  wire       [0:0]    tmp_c_hidden;
  wire       [7:0]    tmp_product_exp;
  wire                a_sign;
  wire                b_sign;
  wire       [7:0]    a_exp;
  wire       [7:0]    b_exp;
  wire       [7:0]    c_exp;
  wire       [22:0]   a_man;
  wire       [22:0]   b_man;
  wire       [22:0]   c_man;
  wire       [0:0]    a_hidden;
  wire       [0:0]    b_hidden;
  wire       [0:0]    c_hidden;
  wire       [7:0]    exp_all_one;
  wire                a_is_inf;
  wire                b_is_inf;
  wire                a_is_nan;
  wire                b_is_nan;
  wire                c_is_nan;
  wire                output_nan;
  wire                a_zero;
  wire                b_zero;
  wire                inf_x_zero;
  wire                prod_is_inf;
  wire                inf_cancel;

  // Combinational logic from original fp_mac.sv
  assign tmp_a_hidden = (a_exp != 8'h00);
  assign tmp_b_hidden = (b_exp != 8'h00);
  assign tmp_c_hidden = (c_exp != 8'h00);
  assign tmp_product_exp = (a_exp + b_exp);

  assign a_sign = io_a[31];
  assign b_sign = io_b[31];
  assign c_sign = io_c[31];
  assign a_exp = io_a[30 : 23];
  assign b_exp = io_b[30 : 23];
  assign c_exp = io_c[30 : 23];
  assign a_man = io_a[22 : 0];
  assign b_man = io_b[22 : 0];
  assign c_man = io_c[22 : 0];

  assign a_hidden = tmp_a_hidden;
  assign b_hidden = tmp_b_hidden;
  assign c_hidden = tmp_c_hidden;
  assign a_man_1 = {a_hidden, a_man};
  assign b_man_1 = {b_hidden, b_man};
  assign c_man_1 = {c_hidden, c_man};

  assign product_sign = (a_sign ^ b_sign);
  assign exp_all_one = 8'hff;
  assign a_is_inf = ((a_exp == exp_all_one) && (a_man == 23'h000000));
  assign b_is_inf = ((b_exp == exp_all_one) && (b_man == 23'h000000));
  assign c_is_inf = ((c_exp == exp_all_one) && (c_man == 23'h000000));
  assign a_is_nan = ((a_exp == exp_all_one) && (a_man != 23'h000000));
  assign b_is_nan = ((b_exp == exp_all_one) && (b_man != 23'h000000));
  assign c_is_nan = ((c_exp == exp_all_one) && (c_man != 23'h000000));
  assign output_nan = ((a_is_nan || b_is_nan) || c_is_nan);
  assign a_b_inf = (a_is_inf || b_is_inf);
  assign a_zero = ((a_exp == 8'h00) && (a_man == 23'h000000));
  assign b_zero = ((b_exp == 8'h00) && (b_man == 23'h000000));
  assign inf_x_zero = ((a_is_inf && b_zero) || (b_is_inf && a_zero));
  assign prod_is_inf = (a_b_inf && (! inf_x_zero));
  assign inf_cancel = ((prod_is_inf && c_is_inf) && (product_sign != c_sign));
  assign output_nan_inf = ((output_nan || inf_x_zero) || inf_cancel);
  assign inf_sign = (a_b_inf ? product_sign : c_sign);
  assign product_exp = (tmp_product_exp - 8'h7f);
  assign exp_diff_dir = (c_exp < product_exp);

  always @(*) begin
    if (exp_diff_dir) begin
      exp_diff = (product_exp - c_exp);
    end else begin
      exp_diff = (c_exp - product_exp);
    end
  end

  // Register assignments (pipeline stage 1)
  always @(posedge clk) begin
    if (!resetn) begin
      a_man_1_r1 <= 24'b0;
      b_man_1_r1 <= 24'b0;
      c_man_1_r1 <= 24'b0;
      exp_diff_dir_r1 <= 1'b0;
      exp_diff_r1 <= 8'b0;
      product_exp_r1 <= 8'b0;
      c_exp_r1 <= 8'b0;
      product_sign_r1 <= 1'b0;
      c_sign_r1 <= 1'b0;
      output_nan_inf_r1 <= 1'b0;
      inf_sign_r1 <= 1'b0;
      a_b_inf_r1 <= 1'b0;
      c_is_inf_r1 <= 1'b0;
    end else begin
      a_man_1_r1 <= a_man_1;
      b_man_1_r1 <= b_man_1;
      c_man_1_r1 <= c_man_1;
      exp_diff_dir_r1 <= exp_diff_dir;
      exp_diff_r1 <= exp_diff;
      product_exp_r1 <= product_exp;
      c_exp_r1 <= c_exp;
      product_sign_r1 <= product_sign;
      c_sign_r1 <= c_sign;
      output_nan_inf_r1 <= output_nan_inf;
      inf_sign_r1 <= inf_sign;
      a_b_inf_r1 <= a_b_inf;
      c_is_inf_r1 <= c_is_inf;
    end
  end

endmodule
