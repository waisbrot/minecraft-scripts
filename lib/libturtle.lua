local log = libnjw.log

Position = {
  x = nil,
  y = nil,
  z = nil,

  -- north: -Z
  -- west: -X
  facing = nil,
}

function Position:new(x, y, z, facing)
  local o = {x = x, y = y, z = z, facing = facing}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Position:clone()
  return Position:new(self.x, self.y, self.z)
end

function Position:tostring()
  return "(" .. tostring(self.x) .. "," .. tostring(self.y) .. "," .. tostring(self.z) .. ")" .. ":" .. tostring(self.facing)
end

position = Position:new()

function Position:validate()
  assert(self.x ~= nil, "nil x")
  assert(self.y ~= nil, "nil y")
  assert(self.z ~= nil, "nil z")
  assert(self.facing ~= nil, "nil facing")
end

function Position:update_from_move(distance)
  if self.facing == "n" then self.z = self.z - distance
  elseif self.facing == "s" then self.z = self.z + distance
  elseif self.facing == "w" then self.x = self.x - distance
  elseif self.facing == "e" then self.x = self.x + distance
  else error("Invalid facing: " .. tostring(self.facing)
  end
end

function Position:turn_left()
  if self.facing == "n" then self.facing = "w"
  elseif self.facing == "w" then self.facing = "s"
  elseif self.facing == "s" then self.facing = "e"
  elseif self.facing == "e" then self.facing = "n"
  else error("Invalid facing: " .. tostring(self.facing))
  end
end

function Position:turn_right()
  if self.facing == "n" then self.facing = "e"
  elseif self.facing == "w" then self.facing = "n"
  elseif self.facing == "s" then self.facing = "w"
  elseif self.facing == "e" then self.facing = "s"
  else error("Invalid facing: " .. tostring(self.facing))
  end
end

function Position:path_to(dest)
  self:validate()
  dest:validate()

  local path = {}
  local bpath = dest:clone()

  while bpath.y > self.y do
    table.insert(path, "u")
    bpath.y = bpath.y - 1
  end
  while bpath.y < self.y do
    table.insert(path, "d")
    bpath.y = bpath.y + 1
  end

  while bpath.z > self.z do
    table.insert(path, "s")
    bpath.z = bpath.z - 1
  end
  while bpath.z < self.z do
    table.insert(path, "n")
    bpath.z = bpath.z + 1
  end

  while bpath.x > self.x do
    table.insert(path, "e")
    bpath.x = bpath.x - 1
  end
  while bpath.x < self.x do
    table.insert(path, "w")
    bpath.x = bpath.x + 1
  end

  return path
end

-- forward or error
function forward(err_msg)
  err_msg = err_msg or "Cannot move forward!"
  assert(turtle.forward(), err_msg)
  position:update_from_move(1)
end

-- back or error
function back(err_msg)
  err_msg = err_msg or "Cannot move back!"
  assert(turtle.back(), err_msg)
  position:update_from_move(-1)
end

-- up or error
function up(err_msg)
  err_msg = err_msg or "Cannot move up!"
  assert(turtle.up(), err_msg)
  position.y = position.y + 1
end

-- down or error
function down(err_msg)
  err_msg = err_msg or "Cannot move down!"
  assert(turtle.down(), err_msg)
  position.y = position.y - 1
end

function left()
  assert(turtle.turnLeft(), "Failed to turn left")
  position:turn_left()
end

function right()
  assert(turtle.turnRight(), "Failed to turn right")
  position:turn_right()
end

-- fill in the turtle's facing and absolute position
function orient()
  log("Locating...")
  position.x, position.y, position.z = gps.locate(10)
  assert(position.x, "GPS location failed!")
  log("Find facing...")
  assert(turtle.forward(), "No space in front of the turtle! Start the turtle with an empty space in front of it.")
  local xp, yp, zp = gps.locate(10)
  assert(xp, "GPS second location failed!")
  if xp < position.x then
    position.facing = "w"
  elseif xp > position.x then
    position.facing = "e"
  elseif zp < position.z then
    position.facing = "n"
  elseif zp > position.z then
    position.facing = "s"
  else
    error("Unable to determine turtle's facing")
  end
  log("Return to start")
  back()
  log("Ready!")
end

-- Run orient() iff it hasn't been run since the turtle turned on
function ensure_oriented()
  if position.facing == nil then
    orient()
  else
    log("Existing orientation")
  end
end

function dig_up()
  turtle.digUp()
  up()
end

function dig_down()
  turtle.digDown()
  down()
end

function dig_forward()
  while turtle.dig() do end
  forward()
  turtle.digUp()
  turtle.digDown()
end

function dig_row(size)
  for i=1,size do
    dig_forward()
  end
end

function dig_out_back(size)
  dig_row(size)
  left()
  dig_forward()
  left()
  dig_row(size)
  right()
  dig_forward()
  right()
end

function dig_rows(count, length)
  for i=1,(count/2) do
    dig_out_back(length)
  end
end

function about_face()
  left()
  left()
end

function change_facing(want)
  if want == position.facing then return
  elseif position.facing == "e" then
    if want == "w" then about_face()
    elseif want == "n" then left()
    elseif want == "s" then right()
    else error("bad facing")
    end
  elseif position.facing == "n" then
    if want == "s" then about_face()
    elseif want == "e" then right()
    elseif want == "w" then left()
    else error("bad facing")
    end
  elseif position.facing == "w" then
    if want == "e" then about_face()
    elseif want == "s" then left()
    elseif want == "n" then right()
    else error("bad facing")
    end
  elseif position.facing == "s" then
    if want == "n" then about_face()
    elseif want == "w" then right()
    elseif want == "e" then left()
    else error("bad facing")
    end
  else error("bad facing")
  end
end

function move_step(want)
  if want == "u" then up()
  elseif want == "d" then down()
  else
    change_facing(want)
    forward()
  end
end

function stringify_path(p)
  assert(p ~= nil, "nil path")
  if #p == 0 then
    return ""
  end
  local buff = p[1]
  local len = math.min(MAX_PATH_PRINT, #p)
  for i=2,len do
    buff = buff .. ", " .. p[i]
  end
  if len == MAX_PATH_PRINT then
    buff = buff .. ", ..."
  end
  return buff
end

function move_to(dest)
  log("move from " .. position:tostring() .. " to " .. dest:tostring())
  local path = position:path_to(dest)
  log("path: " .. stringify_path(path))
  for i=1,#path do
    log("move: " .. path[i])
    move_step(path[i])
  end
end

function dig_step(want)
  if want == "u" then dig_up()
  elseif want == "d" then dig_down()
  else
    change_facing(want)
    dig_forward()
  end
end

function dig_to(dest)
  local path = path_to(dest)
  for i=1,#path do
    dig_step(path[i])
  end
end

function dig_space(wx, wy, wz)
  assert(wy >= 3, "Must be at least 3 blocks high")
  assert(wy == 3, "Larger than height 3 unimplemented")
  orient()
--  local found, item = turtle.inspectDown()
--  assert(found, "Need to start hovering over a chest")
--  assert(item.name == "minecraft:chest", "Need to start hovering over a chest")
  local start = Coordinates(position.x, position.y, position.z)
  local start_face = position.facing
  if position.facing == "n" or position.facing == "s" then dig_rows(wx, wz)
  else dig_rows(wz, wx)
  end
  move_to(start)
  change_facing(start_face)
end
