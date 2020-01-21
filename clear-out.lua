local MAX_PATH_PRINT = 10

function newline(win)
  win = win or term
  local _,cY = win.getCursorPos()
  win.setCursorPos(1, cY+1)
end

function log(msg)
  term.setTextColor(colors.cyan)
  print(msg)
end

function Coordinates(cx, cy, cz)
  return {
    x = cx
    y = cy
    z = cz
  }
end

-- north: -Z
-- west: -X

local facing = nil
local position = Coordinates(nil, nil, nil)

function update_pos(distance)
  if facing == "n" then position.z = position.z - distance
  elseif facing == "s" then position.z = position.z + distance
  elseif facing == "w" then position.x = position.x - distance
  elseif facing == "e" then position.x = position.x + distance
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
  position.x, position.y, position.z = gps.locate(10)
  assert(position.x, "GPS location failed!")
  log("Find facing...")
  assert(turtle.forward(), "No space in front of the turtle! Start the turtle with an empty space in front of it.")
  local xp, yp, zp = gps.locate(10)
  assert(xp, "GPS second location failed!")
  if xp < position.x then
    facing = "w"
  elseif xp > position.x then
    facing = "e"
  elseif zp < position.z then
    facing = "n"
  elseif zp > position.z then
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

function path_to(dest)
  local path = {}

  while dest.y > position.y do
    table.insert(path, "u")
    dest.y = dest.y - 1
  end
  while dest.y < position.y do
    table.insert(path, "d")
    dest.y = dest.y + 1
  end

  while dest.z > position.z do
    table.insert(path, "s")
    dest.z = dest.z - 1
  end
  while dest.z < position.z do
    table.insert(path, "n")
    dest.z = dest.z + 1
  end

  while dest.x > position.x do
    table.insert(path, "e")
    dest.x = dest.x - 1
  end
  while dest.x < position.x do
    table.insert(path, "w")
    dest.x = dest.x + 1
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
  log("move from " .. stringify_coordinates(position) .. " to " .. stringify_coordinates(dest)
  local path = path_to(dest)
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
  local start = Coordinates(x, y, z)
  if facing == "n" or facing == "s" then dig_rows(wx, wz)
  else dig_rows(wz, wx)
  end
  move_to(start)
end

dig_space(tonumber(arg[1]), tonumber(arg[2]), tonumber(arg[3]))
