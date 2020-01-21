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
  if facing == "n" then z = z - distance
  elseif facing == "s" then z = z + distance
  elseif facing == "w" then x = x - distance
  elseif facing == "e" then x = x + distance
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
  if facing == "n" then facing = "w"
  elseif facing == "w" then facing = "s"
  elseif facing == "s" then facing = "e"
  elseif facing == "e" then facing = "n"
  else error("Invalid facing: " .. facing)
  end
end

function right()
  assert(turtle.turnRight(), "Failed to turn right")
  if facing == "n" then facing = "e"
  elseif facing == "w" then facing = "n"
  elseif facing == "s" then facing = "w"
  elseif facing == "e" then facing = "s"
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
    facing = "w"
  elseif xp > x then
    facing = "e"
  elseif zp < z then
    facing = "n"
  elseif zp > z then
    facing = "s"
  else
    error("Unable to determine turtle's facing")
  end
  log("Return to start")
  back()
  log("Ready!")
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

function path_to(dx, dy, dz)
  local path = {}

  while dy > y do
    table.insert(path, "u")
    dy = dy - 1
  end
  while dy < y do
    table.insert(path, "d")
    dy = dy + 1
  end

  while dz > z do
    table.insert(path, "s")
    dz = dz - 1
  end
  while dz < z do
    table.insert(path, "n")
    dz = dz + 1
  end

  while dx > x do
    table.insert(path, "e")
    dx = dx - 1
  end
  while dx < x do
    table.insert(path, "w")
    dx = dx + 1
  end

  return path
end

function about_face()
  left()
  left()
end

function change_facing(want)
  if want == facing then return
  elseif facing == "e" then
    if want == "w" then about_face()
    elseif want == "n" then left()
    elseif want == "s" then right()
    else error("bad facing")
    end
  elseif facing == "n" then
    if want == "s" then about_face()
    elseif want == "e" then right()
    elseif want == "w" then left()
    else error("bad facing")
    end
  elseif facing == "w" then
    if want == "e" then about_face()
    elseif want == "s" then left()
    elseif want == "n" then right()
    else error("bad facing")
    end
  elseif facing == "s" then
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

function stringify_coordinates(c)
  return "(" .. c[1] .. "," .. c[2] .. "," .. c[3] .. ")"
end

function stringify_path(p)
  if #p == 0 then
    return ""
  end
  local buff = p[1]
  for i=2,#p do
    buff = buff .. ", " .. p[i]
  end
  return buff
end

function move_to(tx, ty, tz)
  log("move to " .. stringify_coordinates({tx, ty, tz}))
  local path = path_to(tx, tz, tz)
  log("path: " .. stringify_path(path))
  for n=1,#path do
    log("move: " .. path[n])
    move_step(path[n])
  end
end

function dig_space(wx, wy, wz)
  assert(wy >= 3, "Must be at least 3 blocks high")
  assert(wy == 3, "Larger than height 3 unimplemented")
  orient()
--  local found, item = turtle.inspectDown()
--  assert(found, "Need to start hovering over a chest")
--  assert(item.name == "minecraft:chest", "Need to start hovering over a chest")
  local sx, sy, sz = x, y, z
  if facing == "n" or facing == "s" then dig_rows(wx, wz)
  else dig_rows(wz, wx)
  end
  move_to(sx, sy, sz)
end

dig_space(tonumber(arg[1]), tonumber(arg[2]), tonumber(arg[3]))
