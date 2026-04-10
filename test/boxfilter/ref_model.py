"""
Reference model for BoxFilter algorithm
"""

import numpy as np
from config import DataType

class BoxFilterRefModel:
    """Reference model for box filter (square mean filter)"""

    @staticmethod
    def box_filter_2d(image, rx, ry, dtype):
        """
        Apply box filter to 2D image.

        Args:
            image: 2D numpy array of input pixels
            rx: horizontal window radius (0-15)
            ry: vertical window radius (0-15)
            dtype: DataType enum

        Returns:
            2D numpy array of filtered output pixels
        """
        height, width = image.shape
        win_size_x = 2 * rx + 1
        win_size_y = 2 * ry + 1
        win_area = win_size_x * win_size_y

        # Output dimensions
        outw = width - 2 * rx
        outh = height - 2 * ry

        if outw <= 0 or outh <= 0:
            raise ValueError(f"Invalid output dimensions: {outw}x{outh}")

        # Create output array
        output = np.zeros((outh, outw), dtype=np.int64)

        # Apply sliding window algorithm (naive for reference)
        # This is O(width*height*win_area) but accurate for verification
        for y in range(ry, height - ry):
            for x in range(rx, width - rx):
                # Sum over window
                window_sum = 0
                for dy in range(-ry, ry + 1):
                    for dx in range(-rx, rx + 1):
                        window_sum += image[y + dy, x + dx]

                # Compute mean with rounding
                mean = window_sum // win_area
                if window_sum % win_area >= (win_area + 1) // 2:
                    mean += 1 if window_sum > 0 else -1

                output[y - ry, x - rx] = mean

        # Clip to data type range
        min_val, max_val = BoxFilterRefModel.get_value_range(dtype)
        output = np.clip(output, min_val, max_val)

        # Convert to appropriate data type
        if dtype in [DataType.CHAR, DataType.UCHAR]:
            output = output.astype(np.int8) if dtype == DataType.CHAR else output.astype(np.uint8)
        elif dtype in [DataType.SHORT, DataType.USHORT]:
            output = output.astype(np.int16) if dtype == DataType.SHORT else output.astype(np.uint16)
        else:  # WORD, UWORD
            output = output.astype(np.int32) if dtype == DataType.WORD else output.astype(np.uint32)

        return output

    @staticmethod
    def get_value_range(dtype):
        """Get min/max value range for data type"""
        if dtype == DataType.CHAR:
            return -128, 127
        elif dtype == DataType.UCHAR:
            return 0, 255
        elif dtype == DataType.SHORT:
            return -32768, 32767
        elif dtype == DataType.USHORT:
            return 0, 65535
        elif dtype == DataType.WORD:
            return -2147483648, 2147483647
        else:  # UWORD
            return 0, 4294967295

    @staticmethod
    def generate_test_image(width, height, dtype, seed=None):
        """Generate random test image for given data type"""
        if seed is not None:
            np.random.seed(seed)

        min_val, max_val = BoxFilterRefModel.get_value_range(dtype)

        # Generate random values in range
        if dtype in [DataType.CHAR, DataType.SHORT, DataType.WORD]:
            # Signed types
            image = np.random.randint(min_val, max_val + 1, size=(height, width), dtype=np.int32)
        else:
            # Unsigned types
            image = np.random.randint(min_val, max_val + 1, size=(height, width), dtype=np.uint32)

        return image

    @staticmethod
    def compare_outputs(expected, actual, tolerance=0):
        """Compare expected and actual outputs"""
        if expected.shape != actual.shape:
            raise ValueError(f"Shape mismatch: expected {expected.shape}, got {actual.shape}")

        mismatches = np.where(expected != actual)
        if len(mismatches[0]) == 0:
            return True, []

        errors = []
        for i in range(len(mismatches[0])):
            y, x = mismatches[0][i], mismatches[1][i]
            errors.append({
                'x': x, 'y': y,
                'expected': int(expected[y, x]),
                'actual': int(actual[y, x])
            })

        return False, errors