// Generator : SpinalHDL v1.9.0    git head : 7d30dbacbd3aa1be42fb2a3d4da5675703aae2ae
// Component : wallace_tree
// Git hash  : c982d0aac03e1ed897d6c33309713a5773bade24

`timescale 1ns/1ps 
module wallace_tree (
  input      [49:0]   io_din_vec_0,
  input      [49:0]   io_din_vec_1,
  input      [49:0]   io_din_vec_2,
  input      [49:0]   io_din_vec_3,
  input      [49:0]   io_din_vec_4,
  input      [49:0]   io_din_vec_5,
  input      [49:0]   io_din_vec_6,
  input      [49:0]   io_din_vec_7,
  input      [49:0]   io_din_vec_8,
  input      [49:0]   io_din_vec_9,
  input      [49:0]   io_din_vec_10,
  input      [49:0]   io_din_vec_11,
  input      [49:0]   io_din_vec_12,
  output     [49:0]   io_sum
);

  wire       [49:0]   csa0_4_io_a;
  wire       [49:0]   csa0_4_io_b;
  wire       [49:0]   csa0_4_io_c;
  wire       [49:0]   csa1_3_io_a;
  wire       [49:0]   csa1_3_io_b;
  wire       [49:0]   csa1_3_io_c;
  wire       [49:0]   csa2_2_io_a;
  wire       [49:0]   csa2_2_io_b;
  wire       [49:0]   csa2_2_io_c;
  wire       [49:0]   csa3_1_io_a;
  wire       [49:0]   csa3_1_io_b;
  wire       [49:0]   csa3_1_io_c;
  wire       [49:0]   cla_adder_io_a;
  wire       [49:0]   cla_adder_io_b;
  wire       [49:0]   csa0_0_io_sum;
  wire       [49:0]   csa0_0_io_carry;
  wire       [49:0]   csa0_1_io_sum;
  wire       [49:0]   csa0_1_io_carry;
  wire       [49:0]   csa0_2_io_sum;
  wire       [49:0]   csa0_2_io_carry;
  wire       [49:0]   csa0_3_io_sum;
  wire       [49:0]   csa0_3_io_carry;
  wire       [49:0]   csa0_4_io_sum;
  wire       [49:0]   csa0_4_io_carry;
  wire       [49:0]   csa1_0_io_sum;
  wire       [49:0]   csa1_0_io_carry;
  wire       [49:0]   csa1_1_io_sum;
  wire       [49:0]   csa1_1_io_carry;
  wire       [49:0]   csa1_2_io_sum;
  wire       [49:0]   csa1_2_io_carry;
  wire       [49:0]   csa1_3_io_sum;
  wire       [49:0]   csa1_3_io_carry;
  wire       [49:0]   csa2_0_io_sum;
  wire       [49:0]   csa2_0_io_carry;
  wire       [49:0]   csa2_1_io_sum;
  wire       [49:0]   csa2_1_io_carry;
  wire       [49:0]   csa2_2_io_sum;
  wire       [49:0]   csa2_2_io_carry;
  wire       [49:0]   csa3_0_io_sum;
  wire       [49:0]   csa3_0_io_carry;
  wire       [49:0]   csa3_1_io_sum;
  wire       [49:0]   csa3_1_io_carry;
  wire       [49:0]   csa4_0_io_sum;
  wire       [49:0]   csa4_0_io_carry;
  wire       [49:0]   cla_adder_io_sum;
  wire                cla_adder_io_cout;
  wire       [49:0]   tmp_io_a;
  wire       [49:0]   tmp_io_b;
  wire       [49:0]   tmp_sum_cla;
  wire       [50:0]   tmp_sum_cla_1;
  wire       [49:0]   sum_cla;

  assign tmp_io_a = csa4_0_io_sum;
  assign tmp_io_b = csa4_0_io_carry;
  assign tmp_sum_cla_1 = {cla_adder_io_cout,cla_adder_io_sum};
  assign tmp_sum_cla = tmp_sum_cla_1[49:0];
  csa_3t2 csa0_0 (
    .io_a     (io_din_vec_0[49:0]   ), //i
    .io_b     (io_din_vec_1[49:0]   ), //i
    .io_c     (io_din_vec_2[49:0]   ), //i
    .io_sum   (csa0_0_io_sum[49:0]  ), //o
    .io_carry (csa0_0_io_carry[49:0])  //o
  );
  csa_3t2 csa0_1 (
    .io_a     (io_din_vec_3[49:0]   ), //i
    .io_b     (io_din_vec_4[49:0]   ), //i
    .io_c     (io_din_vec_5[49:0]   ), //i
    .io_sum   (csa0_1_io_sum[49:0]  ), //o
    .io_carry (csa0_1_io_carry[49:0])  //o
  );
  csa_3t2 csa0_2 (
    .io_a     (io_din_vec_6[49:0]   ), //i
    .io_b     (io_din_vec_7[49:0]   ), //i
    .io_c     (io_din_vec_8[49:0]   ), //i
    .io_sum   (csa0_2_io_sum[49:0]  ), //o
    .io_carry (csa0_2_io_carry[49:0])  //o
  );
  csa_3t2 csa0_3 (
    .io_a     (io_din_vec_9[49:0]   ), //i
    .io_b     (io_din_vec_10[49:0]  ), //i
    .io_c     (io_din_vec_11[49:0]  ), //i
    .io_sum   (csa0_3_io_sum[49:0]  ), //o
    .io_carry (csa0_3_io_carry[49:0])  //o
  );
  csa_3t2 csa0_4 (
    .io_a     (csa0_4_io_a[49:0]    ), //i
    .io_b     (csa0_4_io_b[49:0]    ), //i
    .io_c     (csa0_4_io_c[49:0]    ), //i
    .io_sum   (csa0_4_io_sum[49:0]  ), //o
    .io_carry (csa0_4_io_carry[49:0])  //o
  );
  csa_3t2 csa1_0 (
    .io_a     (csa0_0_io_sum[49:0]  ), //i
    .io_b     (csa0_0_io_carry[49:0]), //i
    .io_c     (csa0_1_io_sum[49:0]  ), //i
    .io_sum   (csa1_0_io_sum[49:0]  ), //o
    .io_carry (csa1_0_io_carry[49:0])  //o
  );
  csa_3t2 csa1_1 (
    .io_a     (csa0_1_io_carry[49:0]), //i
    .io_b     (csa0_2_io_sum[49:0]  ), //i
    .io_c     (csa0_2_io_carry[49:0]), //i
    .io_sum   (csa1_1_io_sum[49:0]  ), //o
    .io_carry (csa1_1_io_carry[49:0])  //o
  );
  csa_3t2 csa1_2 (
    .io_a     (csa0_3_io_sum[49:0]  ), //i
    .io_b     (csa0_3_io_carry[49:0]), //i
    .io_c     (io_din_vec_12[49:0]  ), //i
    .io_sum   (csa1_2_io_sum[49:0]  ), //o
    .io_carry (csa1_2_io_carry[49:0])  //o
  );
  csa_3t2 csa1_3 (
    .io_a     (csa1_3_io_a[49:0]    ), //i
    .io_b     (csa1_3_io_b[49:0]    ), //i
    .io_c     (csa1_3_io_c[49:0]    ), //i
    .io_sum   (csa1_3_io_sum[49:0]  ), //o
    .io_carry (csa1_3_io_carry[49:0])  //o
  );
  csa_3t2 csa2_0 (
    .io_a     (csa1_0_io_sum[49:0]  ), //i
    .io_b     (csa1_0_io_carry[49:0]), //i
    .io_c     (csa1_1_io_sum[49:0]  ), //i
    .io_sum   (csa2_0_io_sum[49:0]  ), //o
    .io_carry (csa2_0_io_carry[49:0])  //o
  );
  csa_3t2 csa2_1 (
    .io_a     (csa1_1_io_carry[49:0]), //i
    .io_b     (csa1_2_io_sum[49:0]  ), //i
    .io_c     (csa1_2_io_carry[49:0]), //i
    .io_sum   (csa2_1_io_sum[49:0]  ), //o
    .io_carry (csa2_1_io_carry[49:0])  //o
  );
  csa_3t2 csa2_2 (
    .io_a     (csa2_2_io_a[49:0]    ), //i
    .io_b     (csa2_2_io_b[49:0]    ), //i
    .io_c     (csa2_2_io_c[49:0]    ), //i
    .io_sum   (csa2_2_io_sum[49:0]  ), //o
    .io_carry (csa2_2_io_carry[49:0])  //o
  );
  csa_3t2 csa3_0 (
    .io_a     (csa2_0_io_sum[49:0]  ), //i
    .io_b     (csa2_0_io_carry[49:0]), //i
    .io_c     (csa2_1_io_sum[49:0]  ), //i
    .io_sum   (csa3_0_io_sum[49:0]  ), //o
    .io_carry (csa3_0_io_carry[49:0])  //o
  );
  csa_3t2 csa3_1 (
    .io_a     (csa3_1_io_a[49:0]    ), //i
    .io_b     (csa3_1_io_b[49:0]    ), //i
    .io_c     (csa3_1_io_c[49:0]    ), //i
    .io_sum   (csa3_1_io_sum[49:0]  ), //o
    .io_carry (csa3_1_io_carry[49:0])  //o
  );
  csa_3t2 csa4_0 (
    .io_a     (csa3_0_io_sum[49:0]  ), //i
    .io_b     (csa3_0_io_carry[49:0]), //i
    .io_c     (csa2_1_io_carry[49:0]), //i
    .io_sum   (csa4_0_io_sum[49:0]  ), //o
    .io_carry (csa4_0_io_carry[49:0])  //o
  );
  CLA cla_adder (
    .io_a    (cla_adder_io_a[49:0]  ), //i
    .io_b    (cla_adder_io_b[49:0]  ), //i
    .io_cin  (1'b0                  ), //i
    .io_sum  (cla_adder_io_sum[49:0]), //o
    .io_cout (cla_adder_io_cout     )  //o
  );
  assign cla_adder_io_a = tmp_io_a;
  assign cla_adder_io_b = tmp_io_b;
  assign sum_cla = tmp_sum_cla;
  assign io_sum = sum_cla;

endmodule
