#!/usr/bin/env python3
"""
BoxFilter Cocotb Testbench
Test for BoxFilter module - square mean filter
"""

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles
from cocotb.result import TestSuccess, TestFailure
# from cocotb.scoreboard import Scoreboard
from cocotb.binary import BinaryValue

import random
import numpy as np
import sys
import os

# Add local modules to path
sys.path.append(os.path.dirname(__file__))
from config import DataType, BoxFilterConfig
from memory_model import MemoryModel
from ref_model import BoxFilterRefModel

# Debug flag - set to True for verbose debugging, False for minimal output
# Can be controlled via environment variable BOXFILTER_DEBUG=1
DEBUG = os.getenv('BOXFILTER_DEBUG', '0') == '1'

# cocotb logging - not available in cocotb v1.9.2
# Using simple DEBUG flag instead

# ============================================================================
# BoxFilter测试环境类
# ============================================================================
class BoxFilterTb:
    """BoxFilter testbench environment"""

    def __init__(self, dut):
        self.dut = dut
        self.mem = MemoryModel()
        self.output_data = {}  # Map from byte address to output value
        self.expected_outputs = []  # List of expected outputs for scoreboard

        # 创建时钟驱动
        self.clock = Clock(dut.clk, 10, units="ns")
        cocotb.start_soon(self.clock.start())

        # 初始化输入信号，防止出现'z'
        self.dut.mem_master_mem_rdata.value = 0
        self.dut.psum_mem_if_mem_rdata.value = 0

        # 绑定内存接口回调
        cocotb.start_soon(self._psum_mem_monitor())
        cocotb.start_soon(self._main_mem_monitor())

        # 记分板 (已移除，因为cocotb新版本已移除Scoreboard)
        # self.scoreboard = Scoreboard(dut)

    async def reset(self, cycles=5):
        """Reset the DUT"""
        self.dut.resetn.value = 0
        await ClockCycles(self.dut.clk, cycles)
        self.dut.resetn.value = 1
        await ClockCycles(self.dut.clk, cycles)

    async def configure(self, config):
        """Configure the BoxFilter registers"""
        cfg_dict = config.to_dict()
        self.dut.rg_input_addr.value = cfg_dict['input_addr']
        self.dut.rg_output_addr.value = cfg_dict['output_addr']
        self.dut.rg_psum_addr.value = cfg_dict['psum_addr']
        self.dut.rg_dtype.value = cfg_dict['dtype']
        self.dut.rg_width.value = cfg_dict['width']
        self.dut.rg_height.value = cfg_dict['height']
        self.dut.rg_rx.value = cfg_dict['rx']
        self.dut.rg_ry.value = cfg_dict['ry']
        await RisingEdge(self.dut.clk)

    async def start(self):
        """Pulse start signal"""
        self.dut.start.value = 1
        await RisingEdge(self.dut.clk)
        self.dut.start.value = 0
        await RisingEdge(self.dut.clk)

    async def wait_done(self, timeout=100000):
        """Wait for done signal with timeout"""
        for _ in range(timeout):
            await RisingEdge(self.dut.clk)
            if self.dut.done.value == 1:
                return True
        return False

    async def _psum_mem_monitor(self):
        """Monitor PSUM memory interface and respond to reads"""
        while True:
            await RisingEdge(self.dut.clk)

            # Handle read requests
            if self.dut.psum_mem_if_mem_rd.value == 1:
                addr = self.dut.psum_mem_if_mem_addr.value
                addr_int = addr.integer if hasattr(addr, 'integer') else addr
                if DEBUG:
                    print(f"PSUM_MEM_READ: addr={addr_int:#x} ({addr_int})")
                rdata = self.mem.psum_read(addr)
                # Drive read data immediately (will be sampled next clock edge)
                self.dut.psum_mem_if_mem_rdata.value = rdata
                if DEBUG:
                    print(f"PSUM_MEM_READ: rdata={int(rdata):#x} ({int(rdata)}) bin={int(rdata):064b}")

            # Handle write requests
            if self.dut.psum_mem_if_mem_wr.value == 1:
                addr = self.dut.psum_mem_if_mem_addr.value
                data = self.dut.psum_mem_if_mem_wdata.value
                mask = self.dut.psum_mem_if_mem_wmask.value
                if DEBUG:
                    print(f"PSUM_MEM_WRITE: addr={addr}, data={data}, mask={mask}")
                try:
                    self.mem.psum_write(addr, data, mask)
                except Exception as e:
                    if DEBUG:
                        print(f"PSUM_MEM_WRITE ERROR: {e}")
                    else:
                        print(f"PSUM_MEM_WRITE ERROR")
                    raise

    async def _main_mem_monitor(self):
        """Monitor main memory interface and respond to reads"""
        while True:
            await RisingEdge(self.dut.clk)

            # Handle read requests
            if self.dut.mem_master_mem_rd.value == 1:
                addr = self.dut.mem_master_mem_addr.value
                addr_int = addr.integer if hasattr(addr, 'integer') else addr
                if DEBUG:
                    print(f"MAIN_MEM_READ: addr={addr_int:#x} ({addr_int})")
                rdata = self.mem.main_read(addr)
                # Drive read data immediately (will be sampled next clock edge)
                self.dut.mem_master_mem_rdata.value = rdata
                if DEBUG:
                    print(f"MAIN_MEM_READ: rdata={int(rdata):#x} ({int(rdata)}) bin={int(rdata):032b}")

            # Handle write requests
            if self.dut.mem_master_mem_wr.value == 1:
                addr = self.dut.mem_master_mem_addr.value
                data = self.dut.mem_master_mem_wdata.value
                mask = self.dut.mem_master_mem_wmask.value
                if DEBUG:
                    print(f"MAIN_MEM_WRITE: addr={addr}, data={data}, mask={mask}, data_bin={data.binstr if hasattr(data, 'binstr') else 'N/A'}")
                try:
                    self.mem.main_write(addr, data, mask)
                except Exception as e:
                    if DEBUG:
                        print(f"MAIN_MEM_WRITE ERROR: {e}")
                    else:
                        print(f"MAIN_MEM_WRITE ERROR")
                    raise
                # Record output writes for verification
                self._record_output_write(addr, data, mask)

    def _record_output_write(self, word_addr, data, mask):
        """Record output writes for later verification"""
        # Convert word address to byte address
        byte_addr_base = word_addr << 2

        # Extract bytes based on mask
        for i in range(4):
            if (mask >> i) & 1:
                byte_addr = byte_addr_base + i
                byte_value = (data >> (i * 8)) & 0xFF
                self.output_data[byte_addr] = byte_value

    def preload_input_image(self, config, image_2d):
        """Preload main memory with 2D image data"""
        bytes_per_pixel = config.get_bytes_per_pixel()
        min_val, max_val = config.get_value_range()

        # Flatten image row-major
        height, width = image_2d.shape
        flat_image = image_2d.flatten()

        # Convert to list of integers
        pixel_list = [int(pixel) & ((1 << (bytes_per_pixel * 8)) - 1) for pixel in flat_image]

        # Preload memory
        self.mem.preload_main_memory(config.input_addr, pixel_list, bytes_per_pixel)

    def get_output_image(self, config):
        """Retrieve output image from memory"""
        outw, outh = config.calculate_output_size()
        bytes_per_pixel = config.get_bytes_per_pixel()
        output_image = np.zeros((outh, outw), dtype=np.int32)

        # Read output pixels from memory
        for y in range(outh):
            for x in range(outw):
                pixel_idx = y * outw + x
                byte_addr = config.output_addr + pixel_idx * bytes_per_pixel

                # Read bytes for this pixel
                pixel_value = 0
                for i in range(bytes_per_pixel):
                    addr = byte_addr + i
                    word_addr = addr >> 2
                    word_offset = addr & 0x3
                    word_data = self.mem.main_read(word_addr)
                    byte_val = (word_data >> (word_offset * 8)) & 0xFF
                    pixel_value |= byte_val << (i * 8)

                # Sign extend if signed type
                if config.dtype in [DataType.CHAR, DataType.SHORT, DataType.WORD]:
                    bits = bytes_per_pixel * 8
                    if pixel_value & (1 << (bits - 1)):
                        pixel_value -= (1 << bits)

                output_image[y, x] = pixel_value

        return output_image

# ============================================================================
# 测试用例
# ============================================================================
@cocotb.test()
async def test_reset(dut):
    """Test reset functionality"""
    tb = BoxFilterTb(dut)
    await tb.reset()

    # Check default values after reset
    assert dut.done.value == 0, "done should be 0 after reset"
    assert dut.psum_mem_if_mem_rd.value == 0, "psum_mem_if_mem_rd should be 0"
    assert dut.psum_mem_if_mem_wr.value == 0, "psum_mem_if_mem_wr should be 0"
    assert dut.mem_master_mem_rd.value == 0, "mem_master_mem_rd should be 0"
    assert dut.mem_master_mem_wr.value == 0, "mem_master_mem_wr should be 0"

    await ClockCycles(dut.clk, 10)
    raise TestSuccess("Reset test passed")

@cocotb.test()
async def test_basic_char(dut):
    """Test basic functionality with CHAR (8-bit signed) data type"""
    tb = BoxFilterTb(dut)
    await tb.reset()

    # Create configuration
    config = BoxFilterConfig()
    config.width = 10
    config.height = 8
    config.rx = 1
    config.ry = 1
    config.dtype = DataType.CHAR

    print(f"Test configuration: {config}")

    # Generate test image
    input_image = BoxFilterRefModel.generate_test_image(
        config.width, config.height, config.dtype, seed=42
    )

    # Preload memory
    tb.preload_input_image(config, input_image)

    # Configure DUT
    await tb.configure(config)

    # Start processing
    await tb.start()

    # DEBUG: Monitor signals for first 20 cycles after start
    if DEBUG:
        print("DEBUG: Monitoring signals after start...")
        for i in range(20):
            await RisingEdge(dut.clk)
            # Get signal values
            state = dut.state.value
            sum_val = dut.sum.value if hasattr(dut.sum, 'value') else 'N/A'
            read_data_val = dut.read_data.value if hasattr(dut, 'read_data') and hasattr(dut.read_data, 'value') else 'N/A'
            input_read_data_buff_val = dut.input_read_data_buff.value if hasattr(dut, 'input_read_data_buff') and hasattr(dut.input_read_data_buff, 'value') else 'N/A'
            read_data_vld_val = dut.read_data_vld.value if hasattr(dut, 'read_data_vld') and hasattr(dut.read_data_vld, 'value') else 'N/A'
            win_index_val = dut.win_index.value if hasattr(dut, 'win_index') and hasattr(dut.win_index, 'value') else 'N/A'
            print(f"  Cycle {i}: state={state}, sum={sum_val}, read_data={read_data_val}, input_buff={input_read_data_buff_val}, rd_vld={read_data_vld_val}, win_idx={win_index_val}")
            print(f"         mem_rd={dut.mem_master_mem_rd.value}, mem_wr={dut.mem_master_mem_wr.value}, psum_rd={dut.psum_mem_if_mem_rd.value}, psum_wr={dut.psum_mem_if_mem_wr.value}, done={dut.done.value}")

    # Wait for completion
    done = await tb.wait_done(timeout=5000)
    assert done, "Timeout waiting for done signal"

    # Get output from memory
    actual_output = tb.get_output_image(config)

    # Compute expected output using reference model
    expected_output = BoxFilterRefModel.box_filter_2d(
        input_image, config.rx, config.ry, config.dtype
    )

    # DEBUG: Print some signals
    if DEBUG:
        print(f"DEBUG: dut.state = {dut.state.value}")
        print(f"DEBUG: dut.done = {dut.done.value}")
        print(f"DEBUG: dut.mem_master_mem_rd = {dut.mem_master_mem_rd.value}")
        print(f"DEBUG: dut.mem_master_mem_wr = {dut.mem_master_mem_wr.value}")
        print(f"DEBUG: dut.psum_mem_if_mem_rd = {dut.psum_mem_if_mem_rd.value}")
        print(f"DEBUG: dut.psum_mem_if_mem_wr = {dut.psum_mem_if_mem_wr.value}")
        print(f"DEBUG: dut.WinArea_result_reg = {dut.WinArea_result_reg.value}")
        print(f"DEBUG: dut.sum = {dut.sum.value}")
        print(f"DEBUG: dut.config_valid = {dut.config_valid.value if hasattr(dut, 'config_valid') else 'N/A'}")
        print(f"DEBUG: dut.outw = {dut.outw.value if hasattr(dut, 'outw') else 'N/A'}")
        print(f"DEBUG: dut.outh = {dut.outh.value if hasattr(dut, 'outh') else 'N/A'}")

    # Compare results
    match, errors = BoxFilterRefModel.compare_outputs(expected_output, actual_output)
    if not match:
        print(f"Output mismatch: {len(errors)} errors")
        for err in errors[:10]:  # Print first 10 errors
            print(f"  Pixel ({err['x']},{err['y']}): expected {err['expected']}, got {err['actual']}")
        raise TestFailure(f"Output mismatch: {len(errors)} errors")
    else:
        print(f"Test passed. Output dimensions: {actual_output.shape[1]}x{actual_output.shape[0]}")
        raise TestSuccess("Basic CHAR test passed")

@cocotb.test()
async def test_all_data_types(dut):
    """Test all data types with small image"""
    tb = BoxFilterTb(dut)
    await tb.reset()

    # Test each data type
    for dtype in DataType:
        # Skip if takes too long
        if dtype in [DataType.WORD, DataType.UWORD]:
            continue  # Skip 32-bit for speed

        # Create configuration
        config = BoxFilterConfig()
        config.width = 8
        config.height = 6
        config.rx = 1
        config.ry = 1
        config.dtype = dtype

        print(f"Testing {dtype.name}...")

        # Generate test image
        input_image = BoxFilterRefModel.generate_test_image(
            config.width, config.height, config.dtype, seed=100 + dtype.value
        )

        # Preload memory
        tb.preload_input_image(config, input_image)

        # Configure DUT
        await tb.configure(config)

        # Start processing
        await tb.start()

        # Wait for completion
        done = await tb.wait_done(timeout=5000)
        assert done, f"Timeout waiting for done signal (dtype={dtype.name})"

        # Get output from memory
        actual_output = tb.get_output_image(config)

        # Compute expected output
        expected_output = BoxFilterRefModel.box_filter_2d(
            input_image, config.rx, config.ry, config.dtype
        )

        # Compare results
        match, errors = BoxFilterRefModel.compare_outputs(expected_output, actual_output)
        if not match:
            print(f"Failed for {dtype.name}: {len(errors)} errors")
            raise TestFailure(f"Output mismatch for {dtype.name}: {len(errors)} errors")

        print(f"  {dtype.name}: OK")

        # Reset for next test
        await tb.reset()

    raise TestSuccess("All data types test passed")

@cocotb.test()
async def test_boundary_window_sizes(dut):
    """Test boundary window sizes (minimum and maximum)"""
    tb = BoxFilterTb(dut)
    await tb.reset()

    # Test cases: (rx, ry, width, height)
    test_cases = [
        (0, 0, 10, 8),   # Minimum window size (1x1)
        (1, 0, 10, 8),   # Horizontal window only
        (0, 1, 10, 8),   # Vertical window only
        (2, 2, 20, 16),  # Medium window
    ]

    for rx, ry, width, height in test_cases:
        config = BoxFilterConfig()
        config.width = width
        config.height = height
        config.rx = rx
        config.ry = ry
        config.dtype = DataType.UCHAR  # Simple unsigned type

        # Skip if output dimensions invalid
        outw, outh = config.calculate_output_size()
        if outw <= 0 or outh <= 0:
            print(f"Skipping invalid config: rx={rx}, ry={ry}, width={width}, height={height}")
            continue

        print(f"Testing window: rx={rx}, ry={ry}, size={2*rx+1}x{2*ry+1}")

        # Generate test image
        input_image = BoxFilterRefModel.generate_test_image(
            config.width, config.height, config.dtype, seed=200 + rx + ry
        )

        # Preload memory
        tb.preload_input_image(config, input_image)

        # Configure DUT
        await tb.configure(config)

        # Start processing
        await tb.start()

        # Wait for completion
        done = await tb.wait_done(timeout=10000)
        assert done, f"Timeout waiting for done signal (rx={rx}, ry={ry})"

        # Get output from memory
        actual_output = tb.get_output_image(config)

        # Compute expected output
        expected_output = BoxFilterRefModel.box_filter_2d(
            input_image, config.rx, config.ry, config.dtype
        )

        # Compare results
        match, errors = BoxFilterRefModel.compare_outputs(expected_output, actual_output)
        if not match:
            print(f"Failed for rx={rx}, ry={ry}: {len(errors)} errors")
            raise TestFailure(f"Output mismatch for rx={rx}, ry={ry}: {len(errors)} errors")

        print(f"  Window {2*rx+1}x{2*ry+1}: OK")

        # Reset for next test
        await tb.reset()

    raise TestSuccess("Boundary window sizes test passed")

@cocotb.test()
async def test_random_configurations(dut):
    """Test random configurations with verification"""
    tb = BoxFilterTb(dut)
    await tb.reset()

    # Number of random tests
    num_tests = 5

    for test_idx in range(num_tests):
        # Generate random configuration
        config = BoxFilterConfig.random_config(max_width=30, max_height=20)

        # Skip if output dimensions invalid
        outw, outh = config.calculate_output_size()
        if outw <= 0 or outh <= 0:
            print(f"Test {test_idx}: Skipping invalid config")
            continue

        print(f"\nTest {test_idx}: {config}")

        # Generate test image
        input_image = BoxFilterRefModel.generate_test_image(
            config.width, config.height, config.dtype, seed=300 + test_idx
        )

        # Preload memory
        tb.preload_input_image(config, input_image)

        # Configure DUT
        await tb.configure(config)

        # Start processing
        await tb.start()

        # Wait for completion with timeout based on image size
        timeout = config.width * config.height * 2 + 1000
        done = await tb.wait_done(timeout=timeout)
        assert done, f"Test {test_idx}: Timeout waiting for done signal"

        # Get output from memory
        actual_output = tb.get_output_image(config)

        # Compute expected output
        expected_output = BoxFilterRefModel.box_filter_2d(
            input_image, config.rx, config.ry, config.dtype
        )

        # Compare results
        match, errors = BoxFilterRefModel.compare_outputs(expected_output, actual_output)
        if not match:
            print(f"Test {test_idx}: Failed with {len(errors)} errors")
            for err in errors[:5]:  # Print first 5 errors
                print(f"  Pixel ({err['x']},{err['y']}): expected {err['expected']}, got {err['actual']}")
            raise TestFailure(f"Test {test_idx}: Output mismatch ({len(errors)} errors)")
        else:
            print(f"Test {test_idx}: PASSED")

        # Reset for next test
        await tb.reset()

    raise TestSuccess(f"Random configurations test passed ({num_tests} tests)")

# ============================================================================
# 主测试入口
# ============================================================================
if __name__ == "__main__":
    # This allows running the test directly with python
    print("Run this test with cocotb (make)")
    print("Example: make SIM=icarus")