"""
Configuration classes for BoxFilter tests
"""

from enum import IntEnum
import random

class DataType(IntEnum):
    WORD   = 0  # 32-bit signed
    UWORD  = 1  # 32-bit unsigned
    SHORT  = 2  # 16-bit signed
    USHORT = 3  # 16-bit unsigned
    CHAR   = 4  # 8-bit signed
    UCHAR  = 5  # 8-bit unsigned

class BoxFilterConfig:
    """BoxFilter configuration parameters"""

    def __init__(self):
        self.input_addr = 0x00000   # 19-bit byte address
        self.output_addr = 0x10000  # 19-bit byte address
        self.psum_addr = 0x20000    # 19-bit byte address
        self.dtype = DataType.CHAR  # 3-bit data type
        self.width = 10             # 12-bit width
        self.height = 8             # 12-bit height
        self.rx = 1                 # 4-bit window radius X
        self.ry = 1                 # 4-bit window radius Y

    def to_dict(self):
        """Convert to dictionary for DUT assignment"""
        return {
            'input_addr': self.input_addr,
            'output_addr': self.output_addr,
            'psum_addr': self.psum_addr,
            'dtype': self.dtype.value,
            'width': self.width,
            'height': self.height,
            'rx': self.rx,
            'ry': self.ry,
        }

    def calculate_window_size(self):
        """Calculate window dimensions"""
        win_size_x = 2 * self.rx + 1
        win_size_y = 2 * self.ry + 1
        win_area = win_size_x * win_size_y
        return win_size_x, win_size_y, win_area

    def calculate_output_size(self):
        """Calculate output image dimensions"""
        outw = self.width - 2 * self.rx
        outh = self.height - 2 * self.ry
        return outw, outh

    def get_bytes_per_pixel(self):
        """Get bytes per pixel based on data type"""
        if self.dtype in [DataType.CHAR, DataType.UCHAR]:
            return 1
        elif self.dtype in [DataType.SHORT, DataType.USHORT]:
            return 2
        else:  # WORD, UWORD
            return 4

    def get_value_range(self):
        """Get min/max value range for data type"""
        if self.dtype == DataType.CHAR:
            return -128, 127
        elif self.dtype == DataType.UCHAR:
            return 0, 255
        elif self.dtype == DataType.SHORT:
            return -32768, 32767
        elif self.dtype == DataType.USHORT:
            return 0, 65535
        elif self.dtype == DataType.WORD:
            return -2147483648, 2147483647
        else:  # UWORD
            return 0, 4294967295

    @classmethod
    def random_config(cls, max_width=100, max_height=100):
        """Generate random configuration"""
        cfg = cls()
        cfg.input_addr = random.randint(0, 0x7FFFF)
        cfg.output_addr = random.randint(0, 0x7FFFF)
        cfg.psum_addr = random.randint(0, 0x7FFFF)
        cfg.dtype = random.choice(list(DataType))
        cfg.width = random.randint(5, max_width)
        cfg.height = random.randint(5, max_height)

        # Limit window radius to ensure positive output dimensions
        max_rx = min(15, (cfg.width - 1) // 2)
        max_ry = min(15, (cfg.height - 1) // 2)
        cfg.rx = random.randint(0, max_rx)
        cfg.ry = random.randint(0, max_ry)

        return cfg

    def __str__(self):
        outw, outh = self.calculate_output_size()
        win_x, win_y, win_area = self.calculate_window_size()
        return (f"BoxFilterConfig: width={self.width}, height={self.height}, "
                f"rx={self.rx}, ry={self.ry}, dtype={self.dtype.name}, "
                f"outw={outw}, outh={outh}, win_size={win_x}x{win_y}={win_area}")