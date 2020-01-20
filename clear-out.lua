function newline(win)
  win = win or term
  local _,cY = win.getCursorPos()
  win.setCursorPos(1, cY+1)
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
  else error("Invalid facing")
  end
end

-- forward or error
function forward(err_msg)
  err_msg = err_msg or "Cannot move forward!"
  turtle.forward() or error(err_msg)
  update_pos(1)
end

-- back or error
function back(err_msg)
  err_msg = err_msg or "Cannot move back!"
  turtle.back() or error(err_msg)
  update_pos(-1)
end

-- up or error
function up(err_msg)
  err_msg = err_msg or "Cannot move up!"
  turtle.up() or error(err_msg)
  y = y + 1
end

-- down or error
function down(err_msg)
  err_msg = err_msg or "Cannot move down!"
  turtle.down() or error(err_msg)
  y = y - 1
end

-- fill in the turtle's facing and absolute position
function orient()
  x, y, z = gps.locate(10)
  x or error("GPS location failed!")
  forward("No space in front of the turtle! Start the turtle with an empty space in front of it.")
  local xp, yp, zp = gps.locate(10)
  xp or error("GPS second location failed!")
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
  back()
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
  turtle.turnLeft()
  dig_forward()
  turtle.turnLeft()
  dig_row(size)
  turtle.turnRight()
  dig_forward()
  turtle.turnRight()
end

function dig_rows(count, length)
  for i=1,(count/2) do
    dig_out_back(length)
  end
end

function dig_space(wx, wy, wz)
  wy >= 3 or error("Must be at least 3 blocks high")
  wy == 3 or error("Larger than height 3 unimplemented")
  orient()
  local found, item = turtle.inspectDown()
  found or error("Need to start hovering over a chest")
  item.name == "minecraft:chest" or error("Need to start hovering over a chest")
  local sx, sy, sz = x, y, z
  if facing == "north" or facing == "south" then dig_rows(wx, wz)
  else dig_rows(wz, wx)
  end
end

dig_space(tonumber(arg[1]), tonumber(arg[2]), tonumber(arg[3]))
