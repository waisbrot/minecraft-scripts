-- Send commands to remote servers

local log = libnjw.log

assert(#arg >= 2, "Usage: <protocol> <command> <arg1> <arg2> ...")
local protocol = arg[1]
local command = {}
for i = 2, #arg, 1 do
  command[i-1] = arg[i]
end
local modem_side = libnjw.find_modem()
assert(modem_side ~= nil, "No modem found")
rednet.open(modem_side)
log("Finding a host for " .. protocol)
local host = rednet.lookup(protocol)
assert(host ~= nil, "No host found for protocol " .. protocol)
log("Sending message to " .. host)
rednet.send(host, command, protocol)
log("Waiting for reply")
local _, response = rednet.receive(protocol, 5)
log(inspect.dump(response))
