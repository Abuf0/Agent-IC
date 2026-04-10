# boxfilter模块设计规格

## 1. 设计概述
- **模块名称**: BoxFilter
- **功能描述**: 方形均值滤波
- **设计者**: Abu
- **版本**: 1.0

## 2. 接口信号

### 2.1 时钟与复位
| 信号名 | 方向 | 宽度 | 描述 |
|--------|------|------|------|
| clk    | input | 1    | 系统时钟 |
| resetn | input | 1    | 低有效异步复位 |

### 2.2 控制信号
| 信号名 | 方向 | 宽度 | 描述 |
|--------|------|------|------|
| start  | input | 1    | 启动信号，高电平触发开始处理 |
| done   | output| 1    | 完成信号，高电平表示处理完成 |

### 2.3 配置寄存器
| 信号名 | 方向 | 宽度 | 描述 |
|--------|------|------|------|
| rg_input_addr | input | 19   | 输入图像起始地址（字节地址） |
| rg_output_addr| input | 19   | 输出图像起始地址（字节地址） |
| rg_psum_addr  | input | 19   | PSUM内存起始地址（字节地址） |
| rg_dtype      | input | 3    | 数据类型编码: 0=WORD,1=UWORD,2=SHORT,3=USHORT,4=CHAR,5=UCHAR |
| rg_width      | input | 12   | 输入图像宽度（像素数） |
| rg_height     | input | 12   | 输入图像高度（像素数） |
| rg_rx         | input | 4    | 窗口水平半径（0-7） |
| rg_ry         | input | 4    | 窗口垂直半径（0-7） |

### 2.4 PSUM内存接口（64位宽）
| 信号名 | 方向 | 宽度 | 描述 |
|--------|------|------|------|
| psum_mem_if_mem_rd   | output | 1    | 读使能 |
| psum_mem_if_mem_wr   | output | 1    | 写使能 |
| psum_mem_if_mem_addr | output | 16   | 地址（64位字地址） |
| psum_mem_if_mem_wdata| output | 64   | 写数据 |
| psum_mem_if_mem_wmask| output | 8    | 写掩码（每字节1位） |
| psum_mem_if_mem_rdata| input  | 64   | 读数据 |

### 2.5 主内存接口（32位宽）
| 信号名 | 方向 | 宽度 | 描述 |
|--------|------|------|------|
| mem_master_mem_rd   | output | 1    | 读使能 |
| mem_master_mem_wr   | output | 1    | 写使能 |
| mem_master_mem_addr | output | 17   | 地址（32位字地址） |
| mem_master_mem_wdata| output | 32   | 写数据 |
| mem_master_mem_wmask| output | 4    | 写掩码（每字节1位） |
| mem_master_mem_rdata| input  | 32   | 读数据 |

## 3. 功能描述

### 3.1 算法概述
本模块实现对输入图像的方形均值滤波，采用两步累加算法：
1. **行累加阶段(ROW_SUM)**: 按行滑动窗口累加，将部分和写入PSUM memory
2. **列累加阶段(COL_SUM)**: 从PSUM memory读回部分和，按列累加得到窗口总和
3. **均值计算与裁剪**: 计算窗口均值，裁剪到数据类型的合法范围，写回输出内存

### 3.2 数据格式支持
| 数据类型 | 编码 | 位宽 | 有符号 | 最小值 | 最大值 |
|----------|------|------|--------|--------|--------|
| WORD     | 0    | 32   | 有     | -2^31  | 2^31-1 |
| UWORD    | 1    | 32   | 无     | 0      | 2^32-1 |
| SHORT    | 2    | 16   | 有     | -2^15  | 2^15-1 |
| USHORT   | 3    | 16   | 无     | 0      | 2^16-1 |
| CHAR     | 4    | 8    | 有     | -2^7   | 2^7-1  |
| UCHAR    | 5    | 8    | 无     | 0      | 2^8-1  |

### 3.3 窗口尺寸计算
- **窗口水平尺寸**: WinSizeX = 2 × rg_rx + 1 (范围: 1~15)
- **窗口垂直尺寸**: WinSizeY = 2 × rg_ry + 1 (范围: 1~15)
- **窗口面积**: WinArea = WinSizeX × WinSizeY (范围: 1~225)
- **输出图像宽度**: outw = rg_width - 2 × rg_rx (需满足 outw > 0)
- **输出图像高度**: outh = rg_height - 2 × rg_ry (需满足 outh > 0)

### 3.4 地址计算
#### 输入地址计算
- **字节地址**: input_byte_addr = rg_input_addr + pixel_index × bytes_per_pixel
- **字地址**: mem_master_mem_addr = input_byte_addr >> 2 (32位字对齐)
- bytes_per_pixel: 根据数据类型分别为 1, 2, 4 字节

#### PSUM地址计算
- **字节地址**: psum_byte_addr = rg_psum_addr + pixel_index × 8 (64位字)
- **字地址**: psum_mem_if_mem_addr = psum_byte_addr >> 3 (64位字对齐)

#### 输出地址计算
- **字节地址**: output_byte_addr = rg_output_addr + clip_index × bytes_per_pixel
- **字地址**: mem_master_mem_addr = output_byte_addr >> 2

### 3.5 滑动窗口累加算法
#### 行累加（水平方向滑动）
- 对于每一行，维护一个长度为WinSizeX的滑动窗口和
- 每次右移一个像素: sum_new = sum_old + new_pixel - old_pixel
- 窗口和达到稳定后（累积了WinSizeX个像素），写入PSUM memory

#### 列累加（垂直方向滑动）
- 对于每一列，从PSUM memory读回行部分和
- 维护一个长度为WinSizeY的滑动窗口和
- 每次下移一行: sum_new = sum_old + new_row_sum - old_row_sum
- 窗口和达到稳定后（累积了WinSizeY个行和），计算均值

### 3.6 均值计算与裁剪
- **均值计算**: mean = sum / WinArea (有符号除法，四舍五入)
- **裁剪处理**: 
  - 若 mean > maxValue，输出 maxValue
  - 若 mean < minValue，输出 minValue
  - 否则输出 mean
- **写回输出**: 根据数据类型和字节对齐生成写掩码，写入主内存

### 3.7 状态机流程
1. **IDLE**: 等待start信号
2. **ROW_SUM**: 行累加阶段，读取输入像素，计算行部分和，写入PSUM
3. **WAIT_1**: 等待流水线排空，切换累加方向
4. **COL_SUM**: 列累加阶段，读取PSUM，计算列总和，得到窗口均值
5. **WAIT_1**: 等待裁剪写回完成
6. **DONE**: 处理完成，输出done信号

## 4. 性能指标
- **工艺节点**: TSMC 22nm
- **目标频率**: 400MHz
- **吞吐量**: 每周期处理1个像素（行累加阶段）或1个行和（列累加阶段）
- **延迟**: 与图像尺寸和窗口大小相关，约 width×height + outw×WinSizeY 周期
- **资源估计**: 约 2K LUTs, 2K FFs, 1 BRAM (Line Buffer)

## 5. 时序要求
- **启动时序**: start信号至少保持1个时钟周期高电平
- **配置寄存器**: 在start上升沿前必须稳定
- **内存接口**: 遵循标准同步内存接口时序，1周期读延迟
- **完成信号**: done信号在DONE状态保持高电平，直到下次start

## 6. 验证要点
- 边界条件测试: 最小/最大窗口尺寸，最小/最大图像尺寸
- 数据类型测试: 所有6种数据类型，有/无符号，边界值
- 地址对齐测试: 各种字节对齐情况
- 性能测试: 最大吞吐量，延迟测量
- 正确性验证: 与软件参考模型对比，随机测试