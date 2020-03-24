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
  log("dig_step(" .. want .. ")")
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
  for _, step in pairs(path) do
    dig_step(step)
  end
end

function dig_x_out()
  -- dig +x all the way
  libturtle.change_facing("e")
  while pos.x <= pos_max.x do
    dig_forward()
  end
end

function dig_z_one()
  -- dig z+1
  libturtle.change_facing("s")
  dig_forward()
end

function dig_x_out_and_back()
  dig_x_out()
  -- dig +z one step
  dig_z_one()
  -- dig -x all the way
  libturtle.change_facing("w")
  while pos.x >= pos_min.x do
    dig_forward()
  end
end

local function dig_cube_main()
  while pos.y <= pos_max.y do
    log("dig y = " .. tostring(pos.y))
    local start_pos = pos:clone()
    while pos.z <= (pos_max.z - 1) do
      log("dig z = " .. tostring(pos.z))
      dig_x_out_and_back()
      if pos.z < pos_max.z then
        -- dig +z one step to prep for next move
        dig_z_one()
      end
    end
    if pos.z == pos_max.z then
      -- dig a half-row
      dig_x_out()
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

local FILENAME = "/saved_dig.lua"

local function save_dig()
  local outstring = string.format("saved_dig = {\n pos_min = %s,\n pos_max = %s,\n y = %d,\n}\n", pos_min:serialize(), pos_max:serialize(), pos.y)
  local fh = assert(io.open(FILENAME, "w"))
  fh:write(outstring)
  fh:close()
end

function dig_cube(pmin, pmax, jump_y)
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
  local initial_y = pos.y
  while jump_y and jump_y > pos.y do
    libturtle.up()
  end
  local success, msg = pcall(dig_cube_main)
  if not success then
    save_dig()
  end
  log("return to starting level")
  local dest = pos:clone()
  dest.y = initial_y
  libturtle.move_to(dest)
  if not success then
    error(msg)
  end
end

function maybe_resume_digging()
  local fh = io.open(FILENAME, "r")
  if fh then
    local codestr = fh:read("*all")
    fh:close()
    local code, msg = loadstring(codestr)
    assert(code, "Failed to load saved dig: " .. tostring(msg))
    code()
    log("Resuming dig")
    dig_cube(libturtle.Position:new(saved_dig.pos_min), libturtle.Position:new(saved_dig.pos_max))
  end
end
