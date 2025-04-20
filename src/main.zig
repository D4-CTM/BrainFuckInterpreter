const std = @import("std");
const File = std.fs.File;
const stdPrint = std.debug.print;

const BrainFuckingErrors = error{
    LOOP_NOT_INITALIZED,
    LOOP_NOT_TERMINATED,
};

const Tokens = enum(c_char) {
    const MOVE_LEFT = '<';
    const MOVE_RIGHT = '>';
    const INCREASE = '+';
    const DECREASE = '-';
    const LOOP_START = '[';
    const LOOP_END = ']';
    const PRINT = '.';
    const SCAN = ',';
};

// BrainFuck cell
const BF_cell = struct {
    content: u8 = 0,

    pub fn increment(self: *BF_cell) void {
        if (self.content == 255) {
            self.content = 0;
            return;
        }
        self.content += 1;
    }

    pub fn decrease(self: *BF_cell) void {
        if (self.content == 0) {
            self.content = 255;
            return;
        }
        self.content -= 1;
    }
};

// BrainFuck table & pointer
const BF_array = struct {
    cells: [30000]BF_cell = undefined,
    cell_pointer: u32 = 0,

    pub fn movePointerLeft(self: *BF_array) void {
        if (self.cell_pointer == 0) {
            self.cell_pointer = self.cells.len;
            return;
        }
        self.cell_pointer -= 1;
    }

    pub fn movePointerRight(self: *BF_array) void {
        if (self.cell_pointer == self.cells.len) {
            self.cell_pointer = 0;
            return;
        }
        self.cell_pointer += 1;
    }

    pub fn printCurrentCell(self: *BF_array) void {
        const pointer: u32 = self.cell_pointer;
        stdPrint("{c}", .{self.cells[pointer].content});
    }

    pub fn increseCurrentCell(self: *BF_array) void {
        const pointer: u32 = self.cell_pointer;
        self.cells[pointer].increment();
    }

    pub fn decreseCurrentCell(self: *BF_array) void {
        const pointer: u32 = self.cell_pointer;
        self.cells[pointer].decrease();
    }

    pub fn getCurrentCell(self: *BF_array) BF_cell {
        const pointer: u32 = self.cell_pointer;
        return self.cells[pointer];
    }

    pub fn execute(self: *BF_array, action: u8) void {
        switch (action) {
            Tokens.INCREASE => self.increseCurrentCell(),
            Tokens.DECREASE => self.decreseCurrentCell(),
            Tokens.MOVE_LEFT => self.movePointerLeft(),
            Tokens.MOVE_RIGHT => self.movePointerRight(),
            Tokens.PRINT => self.printCurrentCell(),
            else => {},
        }
    }
};

fn brainfuckLoop(file: *File, brainfuck: *BF_array, startPos: u32) !u32 {
    var buff: [1]u8 = undefined;
    var index: u32 = startPos;

    while (try file.read(&buff) > 0) {
        if (buff[0] == Tokens.LOOP_START) {
            index = brainfuckLoop(file, brainfuck, index + 1) catch |err| {
                return err;
            };

            try file.seekTo(index);
        } else if (buff[0] == Tokens.LOOP_END) {
            if (startPos == 0) {
                return BrainFuckingErrors.LOOP_NOT_INITALIZED;
            }

            if (brainfuck.getCurrentCell().content != 0) {
                return startPos - 1;
            }

            return index + 1;
        } else {
            brainfuck.execute(buff[0]);
            index += 1;
        }
    }
    if (startPos != 0) {
        return BrainFuckingErrors.LOOP_NOT_TERMINATED;
    }

    return index;
}

pub fn main() !void {
    var args = std.process.args();
    var brainfuck: BF_array = .{};

    _ = args.next();
    while (args.next()) |file_path| {
        const reader_flag = std.fs.File.OpenFlags{ .mode = .read_only };
        var file = try std.fs.cwd().openFile(file_path, reader_flag);
        defer file.close();

        _ = brainfuckLoop(&file, &brainfuck, 0) catch |err| {
            switch (err) {
                BrainFuckingErrors.LOOP_NOT_INITALIZED => {
                    stdPrint("Crash!\nTried to end a loop without being in one!", .{});
                },

                BrainFuckingErrors.LOOP_NOT_TERMINATED => {
                    stdPrint("Crash!\nA loop was started but not finished!", .{});
                },

                else => {},
            }
        };

        stdPrint("\n", .{});
    }
}
