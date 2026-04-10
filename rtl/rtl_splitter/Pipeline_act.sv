// Generator : SpinalHDL v1.9.0    git head : 7d30dbacbd3aa1be42fb2a3d4da5675703aae2ae
// Component : Pipeline_act
// Git hash  : e71210596241f9a8ee75efce647f5095a787e749

`timescale 1ns/1ps 
module Pipeline_act (
  input      [32:0]   io_i,
  input               io_iv,
  output     [32:0]   io_o,
  output              io_ov,
  output              io_active,
  input               clk,
  input               resetn
);

  reg        [32:0]   regs_0;
  reg        [32:0]   regs_1;
  reg        [32:0]   regs_2;
  reg        [32:0]   regs_3;
  reg                 regs_v_0;
  reg                 regs_v_1;
  reg                 regs_v_2;
  reg                 regs_v_3;

  assign io_o = regs_3;
  assign io_ov = regs_v_3;
  assign io_active = (|{regs_v_3,{regs_v_2,{regs_v_1,regs_v_0}}});
  always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
      regs_0 <= 33'h000000000;
      regs_1 <= 33'h000000000;
      regs_2 <= 33'h000000000;
      regs_3 <= 33'h000000000;
      regs_v_0 <= 1'b0;
      regs_v_1 <= 1'b0;
      regs_v_2 <= 1'b0;
      regs_v_3 <= 1'b0;
    end else begin
      regs_0 <= io_i;
      regs_v_0 <= io_iv;
      regs_1 <= regs_0;
      regs_v_1 <= regs_v_0;
      regs_2 <= regs_1;
      regs_v_2 <= regs_v_1;
      regs_3 <= regs_2;
      regs_v_3 <= regs_v_2;
    end
  end


endmodule
