// Generator : SpinalHDL v1.9.0    git head : 7d30dbacbd3aa1be42fb2a3d4da5675703aae2ae
// Component : csa_3t2
// Git hash  : c982d0aac03e1ed897d6c33309713a5773bade24

`timescale 1ns/1ps 
module csa_3t2 (
  input      [49:0]   io_a,
  input      [49:0]   io_b,
  input      [49:0]   io_c,
  output     [49:0]   io_sum,
  output     [49:0]   io_carry
);

  wire       [50:0]   tmp_io_carry;

  assign tmp_io_carry = ({1'd0,(((io_a & io_b) | (io_a & io_c)) | (io_b & io_c))} <<< 1'd1);
  assign io_sum = ((io_a ^ io_b) ^ io_c);
  assign io_carry = tmp_io_carry[49:0];

endmodule
