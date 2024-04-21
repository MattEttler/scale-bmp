/// Stored in a format optimized for linear reading/writing to the file system.
pub const ImageFile = packed struct {
    /// Stores general information about the bitmap image file.
    /// All integers must be stored in little-endian format.
    header: Header,
    header_info: HeaderInfo,
};

pub const Header = packed struct {
    /// A 16-bit indicator that this is a bitmap image using the ASCII code "BM".
    header_field: u16,
    /// The size of the entire file in bytes.
    size: u32,
    /// Arbitrary application data.
    app_data: u32,
    /// The offset of the file where the pixel data begins.
    pixel_array_starting_address: u32,
};
pub const HeaderInfo = packed struct {
    size: u32,
    pixel_width: u32,
    pixel_height: u32,
    num_color_planes: u16,
    pixel_depth: u16,
    compression_method_flag: u32,
    image_size: u32,
    horizontal_pixels_per_meter: u32,
    vertical_pixels_per_meter: u32,
    num_colors: u32,
    important_colors: u32,
};
