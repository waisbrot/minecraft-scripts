function newline(win)
  win = win or term
  local _,cY = win.getCursorPos()
  win.setCursorPos(1, cY+1)
end

function log(msg)
  term.setTextColor(colors.cyan)
  print(msg)
end

-- north: -Z
-- west: -X

local facing = nil
local x, y, z = nil, nil, nil

function update_pos(distance)
  if facing == "north" then z = z - distance
  elseif facing == "south" then z = z + distance
  elseif facing == "west" then x = x - distance
  elseif facing == "east" then x = x + distance
  else error("Invalid facing: " .. facing)
  end
end

-- forward or error
function forward(err_msg)
  err_msg = err_msg or "Cannot move forward!"
  assert(turtle.forward(), err_msg)
  update_pos(1)
end

-- back or error
function back(err_msg)
  err_msg = err_msg or "Cannot move back!"
  assert(turtle.back(), err_msg)
  update_pos(-1)
end

-- up or error
function up(err_msg)
  err_msg = err_msg or "Cannot move up!"
  assert(turtle.up(), err_msg)
  y = y + 1
end

-- down or error
function down(err_msg)
  err_msg = err_msg or "Cannot move down!"
  assert(turtle.down(), err_msg)
  y = y - 1
end

function left()
  assert(turtle.turnLeft(), "Failed to turn left")
  if facing == "north" then facing = "west"
  elseif facing == "west" then facing = "south"
  elseif facing == "south" then facing = "east"
  elseif facing == "east" then facing = "north"
  else error("Invalid facing: " .. facing)
  end
end

function right()
  assert(turtle.turnRight(), "Failed to turn right")
  if facing == "north" then facing = "east"
  elseif facing == "west" then facing = "north"
  elseif facing == "south" then facing = "west"
  elseif facing == "east" then facing = "south"
  else error("Invalid facing: " .. facing)
  end
end

-- fill in the turtle's facing and absolute position
function orient()
  log("Locating...")
  x, y, z = gps.locate(10)
  assert(x, "GPS location failed!")
  log("Find facing...")
  assert(turtle.forward(), "No space in front of the turtle! Start the turtle with an empty space in front of it.")
  local xp, yp, zp = gps.locate(10)
  assert(xp, "GPS second location failed!")
  if xp < x then
    facing = "west"
  elseif xp > x then
    facing = "east"
  elseif zp < z then
    facing = "north"
  elseif zp > z then
    facing = "south"
  else
    error("Unable to determine turtle's facing")
  end
  log("Return to start")
  back()
  log("Ready!")
end

function dig_forward()
  turtle.dig()
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

function dig_space(wx, wy, wz)
  assert(wy >= 3, "Must be at least 3 blocks high")
  assert(wy == 3, "Larger than height 3 unimplemented")
  orient()
  local found, item = turtle.inspectDown()
  assert(found, "Need to start hovering over a chest")
  assert(item.name == "minecraft:chest", "Need to start hovering over a chest")
  local sx, sy, sz = x, y, z
  if facing == "north" or facing == "south" then dig_rows(wx, wz)
  else dig_rows(wz, wx)
  end
end

dig_space(tonumber(arg[1]), tonumber(arg[2]), tonumber(arg[3]))
