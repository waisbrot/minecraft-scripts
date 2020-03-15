local CubeBase = {
  points = {libturtle.Position:new(), libturtle.Position:new()},
  wins = {nil, nil},
}

Cube = CubeBase

function Cube:new()
  local o = table.clone(CubeBase)
  setmetatable(o, self)
  self.__index = self
  return o
end

function Cube:tostring()
  local p1, p2
  if self.points[1] then
    p1 = self.points[1]:tostring()
  else
    p1 = "nil"
  end
  if self.points[2] then
    p2 = self.points[2]:tostring()
  else
    p2 = "nil"
  end
  return "P1: " .. p1 .. "; P2: " .. p2
end

function Cube:set_via_gps(index, facing)
  assert(index)
  assert(index >= 1)
  assert(index <= 2)
  if facing == nil then
    facing = "n"
  end
  local x, y, z = gps.locate(10)
  self:modify_point(index, "x", math.floor(x))
  self:modify_point(index, "y", math.floor(y))
  self:modify_point(index, "z", math.floor(z))
  self:modify_point(index, "facing", facing)
end

function Cube:modify_point(index, dimension, value)
  assert(index)
  assert(index >= 1)
  assert(index <= 2)
  assert(dimension)
  assert(value)
  self.points[index][dimension] = value
end

local function draw_prompts(win)
  win.setTextColor(colors.yellow)
  win.setCursorPos(1, 1)
  win.write("x:")
  win.setCursorPos(1, 2)
  win.write("y:")
  win.setCursorPos(1, 3)
  win.write("z:")
  win.setCursorPos(1, 4)
  win.write("f:")
end

local KEY_TO_CHAR = {
  keys.one = "1",
  keys.two = "2",
  keys.three = "3",
  keys.four = "4",
  keys.five = "5",
  keys.six = "6",
  keys.seven = "7",
  keys.eight = "8",
  keys.nine = "9",
  keys.zero = "0",
}

function define_interactively()
  local cube = Cube:new()
  local w, h = term.getSize()
  w = math.floor((w/2) - 2)
  term.setCursorPos(1, 1)
  term.setTextColor(colors.lime)
  term.write("Tab to cycle fields, 'g' to use GPS")
  cube.wins[1] = window.create(term.current(), 1, 3, w, h)
  cube.wins[2] = window.create(term.current(), w + 3, 1, w, h)
  draw_prompts(cub.wins[1])
  draw_prompts(cub.wins[2])
  local current_win = 1
  local current_line = 1
  local continue = true
  while continue do
    local _, k = os.pullEvent("key")
    if k == keys.tab then
      if current_line == 4 then
        if current_win = 1 then
          current_win = 2
        else
          current_win = 1
        end
        current_line = 1
      else
        current_line = current_line + 1
      end
    elseif k > 
    end
  end
end
