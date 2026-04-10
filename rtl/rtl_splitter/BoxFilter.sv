// Generator : SpinalHDL v1.9.0    git head : 7d30dbacbd3aa1be42fb2a3d4da5675703aae2ae
// Component : BoxFilter
// Git hash  : e71210596241f9a8ee75efce647f5095a787e749

// ============================================================================
// BoxFilter: 方形均值滤波模块
// ============================================================================
// 功能描述:
//   对输入图像进行方形均值滤波，采用两步累加算法：
//   1. 行累加阶段(ROW_SUM): 按行滑动窗口累加，将部分和写入PSUM memory
//   2. 列累加阶段(COL_SUM): 从PSUM memory读回部分和，按列累加得到窗口总和
//   3. 计算均值并裁剪到数据类型的合法范围，写回输出内存
//
// 算法细节:
//   - 窗口尺寸: WinSizeX = 2*rg_rx + 1, WinSizeY = 2*rg_ry + 1
//   - 输出尺寸: outw = width - 2*rg_rx, outh = height - 2*rg_ry
//   - 支持的数据类型: CHAR/UCHAR, SHORT/USHORT, WORD/UWORD (8/16/32位有/无符号)
//   - 使用滑动窗口累加算法减少计算量: O(width*height) 而非 O(width*height*winArea)
//   - 行累加: sum[i][j] = sum[i][j-1] + new_pixel - old_pixel
//   - 列累加: sum[i][j] = sum[i-1][j] + new_row_sum - old_row_sum
//   - 均值: mean = sum / (WinSizeX * WinSizeY)
//   - 裁剪: clip to [minValue, maxValue] based on data type
//
// 状态机:
//   IDLE -> ROW_SUM -> WAIT_1 -> COL_SUM -> WAIT_1 -> DONE
//   行累加完成后等待流水线排空，然后切换到列累加，最后等待裁剪写回完成
//
// 接口说明:
//   psum_mem_if: 与PSUM memory接口，64位宽，用于存储部分和
//   mem_master: 与主内存接口，32位宽，用于读取输入和写入输出
//   rg_*: 配置寄存器，包括输入/输出/psum地址、图像尺寸、窗口半径、数据类型
//   start/done: 启动和完成信号
// ============================================================================


`timescale 1ns/1ps 
module BoxFilter (
  output reg          psum_mem_if_mem_rd,
  output reg          psum_mem_if_mem_wr,
  output reg [15:0]   psum_mem_if_mem_addr,
  output     [63:0]   psum_mem_if_mem_wdata,
  output reg [7:0]    psum_mem_if_mem_wmask,
  input      [63:0]   psum_mem_if_mem_rdata,
  output reg          mem_master_mem_rd,
  output reg          mem_master_mem_wr,
  output reg [16:0]   mem_master_mem_addr,
  output reg [31:0]   mem_master_mem_wdata,
  output reg [3:0]    mem_master_mem_wmask,
  input      [31:0]   mem_master_mem_rdata,
  input               start,
  output reg          done,
  input      [18:0]   rg_input_addr,
  input      [18:0]   rg_output_addr,
  input      [18:0]   rg_psum_addr,
  input      [2:0]    rg_dtype,
  input      [11:0]   rg_width,
  input      [11:0]   rg_height,
  input      [3:0]    rg_rx,
  input      [3:0]    rg_ry,
  input               clk,
  input               resetn
);
  localparam WORD = 3'd0;
  localparam UWORD = 3'd1;
  localparam SHORT = 3'd2;
  localparam USHORT = 3'd3;
  localparam CHAR = 3'd4;
  localparam UCHAR = 3'd5;
  localparam IDLE = 3'd0;
  localparam ROW_SUM = 3'd1;
  localparam COL_SUM = 3'd2;
  localparam WAIT_1 = 3'd3;
  localparam DONE = 3'd4;
  // 状态机状态定义

  wire                line_buffer_flush;
  wire       [32:0]   filter_mean_io_i;
  wire                line_buffer_push_ready;
  wire                line_buffer_pop_valid;
  wire       [36:0]   line_buffer_pop_payload;
  wire       [32:0]   filter_mean_io_o;
  wire                filter_mean_io_ov;
  wire                filter_mean_io_active;
  wire       [4:0]    tmp_WinSizeX;
  wire       [4:0]    tmp_WinSizeY;
  wire       [9:0]    tmp_WinArea;
  wire       [11:0]   tmp_outw;
  wire       [4:0]    tmp_outw_1;
  wire       [11:0]   tmp_outh;
  wire       [4:0]    tmp_outh_1;
  wire       [12:0]   tmp_pix_done;
  wire       [11:0]   tmp_pix_done_1;
  wire       [12:0]   tmp_pix_done_2;
  wire       [11:0]   tmp_pix_done_3;
  wire       [11:0]   tmp_rowsum_done;
  wire       [11:0]   tmp_colsum_done;
  wire       [4:0]    tmp_read_data_bias;
  wire       [12:0]   tmp_filter_sum_vld;
  wire       [4:0]    tmp_filter_sum_vld_1;
  wire       [32:0]   tmp_io_i;
  wire       [63:0]   tmp_io_i_1;
  wire       [36:0]   tmp_line_st_in_payload;
  wire       [36:0]   tmp_line_st_in_payload_1;
  wire       [63:0]   tmp_sum;
  wire       [63:0]   tmp_sum_1;
  wire       [63:0]   tmp_sum_2;
  wire       [63:0]   tmp_sum_3;
  wire       [36:0]   tmp_sum_4;
  wire       [12:0]   tmp_when_BoxFilter_l227;
  wire       [4:0]    tmp_when_BoxFilter_l227_1;
  wire       [36:0]   tmp_sum_5;
  wire       [36:0]   tmp_sum_6;
  wire       [63:0]   tmp_sum_7;
  wire       [63:0]   tmp_sum_8;
  wire       [63:0]   tmp_sum_9;
  wire       [63:0]   tmp_sum_10;
  wire       [36:0]   tmp_sum_11;
  wire       [12:0]   tmp_when_BoxFilter_l235;
  wire       [4:0]    tmp_when_BoxFilter_l235_1;
  wire       [7:0]    tmp_read_data;
  wire       [7:0]    tmp_read_data_1;
  wire       [7:0]    tmp_read_data_2;
  wire       [7:0]    tmp_read_data_3;
  wire       [32:0]   tmp_read_data_4;
  wire       [7:0]    tmp_read_data_5;
  wire       [32:0]   tmp_read_data_6;
  wire       [7:0]    tmp_read_data_7;
  wire       [32:0]   tmp_read_data_8;
  wire       [7:0]    tmp_read_data_9;
  wire       [32:0]   tmp_read_data_10;
  wire       [7:0]    tmp_read_data_11;
  wire       [15:0]   tmp_read_data_12;
  wire       [15:0]   tmp_read_data_13;
  wire       [32:0]   tmp_read_data_14;
  wire       [15:0]   tmp_read_data_15;
  wire       [32:0]   tmp_read_data_16;
  wire       [15:0]   tmp_read_data_17;
  wire       [31:0]   tmp_read_data_18;
  wire       [32:0]   tmp_read_data_19;
  wire       [31:0]   tmp_read_data_20;
  wire       [36:0]   tmp_psum_data;
  wire       [11:0]   tmp_pixel_index;
  wire       [25:0]   tmp_pixel_index_1;
  wire       [12:0]   tmp_when_BoxFilter_l353;
  wire       [11:0]   tmp_when_BoxFilter_l353_1;
  wire       [12:0]   tmp_when_BoxFilter_l355;
  wire       [11:0]   tmp_when_BoxFilter_l355_1;
  wire       [25:0]   tmp_psum_mem_if_mem_addr;
  wire       [25:0]   tmp_psum_mem_if_mem_addr_1;
  wire       [15:0]   tmp_psum_mem_if_mem_addr_2;
  wire       [12:0]   tmp_when_BoxFilter_l383;
  wire       [4:0]    tmp_when_BoxFilter_l383_1;
  wire       [7:0]    tmp_psum_mem_if_mem_wmask;
  wire       [0:0]    tmp_psum_mem_if_mem_wmask_1;
  wire       [63:0]   tmp_psum_mem_if_mem_wdata;
  wire       [63:0]   tmp_when_BoxFilter_l425;
  wire       [63:0]   tmp_when_BoxFilter_l427;
  wire       [12:0]   tmp_clip_index_hit;
  wire       [11:0]   tmp_clip_index_hit_1;
  wire       [25:0]   tmp_clip_index;
  wire       [7:0]    tmp_ClipValueByteShift;
  wire       [7:0]    tmp_ClipValueByteShift_1;
  wire       [15:0]   tmp_ClipValueByteShift_2;
  wire       [15:0]   tmp_ClipValueByteShift_3;
  wire       [7:0]    tmp_ClipValueByteShift_4;
  wire       [23:0]   tmp_ClipValueByteShift_5;
  wire       [23:0]   tmp_ClipValueByteShift_6;
  wire       [7:0]    tmp_ClipValueByteShift_7;
  wire       [31:0]   tmp_ClipValueByteShift_8;
  wire       [7:0]    tmp_ClipValueByteShift_9;
  wire       [15:0]   tmp_ClipValueByteShift_10;
  wire       [15:0]   tmp_ClipValueByteShift_11;
  wire       [31:0]   tmp_ClipValueByteShift_12;
  wire       [15:0]   tmp_ClipValueByteShift_13;
  wire       [31:0]   tmp_ClipValueByteShift_14;
  wire       [26:0]   tmp_mem_master_mem_addr;
  wire       [28:0]   tmp_mem_master_mem_addr_1;
  wire       [28:0]   tmp_mem_master_mem_addr_2;
  wire       [28:0]   tmp_mem_master_mem_addr_3;
  wire       [26:0]   tmp_mem_master_mem_addr_4;
  wire       [28:0]   tmp_mem_master_mem_addr_5;
  wire       [28:0]   tmp_mem_master_mem_addr_6;
  wire       [28:0]   tmp_mem_master_mem_addr_7;
  wire                config_valid;
  wire       [36:0]   psumType;
  wire       [4:0]    WinSizeX;
  wire       [4:0]    WinSizeY;
  wire       [9:0]    WinArea;
  reg        [9:0]    WinArea_result_reg;
  wire       [9:0]    HalfWinArea;
  reg        [1:0]    dtype_shift;
  reg        [2:0]    clip_dtype_num;
  wire       [11:0]   outw;
  wire       [11:0]   outh;
  reg        [2:0]    state;
  reg        [2:0]    state_next;
  reg        [63:0]   minValue;
  reg        [63:0]   maxValue;
  reg        [63:0]   ClipValue;
  reg        [31:0]   ClipValueByteShift;
  reg        [3:0]    ClipDataWriteMask;
  wire       [16:0]   ClipDataWriteAddr;
  wire                state_rowsum;
  wire                state_colsum;
  wire                state_wait;
  reg        [12:0]   pix_cnt;
  wire                pix_done;
  reg        [11:0]   row_cnt;
  reg        [11:0]   col_cnt;
  wire                rowsum_done;
  wire                colsum_done;
  wire                wait_done_pre;
  reg                 wait_done;
  reg                 to_done_flag;
  reg        [25:0]   pixel_index;
  reg        [1:0]    pixel_index_d1_l;
  reg        [1:0]    pixel_index_lsb;
  reg        [12:0]   win_index;
  reg        [63:0]   sum;
  wire                when_BoxFilter_l142;
  reg                 line_st_in_valid;
  wire                line_st_in_ready;
  reg        [36:0]   line_st_in_payload;
  wire                line_st_out_valid;
  reg                 line_st_out_ready;
  wire       [36:0]   line_st_out_payload;
  reg                 mem_master_rd_d1;
  reg        [31:0]   input_read_data_buff;
  reg                 read_data_vld;
  reg                 psum_rd_d1;
  reg                 psum_data_vld;
  reg        [63:0]   psum_read_data_buff;
  reg        [32:0]   read_data;
  wire       [36:0]   psum_data;
  reg        [1:0]    read_data_bias;
  reg                 filter_sum_vld;
  wire       [32:0]   filter_mean_data;
  reg        [4:0]    slide_len;
  wire                when_BoxFilter_l219;
  wire                when_BoxFilter_l225;
  wire                when_BoxFilter_l227;
  wire                when_BoxFilter_l233;
  wire                when_BoxFilter_l235;
  wire                when_BoxFilter_l338;
  wire                when_BoxFilter_l350;
  wire                when_BoxFilter_l353;
  wire                when_BoxFilter_l355;
  wire                when_BoxFilter_l352;
  wire                when_BoxFilter_l383;
  wire                when_BoxFilter_l425;
  wire                when_BoxFilter_l427;
  reg        [25:0]   clip_index;
  reg        [25:0]   clip_index_head;
  reg        [12:0]   clip_index_cnt;
  wire                clip_index_hit;
  reg        [25:0]   clip_index_d1;
  wire       [1:0]    switch_BoxFilter_l456;
  wire       [1:0]    switch_BoxFilter_l476;
  wire                when_BoxFilter_l504;
  `ifndef SYNTHESIS
  reg [47:0] rg_dtype_string;
  reg [55:0] state_string;
  reg [55:0] state_next_string;
  `endif


  assign tmp_WinSizeX = ({1'd0,rg_rx} <<< 1'd1);
  assign tmp_WinSizeY = ({1'd0,rg_ry} <<< 1'd1);
  assign tmp_WinArea = (WinSizeX * WinSizeY);
  assign tmp_outw_1 = ({1'd0,rg_rx} <<< 1'd1);
  assign tmp_outw = {7'd0, tmp_outw_1};
  assign tmp_outh_1 = ({1'd0,rg_ry} <<< 1'd1);
  assign tmp_outh = {7'd0, tmp_outh_1};
  assign tmp_pix_done_1 = (rg_width - 12'h001);
  assign tmp_pix_done = {1'd0, tmp_pix_done_1};
  assign tmp_pix_done_3 = (rg_height - 12'h001);
  assign tmp_pix_done_2 = {1'd0, tmp_pix_done_3};
  assign tmp_rowsum_done = (rg_height - 12'h001);
  assign tmp_colsum_done = (outw - 12'h001);
  assign tmp_read_data_bias = ({3'd0,pixel_index_lsb} <<< dtype_shift);
  assign tmp_filter_sum_vld_1 = (WinSizeY - 5'h01);
  assign tmp_filter_sum_vld = {8'd0, tmp_filter_sum_vld_1};
  assign tmp_io_i_1 = ($signed(sum) / $signed(WinArea_result_reg));
  assign tmp_io_i = tmp_io_i_1[32:0];
  assign tmp_line_st_in_payload = {{4{read_data[32]}}, read_data};
  assign tmp_line_st_in_payload_1 = psum_data;
  assign tmp_sum = {{31{read_data[32]}}, read_data};
  assign tmp_sum_1 = ($signed(sum) + $signed(tmp_sum_2));
  assign tmp_sum_2 = {{31{read_data[32]}}, read_data};
  assign tmp_sum_4 = line_st_out_payload;
  assign tmp_sum_3 = {{27{tmp_sum_4[36]}}, tmp_sum_4};
  assign tmp_when_BoxFilter_l227_1 = (WinSizeX - 5'h01);
  assign tmp_when_BoxFilter_l227 = {8'd0, tmp_when_BoxFilter_l227_1};
  assign tmp_sum_5 = ($signed(psum_data) + $signed(tmp_sum_6));
  assign tmp_sum_6 = {{27{HalfWinArea[9]}}, HalfWinArea};
  assign tmp_sum_7 = {{27{psum_data[36]}}, psum_data};
  assign tmp_sum_8 = ($signed(sum) + $signed(tmp_sum_9));
  assign tmp_sum_9 = {{27{psum_data[36]}}, psum_data};
  assign tmp_sum_11 = line_st_out_payload;
  assign tmp_sum_10 = {{27{tmp_sum_11[36]}}, tmp_sum_11};
  assign tmp_when_BoxFilter_l235_1 = (WinSizeY - 5'h01);
  assign tmp_when_BoxFilter_l235 = {8'd0, tmp_when_BoxFilter_l235_1};
  assign tmp_read_data = input_read_data_buff[7 : 0];
  assign tmp_read_data_1 = input_read_data_buff[15 : 8];
  assign tmp_read_data_2 = input_read_data_buff[23 : 16];
  assign tmp_read_data_3 = input_read_data_buff[31 : 24];
  assign tmp_read_data_5 = input_read_data_buff[7 : 0];
  assign tmp_read_data_4 = {25'd0, tmp_read_data_5};
  assign tmp_read_data_7 = input_read_data_buff[15 : 8];
  assign tmp_read_data_6 = {25'd0, tmp_read_data_7};
  assign tmp_read_data_9 = input_read_data_buff[23 : 16];
  assign tmp_read_data_8 = {25'd0, tmp_read_data_9};
  assign tmp_read_data_11 = input_read_data_buff[31 : 24];
  assign tmp_read_data_10 = {25'd0, tmp_read_data_11};
  assign tmp_read_data_12 = input_read_data_buff[15 : 0];
  assign tmp_read_data_13 = input_read_data_buff[31 : 16];
  assign tmp_read_data_15 = input_read_data_buff[15 : 0];
  assign tmp_read_data_14 = {17'd0, tmp_read_data_15};
  assign tmp_read_data_17 = input_read_data_buff[31 : 16];
  assign tmp_read_data_16 = {17'd0, tmp_read_data_17};
  assign tmp_read_data_18 = input_read_data_buff[31 : 0];
  assign tmp_read_data_20 = input_read_data_buff[31 : 0];
  assign tmp_read_data_19 = {1'd0, tmp_read_data_20};
  assign tmp_psum_data = psum_read_data_buff[36:0];
  assign tmp_pixel_index = (col_cnt + 12'h001);
  assign tmp_pixel_index_1 = {14'd0, outw};
  assign tmp_when_BoxFilter_l353_1 = (rg_width - 12'h001);
  assign tmp_when_BoxFilter_l353 = {1'd0, tmp_when_BoxFilter_l353_1};
  assign tmp_when_BoxFilter_l355_1 = (rg_height - 12'h001);
  assign tmp_when_BoxFilter_l355 = {1'd0, tmp_when_BoxFilter_l355_1};
  assign tmp_psum_mem_if_mem_addr = (tmp_psum_mem_if_mem_addr_1 + pixel_index);
  assign tmp_psum_mem_if_mem_addr_2 = (rg_psum_addr >>> 2'd3);
  assign tmp_psum_mem_if_mem_addr_1 = {10'd0, tmp_psum_mem_if_mem_addr_2};
  assign tmp_when_BoxFilter_l383_1 = (WinSizeX - 5'h01);
  assign tmp_when_BoxFilter_l383 = {8'd0, tmp_when_BoxFilter_l383_1};
  assign tmp_psum_mem_if_mem_wmask_1 = 1'b1;
  assign tmp_psum_mem_if_mem_wmask = {{7{tmp_psum_mem_if_mem_wmask_1[0]}}, tmp_psum_mem_if_mem_wmask_1};
  assign tmp_psum_mem_if_mem_wdata = sum;
  assign tmp_when_BoxFilter_l425 = {{31{filter_mean_data[32]}}, filter_mean_data};
  assign tmp_when_BoxFilter_l427 = {{31{filter_mean_data[32]}}, filter_mean_data};
  assign tmp_clip_index_hit_1 = (outh - 12'h001);
  assign tmp_clip_index_hit = {1'd0, tmp_clip_index_hit_1};
  assign tmp_clip_index = {14'd0, outw};
  assign tmp_ClipValueByteShift = tmp_ClipValueByteShift_1;
  assign tmp_ClipValueByteShift_1 = ClipValue[7 : 0];
  assign tmp_ClipValueByteShift_2 = tmp_ClipValueByteShift_3;
  assign tmp_ClipValueByteShift_3 = ({8'd0,tmp_ClipValueByteShift_4} <<< 4'd8);
  assign tmp_ClipValueByteShift_4 = ClipValue[7 : 0];
  assign tmp_ClipValueByteShift_5 = tmp_ClipValueByteShift_6;
  assign tmp_ClipValueByteShift_6 = ({16'd0,tmp_ClipValueByteShift_7} <<< 5'd16);
  assign tmp_ClipValueByteShift_7 = ClipValue[7 : 0];
  assign tmp_ClipValueByteShift_8 = ({24'd0,tmp_ClipValueByteShift_9} <<< 5'd24);
  assign tmp_ClipValueByteShift_9 = ClipValue[7 : 0];
  assign tmp_ClipValueByteShift_10 = tmp_ClipValueByteShift_11;
  assign tmp_ClipValueByteShift_11 = ClipValue[15 : 0];
  assign tmp_ClipValueByteShift_12 = ({16'd0,tmp_ClipValueByteShift_13} <<< 5'd16);
  assign tmp_ClipValueByteShift_13 = ClipValue[15 : 0];
  assign tmp_ClipValueByteShift_14 = ClipValue[31 : 0];
  assign tmp_mem_master_mem_addr = (tmp_mem_master_mem_addr_1 >>> 2'd2);
  assign tmp_mem_master_mem_addr_1 = (tmp_mem_master_mem_addr_2 + tmp_mem_master_mem_addr_3);
  assign tmp_mem_master_mem_addr_2 = {10'd0, rg_input_addr};
  assign tmp_mem_master_mem_addr_3 = ({3'd0,pixel_index} <<< dtype_shift);
  assign tmp_mem_master_mem_addr_4 = (tmp_mem_master_mem_addr_5 >>> 2'd2);
  assign tmp_mem_master_mem_addr_5 = (tmp_mem_master_mem_addr_6 + tmp_mem_master_mem_addr_7);
  assign tmp_mem_master_mem_addr_6 = {10'd0, rg_output_addr};
  assign tmp_mem_master_mem_addr_7 = ({3'd0,clip_index} <<< dtype_shift);
  RegQueue line_buffer (
    .len          (slide_len[4:0]               ), //i
    .flush        (line_buffer_flush            ), //i
    .push_valid   (line_st_in_valid             ), //i
    .push_ready   (line_buffer_push_ready       ), //o
    .push_payload (line_st_in_payload[36:0]     ), //i
    .pop_valid    (line_buffer_pop_valid        ), //o
    .pop_ready    (line_st_out_ready            ), //i
    .pop_payload  (line_buffer_pop_payload[36:0]), //o
    .clk          (clk                          ), //i
    .resetn       (resetn                       )  //i
  );
  Pipeline_act filter_mean (
    .io_i      (filter_mean_io_i[32:0]), //i
    .io_iv     (filter_sum_vld        ), //i
    .io_o      (filter_mean_io_o[32:0]), //o
    .io_ov     (filter_mean_io_ov     ), //o
    .io_active (filter_mean_io_active ), //o
    .clk       (clk                   ), //i
    .resetn    (resetn                )  //i
  );
  `ifndef SYNTHESIS
  always @(*) begin
    case(rg_dtype)
      WORD : rg_dtype_string = "WORD  ";
      UWORD : rg_dtype_string = "UWORD ";
      SHORT : rg_dtype_string = "SHORT ";
      USHORT : rg_dtype_string = "USHORT";
      CHAR : rg_dtype_string = "CHAR  ";
      UCHAR : rg_dtype_string = "UCHAR ";
      default : rg_dtype_string = "??????";
    endcase
  end
  always @(*) begin
    case(state)
      IDLE : state_string = "IDLE   ";
      ROW_SUM : state_string = "ROW_SUM";
      COL_SUM : state_string = "COL_SUM";
      WAIT_1 : state_string = "WAIT_1 ";
      DONE : state_string = "DONE   ";
      default : state_string = "???????";
    endcase
  end
  always @(*) begin
    case(state_next)
      IDLE : state_next_string = "IDLE   ";
      ROW_SUM : state_next_string = "ROW_SUM";
      COL_SUM : state_next_string = "COL_SUM";
      WAIT_1 : state_next_string = "WAIT_1 ";
      DONE : state_next_string = "DONE   ";
      default : state_next_string = "???????";
    endcase
  end
  `endif

  assign WinSizeX = (tmp_WinSizeX + 5'h01);
  assign WinSizeY = (tmp_WinSizeY + 5'h01);
  assign WinArea = tmp_WinArea;
  assign HalfWinArea = ($signed(WinArea_result_reg) >>> 1);
  assign outw = (rg_width - tmp_outw);
  assign outh = (rg_height - tmp_outh);
  assign config_valid = (rg_width > tmp_outw) && (rg_height > tmp_outh);
  assign state_rowsum = (state == ROW_SUM);
  assign state_colsum = (state == COL_SUM);
  assign state_wait = (state == WAIT_1);
  assign pix_done = ((state_rowsum && (pix_cnt == tmp_pix_done)) || (state_colsum && (pix_cnt == tmp_pix_done_2)));
  assign rowsum_done = ((state_rowsum && (row_cnt == tmp_rowsum_done)) && pix_done);
  assign colsum_done = ((state_colsum && (col_cnt == tmp_colsum_done)) && pix_done);
  always @(*) begin
    state_next = state;
    case(state)
      IDLE : begin
        if(start && config_valid) begin
          state_next = ROW_SUM;
        end
      end
      ROW_SUM : begin
        if(rowsum_done) begin
          state_next = WAIT_1;
        end else begin
          state_next = ROW_SUM;
        end
      end
      COL_SUM : begin
        if(colsum_done) begin
          state_next = WAIT_1;
        end else begin
          state_next = COL_SUM;
        end
      end
      WAIT_1 : begin
        if(wait_done) begin
          if(to_done_flag) begin
            state_next = DONE;
          end else begin
            state_next = COL_SUM;
          end
        end
      end
      default : begin
        state_next = IDLE;
      end
    endcase
  end

  assign when_BoxFilter_l142 = (state_rowsum || state_colsum);
  assign filter_mean_io_i = tmp_io_i;
  assign filter_mean_data = filter_mean_io_o;
  assign wait_done_pre = ((state_wait && (! (((read_data_vld || psum_data_vld) || filter_sum_vld) || filter_mean_io_active))) && (! wait_done));
  always @(*) begin
    line_st_in_valid = 1'b0;
    if(read_data_vld) begin
      line_st_in_valid = 1'b1;
    end else begin
      if(psum_data_vld) begin
        line_st_in_valid = 1'b1;
      end
    end
  end

  always @(*) begin
    line_st_in_payload = 37'h0000000000;
    if(read_data_vld) begin
      line_st_in_payload = tmp_line_st_in_payload;
    end else begin
      if(psum_data_vld) begin
        line_st_in_payload = tmp_line_st_in_payload_1;
      end
    end
  end

  always @(*) begin
    line_st_out_ready = 1'b0;
    if(read_data_vld) begin
      line_st_out_ready = 1'b1;
    end else begin
      if(psum_data_vld) begin
        line_st_out_ready = 1'b1;
      end
    end
  end

  assign line_buffer_flush = (start || wait_done);
  assign line_st_in_ready = line_buffer_push_ready;
  assign line_st_out_valid = line_buffer_pop_valid;
  assign line_st_out_payload = line_buffer_pop_payload;
  assign when_BoxFilter_l219 = (wait_done && (! to_done_flag));
  assign when_BoxFilter_l225 = (win_index == 13'h0000);
  assign when_BoxFilter_l227 = ((win_index <= tmp_when_BoxFilter_l227) && (! to_done_flag));
  assign when_BoxFilter_l233 = (win_index == 13'h0000);
  assign when_BoxFilter_l235 = ((win_index <= tmp_when_BoxFilter_l235) && to_done_flag);
  always @(*) begin
    case(rg_dtype)
      CHAR : begin
        case(read_data_bias)
          2'b00 : begin
            read_data = {{25{tmp_read_data[7]}}, tmp_read_data};
          end
          2'b01 : begin
            read_data = {{25{tmp_read_data_1[7]}}, tmp_read_data_1};
          end
          2'b10 : begin
            read_data = {{25{tmp_read_data_2[7]}}, tmp_read_data_2};
          end
          default : begin
            read_data = {{25{tmp_read_data_3[7]}}, tmp_read_data_3};
          end
        endcase
      end
      UCHAR : begin
        case(read_data_bias)
          2'b00 : begin
            read_data = tmp_read_data_4;
          end
          2'b01 : begin
            read_data = tmp_read_data_6;
          end
          2'b10 : begin
            read_data = tmp_read_data_8;
          end
          default : begin
            read_data = tmp_read_data_10;
          end
        endcase
      end
      SHORT : begin
        case(read_data_bias)
          2'b00 : begin
            read_data = {{17{tmp_read_data_12[15]}}, tmp_read_data_12};
          end
          2'b10 : begin
            read_data = {{17{tmp_read_data_13[15]}}, tmp_read_data_13};
          end
          default : begin
            read_data = 33'h000000000;
          end
        endcase
      end
      USHORT : begin
        case(read_data_bias)
          2'b00 : begin
            read_data = tmp_read_data_14;
          end
          2'b10 : begin
            read_data = tmp_read_data_16;
          end
          default : begin
            read_data = 33'h000000000;
          end
        endcase
      end
      WORD : begin
        read_data = {{1{tmp_read_data_18[31]}}, tmp_read_data_18};
      end
      default : begin
        read_data = tmp_read_data_19;
      end
    endcase
  end

  always @(*) begin
    case(rg_dtype)
      WORD : begin
        dtype_shift = 2'b10;
      end
      UWORD : begin
        dtype_shift = 2'b10;
      end
      SHORT : begin
        dtype_shift = 2'b01;
      end
      USHORT : begin
        dtype_shift = 2'b01;
      end
      CHAR : begin
        dtype_shift = 2'b00;
      end
      default : begin
        dtype_shift = 2'b00;
      end
    endcase
  end

  always @(*) begin
    case(rg_dtype)
      WORD : begin
        clip_dtype_num = 3'b001;
      end
      UWORD : begin
        clip_dtype_num = 3'b001;
      end
      SHORT : begin
        clip_dtype_num = 3'b010;
      end
      USHORT : begin
        clip_dtype_num = 3'b010;
      end
      CHAR : begin
        clip_dtype_num = 3'b100;
      end
      default : begin
        clip_dtype_num = 3'b100;
      end
    endcase
  end

  assign psum_data = tmp_psum_data;
  assign when_BoxFilter_l338 = ((start || rowsum_done) || colsum_done);
  assign when_BoxFilter_l350 = (start || wait_done);
  assign when_BoxFilter_l353 = ((win_index == tmp_when_BoxFilter_l353) && (! to_done_flag));
  assign when_BoxFilter_l355 = ((win_index == tmp_when_BoxFilter_l355) && to_done_flag);
  assign when_BoxFilter_l352 = (read_data_vld || psum_data_vld);
  assign when_BoxFilter_l383 = ((tmp_when_BoxFilter_l383 <= win_index) && (! to_done_flag));
  assign psum_mem_if_mem_wdata = tmp_psum_mem_if_mem_wdata;
  always @(*) begin
    case(rg_dtype)
      WORD : begin
        minValue = 64'hffffffff80000000;
      end
      UWORD : begin
        minValue = 64'h0000000000000000;
      end
      SHORT : begin
        minValue = 64'hffffffffffff8000;
      end
      USHORT : begin
        minValue = 64'h0000000000000000;
      end
      CHAR : begin
        minValue = 64'hffffffffffffff80;
      end
      default : begin
        minValue = 64'h0000000000000000;
      end
    endcase
  end

  always @(*) begin
    case(rg_dtype)
      WORD : begin
        maxValue = 64'h000000007fffffff;
      end
      UWORD : begin
        maxValue = 64'h00000000ffffffff;
      end
      SHORT : begin
        maxValue = 64'h0000000000007fff;
      end
      USHORT : begin
        maxValue = 64'h000000000000ffff;
      end
      CHAR : begin
        maxValue = 64'h000000000000007f;
      end
      default : begin
        maxValue = 64'h00000000000000ff;
      end
    endcase
  end

  assign when_BoxFilter_l425 = ($signed(maxValue) < $signed(tmp_when_BoxFilter_l425));
  always @(*) begin
    if(when_BoxFilter_l425) begin
      ClipValue = maxValue;
    end else begin
      if(when_BoxFilter_l427) begin
        ClipValue = minValue;
      end else begin
        ClipValue = {{31{filter_mean_data[32]}}, filter_mean_data};
      end
    end
  end

  assign when_BoxFilter_l427 = ($signed(tmp_when_BoxFilter_l427) < $signed(minValue));
  assign clip_index_hit = (filter_mean_io_ov && (clip_index_cnt == tmp_clip_index_hit));
  assign switch_BoxFilter_l456 = clip_index[1 : 0];
  always @(*) begin
    case(dtype_shift)
      2'b00 : begin
        case(switch_BoxFilter_l456)
          2'b00 : begin
            ClipValueByteShift = {24'd0, tmp_ClipValueByteShift};
          end
          2'b01 : begin
            ClipValueByteShift = {16'd0, tmp_ClipValueByteShift_2};
          end
          2'b10 : begin
            ClipValueByteShift = {8'd0, tmp_ClipValueByteShift_5};
          end
          default : begin
            ClipValueByteShift = tmp_ClipValueByteShift_8;
          end
        endcase
      end
      2'b01 : begin
        case(switch_BoxFilter_l476)
          2'b00, 2'b10 : begin
            ClipValueByteShift = {16'd0, tmp_ClipValueByteShift_10};
          end
          default : begin
            ClipValueByteShift = tmp_ClipValueByteShift_12;
          end
        endcase
      end
      2'b10 : begin
        ClipValueByteShift = tmp_ClipValueByteShift_14;
      end
      default : begin
        ClipValueByteShift = 32'h00000000;
      end
    endcase
  end

  always @(*) begin
    case(dtype_shift)
      2'b00 : begin
        case(switch_BoxFilter_l456)
          2'b00 : begin
            ClipDataWriteMask = 4'b0001;
          end
          2'b01 : begin
            ClipDataWriteMask = 4'b0010;
          end
          2'b10 : begin
            ClipDataWriteMask = 4'b0100;
          end
          default : begin
            ClipDataWriteMask = 4'b1000;
          end
        endcase
      end
      2'b01 : begin
        case(switch_BoxFilter_l476)
          2'b00, 2'b10 : begin
            ClipDataWriteMask = 4'b0011;
          end
          default : begin
            ClipDataWriteMask = 4'b1100;
          end
        endcase
      end
      2'b10 : begin
        ClipDataWriteMask = 4'b1111;
      end
      default : begin
        ClipDataWriteMask = 4'b0000;
      end
    endcase
  end

  assign switch_BoxFilter_l476 = clip_index[1 : 0];
  assign when_BoxFilter_l504 = (wait_done && (! to_done_flag));
  always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
      WinArea_result_reg <= 10'h000;
      state <= IDLE;
      pix_cnt <= 13'h0000;
      row_cnt <= 12'h000;
      col_cnt <= 12'h000;
      wait_done <= 1'b0;
      to_done_flag <= 1'b0;
      pixel_index <= 26'h0000000;
      pixel_index_lsb <= 2'b00;
      win_index <= 13'h0000;
      sum <= 64'h0000000000000000;
      done <= 1'b0;
      mem_master_rd_d1 <= 1'b0;
      input_read_data_buff <= 32'h00000000;
      read_data_vld <= 1'b0;
      psum_rd_d1 <= 1'b0;
      psum_data_vld <= 1'b0;
      psum_read_data_buff <= 64'h0000000000000000;
      read_data_bias <= 2'b00;
      filter_sum_vld <= 1'b0;
      slide_len <= 5'h00;
      mem_master_mem_rd <= 1'b0;
      mem_master_mem_wr <= 1'b0;
      mem_master_mem_addr <= 17'h00000;
      mem_master_mem_wdata <= 32'h00000000;
      mem_master_mem_wmask <= 4'b0000;
      psum_mem_if_mem_rd <= 1'b0;
      psum_mem_if_mem_wr <= 1'b0;
      psum_mem_if_mem_addr <= 16'h0000;
      psum_mem_if_mem_wmask <= 8'h00;
      clip_index <= 26'h0000000;
      clip_index_head <= 26'h0000000;
      clip_index_cnt <= 13'h0000;
      clip_index_d1 <= 26'h0000000;
    end else begin
      if(start) begin
        WinArea_result_reg <= WinArea;
      end
      wait_done <= wait_done_pre;
      pixel_index_lsb <= pixel_index_d1_l[1 : 0];
      done <= (state == DONE);
      state <= state_next;
      if(start) begin
        to_done_flag <= 1'b0;
      end else begin
        if(wait_done) begin
          to_done_flag <= (! to_done_flag);
        end
      end
      if(start) begin
        pix_cnt <= 13'h0000;
      end else begin
        if(when_BoxFilter_l142) begin
          if(pix_done) begin
            pix_cnt <= 13'h0000;
          end else begin
            pix_cnt <= (pix_cnt + 13'h0001);
          end
        end
      end
      if(start) begin
        row_cnt <= 12'h000;
      end else begin
        if(state_rowsum) begin
          if(rowsum_done) begin
            row_cnt <= 12'h000;
          end else begin
            if(pix_done) begin
              row_cnt <= (row_cnt + 12'h001);
            end
          end
        end
      end
      if(start) begin
        col_cnt <= 12'h000;
      end else begin
        if(state_colsum) begin
          if(colsum_done) begin
            col_cnt <= 12'h000;
          end else begin
            if(pix_done) begin
              col_cnt <= (col_cnt + 12'h001);
            end
          end
        end
      end
      mem_master_rd_d1 <= mem_master_mem_rd;
      if(mem_master_rd_d1) begin
        input_read_data_buff <= mem_master_mem_rdata;
      end
      read_data_vld <= mem_master_rd_d1;
      psum_rd_d1 <= psum_mem_if_mem_rd;
      psum_data_vld <= psum_rd_d1;
      if(psum_rd_d1) begin
        psum_read_data_buff <= psum_mem_if_mem_rdata;
      end
      read_data_bias <= tmp_read_data_bias[1 : 0];
      filter_sum_vld <= (psum_data_vld && ((tmp_filter_sum_vld <= win_index) && to_done_flag));
      if(start) begin
        slide_len <= WinSizeX;
      end else begin
        if(when_BoxFilter_l219) begin
          slide_len <= WinSizeY;
        end
      end
      if(read_data_vld) begin
        if(when_BoxFilter_l225) begin
          sum <= {{31{read_data[32]}}, read_data};
        end else begin
          if(when_BoxFilter_l227) begin
            sum <= ($signed(sum) + $signed(tmp_sum));
          end else begin
            sum <= ($signed(tmp_sum_1) - $signed(tmp_sum_3));
          end
        end
      end else begin
        if(psum_data_vld) begin
          if(when_BoxFilter_l233) begin
            sum <= {{27{tmp_sum_5[36]}}, tmp_sum_5};
          end else begin
            if(when_BoxFilter_l235) begin
              sum <= ($signed(sum) + $signed(tmp_sum_7));
            end else begin
              sum <= ($signed(tmp_sum_8) - $signed(tmp_sum_10));
            end
          end
        end
      end
      if(when_BoxFilter_l338) begin
        pixel_index <= 26'h0000000;
      end else begin
        if(state_rowsum) begin
          pixel_index <= (pixel_index + 26'h0000001);
        end else begin
          if(state_colsum) begin
            if(pix_done) begin
              pixel_index <= {14'd0, tmp_pixel_index};
            end else begin
              pixel_index <= (pixel_index + tmp_pixel_index_1);
            end
          end
        end
      end
      if(when_BoxFilter_l350) begin
        win_index <= 13'h0000;
      end else begin
        if(when_BoxFilter_l352) begin
          if(when_BoxFilter_l353) begin
            win_index <= 13'h0000;
          end else begin
            if(when_BoxFilter_l355) begin
              win_index <= 13'h0000;
            end else begin
              win_index <= (win_index + 13'h0001);
            end
          end
        end
      end
      psum_mem_if_mem_rd <= state_colsum;
      if(start) begin
        psum_mem_if_mem_addr <= (rg_psum_addr >>> 2'd3);
      end else begin
        if(psum_mem_if_mem_wr) begin
          psum_mem_if_mem_addr <= (psum_mem_if_mem_addr + 16'h0001);
        end else begin
          if(state_colsum) begin
            psum_mem_if_mem_addr <= tmp_psum_mem_if_mem_addr[15:0];
          end
        end
      end
      if(read_data_vld) begin
        if(when_BoxFilter_l383) begin
          psum_mem_if_mem_wr <= 1'b1;
          psum_mem_if_mem_wmask <= tmp_psum_mem_if_mem_wmask;
        end else begin
          psum_mem_if_mem_wr <= 1'b0;
          psum_mem_if_mem_wmask <= 8'h00;
        end
      end else begin
        psum_mem_if_mem_wr <= 1'b0;
        psum_mem_if_mem_wmask <= 8'h00;
      end
      clip_index_d1 <= clip_index;
      if(start) begin
        clip_index <= 26'h0000000;
        clip_index_head <= 26'h0000000;
        clip_index_cnt <= 13'h0000;
      end else begin
        if(filter_mean_io_ov) begin
          if(clip_index_hit) begin
            clip_index <= (clip_index_head + 26'h0000001);
            clip_index_head <= (clip_index_head + 26'h0000001);
            clip_index_cnt <= 13'h0000;
          end else begin
            clip_index <= (clip_index + tmp_clip_index);
            clip_index_cnt <= (clip_index_cnt + 13'h0001);
          end
        end
      end
      mem_master_mem_rd <= state_rowsum;
      if(state_rowsum) begin
        mem_master_mem_addr <= tmp_mem_master_mem_addr[16:0];
      end else begin
        if(when_BoxFilter_l504) begin
          mem_master_mem_addr <= (rg_output_addr >>> 2'd2);
        end else begin
          if(filter_mean_io_ov) begin
            mem_master_mem_addr <= tmp_mem_master_mem_addr_4[16:0];
          end
        end
      end
      mem_master_mem_wr <= filter_mean_io_ov;
      mem_master_mem_wdata <= ClipValueByteShift;
      mem_master_mem_wmask <= ClipDataWriteMask;
    end
  end

  always @(posedge clk) begin
    pixel_index_d1_l <= pixel_index[1 : 0];
  end


endmodule
