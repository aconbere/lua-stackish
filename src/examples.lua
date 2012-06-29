local stackish = require("stackish")

local print_table = stackish.print_table
local parse = stackish.parse
print_table(parse([[ [ "abcd" [ "1234 " 5678 454.234 root things ]]))
print_table(parse([[ [ [ "hello" 1 child root ]]))
