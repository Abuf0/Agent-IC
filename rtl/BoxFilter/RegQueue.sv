// Generator : SpinalHDL v1.9.0    git head : 7d30dbacbd3aa1be42fb2a3d4da5675703aae2ae
// Component : RegQueue
// Git hash  : e71210596241f9a8ee75efce647f5095a787e749

`timescale 1ns/1ps 
module RegQueue (
  input      [4:0]    len,
  input               flush,
  input               push_valid,
  output              push_ready,
  input      [36:0]   push_payload,
  output              pop_valid,
  input               pop_ready,
  output     [36:0]   pop_payload,
  input               clk,
  input               resetn
);

  reg        [36:0]   tmp_pop_payload;
  wire       [4:0]    tmp_pop_payload_1;
  reg        [36:0]   reg_array_0;
  reg        [36:0]   reg_array_1;
  reg        [36:0]   reg_array_2;
  reg        [36:0]   reg_array_3;
  reg        [36:0]   reg_array_4;
  reg        [36:0]   reg_array_5;
  reg        [36:0]   reg_array_6;
  reg        [36:0]   reg_array_7;
  reg        [36:0]   reg_array_8;
  reg        [36:0]   reg_array_9;
  reg        [36:0]   reg_array_10;
  reg        [36:0]   reg_array_11;
  reg        [36:0]   reg_array_12;
  reg        [36:0]   reg_array_13;
  reg        [36:0]   reg_array_14;
  reg        [36:0]   reg_array_15;
  reg        [36:0]   reg_array_16;
  reg        [36:0]   reg_array_17;
  reg        [36:0]   reg_array_18;

  assign tmp_pop_payload_1 = (len - 5'h01);
  always @(*) begin
    case(tmp_pop_payload_1)
      5'b00000 : tmp_pop_payload = reg_array_0;
      5'b00001 : tmp_pop_payload = reg_array_1;
      5'b00010 : tmp_pop_payload = reg_array_2;
      5'b00011 : tmp_pop_payload = reg_array_3;
      5'b00100 : tmp_pop_payload = reg_array_4;
      5'b00101 : tmp_pop_payload = reg_array_5;
      5'b00110 : tmp_pop_payload = reg_array_6;
      5'b00111 : tmp_pop_payload = reg_array_7;
      5'b01000 : tmp_pop_payload = reg_array_8;
      5'b01001 : tmp_pop_payload = reg_array_9;
      5'b01010 : tmp_pop_payload = reg_array_10;
      5'b01011 : tmp_pop_payload = reg_array_11;
      5'b01100 : tmp_pop_payload = reg_array_12;
      5'b01101 : tmp_pop_payload = reg_array_13;
      5'b01110 : tmp_pop_payload = reg_array_14;
      5'b01111 : tmp_pop_payload = reg_array_15;
      5'b10000 : tmp_pop_payload = reg_array_16;
      5'b10001 : tmp_pop_payload = reg_array_17;
      default : tmp_pop_payload = reg_array_18;
    endcase
  end

  assign pop_valid = pop_ready;
  assign pop_payload = tmp_pop_payload;
  always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
      reg_array_0 <= 37'h0000000000;
      reg_array_1 <= 37'h0000000000;
      reg_array_2 <= 37'h0000000000;
      reg_array_3 <= 37'h0000000000;
      reg_array_4 <= 37'h0000000000;
      reg_array_5 <= 37'h0000000000;
      reg_array_6 <= 37'h0000000000;
      reg_array_7 <= 37'h0000000000;
      reg_array_8 <= 37'h0000000000;
      reg_array_9 <= 37'h0000000000;
      reg_array_10 <= 37'h0000000000;
      reg_array_11 <= 37'h0000000000;
      reg_array_12 <= 37'h0000000000;
      reg_array_13 <= 37'h0000000000;
      reg_array_14 <= 37'h0000000000;
      reg_array_15 <= 37'h0000000000;
      reg_array_16 <= 37'h0000000000;
      reg_array_17 <= 37'h0000000000;
      reg_array_18 <= 37'h0000000000;
    end else begin
      if(flush) begin
        reg_array_0 <= 37'h0000000000;
      end else begin
        if(push_valid) begin
          reg_array_0 <= push_payload;
        end
      end
      if(flush) begin
        reg_array_1 <= 37'h0000000000;
      end else begin
        if(push_valid) begin
          reg_array_1 <= reg_array_0;
        end
      end
      if(flush) begin
        reg_array_2 <= 37'h0000000000;
      end else begin
        if(push_valid) begin
          reg_array_2 <= reg_array_1;
        end
      end
      if(flush) begin
        reg_array_3 <= 37'h0000000000;
      end else begin
        if(push_valid) begin
          reg_array_3 <= reg_array_2;
        end
      end
      if(flush) begin
        reg_array_4 <= 37'h0000000000;
      end else begin
        if(push_valid) begin
          reg_array_4 <= reg_array_3;
        end
      end
      if(flush) begin
        reg_array_5 <= 37'h0000000000;
      end else begin
        if(push_valid) begin
          reg_array_5 <= reg_array_4;
        end
      end
      if(flush) begin
        reg_array_6 <= 37'h0000000000;
      end else begin
        if(push_valid) begin
          reg_array_6 <= reg_array_5;
        end
      end
      if(flush) begin
        reg_array_7 <= 37'h0000000000;
      end else begin
        if(push_valid) begin
          reg_array_7 <= reg_array_6;
        end
      end
      if(flush) begin
        reg_array_8 <= 37'h0000000000;
      end else begin
        if(push_valid) begin
          reg_array_8 <= reg_array_7;
        end
      end
      if(flush) begin
        reg_array_9 <= 37'h0000000000;
      end else begin
        if(push_valid) begin
          reg_array_9 <= reg_array_8;
        end
      end
      if(flush) begin
        reg_array_10 <= 37'h0000000000;
      end else begin
        if(push_valid) begin
          reg_array_10 <= reg_array_9;
        end
      end
      if(flush) begin
        reg_array_11 <= 37'h0000000000;
      end else begin
        if(push_valid) begin
          reg_array_11 <= reg_array_10;
        end
      end
      if(flush) begin
        reg_array_12 <= 37'h0000000000;
      end else begin
        if(push_valid) begin
          reg_array_12 <= reg_array_11;
        end
      end
      if(flush) begin
        reg_array_13 <= 37'h0000000000;
      end else begin
        if(push_valid) begin
          reg_array_13 <= reg_array_12;
        end
      end
      if(flush) begin
        reg_array_14 <= 37'h0000000000;
      end else begin
        if(push_valid) begin
          reg_array_14 <= reg_array_13;
        end
      end
      if(flush) begin
        reg_array_15 <= 37'h0000000000;
      end else begin
        if(push_valid) begin
          reg_array_15 <= reg_array_14;
        end
      end
      if(flush) begin
        reg_array_16 <= 37'h0000000000;
      end else begin
        if(push_valid) begin
          reg_array_16 <= reg_array_15;
        end
      end
      if(flush) begin
        reg_array_17 <= 37'h0000000000;
      end else begin
        if(push_valid) begin
          reg_array_17 <= reg_array_16;
        end
      end
      if(flush) begin
        reg_array_18 <= 37'h0000000000;
      end else begin
        if(push_valid) begin
          reg_array_18 <= reg_array_17;
        end
      end
    end
  end


endmodule
