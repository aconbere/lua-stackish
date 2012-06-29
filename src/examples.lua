local stackish = require("stackish")

local print_stack     = stackish.print_stack
local serialize_table = stackish.serialize_table
local parse           = stackish.parse

local stack1 = parse([[ [ "abcd" [ "1234 " 5678 454.234 root things ]])
local stack2 = parse([[ [ [ "hello" 1 child root ]])

print_stack(stack1)

print("")

print_stack(stack2)

print("")

print(serialize_table(stack1))
print(serialize_table(stack2))
