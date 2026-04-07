// Generator : SpinalHDL v1.9.0    git head : 7d30dbacbd3aa1be42fb2a3d4da5675703aae2ae
// Component : mult_booth4
// Git hash  : c982d0aac03e1ed897d6c33309713a5773bade24

`timescale 1ns/1ps 
module mult_booth4 (
  input      [23:0]   io_a,
  input      [23:0]   io_b,
  input               io_tc,
  output     [47:0]   io_z
);

  wire       [49:0]   wallace_adder_io_sum;
  wire       [24:0]   tmp_b_ext;
  wire       [25:0]   tmp_b_ext_1;
  wire       [24:0]   tmp_b_ext_2;
  wire       [24:0]   tmp_a_ext;
  wire       [50:0]   tmp_pp_grp_0;
  wire       [49:0]   tmp_pp_grp_0_1;
  wire       [49:0]   tmp_pp_grp_0_2;
  wire       [50:0]   tmp_pp_grp_0_3;
  wire       [49:0]   tmp_pp_grp_0_4;
  wire       [49:0]   tmp_pp_grp_0_5;
  wire       [49:0]   tmp_pp_grp_0_6;
  wire       [50:0]   tmp_pp_grp_1;
  wire       [49:0]   tmp_pp_grp_1_1;
  wire       [49:0]   tmp_pp_grp_1_2;
  wire       [50:0]   tmp_pp_grp_1_3;
  wire       [49:0]   tmp_pp_grp_1_4;
  wire       [49:0]   tmp_pp_grp_1_5;
  wire       [49:0]   tmp_pp_grp_1_6;
  wire       [50:0]   tmp_pp_grp_2;
  wire       [49:0]   tmp_pp_grp_2_1;
  wire       [49:0]   tmp_pp_grp_2_2;
  wire       [50:0]   tmp_pp_grp_2_3;
  wire       [49:0]   tmp_pp_grp_2_4;
  wire       [49:0]   tmp_pp_grp_2_5;
  wire       [49:0]   tmp_pp_grp_2_6;
  wire       [50:0]   tmp_pp_grp_3;
  wire       [49:0]   tmp_pp_grp_3_1;
  wire       [49:0]   tmp_pp_grp_3_2;
  wire       [50:0]   tmp_pp_grp_3_3;
  wire       [49:0]   tmp_pp_grp_3_4;
  wire       [49:0]   tmp_pp_grp_3_5;
  wire       [49:0]   tmp_pp_grp_3_6;
  wire       [50:0]   tmp_pp_grp_4;
  wire       [49:0]   tmp_pp_grp_4_1;
  wire       [49:0]   tmp_pp_grp_4_2;
  wire       [50:0]   tmp_pp_grp_4_3;
  wire       [49:0]   tmp_pp_grp_4_4;
  wire       [49:0]   tmp_pp_grp_4_5;
  wire       [49:0]   tmp_pp_grp_4_6;
  wire       [50:0]   tmp_pp_grp_5;
  wire       [49:0]   tmp_pp_grp_5_1;
  wire       [49:0]   tmp_pp_grp_5_2;
  wire       [50:0]   tmp_pp_grp_5_3;
  wire       [49:0]   tmp_pp_grp_5_4;
  wire       [49:0]   tmp_pp_grp_5_5;
  wire       [49:0]   tmp_pp_grp_5_6;
  wire       [50:0]   tmp_pp_grp_6;
  wire       [49:0]   tmp_pp_grp_6_1;
  wire       [49:0]   tmp_pp_grp_6_2;
  wire       [50:0]   tmp_pp_grp_6_3;
  wire       [49:0]   tmp_pp_grp_6_4;
  wire       [49:0]   tmp_pp_grp_6_5;
  wire       [49:0]   tmp_pp_grp_6_6;
  wire       [50:0]   tmp_pp_grp_7;
  wire       [49:0]   tmp_pp_grp_7_1;
  wire       [49:0]   tmp_pp_grp_7_2;
  wire       [50:0]   tmp_pp_grp_7_3;
  wire       [49:0]   tmp_pp_grp_7_4;
  wire       [49:0]   tmp_pp_grp_7_5;
  wire       [49:0]   tmp_pp_grp_7_6;
  wire       [50:0]   tmp_pp_grp_8;
  wire       [49:0]   tmp_pp_grp_8_1;
  wire       [49:0]   tmp_pp_grp_8_2;
  wire       [50:0]   tmp_pp_grp_8_3;
  wire       [49:0]   tmp_pp_grp_8_4;
  wire       [49:0]   tmp_pp_grp_8_5;
  wire       [49:0]   tmp_pp_grp_8_6;
  wire       [50:0]   tmp_pp_grp_9;
  wire       [49:0]   tmp_pp_grp_9_1;
  wire       [49:0]   tmp_pp_grp_9_2;
  wire       [50:0]   tmp_pp_grp_9_3;
  wire       [49:0]   tmp_pp_grp_9_4;
  wire       [49:0]   tmp_pp_grp_9_5;
  wire       [49:0]   tmp_pp_grp_9_6;
  wire       [50:0]   tmp_pp_grp_10;
  wire       [49:0]   tmp_pp_grp_10_1;
  wire       [49:0]   tmp_pp_grp_10_2;
  wire       [50:0]   tmp_pp_grp_10_3;
  wire       [49:0]   tmp_pp_grp_10_4;
  wire       [49:0]   tmp_pp_grp_10_5;
  wire       [49:0]   tmp_pp_grp_10_6;
  wire       [50:0]   tmp_pp_grp_11;
  wire       [49:0]   tmp_pp_grp_11_1;
  wire       [49:0]   tmp_pp_grp_11_2;
  wire       [50:0]   tmp_pp_grp_11_3;
  wire       [49:0]   tmp_pp_grp_11_4;
  wire       [49:0]   tmp_pp_grp_11_5;
  wire       [49:0]   tmp_pp_grp_11_6;
  wire       [50:0]   tmp_pp_grp_12;
  wire       [49:0]   tmp_pp_grp_12_1;
  wire       [49:0]   tmp_pp_grp_12_2;
  wire       [50:0]   tmp_pp_grp_12_3;
  wire       [49:0]   tmp_pp_grp_12_4;
  wire       [49:0]   tmp_pp_grp_12_5;
  wire       [49:0]   tmp_pp_grp_12_6;
  wire       [51:0]   tmp_pp_shifted_1;
  wire       [53:0]   tmp_pp_shifted_2;
  wire       [55:0]   tmp_pp_shifted_3;
  wire       [57:0]   tmp_pp_shifted_4;
  wire       [59:0]   tmp_pp_shifted_5;
  wire       [61:0]   tmp_pp_shifted_6;
  wire       [63:0]   tmp_pp_shifted_7;
  wire       [65:0]   tmp_pp_shifted_8;
  wire       [67:0]   tmp_pp_shifted_9;
  wire       [69:0]   tmp_pp_shifted_10;
  wire       [71:0]   tmp_pp_shifted_11;
  wire       [73:0]   tmp_pp_shifted_12;
  wire       [49:0]   tmp_pp_sum;
  wire       [49:0]   tmp_pp_sum_1;
  wire       [49:0]   tmp_pp_sum_2;
  wire       [49:0]   tmp_pp_sum_3;
  wire       [49:0]   tmp_pp_sum_4;
  wire       [49:0]   tmp_pp_sum_5;
  wire       [49:0]   tmp_pp_sum_6;
  wire       [49:0]   tmp_pp_sum_7;
  wire       [49:0]   tmp_pp_sum_8;
  wire       [49:0]   tmp_pp_sum_9;
  wire       [49:0]   tmp_pp_sum_10;
  wire       [49:0]   tmp_pp_sum_11;
  wire       [47:0]   tmp_io_z;
  wire       [24:0]   a_ts;
  wire       [24:0]   b_ts;
  reg        [25:0]   b_ext;
  reg        [26:0]   a_ext;
  wire       [2:0]    dec_grp_0;
  wire       [2:0]    dec_grp_1;
  wire       [2:0]    dec_grp_2;
  wire       [2:0]    dec_grp_3;
  wire       [2:0]    dec_grp_4;
  wire       [2:0]    dec_grp_5;
  wire       [2:0]    dec_grp_6;
  wire       [2:0]    dec_grp_7;
  wire       [2:0]    dec_grp_8;
  wire       [2:0]    dec_grp_9;
  wire       [2:0]    dec_grp_10;
  wire       [2:0]    dec_grp_11;
  wire       [2:0]    dec_grp_12;
  reg        [49:0]   pp_grp_0;
  reg        [49:0]   pp_grp_1;
  reg        [49:0]   pp_grp_2;
  reg        [49:0]   pp_grp_3;
  reg        [49:0]   pp_grp_4;
  reg        [49:0]   pp_grp_5;
  reg        [49:0]   pp_grp_6;
  reg        [49:0]   pp_grp_7;
  reg        [49:0]   pp_grp_8;
  reg        [49:0]   pp_grp_9;
  reg        [49:0]   pp_grp_10;
  reg        [49:0]   pp_grp_11;
  reg        [49:0]   pp_grp_12;
  wire       [49:0]   pp_sum;
  wire       [49:0]   pp_shifted_0;
  wire       [49:0]   pp_shifted_1;
  wire       [49:0]   pp_shifted_2;
  wire       [49:0]   pp_shifted_3;
  wire       [49:0]   pp_shifted_4;
  wire       [49:0]   pp_shifted_5;
  wire       [49:0]   pp_shifted_6;
  wire       [49:0]   pp_shifted_7;
  wire       [49:0]   pp_shifted_8;
  wire       [49:0]   pp_shifted_9;
  wire       [49:0]   pp_shifted_10;
  wire       [49:0]   pp_shifted_11;
  wire       [49:0]   pp_shifted_12;
  wire       [49:0]   pp_bit_0;
  wire       [49:0]   pp_bit_1;
  wire       [49:0]   pp_bit_2;
  wire       [49:0]   pp_bit_3;
  wire       [49:0]   pp_bit_4;
  wire       [49:0]   pp_bit_5;
  wire       [49:0]   pp_bit_6;
  wire       [49:0]   pp_bit_7;
  wire       [49:0]   pp_bit_8;
  wire       [49:0]   pp_bit_9;
  wire       [49:0]   pp_bit_10;
  wire       [49:0]   pp_bit_11;
  wire       [49:0]   pp_bit_12;
  wire                pp_sum_error;

  assign tmp_b_ext = b_ts;
  assign tmp_b_ext_2 = b_ts;
  assign tmp_b_ext_1 = {1'd0, tmp_b_ext_2};
  assign tmp_a_ext = a_ts;
  assign tmp_pp_grp_0 = ({1'd0,tmp_pp_grp_0_1} <<< 1'd1);
  assign tmp_pp_grp_0_1 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_0_3 = ({1'd0,tmp_pp_grp_0_4} <<< 1'd1);
  assign tmp_pp_grp_0_2 = tmp_pp_grp_0_3[49:0];
  assign tmp_pp_grp_0_4 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_0_5 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_0_6 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_1 = ({1'd0,tmp_pp_grp_1_1} <<< 1'd1);
  assign tmp_pp_grp_1_1 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_1_3 = ({1'd0,tmp_pp_grp_1_4} <<< 1'd1);
  assign tmp_pp_grp_1_2 = tmp_pp_grp_1_3[49:0];
  assign tmp_pp_grp_1_4 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_1_5 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_1_6 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_2 = ({1'd0,tmp_pp_grp_2_1} <<< 1'd1);
  assign tmp_pp_grp_2_1 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_2_3 = ({1'd0,tmp_pp_grp_2_4} <<< 1'd1);
  assign tmp_pp_grp_2_2 = tmp_pp_grp_2_3[49:0];
  assign tmp_pp_grp_2_4 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_2_5 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_2_6 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_3 = ({1'd0,tmp_pp_grp_3_1} <<< 1'd1);
  assign tmp_pp_grp_3_1 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_3_3 = ({1'd0,tmp_pp_grp_3_4} <<< 1'd1);
  assign tmp_pp_grp_3_2 = tmp_pp_grp_3_3[49:0];
  assign tmp_pp_grp_3_4 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_3_5 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_3_6 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_4 = ({1'd0,tmp_pp_grp_4_1} <<< 1'd1);
  assign tmp_pp_grp_4_1 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_4_3 = ({1'd0,tmp_pp_grp_4_4} <<< 1'd1);
  assign tmp_pp_grp_4_2 = tmp_pp_grp_4_3[49:0];
  assign tmp_pp_grp_4_4 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_4_5 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_4_6 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_5 = ({1'd0,tmp_pp_grp_5_1} <<< 1'd1);
  assign tmp_pp_grp_5_1 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_5_3 = ({1'd0,tmp_pp_grp_5_4} <<< 1'd1);
  assign tmp_pp_grp_5_2 = tmp_pp_grp_5_3[49:0];
  assign tmp_pp_grp_5_4 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_5_5 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_5_6 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_6 = ({1'd0,tmp_pp_grp_6_1} <<< 1'd1);
  assign tmp_pp_grp_6_1 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_6_3 = ({1'd0,tmp_pp_grp_6_4} <<< 1'd1);
  assign tmp_pp_grp_6_2 = tmp_pp_grp_6_3[49:0];
  assign tmp_pp_grp_6_4 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_6_5 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_6_6 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_7 = ({1'd0,tmp_pp_grp_7_1} <<< 1'd1);
  assign tmp_pp_grp_7_1 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_7_3 = ({1'd0,tmp_pp_grp_7_4} <<< 1'd1);
  assign tmp_pp_grp_7_2 = tmp_pp_grp_7_3[49:0];
  assign tmp_pp_grp_7_4 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_7_5 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_7_6 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_8 = ({1'd0,tmp_pp_grp_8_1} <<< 1'd1);
  assign tmp_pp_grp_8_1 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_8_3 = ({1'd0,tmp_pp_grp_8_4} <<< 1'd1);
  assign tmp_pp_grp_8_2 = tmp_pp_grp_8_3[49:0];
  assign tmp_pp_grp_8_4 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_8_5 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_8_6 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_9 = ({1'd0,tmp_pp_grp_9_1} <<< 1'd1);
  assign tmp_pp_grp_9_1 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_9_3 = ({1'd0,tmp_pp_grp_9_4} <<< 1'd1);
  assign tmp_pp_grp_9_2 = tmp_pp_grp_9_3[49:0];
  assign tmp_pp_grp_9_4 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_9_5 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_9_6 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_10 = ({1'd0,tmp_pp_grp_10_1} <<< 1'd1);
  assign tmp_pp_grp_10_1 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_10_3 = ({1'd0,tmp_pp_grp_10_4} <<< 1'd1);
  assign tmp_pp_grp_10_2 = tmp_pp_grp_10_3[49:0];
  assign tmp_pp_grp_10_4 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_10_5 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_10_6 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_11 = ({1'd0,tmp_pp_grp_11_1} <<< 1'd1);
  assign tmp_pp_grp_11_1 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_11_3 = ({1'd0,tmp_pp_grp_11_4} <<< 1'd1);
  assign tmp_pp_grp_11_2 = tmp_pp_grp_11_3[49:0];
  assign tmp_pp_grp_11_4 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_11_5 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_11_6 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_12 = ({1'd0,tmp_pp_grp_12_1} <<< 1'd1);
  assign tmp_pp_grp_12_1 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_12_3 = ({1'd0,tmp_pp_grp_12_4} <<< 1'd1);
  assign tmp_pp_grp_12_2 = tmp_pp_grp_12_3[49:0];
  assign tmp_pp_grp_12_4 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_12_5 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_grp_12_6 = {{24{b_ext[25]}}, b_ext};
  assign tmp_pp_shifted_1 = ({2'd0,pp_grp_1} <<< 2'd2);
  assign tmp_pp_shifted_2 = ({4'd0,pp_grp_2} <<< 3'd4);
  assign tmp_pp_shifted_3 = ({6'd0,pp_grp_3} <<< 3'd6);
  assign tmp_pp_shifted_4 = ({8'd0,pp_grp_4} <<< 4'd8);
  assign tmp_pp_shifted_5 = ({10'd0,pp_grp_5} <<< 4'd10);
  assign tmp_pp_shifted_6 = ({12'd0,pp_grp_6} <<< 4'd12);
  assign tmp_pp_shifted_7 = ({14'd0,pp_grp_7} <<< 4'd14);
  assign tmp_pp_shifted_8 = ({16'd0,pp_grp_8} <<< 5'd16);
  assign tmp_pp_shifted_9 = ({18'd0,pp_grp_9} <<< 5'd18);
  assign tmp_pp_shifted_10 = ({20'd0,pp_grp_10} <<< 5'd20);
  assign tmp_pp_shifted_11 = ({22'd0,pp_grp_11} <<< 5'd22);
  assign tmp_pp_shifted_12 = ({24'd0,pp_grp_12} <<< 5'd24);
  assign tmp_pp_sum = ($signed(tmp_pp_sum_1) + $signed(tmp_pp_sum_8));
  assign tmp_pp_sum_1 = ($signed(tmp_pp_sum_2) + $signed(tmp_pp_sum_5));
  assign tmp_pp_sum_2 = ($signed(tmp_pp_sum_3) + $signed(tmp_pp_sum_4));
  assign tmp_pp_sum_3 = ($signed(pp_shifted_0) + $signed(pp_shifted_1));
  assign tmp_pp_sum_4 = ($signed(pp_shifted_2) + $signed(pp_shifted_3));
  assign tmp_pp_sum_5 = ($signed(tmp_pp_sum_6) + $signed(tmp_pp_sum_7));
  assign tmp_pp_sum_6 = ($signed(pp_shifted_4) + $signed(pp_shifted_5));
  assign tmp_pp_sum_7 = ($signed(pp_shifted_6) + $signed(pp_shifted_7));
  assign tmp_pp_sum_8 = ($signed(tmp_pp_sum_9) + $signed(pp_shifted_12));
  assign tmp_pp_sum_9 = ($signed(tmp_pp_sum_10) + $signed(tmp_pp_sum_11));
  assign tmp_pp_sum_10 = ($signed(pp_shifted_8) + $signed(pp_shifted_9));
  assign tmp_pp_sum_11 = ($signed(pp_shifted_10) + $signed(pp_shifted_11));
  assign tmp_io_z = pp_sum[47:0];
  wallace_tree wallace_adder (
    .io_din_vec_0  (pp_bit_0[49:0]            ), //i
    .io_din_vec_1  (pp_bit_1[49:0]            ), //i
    .io_din_vec_2  (pp_bit_2[49:0]            ), //i
    .io_din_vec_3  (pp_bit_3[49:0]            ), //i
    .io_din_vec_4  (pp_bit_4[49:0]            ), //i
    .io_din_vec_5  (pp_bit_5[49:0]            ), //i
    .io_din_vec_6  (pp_bit_6[49:0]            ), //i
    .io_din_vec_7  (pp_bit_7[49:0]            ), //i
    .io_din_vec_8  (pp_bit_8[49:0]            ), //i
    .io_din_vec_9  (pp_bit_9[49:0]            ), //i
    .io_din_vec_10 (pp_bit_10[49:0]           ), //i
    .io_din_vec_11 (pp_bit_11[49:0]           ), //i
    .io_din_vec_12 (pp_bit_12[49:0]           ), //i
    .io_sum        (wallace_adder_io_sum[49:0])  //o
  );
  assign a_ts = (io_tc ? {io_a[23],io_a} : {1'b0,io_a});
  assign b_ts = (io_tc ? {io_b[23],io_b} : {1'b0,io_b});
  always @(*) begin
    if(io_tc) begin
      b_ext = {{1{tmp_b_ext[24]}}, tmp_b_ext};
    end else begin
      b_ext = tmp_b_ext_1;
    end
  end

  always @(*) begin
    if(io_tc) begin
      a_ext = {a_ts[24],{tmp_a_ext,1'b0}};
    end else begin
      a_ext = {1'b0,{a_ts,1'b0}};
    end
  end

  assign dec_grp_0 = {{a_ext[2],a_ext[1]},a_ext[0]};
  always @(*) begin
    case(dec_grp_0)
      3'b000 : begin
        pp_grp_0 = 50'h0000000000000;
      end
      3'b001 : begin
        pp_grp_0 = {{24{b_ext[25]}}, b_ext};
      end
      3'b010 : begin
        pp_grp_0 = {{24{b_ext[25]}}, b_ext};
      end
      3'b011 : begin
        pp_grp_0 = tmp_pp_grp_0[49:0];
      end
      3'b100 : begin
        pp_grp_0 = (- tmp_pp_grp_0_2);
      end
      3'b101 : begin
        pp_grp_0 = (- tmp_pp_grp_0_5);
      end
      3'b110 : begin
        pp_grp_0 = (- tmp_pp_grp_0_6);
      end
      default : begin
        pp_grp_0 = 50'h0000000000000;
      end
    endcase
  end

  assign dec_grp_1 = {{a_ext[4],a_ext[3]},a_ext[2]};
  always @(*) begin
    case(dec_grp_1)
      3'b000 : begin
        pp_grp_1 = 50'h0000000000000;
      end
      3'b001 : begin
        pp_grp_1 = {{24{b_ext[25]}}, b_ext};
      end
      3'b010 : begin
        pp_grp_1 = {{24{b_ext[25]}}, b_ext};
      end
      3'b011 : begin
        pp_grp_1 = tmp_pp_grp_1[49:0];
      end
      3'b100 : begin
        pp_grp_1 = (- tmp_pp_grp_1_2);
      end
      3'b101 : begin
        pp_grp_1 = (- tmp_pp_grp_1_5);
      end
      3'b110 : begin
        pp_grp_1 = (- tmp_pp_grp_1_6);
      end
      default : begin
        pp_grp_1 = 50'h0000000000000;
      end
    endcase
  end

  assign dec_grp_2 = {{a_ext[6],a_ext[5]},a_ext[4]};
  always @(*) begin
    case(dec_grp_2)
      3'b000 : begin
        pp_grp_2 = 50'h0000000000000;
      end
      3'b001 : begin
        pp_grp_2 = {{24{b_ext[25]}}, b_ext};
      end
      3'b010 : begin
        pp_grp_2 = {{24{b_ext[25]}}, b_ext};
      end
      3'b011 : begin
        pp_grp_2 = tmp_pp_grp_2[49:0];
      end
      3'b100 : begin
        pp_grp_2 = (- tmp_pp_grp_2_2);
      end
      3'b101 : begin
        pp_grp_2 = (- tmp_pp_grp_2_5);
      end
      3'b110 : begin
        pp_grp_2 = (- tmp_pp_grp_2_6);
      end
      default : begin
        pp_grp_2 = 50'h0000000000000;
      end
    endcase
  end

  assign dec_grp_3 = {{a_ext[8],a_ext[7]},a_ext[6]};
  always @(*) begin
    case(dec_grp_3)
      3'b000 : begin
        pp_grp_3 = 50'h0000000000000;
      end
      3'b001 : begin
        pp_grp_3 = {{24{b_ext[25]}}, b_ext};
      end
      3'b010 : begin
        pp_grp_3 = {{24{b_ext[25]}}, b_ext};
      end
      3'b011 : begin
        pp_grp_3 = tmp_pp_grp_3[49:0];
      end
      3'b100 : begin
        pp_grp_3 = (- tmp_pp_grp_3_2);
      end
      3'b101 : begin
        pp_grp_3 = (- tmp_pp_grp_3_5);
      end
      3'b110 : begin
        pp_grp_3 = (- tmp_pp_grp_3_6);
      end
      default : begin
        pp_grp_3 = 50'h0000000000000;
      end
    endcase
  end

  assign dec_grp_4 = {{a_ext[10],a_ext[9]},a_ext[8]};
  always @(*) begin
    case(dec_grp_4)
      3'b000 : begin
        pp_grp_4 = 50'h0000000000000;
      end
      3'b001 : begin
        pp_grp_4 = {{24{b_ext[25]}}, b_ext};
      end
      3'b010 : begin
        pp_grp_4 = {{24{b_ext[25]}}, b_ext};
      end
      3'b011 : begin
        pp_grp_4 = tmp_pp_grp_4[49:0];
      end
      3'b100 : begin
        pp_grp_4 = (- tmp_pp_grp_4_2);
      end
      3'b101 : begin
        pp_grp_4 = (- tmp_pp_grp_4_5);
      end
      3'b110 : begin
        pp_grp_4 = (- tmp_pp_grp_4_6);
      end
      default : begin
        pp_grp_4 = 50'h0000000000000;
      end
    endcase
  end

  assign dec_grp_5 = {{a_ext[12],a_ext[11]},a_ext[10]};
  always @(*) begin
    case(dec_grp_5)
      3'b000 : begin
        pp_grp_5 = 50'h0000000000000;
      end
      3'b001 : begin
        pp_grp_5 = {{24{b_ext[25]}}, b_ext};
      end
      3'b010 : begin
        pp_grp_5 = {{24{b_ext[25]}}, b_ext};
      end
      3'b011 : begin
        pp_grp_5 = tmp_pp_grp_5[49:0];
      end
      3'b100 : begin
        pp_grp_5 = (- tmp_pp_grp_5_2);
      end
      3'b101 : begin
        pp_grp_5 = (- tmp_pp_grp_5_5);
      end
      3'b110 : begin
        pp_grp_5 = (- tmp_pp_grp_5_6);
      end
      default : begin
        pp_grp_5 = 50'h0000000000000;
      end
    endcase
  end

  assign dec_grp_6 = {{a_ext[14],a_ext[13]},a_ext[12]};
  always @(*) begin
    case(dec_grp_6)
      3'b000 : begin
        pp_grp_6 = 50'h0000000000000;
      end
      3'b001 : begin
        pp_grp_6 = {{24{b_ext[25]}}, b_ext};
      end
      3'b010 : begin
        pp_grp_6 = {{24{b_ext[25]}}, b_ext};
      end
      3'b011 : begin
        pp_grp_6 = tmp_pp_grp_6[49:0];
      end
      3'b100 : begin
        pp_grp_6 = (- tmp_pp_grp_6_2);
      end
      3'b101 : begin
        pp_grp_6 = (- tmp_pp_grp_6_5);
      end
      3'b110 : begin
        pp_grp_6 = (- tmp_pp_grp_6_6);
      end
      default : begin
        pp_grp_6 = 50'h0000000000000;
      end
    endcase
  end

  assign dec_grp_7 = {{a_ext[16],a_ext[15]},a_ext[14]};
  always @(*) begin
    case(dec_grp_7)
      3'b000 : begin
        pp_grp_7 = 50'h0000000000000;
      end
      3'b001 : begin
        pp_grp_7 = {{24{b_ext[25]}}, b_ext};
      end
      3'b010 : begin
        pp_grp_7 = {{24{b_ext[25]}}, b_ext};
      end
      3'b011 : begin
        pp_grp_7 = tmp_pp_grp_7[49:0];
      end
      3'b100 : begin
        pp_grp_7 = (- tmp_pp_grp_7_2);
      end
      3'b101 : begin
        pp_grp_7 = (- tmp_pp_grp_7_5);
      end
      3'b110 : begin
        pp_grp_7 = (- tmp_pp_grp_7_6);
      end
      default : begin
        pp_grp_7 = 50'h0000000000000;
      end
    endcase
  end

  assign dec_grp_8 = {{a_ext[18],a_ext[17]},a_ext[16]};
  always @(*) begin
    case(dec_grp_8)
      3'b000 : begin
        pp_grp_8 = 50'h0000000000000;
      end
      3'b001 : begin
        pp_grp_8 = {{24{b_ext[25]}}, b_ext};
      end
      3'b010 : begin
        pp_grp_8 = {{24{b_ext[25]}}, b_ext};
      end
      3'b011 : begin
        pp_grp_8 = tmp_pp_grp_8[49:0];
      end
      3'b100 : begin
        pp_grp_8 = (- tmp_pp_grp_8_2);
      end
      3'b101 : begin
        pp_grp_8 = (- tmp_pp_grp_8_5);
      end
      3'b110 : begin
        pp_grp_8 = (- tmp_pp_grp_8_6);
      end
      default : begin
        pp_grp_8 = 50'h0000000000000;
      end
    endcase
  end

  assign dec_grp_9 = {{a_ext[20],a_ext[19]},a_ext[18]};
  always @(*) begin
    case(dec_grp_9)
      3'b000 : begin
        pp_grp_9 = 50'h0000000000000;
      end
      3'b001 : begin
        pp_grp_9 = {{24{b_ext[25]}}, b_ext};
      end
      3'b010 : begin
        pp_grp_9 = {{24{b_ext[25]}}, b_ext};
      end
      3'b011 : begin
        pp_grp_9 = tmp_pp_grp_9[49:0];
      end
      3'b100 : begin
        pp_grp_9 = (- tmp_pp_grp_9_2);
      end
      3'b101 : begin
        pp_grp_9 = (- tmp_pp_grp_9_5);
      end
      3'b110 : begin
        pp_grp_9 = (- tmp_pp_grp_9_6);
      end
      default : begin
        pp_grp_9 = 50'h0000000000000;
      end
    endcase
  end

  assign dec_grp_10 = {{a_ext[22],a_ext[21]},a_ext[20]};
  always @(*) begin
    case(dec_grp_10)
      3'b000 : begin
        pp_grp_10 = 50'h0000000000000;
      end
      3'b001 : begin
        pp_grp_10 = {{24{b_ext[25]}}, b_ext};
      end
      3'b010 : begin
        pp_grp_10 = {{24{b_ext[25]}}, b_ext};
      end
      3'b011 : begin
        pp_grp_10 = tmp_pp_grp_10[49:0];
      end
      3'b100 : begin
        pp_grp_10 = (- tmp_pp_grp_10_2);
      end
      3'b101 : begin
        pp_grp_10 = (- tmp_pp_grp_10_5);
      end
      3'b110 : begin
        pp_grp_10 = (- tmp_pp_grp_10_6);
      end
      default : begin
        pp_grp_10 = 50'h0000000000000;
      end
    endcase
  end

  assign dec_grp_11 = {{a_ext[24],a_ext[23]},a_ext[22]};
  always @(*) begin
    case(dec_grp_11)
      3'b000 : begin
        pp_grp_11 = 50'h0000000000000;
      end
      3'b001 : begin
        pp_grp_11 = {{24{b_ext[25]}}, b_ext};
      end
      3'b010 : begin
        pp_grp_11 = {{24{b_ext[25]}}, b_ext};
      end
      3'b011 : begin
        pp_grp_11 = tmp_pp_grp_11[49:0];
      end
      3'b100 : begin
        pp_grp_11 = (- tmp_pp_grp_11_2);
      end
      3'b101 : begin
        pp_grp_11 = (- tmp_pp_grp_11_5);
      end
      3'b110 : begin
        pp_grp_11 = (- tmp_pp_grp_11_6);
      end
      default : begin
        pp_grp_11 = 50'h0000000000000;
      end
    endcase
  end

  assign dec_grp_12 = {{a_ext[26],a_ext[25]},a_ext[24]};
  always @(*) begin
    case(dec_grp_12)
      3'b000 : begin
        pp_grp_12 = 50'h0000000000000;
      end
      3'b001 : begin
        pp_grp_12 = {{24{b_ext[25]}}, b_ext};
      end
      3'b010 : begin
        pp_grp_12 = {{24{b_ext[25]}}, b_ext};
      end
      3'b011 : begin
        pp_grp_12 = tmp_pp_grp_12[49:0];
      end
      3'b100 : begin
        pp_grp_12 = (- tmp_pp_grp_12_2);
      end
      3'b101 : begin
        pp_grp_12 = (- tmp_pp_grp_12_5);
      end
      3'b110 : begin
        pp_grp_12 = (- tmp_pp_grp_12_6);
      end
      default : begin
        pp_grp_12 = 50'h0000000000000;
      end
    endcase
  end

  assign pp_shifted_0 = pp_grp_0;
  assign pp_shifted_1 = tmp_pp_shifted_1[49:0];
  assign pp_shifted_2 = tmp_pp_shifted_2[49:0];
  assign pp_shifted_3 = tmp_pp_shifted_3[49:0];
  assign pp_shifted_4 = tmp_pp_shifted_4[49:0];
  assign pp_shifted_5 = tmp_pp_shifted_5[49:0];
  assign pp_shifted_6 = tmp_pp_shifted_6[49:0];
  assign pp_shifted_7 = tmp_pp_shifted_7[49:0];
  assign pp_shifted_8 = tmp_pp_shifted_8[49:0];
  assign pp_shifted_9 = tmp_pp_shifted_9[49:0];
  assign pp_shifted_10 = tmp_pp_shifted_10[49:0];
  assign pp_shifted_11 = tmp_pp_shifted_11[49:0];
  assign pp_shifted_12 = tmp_pp_shifted_12[49:0];
  assign pp_sum = tmp_pp_sum;
  assign pp_bit_0 = pp_shifted_0;
  assign pp_bit_1 = pp_shifted_1;
  assign pp_bit_2 = pp_shifted_2;
  assign pp_bit_3 = pp_shifted_3;
  assign pp_bit_4 = pp_shifted_4;
  assign pp_bit_5 = pp_shifted_5;
  assign pp_bit_6 = pp_shifted_6;
  assign pp_bit_7 = pp_shifted_7;
  assign pp_bit_8 = pp_shifted_8;
  assign pp_bit_9 = pp_shifted_9;
  assign pp_bit_10 = pp_shifted_10;
  assign pp_bit_11 = pp_shifted_11;
  assign pp_bit_12 = pp_shifted_12;
  assign pp_sum_error = (wallace_adder_io_sum != pp_sum);
  assign io_z = tmp_io_z;

endmodule
