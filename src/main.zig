const std = @import("std");
const QueueMaker = @import("./structures.zig.zig");
const stdPrint = std.debug.print;

const TokenQueue = QueueMaker.Queue(u8);

const BrainFuckingErrors = error{
    LOOP_NOT_INITALIZED,
    LOOP_NOT_TERMINATED,
};

const tokens = enum(c_char) {
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
            tokens.INCREASE => self.increseCurrentCell(),
            tokens.DECREASE => self.decreseCurrentCell(),
            tokens.MOVE_LEFT => self.movePointerLeft(),
            tokens.MOVE_RIGHT => self.movePointerRight(),
            tokens.PRINT => self.printCurrentCell(),
            else => {},
        }
    }
};

pub fn main() BrainFuckingErrors!void {
    var brainfuck: BF_array = .{};

    const reader_flag = std.fs.File.OpenFlags{ .mode = .read_only };
    const file = try std.fs.cwd().openFile("test.bf", reader_flag);
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buff: [1]u8 = undefined;
    while (try in_stream.read(&buff) > 0) {
        brainfuck.execute(buff[0]);
    }

    stdPrint("\n", .{});
}
