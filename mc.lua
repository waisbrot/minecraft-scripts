-- miner-controller

local log = libnjw.log
local success = libnjw.success
local PROTOCOL = "remine"

local function do_status(host)
  log("Asking " .. host .. " for status")
  local request = { command = "status" }
  rednet.send(host, request, PROTOCOL)
  log("Waiting for reply")
  local _, response = rednet.receive(PROTOCOL, 5)
  success(inspect.dump(response))
end

local function do_come_here(host)
  log("Finding current position")
  local x, y, z = gps.locate(5)
  local target = libturtle.Position:new(math.floor(x), math.floor(y), math.floor(z), "n")
  log("Asking " .. host .. " to come to " .. target:tostring())
  local request = { command = "moveTo", destination = target }
  rednet.send(host, request, PROTOCOL)
  log("Waiting for reply")
  local _, response = rednet.receive(PROTOCOL, 5)
  success(inspect.dump(response))
end

local function gps_callback(name, key)
  local x, y, z = gps.locate(5)
  if name:sub(1, 1) == "x" then return {string = tostring(x)}
  elseif name:sub(1, 1) == "y" then return {string = tostring(y)}
  elseif name:sub(1, 1) == "z" then return {string = tostring(z)}
  else error("Bad field name")
  end
end

local function read_coordinates_live()
  local cform = form.Form:new()
  local items = {
    {x = nil, y = nil, z = nil},
    {x = nil, y = nil, z = nil},
  }
  local callbacks = {}
  callbacks[keys.g] = gps_callback
  for i=1,#items do
    for _,j in pairs({"x", "y", "z"}) do
      items[i][j] = form.Item:new(j .. tostring(i), {keys.g}, gps_callback)
      cform:add(items[i][j])
    end
  end
  cform:display()
  local result = {}
  for i=1,#items do
    local pos = libturtle.Position:new(math.floor(tonumber(items[i].x.value)),
                                       math.floor(tonumber(items[i].y.value)),
                                       math.floor(tonumber(items[i].z.value)))
    table.insert(result, pos)
  end
  return result
end

local function do_dig_cube(host)
  local coordinates = read_coordinates_live()
  log("Asking " .. host .. " to dig a cube " .. inspect.dump(coordinates))
  local request = { command = "digCube", points = coordinates }
  rednet.send(host, request, PROTOCOL)
  log("Waiting for reply")
  local _, response = rednet.receive(PROTOCOL, 5)
  success(inspect.dump(response))
end

local commands = {
  ["status"] = do_status,
  ["come here"] = do_come_here,
  ["dig cube"] = do_dig_cube,
}

function main()
  local main_menu = menu.Menu:new()
  main_menu:add("status")
  main_menu:add("come here")
  main_menu:add("dig cube")

  local selection = main_menu:display()
  assert(selection)
  log("--> " .. selection)

  local modem_side = libnjw.find_modem()
  assert(modem_side)
  rednet.open(modem_side)
  local host = rednet.lookup(PROTOCOL)
  assert(host, "No host found for " .. PROTOCOL)

  commands[selection](host)
end

main()
