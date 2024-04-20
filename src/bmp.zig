pub const header = packed struct {
    header_field: u16,
    size: u32,
    app_data: u32,
    pixel_array_starting_address: u32,
};

pub const header_info = packed struct {
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
