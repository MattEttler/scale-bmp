const bmp = @import("bmp.zig");

const std = @import("std");

const ScaleBmpErrors = error{InvalidParameterValue};

pub fn main() !void {
    std.log.debug("Creating Allocator ...", .{});
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    var argIterator = try std.process.argsWithAllocator(allocator);
    defer argIterator.deinit();

    var width: u32 = 100;
    var height: u32 = 100;

    // parse width and height from CLI args.
    while (true) {
        const maybeArg = argIterator.next();
        if (maybeArg) |arg| {
            std.log.debug("found argument {s}", .{arg});
            if (std.mem.eql(u8, arg, "--width")) {
                width = try std.fmt.parseInt(u32, argIterator.next() orelse "0", 10);
            }
            if (std.mem.eql(u8, arg, "--height")) {
                height = try std.fmt.parseInt(u32, argIterator.next() orelse "0", 10);
            }
            if (std.mem.eql(u8, arg, "--help")) {
                try stdout.print(
                    \\parameters:
                    \\  --width of the image to be generated in pixels. Default: 100
                    \\  --height of the image to be generated in pixels. Default: 100
                    \\  --help displays this menu.
                    \\
                , .{});
                try bw.flush();
                std.process.exit(0);
            }
            continue;
        }

        std.log.debug("done parsing args ...", .{});
        if (width == 0 or height == 0) {
            return error.InvalidParameterValue;
        }
        std.log.debug("captured argument width of: {}", .{width});
        std.log.debug("captured argument height of: {}", .{height});
        break;
    }

    const bytes_per_pixel = 3;
    const row_byte_alignment = 4;
    const bytes_per_row_raw: u32 = bytes_per_pixel * width;
    const bytes_per_row_padded: u32 = bytes_per_row_raw + (bytes_per_row_raw % row_byte_alignment);
    const pixel_region_size: u32 = height * (bytes_per_row_padded);
    const pixel_region = try allocator.alloc(u8, pixel_region_size);

    const file_data = bmp.ImageFile{
        .header = bmp.Header{
            .header_field = std.mem.nativeToBig(u16, 0x42_4D),
            .size = std.mem.nativeToLittle(u32, ((@bitSizeOf(bmp.Header) + @bitSizeOf(bmp.HeaderInfo)) / 8) + pixel_region_size),
            .app_data = 0,
            .pixel_array_starting_address = std.mem.nativeToLittle(u32, (@bitSizeOf(bmp.Header) + @bitSizeOf(bmp.HeaderInfo)) / 8),
        },

        .header_info = .{
            .size = std.mem.nativeToLittle(u32, @bitSizeOf(bmp.HeaderInfo) / 8),
            .pixel_width = std.mem.nativeToLittle(u32, width),
            .pixel_height = std.mem.nativeToLittle(u32, height),
            .num_color_planes = std.mem.nativeToLittle(u16, 1),
            .pixel_depth = std.mem.nativeToLittle(u16, 24),
            .compression_method_flag = 0,
            .image_size = 0,
            .vertical_pixels_per_meter = 0,
            .horizontal_pixels_per_meter = 0,
            .num_colors = 0,
            .important_colors = 0,
        },
    };

    std.log.debug("writing file to stdout ...", .{});
    try stdout.writeAll(&std.mem.toBytes(file_data));

    for (pixel_region) |byte| {
        try stdout.writeAll(byte);
    }
    std.log.debug("finished writing file to stdout ...", .{});

    std.log.debug("flushing buffered writer to stdout ...", .{});
    try bw.flush(); // don't forget to flush!
}
