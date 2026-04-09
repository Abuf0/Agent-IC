// fp_mac_stage4.sv
// Stage 4: 规格化、舍入、溢出处理、输出选择
// Generated from fp_mac.sv as part of code split
//
// ============================================================================
// Stage 4: Normalization, Rounding, and Result Packing
// ============================================================================
// Function:
//   - Normalizes mantissa using LZC result (left shift).
//   - Adjusts exponent based on normalization shift.
//   - Performs rounding according to IEEE 754 rounding modes.
//   - Handles mantissa overflow and exponent increment.
//   - Selects final result: normal, subnormal, or zero.
//   - Packs sign, exponent, mantissa into 32-bit floating-point format.
//   - Generates status flags (NaN, Inf, etc.) for special cases.
//
// Pipeline:
//   Inputs: Absolute sum, LZC, exponents, signs from Stage 3.
//   Outputs: Final 32-bit result io_z and status io_status.
//
// Key Operations:
//   1. Normalization shift (left shift by LZC).
//   2. Rounding decision based on guard, round, sticky bits.
//   3. Exponent adjustment for normalization and rounding overflow.
//   4. Subnormal handling (large shift) and zero detection.
//   5. Final result multiplexing (normal, subnormal, special).
// ============================================================================


`timescale 1ns/1ps

module fp_mac_stage4 (
  // Clock and reset
  input clk,
  input resetn,

  // Stage 3 inputs (registered)
  input [73:0] sum_man_abs_all_r3,
  input [7:0]  product_exp_shift_r3,
  input        output_nan_inf_r3,
  input        inf_sign_r3,
  input        a_b_inf_r3,
  input        c_is_inf_r3,
  input        sum_man_sign_r3,

  // Stage 3 combinatorial outputs (LZC results)
  input [6:0]  lzc_real,
  input        lzc_large_subnormal,
  input        lzc_huge_zero,
  input        lzc_normal,

  // Rounding mode input (from top)
  input [2:0]  io_rnd,

  // Stage 4 outputs (registered)
  output reg [6:0]  lzc_real_r4,
  output reg [73:0] sum_man_abs_all_r4,
  output reg [7:0]  product_exp_shift_r4,
  output reg        output_nan_inf_r4,
  output reg        inf_sign_r4,
  output reg        a_b_inf_r4,
  output reg        c_is_inf_r4,
  output reg        sum_man_sign_r4,
  output reg        lzc_large_subnormal_r4,
  output reg        lzc_huge_zero_r4,
  output reg        lzc_normal_r4,

  // Final outputs
  output reg [31:0] io_z,
  output reg [7:0]  io_status
);

  // Wire declarations from original fp_mac.sv
  wire       [71:0]   sum_man_abs_r4;
  wire                sum_man_overflow_r4;
  wire       [71:0]   norm_man;
  wire       [7:0]    result_exp;
  wire       [23:0]   result_man;
  wire                guard_bit;
  wire                round_bit;
  wire                sticky_bit;
  reg                 tmp_round_up;
  wire                round_up;
  wire       [22:0]   man_rounded;
  wire                man_overflow;
  wire       [7:0]    exp_final;
  wire       [22:0]   man_final;
  wire       [31:0]   norm_num;
  wire                sub_sign;
  wire       [31:0]   subnorm_num;
  wire       [31:0]   z;
  reg        [22:0]   tmp_io_z;
  wire                when_fp_mac_l254;

  // Additional wires for intermediate calculations
  wire       [71:0]   tmp_norm_man;
  wire       [71:0]   tmp_norm_man_1;
  wire       [71:0]   tmp_norm_man_2;
  wire       [198:0]  tmp_norm_man_3;
  wire       [7:0]    tmp_result_exp;
  wire       [7:0]    tmp_result_exp_1;
  wire       [7:0]    tmp_result_exp_2;
  wire       [7:0]    tmp_result_exp_3;
  wire       [0:0]    tmp_result_exp_4;
  wire       [7:0]    tmp_result_exp_5;
  wire       [0:0]    tmp_result_exp_6;
  wire       [0:0]    tmp_round_up_1;
  wire       [22:0]   tmp_man_rounded;
  wire       [0:0]    tmp_man_rounded_1;
  wire       [7:0]    tmp_exp_final;
  wire       [0:0]    tmp_exp_final_1;
  wire       [31:0]   tmp_norm_num;
  wire       [31:0]   tmp_subnorm_num;
  wire       [31:0]   tmp_subnorm_num_1;

  // Combinational logic from original fp_mac.sv (lines 789-831)
  assign sum_man_abs_r4 = sum_man_abs_all_r4[71 : 0];
  assign sum_man_overflow_r4 = sum_man_abs_all_r4[72];

  assign tmp_norm_man_1 = (sum_man_abs_all_r4[72 : 0] >>> 1'd1);
  assign tmp_norm_man = tmp_norm_man_1;
  assign tmp_norm_man_3 = ({127'd0, sum_man_abs_r4} <<< lzc_real);
  assign tmp_norm_man_2 = tmp_norm_man_3[71:0];
  assign norm_man = (sum_man_overflow_r4 ? tmp_norm_man : tmp_norm_man_2);

  assign tmp_result_exp_1 = (product_exp_shift_r3 - tmp_result_exp_2);
  assign tmp_result_exp_2 = {1'd0, lzc_real};
  assign tmp_result_exp_4 = norm_man[71];
  assign tmp_result_exp_3 = {7'd0, tmp_result_exp_4};
  assign tmp_result_exp = (tmp_result_exp_1 + tmp_result_exp_3);
  assign tmp_result_exp_6 = sum_man_overflow_r4;
  assign tmp_result_exp_5 = {7'd0, tmp_result_exp_6};
  assign result_exp = (tmp_result_exp + tmp_result_exp_5);

  assign result_man = norm_man[71 : 48];
  assign guard_bit = norm_man[47];
  assign round_bit = norm_man[46];
  assign sticky_bit = (|norm_man[45 : 24]);

  // tmp_round_up always block (rounding mode selection)
  always @(*) begin
    case(io_rnd)
      3'b000 : begin
        tmp_round_up = (guard_bit && ((round_bit || sticky_bit) || result_man[0]));
      end
      3'b001 : begin
        tmp_round_up = 1'b0;
      end
      3'b010 : begin
        tmp_round_up = (sum_man_sign_r4 && ((guard_bit || round_bit) || sticky_bit));
      end
      3'b011 : begin
        tmp_round_up = ((! sum_man_sign_r4) && ((guard_bit || round_bit) || sticky_bit));
      end
      3'b100 : begin
        tmp_round_up = (guard_bit && (round_bit || sticky_bit));
      end
      default : begin
        tmp_round_up = (guard_bit && ((round_bit || sticky_bit) || result_man[0]));
      end
    endcase
  end

  assign tmp_round_up_1 = tmp_round_up;
  assign round_up = tmp_round_up_1[0];

  assign tmp_man_rounded_1 = round_up;
  assign tmp_man_rounded = {22'd0, tmp_man_rounded_1};
  assign man_rounded = (result_man[22 : 0] + tmp_man_rounded);
  assign man_overflow = ((&result_man[22 : 0]) && round_up);

  assign tmp_exp_final_1 = man_overflow;
  assign tmp_exp_final = {7'd0, tmp_exp_final_1};
  assign exp_final = (result_exp[7 : 0] + tmp_exp_final);
  assign man_final = ((&exp_final) ? 23'h000000 : man_rounded);

  assign tmp_norm_num = {{sum_man_sign_r4, exp_final}, man_final};
  assign norm_num = tmp_norm_num;

  assign sub_sign = (sum_man_sign_r4 && (|man_final));
  assign tmp_subnorm_num_1 = {{sub_sign, 8'h00}, man_final};
  assign tmp_subnorm_num = tmp_subnorm_num_1;
  assign subnorm_num = (lzc_huge_zero ? 32'h00000000 : tmp_subnorm_num);

  assign z = (lzc_normal ? norm_num : subnorm_num);

  // Function zz_tmp_io_z (for NaN payload)
  function [22:0] zz_tmp_io_z(input dummy);
    begin
      zz_tmp_io_z = 23'h000000;
      zz_tmp_io_z[22] = 1'b1;
    end
  endfunction

  wire [22:0] tmp_1;
  assign tmp_1 = zz_tmp_io_z(1'b0);
  always @(*) tmp_io_z = tmp_1;

  assign when_fp_mac_l254 = (a_b_inf_r4 || c_is_inf_r4);

  // Register assignments (pipeline stage 4)
  always @(posedge clk) begin
    if (!resetn) begin
      lzc_real_r4 <= 7'b0;
      sum_man_abs_all_r4 <= 74'b0;
      product_exp_shift_r4 <= 8'b0;
      output_nan_inf_r4 <= 1'b0;
      inf_sign_r4 <= 1'b0;
      a_b_inf_r4 <= 1'b0;
      c_is_inf_r4 <= 1'b0;
      sum_man_sign_r4 <= 1'b0;
      lzc_large_subnormal_r4 <= 1'b0;
      lzc_huge_zero_r4 <= 1'b0;
      lzc_normal_r4 <= 1'b0;
      io_z <= 32'b0;
      io_status <= 8'b0;
    end else begin
      // Pipeline registers
      lzc_real_r4 <= lzc_real;
      sum_man_abs_all_r4 <= sum_man_abs_all_r3;
      product_exp_shift_r4 <= product_exp_shift_r3;
      output_nan_inf_r4 <= output_nan_inf_r3;
      inf_sign_r4 <= inf_sign_r3;
      a_b_inf_r4 <= a_b_inf_r3;
      c_is_inf_r4 <= c_is_inf_r3;
      sum_man_sign_r4 <= sum_man_sign_r3;
      lzc_large_subnormal_r4 <= lzc_large_subnormal;
      lzc_huge_zero_r4 <= lzc_huge_zero;
      lzc_normal_r4 <= lzc_normal;

      // Output logic (similar to original always block)
      if (output_nan_inf_r4) begin
        io_z <= {{1'b0, 8'hff}, tmp_io_z};
        io_status <= 8'h01;
      end else begin
        if (when_fp_mac_l254) begin
          io_z <= {{inf_sign_r4, 8'hff}, 23'h000000};
          io_status <= 8'h02;
        end else begin
          io_z <= z;
          io_status <= 8'h00;
        end
      end
    end
  end

endmodule
