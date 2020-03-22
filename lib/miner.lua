-- min and max positions as a bounding cube, set by dig_cube
local pos_max
local pos_min
local pos = libturtle.position
local log = libnjw.log

-- when digging forward, also dig up and down?
-- assume we'll set anddown manually, but set andup when using dig_up
local andup = false
local anddown = false

function dig_forward()
  while libturtle.dig_forward() do end
  libturtle.forward()
  if andup then
    libturtle.dig_up()
  end
  if anddown then
    libturtle.dig_down()
  end
end

function dig_up()
  libturtle.dig_up()
  libturtle.up()
  if pos.y < pos_max.y then
    andup = true
  else
    andup = false
  end
end

function dig_down()
  libturtle.dig_down()
  libturtle.down()
end

function dig_step(want)
  if want == "u" then dig_up()
  elseif want == "d" then dig_down()
  else
    andup = false
    anddown = false
    libturtle.change_facing(want)
    dig_forward()
  end
end

function dig_to(dest)
  local path = pos:path_to(dest)
  log("path = " .. libturtle.stringify_path(path))
  for _, step in path do
    dig_step(step)
  end
end

function dig_z_out()
  -- dig +z all the way
  libturtle.change_facing("s")
  while pos.z <= pos_max.z do
    dig_forward()
  end
end

function dig_x_one()
  -- dig x+1
  libturtle.change_facing("e")
  dig_forward()
end

function dig_z_out_and_back()
  dig_z_out()
  -- dig +x one step
  dig_x_one()
  -- dig -z all the way
  libturtle.change_facing("n")
  while pos.z >= pos_min.z do
    dig_forward()
  end
end

function dig_cube(pmin, pmax)
  pos_min = pmin
  pos_max = pmax
  pos_min.facing = pos_min.facing or "s"
  pos_max.facing = pos_max.facing or "s"
  log("Going to start")
  dig_to(pos_min)
  if pos_min.y < pos_max.y then
    log("up one from the floor")
    dig_up()
    anddown = true
  end
  while pos.y <= pos_max.y do
    log("dig y = " .. tostring(pos.y))
    local start_pos = pos:clone()
    while pos.x <= (pos_max.x - 1) do
      log("dig x = " .. tostring(pos.x))
      dig_z_out_and_back()
      if pos.x < pos_max.x then
        -- dig +x one step to prep for next move
        dig_x_one()
      end
    end
    if pos.x < pos_max.x then
      -- dig a half-row
      dig_z_out()
    end
    -- this whole level is clear, reset position and move up
    libturtle.move_to(start_pos)
    if pos.y + 1 >= pos_max.y then
      -- we've already cleared y by digging above us
      break
    elseif pos.y + 3 <= pos_max.y then
      -- +1 is already clear. +2 will be cleared by dig_down and +3 will be cleared by dig_forward
      -- +4 will be cleared by dig_up if needed
      dig_up()
      dig_up()
      dig_up()
    elseif pos.y + 2 == pos_max.y then
      -- up 3 would be too far an up 1 is already clear. Move up 1 and handle it with dig_up
      anddown = false
      dig_up()
    end
  end
end
