-- miner-controller

local log libnjw.log
local success libnjw.success
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

local commands = {
  ["status"] = do_status,
  ["come here"] = do_come_here,
}

function main()
  local main_menu = menu.Menu:new()
  main_menu:add("status")
  main_menu:add("come here")
  main_menu:add("dig cube")

  local selection = main_menu:display()
  assert(selection)

  local modem_side = libnjw.find_modem()
  assert(modem_side)
  rednet.open(modem_side)
  local host = rednet.lookup(PROTOCOL)
  assert(host)

  commands[selection](host)
end

main()
