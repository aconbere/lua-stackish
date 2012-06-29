local quotes = { ["\""] = true,
                 ["\'"] = true,
               }

local numerals = { ["0"] = true
                 , ["1"] = true
                 , ["2"] = true
                 , ["3"] = true
                 , ["4"] = true
                 , ["5"] = true
                 , ["6"] = true
                 , ["7"] = true
                 , ["8"] = true
                 , ["9"] = true
                 }

local whitespace = { [""]   = true
                   , [" "]  = true
                   , ["\t"] = true
                   , ["\n"] = true
                   , ["\r"] = true
                   }

local types = { mark   = { name = "mark" }
              , string = { name = "string" }
              , number = { name = "number" }
              , word   = { name = "word" }
              }

do
  local function mktype(t, value)
    return { value = value
           , __type = types[t]
           }
  end

  for i, t in pairs({ "mark", "string", "number", "word" }) do
    types["mk"..t] = function(value) return mktype(t, value) end
  end

end

local function print_element(v)
  print("el", v.__type.name, v.value)
end

local function print_stack(t)
  for i,v in pairs(t) do
    print_element(v)
  end
end

local function print_table(t, depth)
  if not depth then
    depth = 0
  end

  for i,v in pairs(t) do
    if type(v) == "table" then
      print(string.rep(" ", depth)..tostring(i)..":")
      print_table(v, depth+1)
    elseif type(v) == "string" then
      print(string.rep(" ", depth).."\""..v.."\"")
    else
      print(string.rep(" ", depth)..tostring(v))
    end
  end
end

local function peak(s)
  if #s == 0 then
    return nil
  else
    return s:sub(1,1)
  end
end

local function tail(s)
  return s:sub(2, #s)
end

local function chomp(s)
  local p = peak(s)

  if whitespace[p] then
    return chomp(tail(s))
  else
    return s
  end
end

local function take_until(input, u, output)
  c = peak(input)
  assert(c, "not found: "..u)

  if not output then
    output = ""
  end

  if c == u then
    return output, tail(input)
  else
    return take_until(tail(input), u, output..c)
  end
end

local function tokenize_string(input)
  local c = peak(input)
  assert(quotes[c], "not a string")
  local str, rest = take_until(tail(input), c)
  return types.mkstring(str), rest
end

local function tokenize_number(input, output)
  if not output then
    output = ""
  end

  p = peak(input)

  if (p == nil) or whitespace[p] then
    return types.mknumber(tonumber(output)), tail(input)
  else
    assert(numerals[p] or (p == "."), "Invalid number")
    return tokenize_number(tail(input), output..p)
  end
end

local function tokenize_word(input, output)
  if not output then
    output = ""
  end

  p = peak(input)

  if (p == nil) or whitespace[p] then
    return types.mkword(output), tail(input)
  else
    return tokenize_word(tail(input), output..p)
  end
end

local function tokenize(input, stack)
  if not stack then
    stack = {}
  end

  local c = peak(input)

  if not c then
    return stack
  end

  if c == "[" then
    table.insert(stack, types.mkmark(c))
    return tokenize(tail(input), stack)
  elseif whitespace[c] then
    return tokenize(chomp(input), stack)
  elseif quotes[c] then
    local str, rest = tokenize_string(input)
    table.insert(stack, str)
    return tokenize(rest, stack)
  elseif numerals[c] then
    local number, rest = tokenize_number(input)
    table.insert(stack, number)
    return tokenize(rest, stack)
  else
    word, rest = tokenize_word(input)
    table.insert(stack, word)
    return tokenize(rest, stack)
  end
end

local function map(itterable, f)
  res = {}
  for i,v in ipairs(itterable) do
    table.insert(res, f(v))
  end
  return res
end

local function parse_ast(ast, stack, depth)
  if #ast <= 0 then
    return nil, stack
  end

  local current = table.remove(ast, 1)

  if current.__type == types.word then
    return current.value, stack
  elseif current.__type == types.mark then
    local name, _stack = parse_ast(ast, {}, depth+1)
    stack[name] = _stack
  else
    table.insert(stack, current.value)
  end

  return parse_ast(ast, stack, depth)
end

local function parse(input)
  _name, stack = parse_ast(tokenize(input), {}, 0)
  return stack
end

local function serialize_string(value)
  return "\""..value.."\""
end

local function serialize_number(value)
  return tostring(value)
end

local function serialize_table(value)
  stack = {}
  for i,v in pairs(value) do
    local typei = type(i)
    local typev = type(v)

    if typei == "number" then
      if typev == "string" then
        table.insert(stack, serialize_string(v))
      elseif typev == "number" then
        table.insert(stack, serialize_number(v))
      end
    elseif typei == "string" then
      if typev == "table" then
      else
      end
    end
  end
end

return { print_table = print_table
       , parse       = parse
       , tokenize    = tokenize
       }
