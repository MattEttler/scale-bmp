const std = @import("std");

const ArgErrors = error{InvalidParameterValue};

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

    var width: usize = 100;
    var height: usize = 100;

    // parse width and height from CLI args.
    while (true) {
        const maybeArg = argIterator.next();
        if (maybeArg) |arg| {
            std.log.debug("found argument {s}", .{arg});
            if (std.mem.eql(u8, arg, "--width")) {
                width = try std.fmt.parseInt(usize, argIterator.next() orelse "0", 10);
            }
            if (std.mem.eql(u8, arg, "--height")) {
                height = try std.fmt.parseInt(usize, argIterator.next() orelse "0", 10);
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

    try bw.flush(); // don't forget to flush!
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
