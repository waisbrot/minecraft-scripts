local MAX_PATH_PRINT = 10
local PROTOCOL = "remine"

local log = libnjw.log

function do_status(sender, message)
  reply = {
    position = libturtle.position,
  }
  log("Sending status")
  rednet.send(sender, reply, PROTOCOL)
  return true
end

function do_move_to(sender, message)
  local x, y, z, f = message[2], message[3], message[4], message[5]
  local dest = libturtle.Position:new(math.floor(x), math.floor(y), math.floor(z))
  reply = {
    destination = dest
  }
  rednet.send(sender, reply, PROTOCOL)
  libturtle.move_to(dest)
  return true
end

local commands = {
  status = do_status,
  moveTo = do_move_to,
}

function start_server(hostname)
  libturtle.ensure_oriented()
  local modem_side = libnjw.find_modem()
  assert(modem_side ~= nil, "Could not find a modem")
  print("Found modem")
  rednet.open(modem_side)
  rednet.host("remine", hostname)
  log("Registered as "..hostname)
  local continue = true
  while continue do
    log("Waiting for remote command C-T to exit")
    local sender, message, _ = rednet.receive(PROTOCOL)
    if commands[message[1]] ~= nil then
      log("Command '" .. message[1] .. "' from " .. sender)
      continue = commands[message[1]](sender, message)
    else
      log("Invalid message from " .. sender .. ": " .. inspect.dump(message))
    end
  end
end

function main(hostname)
  start_server(hostname)
end

assert(#arg == 1, "Usage: remine <hostname>")
main(arg[1])

--[[
message format:
{ command, arg1, arg2, ... }
--]]
