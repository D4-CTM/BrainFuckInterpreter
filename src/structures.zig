const std = @import("std");
const assert = std.debug.assert;
const testing = std.testing;

pub fn Queue(comptime T: type) type {
    return struct {
        const Self = @This();

        pub const Node = struct {
            nextNode: ?*Node = null,
            data: T,

            pub const DataType = T;
        };

        First: ?*Node = null,
        Last: ?*Node = null,

        pub fn push(self: *Self, newNode: ?*Node) void {
            if (self.isEmpty()) {
                self.First = newNode;
                self.Last = newNode;
            } else {
                self.Last.?.nextNode = newNode;
                self.Last = newNode;
            }
        }

        pub fn pop(self: *Self) ?*Node {
            const first = self.First orelse return null;
            self.First = first.nextNode;

            if (self.First == null) {
                self.Last = null;
            }

            return first;
        }

        pub fn isEmpty(self: *Self) bool {
            return self.First == null;
        }
    };
}

test "Queue testing ground" {
    const Ch_queue = Queue(u8);
    var queue: Ch_queue = .{};

    try testing.expect(queue.First == null);
    var node1: Ch_queue.Node = .{ .data = 'a' };
    var node2: Ch_queue.Node = .{ .data = 'b' };
    var node3: Ch_queue.Node = .{ .data = 'c' };
    var node4: Ch_queue.Node = .{ .data = 'd' };

    queue.push(&node1);

    try testing.expect(queue.First != null);
    try testing.expect(queue.First == queue.First);
    std.debug.print("Data at first queue node: {c}\n", .{queue.First.?.data});

    queue.push(&node2);
    queue.push(&node3);
    queue.push(&node4);

    std.debug.print("data at first node: {c}\n", .{queue.First.?.data});
    try testing.expect(queue.First.?.data == 'a');
    try testing.expect(queue.Last.?.data == 'd');

    while (!queue.isEmpty()) {
        const pNode = queue.pop();
        try testing.expect(pNode != null);
        std.debug.print("data: {c}\n", .{pNode.?.data});
    }

    try testing.expect(queue.isEmpty());
    try testing.expect(queue.Last == queue.First);
}

pub fn Stack(comptime T: type) type {
    return struct {
        const Self = @This();

        pub const Node = struct {
            nextNode: ?*Node = null,
            data: T,

            pub const DataType = T;
        };

        First: ?*Node = null,

        pub fn push(self: *Self, newNode: *Node) void {
            newNode.nextNode = self.First;
            self.First = newNode;
        }

        pub fn pop(self: *Self) ?*Node {
            const first = self.First orelse return null;
            self.First = first.nextNode;

            return first;
        }

        pub fn isEmpty(self: *Self) bool {
            return self.First == null;
        }
    };
}

test "Stack testing ground" {
    const Ch_stack = Stack(u8);
    var stack: Ch_stack = .{};

    try testing.expect(stack.isEmpty());
    var node1: Ch_stack.Node = .{ .data = 'a' };
    var node2: Ch_stack.Node = .{ .data = 'b' };
    var node3: Ch_stack.Node = .{ .data = 'c' };
    var node4: Ch_stack.Node = .{ .data = 'd' };

    stack.push(&node1);

    try testing.expect(stack.First != null);
    std.debug.print("\nData at first stack node: {c}\n", .{stack.First.?.data});

    stack.push(&node2);
    stack.push(&node3);
    stack.push(&node4);

    std.debug.print("data at first node: {c}\n", .{stack.First.?.data});
    try testing.expect(stack.First.?.data == 'd');

    while (!stack.isEmpty()) {
        const pNode = stack.pop();
        try testing.expect(pNode != null);
        std.debug.print("data: {c}\n", .{pNode.?.data});
    }

    try testing.expect(stack.isEmpty());
}
