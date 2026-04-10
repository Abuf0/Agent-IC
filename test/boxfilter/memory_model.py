"""
Memory models for BoxFilter testbench
"""

import random

class MemoryModel:
    """Simple memory model for PSUM (64-bit) and Main (32-bit) memories"""

    def __init__(self, size=65536):
        self.psum_mem = {}   # 64-bit memory (address in 64-bit words)
        self.main_mem = {}   # 32-bit memory (address in 32-bit words)
        self.size = size
        self.read_log = []
        self.write_log = []

    def psum_read(self, addr):
        """Read from PSUM memory (64-bit)"""
        addr_int = addr.integer if hasattr(addr, 'integer') else addr
        data = self.psum_mem.get(addr_int, 0)
        self.read_log.append(('psum', addr_int, data))
        return data

    def psum_write(self, addr, data, mask=0xFF):
        """Write to PSUM memory (64-bit) with byte mask"""
        addr_int = addr.integer if hasattr(addr, 'integer') else addr
        self.write_log.append(('psum', addr_int, data, mask))
        if mask == 0xFF:
            self.psum_mem[addr_int] = data
        else:
            # Handle partial write with byte mask
            old_data = self.psum_mem.get(addr_int, 0)
            for i in range(8):
                if (mask >> i) & 1:
                    byte_mask = 0xFF << (i*8)
                    old_data = old_data & ~byte_mask
                    old_data = old_data | (data & byte_mask)
            self.psum_mem[addr_int] = old_data

    def main_read(self, addr):
        """Read from main memory (32-bit)"""
        addr_int = addr.integer if hasattr(addr, 'integer') else addr
        data = self.main_mem.get(addr_int, 0)
        self.read_log.append(('main', addr_int, data))
        # DEBUG
        # print(f"MemoryModel.main_read: addr={addr_int:#x}, data={data:#x}")
        return data

    def main_write(self, addr, data, mask=0xF):
        """Write to main memory (32-bit) with byte mask"""
        addr_int = addr.integer if hasattr(addr, 'integer') else addr
        self.write_log.append(('main', addr_int, data, mask))
        if mask == 0xF:
            self.main_mem[addr_int] = data
        else:
            # Handle partial write with byte mask
            old_data = self.main_mem.get(addr_int, 0)
            for i in range(4):
                if (mask >> i) & 1:
                    byte_mask = 0xFF << (i*8)
                    old_data = old_data & ~byte_mask
                    old_data = old_data | (data & byte_mask)
            self.main_mem[addr_int] = old_data

    def preload_main_memory(self, start_addr, data_list, bytes_per_pixel=1):
        """
        Preload main memory with data list.
        start_addr: byte address
        data_list: list of pixel values (integers)
        bytes_per_pixel: 1, 2, or 4
        """
        for i, pixel in enumerate(data_list):
            byte_addr = start_addr + i * bytes_per_pixel
            word_addr = byte_addr >> 2
            word_offset = byte_addr & 0x3

            # Shift pixel to correct byte position
            pixel_shifted = pixel << (word_offset * 8)
            mask = (1 << bytes_per_pixel) - 1
            mask = mask << word_offset

            # Write to memory
            self.main_write(word_addr, pixel_shifted, mask)

    def clear_logs(self):
        """Clear read/write logs"""
        self.read_log = []
        self.write_log = []

    def dump_memory(self, mem_type='main', start=0, count=16):
        """Dump memory contents for debugging"""
        mem_dict = self.main_mem if mem_type == 'main' else self.psum_mem
        print(f"\n{mem_type.upper()} Memory Dump (addresses {start} to {start+count-1}):")
        for i in range(count):
            addr = start + i
            if addr in mem_dict:
                value = mem_dict[addr]
                print(f"  {addr:#06x}: {value:#018x}" if mem_type == 'psum' else f"  {addr:#06x}: {value:#010x}")
            else:
                print(f"  {addr:#06x}: <empty>")