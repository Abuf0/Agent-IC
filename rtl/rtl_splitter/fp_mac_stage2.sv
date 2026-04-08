// fp_mac_stage2.sv
// Stage 2: 乘法器实例、尾数对齐、指数差计算
// Generated from fp_mac.sv as part of code split

`timescale 1ns/1ps

module fp_mac_stage2 (
  // Clock and reset
  input clk,
  input resetn,

  // Stage 1 inputs (registered)
  input [23:0] a_man_1_r1,
  input [23:0] b_man_1_r1,
  input [23:0] c_man_1_r1,
  input        exp_diff_dir_r1,
  input [7:0]  exp_diff_r1,
  input [7:0]  product_exp_r1,
  input [7:0]  c_exp_r1,
  input        product_sign_r1,
  input        c_sign_r1,
  input        output_nan_inf_r1,
  input        inf_sign_r1,
  input        a_b_inf_r1,
  input        c_is_inf_r1,

  // Stage 2 outputs (registered)
  output reg [71:0] c_man_align_r2,
  output reg [7:0]  product_exp_shift_r2,
  output reg [71:0] product_man_align_r2,
  output reg        product_sign_r2,
  output reg        c_sign_r2,
  output reg        output_nan_inf_r2,
  output reg        inf_sign_r2,
  output reg        a_b_inf_r2,
  output reg        c_is_inf_r2,

  // Internal signals (combinational)
  output wire [71:0] c_man_align,
  output wire [7:0]  product_exp_shift,
  output reg [71:0] product_shift,
  output wire        product_sign,
  output wire        c_sign,
  output wire        output_nan_inf,
  output wire        inf_sign,
  output wire        a_b_inf,
  output wire        c_is_inf
);

  // Wire declarations from original fp_mac.sv
  wire       [23:0]   man_booth4_io_a;
  wire       [23:0]   man_booth4_io_b;
  wire       [47:0]   man_booth4_io_z;
  wire       [95:0]   tmp_c_man_ext;
  wire       [71:0]   tmp_c_man_ext_1;
  wire       [95:0]   tmp_product_man;
  wire       [71:0]   tmp_product_man_1;
  wire       [47:0]   tmp_product_man_2;
  wire       [71:0]   tmp_c_man_shift;
  wire       [71:0]   tmp_product_shift;
  wire       [94:0]   tmp_c_man_align;
  wire       [71:0]   c_man_ext;
  wire       [71:0]   product_man;
  wire                when_fp_mac_l120;
  wire                when_fp_mac_l127;

  // Multiplier instantiation
  mult_booth4 man_booth4 (
    .io_a  (man_booth4_io_a[23:0]), //i
    .io_b  (man_booth4_io_b[23:0]), //i
    .io_tc (1'b0                 ), //i
    .io_z  (man_booth4_io_z[47:0])  //o
  );

  // Combinational logic
  assign tmp_c_man_ext_1 = {48'd0, c_man_1_r1};
  assign tmp_c_man_ext = ({24'd0, tmp_c_man_ext_1} <<< 5'd24);
  assign tmp_product_man_2 = man_booth4_io_z;
  assign tmp_product_man_1 = {24'd0, tmp_product_man_2};
  assign tmp_product_man = ({24'd0, tmp_product_man_1} <<< 5'd24);
  assign tmp_c_man_shift = (c_man_ext >>> exp_diff_r1);
  assign tmp_product_shift = (product_man >>> exp_diff_r1);
  assign tmp_c_man_align = ({23'd0, c_man_shift} <<< 5'd23);

  assign man_booth4_io_a = a_man_1_r1;
  assign man_booth4_io_b = b_man_1_r1;
  assign c_man_ext = tmp_c_man_ext[71:0];
  assign product_man = tmp_product_man[71:0];

  assign when_fp_mac_l120 = (exp_diff_r1 < 8'h30);
  assign when_fp_mac_l127 = (exp_diff_r1 < 8'h30);

  // product_shift always block
  always @(*) begin
    if (exp_diff_dir_r1) begin
      product_shift = product_man;
    end else begin
      if (when_fp_mac_l127) begin
        product_shift = tmp_product_shift;
      end else begin
        product_shift = 72'h000000000000000000;
      end
    end
  end

  // c_man_shift always block
  reg [71:0] c_man_shift;
  always @(*) begin
    if (exp_diff_dir_r1) begin
      if (when_fp_mac_l120) begin
        c_man_shift = tmp_c_man_shift;
      end else begin
        c_man_shift = 72'h000000000000000000;
      end
    end else begin
      c_man_shift = c_man_ext;
    end
  end

  assign c_man_align = tmp_c_man_align[71:0];
  assign product_exp_shift = (exp_diff_dir_r1 ? product_exp_r1 : c_exp_r1);

  // Pass-through signals (from stage1)
  assign product_sign = product_sign_r1;
  assign c_sign = c_sign_r1;
  assign output_nan_inf = output_nan_inf_r1;
  assign inf_sign = inf_sign_r1;
  assign a_b_inf = a_b_inf_r1;
  assign c_is_inf = c_is_inf_r1;

  // Register assignments (pipeline stage 2)
  always @(posedge clk) begin
    if (!resetn) begin
      c_man_align_r2 <= 72'b0;
      product_exp_shift_r2 <= 8'b0;
      product_man_align_r2 <= 72'b0;
      product_sign_r2 <= 1'b0;
      c_sign_r2 <= 1'b0;
      output_nan_inf_r2 <= 1'b0;
      inf_sign_r2 <= 1'b0;
      a_b_inf_r2 <= 1'b0;
      c_is_inf_r2 <= 1'b0;
    end else begin
      c_man_align_r2 <= c_man_align;
      product_exp_shift_r2 <= product_exp_shift;
      product_man_align_r2 <= product_shift;
      product_sign_r2 <= product_sign;
      c_sign_r2 <= c_sign;
      output_nan_inf_r2 <= output_nan_inf;
      inf_sign_r2 <= inf_sign;
      a_b_inf_r2 <= a_b_inf;
      c_is_inf_r2 <= c_is_inf;
    end
  end

endmodule