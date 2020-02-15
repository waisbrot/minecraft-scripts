-- Send commands to remote servers

assert(#arg >= 2, "Usage: <protocol> <command> <arg1> <arg2> ...")
local protocol = arg[1]
local command = {}
for i = 2, #arg, 1 do
  command[i-1] = arg[i]
end
local modem_side = libnjw.find_modem()
rednet.open(modem_side)
local hosts = rednet.lookup(protocol)
if (hosts == nil) or (#hosts < 1) then
  print("No host found")
  os.exit()
end
rednet.send(hosts[1], command, protocol)
local response = rednet.receive(protocol, 5)
print(response)
